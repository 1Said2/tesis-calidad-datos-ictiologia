# ================================================================
# LIMPIEZA DE COORDENADAS - Colección Ictiológica MECN-DP INABIO

# Funciones principales:
# 1. Recuperación de coordenadas desde campo verbatim (DMS, UTM truncadas, erratas de signo).
# 2. Validación espacial contra polígonos GADM y jerarquía administrativa.
# 3. Estimación de incertidumbre en función del formato original.
# ================================================================

library(readr)
library(dplyr)
library(parzer)
library(sf)

sf::sf_use_s2(TRUE)   # necesario para que st_distance devuelva metros en EPSG:4326

# ---- 0. Configuración ----
ARCHIVO_ENTRADA <- "datos/02_intermedios/ocurrences_openrefine.csv"
ARCHIVO_SALIDA  <- "datos/02_intermedios/ocurrences_salida_coordenadas.csv"

norm_nombre <- function(x) {
  x <- iconv(x, to = "ASCII//TRANSLIT")
  x <- tolower(gsub("[^A-Za-z ]", "", x))
  trimws(gsub("\\s+", " ", x))
}

# ---- Polígonos administrativos de nivel 1 (GADM 4.1) ----
# Descarga y caché local de polígonos (requiere geodata y terra).
#   install.packages(c("geodata", "terra"))
DIR_REFERENCIA <- "datos/00_referencia"
PAISES_GADM    <- c("ECU", "PER", "VEN")   # Ecuador + los dos transfronterizos
TOLERANCIA_BORDE_M <- 5000

dir.create(DIR_REFERENCIA, recursive = TRUE, showWarnings = FALSE)

cargar_gadm <- function(paises, dir_cache) {
  if (!requireNamespace("geodata", quietly = TRUE) ||
      !requireNamespace("terra",   quietly = TRUE)) {
    cat("AVISO: faltan los paquetes geodata/terra. Se usa el criterio de respaldo.\n")
    return(NULL)
  }
  piezas <- list()
  for (p in paises) {
    v <- tryCatch(geodata::gadm(country = p, level = 1, path = dir_cache),
                  error = function(e) NULL)
    if (is.null(v)) { cat("  no se pudo obtener GADM para", p, "\n"); next }
    g <- sf::st_transform(sf::st_as_sf(v), 4326)
    piezas[[p]] <- sf::st_sf(prov_norm = norm_nombre(g$NAME_1),
                             pais      = p,
                             geometry  = sf::st_geometry(g))
  }
  if (length(piezas) == 0) return(NULL)
  do.call(rbind, piezas)
}

df <- read_csv(ARCHIVO_ENTRADA, col_types = cols(.default = "c"))
cat("Filas cargadas:", nrow(df), "\n")

# ---- 1. Preservación de valores de origen (verbatim) ----
df$verbatimLatitude  <- df$decimalLatitude
df$verbatimLongitude <- df$decimalLongitude

df$decimalLatitude_num  <- suppressWarnings(as.numeric(df$decimalLatitude))
df$decimalLongitude_num <- suppressWarnings(as.numeric(df$decimalLongitude))

# ---- 2. Clasificar tipo de verbatimCoordinates ----
classify_coord <- function(x) {
  if (is.na(x) || trimws(x) == "") return("vacio")
  if (grepl("[°'\"]", x) || grepl("[NSEWnsew]", x)) return("dms")
  x_clean <- gsub("\\s", "", x)
  if (grepl("^-?[0-9]{5,7}[/,|]-?[0-9]{6,8}$", x_clean)) return("utm_o_similar")
  return("otro_no_reconocido")
}
df$coord_tipo <- sapply(df$verbatimCoordinates, classify_coord)

es_utm_con_letra <- function(x) !grepl("°", x) & grepl("[0-9](\\.[0-9]+)?\\s*[ENSWensw]", x)
df$coord_tipo[df$coord_tipo == "dms" & es_utm_con_letra(df$verbatimCoordinates)] <- "utm_o_similar"

# ---- 2b. Validación de rango en minutos y segundos ----
# Detección de valores aritméticamente parseables pero fuera de rango (>=60).
dms_rango_invalido <- function(x) {
  if (is.na(x) || trimws(x) == "") return(FALSE)
  if (!grepl("[°'\"´]", x)) return(FALSE)
  s <- gsub("´´", '"', x); s <- gsub("''", '"', s); s <- gsub("´", "'", s)
  vals <- regmatches(s, gregexpr("[0-9]+([.,][0-9]+)?\\s*['\"]", s))[[1]]
  if (length(vals) == 0) return(FALSE)
  num <- suppressWarnings(as.numeric(gsub("[^0-9.]", "", gsub(",", ".", vals))))
  any(!is.na(num) & num >= 60)
}
df$dms_rango_invalido <- vapply(df$verbatimCoordinates, dms_rango_invalido, logical(1))
cat("Filas con minutos o segundos >= 60 en el origen:", sum(df$dms_rango_invalido), "\n")

# ---- 3. Bounding box: Ecuador continental + Galápagos ----
in_bbox <- function(lat, lon) {
  continental <- !is.na(lat) & !is.na(lon) & lat >= -5.5 & lat <= 1.5 & lon >= -81.5 & lon <= -75
  galapagos   <- !is.na(lat) & !is.na(lon) & lat >= -1.5 & lat <=  1.9 & lon >= -92.5 & lon <= -89
  continental | galapagos
}

# ---- 4. Validación de rangos UTM ----
utm_easting_valido <- function(e) !is.na(e) && e >= 160000 && e <= 840000
utm_northing_valido <- function(n, epsg) {
  if (is.na(n)) return(FALSE)
  if (epsg %in% c(32717, 32718)) return(n >= 9380000 && n <= 10000000)
  if (epsg %in% c(32617, 32618)) return(n >= 0       && n <=   200000)
  FALSE
}

# ================================================================
# CAMBIO A (1/2): los polígonos se cargan ANTES del corrector de signo,
# porque ahora el corrector los necesita para desempatar. En la v3 se
# cargaban al final y por eso la decisión de signo era ciega.
# ================================================================
prov_norm_df <- norm_nombre(df$stateProvince)
gadm <- cargar_gadm(PAISES_GADM, DIR_REFERENCIA)

if (!is.null(gadm)) {
  # Alias: stateProvince que no son nivel 1 en su pais.
  # "Maynas" es provincia peruana dentro del departamento de Loreto.
  alias_provincia <- c("maynas" = "loreto")
  prov_norm_df <- ifelse(prov_norm_df %in% names(alias_provincia),
                         alias_provincia[prov_norm_df], prov_norm_df)
}
prov_norm_df[is.na(prov_norm_df)] <- ""

# Union por provincia, calculada una sola vez y reutilizada tanto por el
# desempate de signo como por la evaluación de coherencia del bloque 14.
poly_cache <- list()
if (!is.null(gadm)) {
  for (p in unique(prov_norm_df[prov_norm_df != ""])) {
    sel <- gadm[gadm$prov_norm == p, ]
    if (nrow(sel) > 0) poly_cache[[p]] <- sf::st_union(sf::st_geometry(sel))
  }
  sin_match <- setdiff(unique(prov_norm_df[prov_norm_df != ""]), names(poly_cache))
  if (length(sin_match) > 0) {
    cat("\nPROVINCIAS SIN POLIGONO (quedaran como no_evaluable):\n")
    print(sin_match)
    cat("Si alguna es un error de nombre y no un caso real, agregala a alias_provincia.\n\n")
  }
  cat("Poligonos cargados:", nrow(gadm), "| provincias con union:", length(poly_cache), "\n")
}

# Devuelve TRUE/FALSE si hay polígono para la provincia declarada, NA si no
# se puede evaluar. NA nunca se interpreta como aprobación.
en_provincia <- function(lat, lon, prov_norm) {
  if (is.na(lat) || is.na(lon)) return(NA)
  if (is.na(prov_norm) || prov_norm == "") return(NA)
  if (!prov_norm %in% names(poly_cache)) return(NA)
  pt <- sf::st_sfc(sf::st_point(c(lon, lat)), crs = 4326)
  as.numeric(sf::st_distance(pt, poly_cache[[prov_norm]])) <= TOLERANCIA_BORDE_M
}

# ---- 5. Corrector de swap/signo ----
# Generación de permutaciones (inversión de lat/lon y signos). 
# Desempate mediante contención en el polígono provincial.
fix_coord <- function(lat, lon, prov_norm = "") {
  if (is.na(lat) || is.na(lon)) return(c(lat = NA, lon = NA, metodo = "vacio"))
  if (in_bbox(lat, lon)) return(c(lat = lat, lon = lon, metodo = "original"))
  
  candidatos <- list(
    swap           = c(lon,  lat),  neg_lon        = c(lat, -lon),
    neg_lat        = c(-lat,  lon), neg_ambos      = c(-lat, -lon),
    swap_neg_lon   = c(lon, -lat),  swap_neg_lat   = c(-lon, lat),
    swap_neg_ambos = c(-lon, -lat)
  )
  validos <- candidatos[vapply(candidatos, function(c) in_bbox(c[1], c[2]), logical(1))]
  if (length(validos) == 0) return(c(lat = NA, lon = NA, metodo = "irreparable"))
  
  if (length(validos) == 1) {
    n <- names(validos)[1]; cand <- validos[[1]]
    return(c(lat = cand[1], lon = cand[2], metodo = n))
  }
  
  dentro <- vapply(validos, function(c) isTRUE(en_provincia(c[1], c[2], prov_norm)), logical(1))
  if (sum(dentro) == 1) {
    n <- names(validos)[dentro]; cand <- validos[[which(dentro)]]
    return(c(lat = cand[1], lon = cand[2], metodo = n))
  }
  
  n <- names(validos)[1]; cand <- validos[[1]]
  c(lat = cand[1], lon = cand[2], metodo = paste0(n, "_ambiguo"))
}

# ---- 6. Guardián transfronterizo ----
regiones_transfronterizas <- c("Apure", "Maynas", "Loreto")
es_transfronterizo <- df$stateProvince %in% regiones_transfronterizas |
  (!is.na(df$country) & !df$country %in% c("Ecuador", ""))
cat("Registros transfronterizos identificados:", sum(es_transfronterizo), "\n")

# ---- 7. Filas con decimalLatitude/Longitude ya pobladas ----
df$lat_final <- NA_real_; df$lon_final <- NA_real_; df$metodo_correccion <- NA_character_

for (i in seq_len(nrow(df))) {
  la <- df$decimalLatitude_num[i]; lo <- df$decimalLongitude_num[i]
  if (is.na(la) || is.na(lo)) { df$metodo_correccion[i] <- "vacio"; next }
  if (es_transfronterizo[i] && abs(la) <= 90 && abs(lo) <= 180) {
    df$lat_final[i] <- la; df$lon_final[i] <- lo
    df$metodo_correccion[i] <- "original_transfronterizo"; next
  }
  r <- fix_coord(la, lo, prov_norm_df[i])
  df$lat_final[i] <- as.numeric(r["lat"]); df$lon_final[i] <- as.numeric(r["lon"])
  df$metodo_correccion[i] <- r["metodo"]
}

# ---- 8. Parsers para reconstruir desde verbatimCoordinates ----
normalize_dms <- function(x) {
  x <- gsub("´´", '"', x); x <- gsub("''", '"', x); x <- gsub("´", "'", x)
  x <- gsub("(\\d),(\\d)", "\\1.\\2", x)
  x <- trimws(x); x <- gsub("O\\s*$", "W", x)
  x <- gsub("\\s*/\\s*", " ", x); x <- gsub("°\\s+", "°", x)
  x
}

# Detección de hemisferio en coordenadas UTM: el valor del northing (>9M = Sur)
# tiene prioridad sobre la letra 'N', que puede representar el eje y no el norte.
detectar_hemisferio <- function(raw) {
  raw_c  <- gsub("\\s", "", raw)
  partes <- strsplit(raw_c, "[/,|]")[[1]]
  if (length(partes) == 2) {
    n <- suppressWarnings(abs(as.numeric(gsub("[^0-9.]", "", partes[2]))))
    if (!is.na(n) && n >= 9e6) return("S")
  }
  if (grepl("[0-9][^0-9A-Za-z]*[Ss](\\s|$)", raw)) return("S")
  if (grepl("[0-9][^0-9A-Za-z]*[Nn](\\s|$)", raw)) return("N")
  NA_character_
}

convertir_utm2 <- function(raw) {
  if (is.na(raw)) return(c(lat = NA, lon = NA, zona = NA))
  hemisferio <- detectar_hemisferio(raw)
  raw_clean <- gsub("[ENSWensw]", "", gsub("\\s", "", raw))
  partes <- strsplit(raw_clean, "[/,|]")[[1]]
  if (length(partes) != 2) return(c(lat = NA, lon = NA, zona = NA))
  easting  <- suppressWarnings(as.numeric(partes[1]))
  northing <- suppressWarnings(abs(as.numeric(partes[2])))
  if (!utm_easting_valido(easting)) return(c(lat = NA, lon = NA, zona = NA))
  
  zonas <- if (identical(hemisferio, "S")) c(32717, 32718)
  else if (identical(hemisferio, "N")) c(32617, 32618)
  else c(32717, 32718, 32617, 32618)
  escalas <- if (is.na(hemisferio)) 1 else c(1, 10, 100)
  
  for (mult in escalas) for (epsg in zonas) {
    n2 <- northing * mult
    if (!utm_northing_valido(n2, epsg)) next
    pt <- sf::st_sfc(sf::st_point(c(easting, n2)), crs = epsg)
    co <- sf::st_coordinates(sf::st_transform(pt, crs = 4326))
    if (in_bbox(co[2], co[1]))
      return(c(lat = co[2], lon = co[1],
               zona = if (mult == 1) epsg else paste0(epsg, "_northing_x", mult)))
  }
  c(lat = NA, lon = NA, zona = NA)
}

resolve_dms <- function(raw, es_transf, prov_norm = "") {
  raw_norm <- normalize_dms(raw)
  partes <- regmatches(raw_norm, regexec("^(.*[NnSs])\\s+(.*[EeWwOo])$", raw_norm))[[1]]
  lat <- NA; lon <- NA
  if (length(partes) == 3) {
    lat <- tryCatch(suppressWarnings(parzer::parse_lat(partes[2])), error = function(e) NA)
    lon <- tryCatch(suppressWarnings(parzer::parse_lon(partes[3])), error = function(e) NA)
  }
  if (is.na(lat) || is.na(lon)) {
    p <- parzer::parse_llstr(raw_norm); lat <- p$lat[1]; lon <- p$lon[1]
  }
  if (!is.na(lat) && !is.na(lon)) {
    if (es_transf) return(c(lat = lat, lon = lon, metodo = "verbatim_transfronterizo"))
    if (in_bbox(lat, lon)) return(c(lat = lat, lon = lon, metodo = "dms_directo"))
    fx <- fix_coord(lat, lon, prov_norm)
    if (!is.na(fx["lat"])) return(c(lat = as.numeric(fx["lat"]), lon = as.numeric(fx["lon"]),
                                    metodo = paste0("dms_", fx["metodo"])))
  }

  c(lat = NA, lon = NA, metodo = NA)
}

vacio_idx <- which(is.na(df$lat_final))
for (i in vacio_idx) {
  tipo <- df$coord_tipo[i]; raw <- df$verbatimCoordinates[i]
  if (is.na(raw) || trimws(raw) == "") next
  if (tipo == "dms") {
    r <- resolve_dms(raw, es_transfronterizo[i], prov_norm_df[i])
    if (!is.na(r["lat"])) {
      df$lat_final[i] <- as.numeric(r["lat"]); df$lon_final[i] <- as.numeric(r["lon"])
      df$metodo_correccion[i] <- r["metodo"]
    }
  } else if (tipo == "utm_o_similar") {
    r <- convertir_utm2(raw)
    if (!is.na(r["lat"])) {
      df$lat_final[i] <- as.numeric(r["lat"]); df$lon_final[i] <- as.numeric(r["lon"])
      df$metodo_correccion[i] <- paste0("utm_zona_", r["zona"])
    }
  } else if (tipo == "otro_no_reconocido" && grepl("^-?[0-9]{1,2}\\.[0-9]+/[0-9]{1,3}\\.[0-9]+$", raw)) {
    partes <- strsplit(raw, "/")[[1]]
    fx <- fix_coord(as.numeric(partes[1]), as.numeric(partes[2]), prov_norm_df[i])
    if (!is.na(fx["lat"])) {
      df$lat_final[i] <- as.numeric(fx["lat"]); df$lon_final[i] <- as.numeric(fx["lon"])
      df$metodo_correccion[i] <- paste0("decimal_sin_signo_", fx["metodo"])
    }
  }
}

# ---- 8b. Coordenadas sin letra de hemisferio (inferencia de signo) ----
intentar_sin_hemisferio <- function(raw, prov_norm = "") {
  x <- raw
  x <- gsub("´´", '"', x); x <- gsub("''", '"', x); x <- gsub("´", "'", x)
  x <- gsub(",", ".", x); x <- gsub("[°'\"]", " ", x)
  x <- gsub("[NSEWOnsewo]", " ", x); x <- gsub("/", " ", x)
  x <- trimws(gsub("\\s+", " ", x))
  partes <- suppressWarnings(as.numeric(strsplit(x, " ")[[1]]))
  partes <- partes[!is.na(partes)]
  if (length(partes) == 2) return(fix_coord(partes[1], partes[2], prov_norm))
  if (length(partes) == 6) {
    lat <- partes[1] + partes[2]/60 + partes[3]/3600
    lon <- partes[4] + partes[5]/60 + partes[6]/3600
    return(fix_coord(lat, lon, prov_norm))
  }
  c(lat = NA, lon = NA, metodo = NA)
}

pendientes_idx <- which(is.na(df$lat_final) & !is.na(df$verbatimCoordinates) &
                          trimws(df$verbatimCoordinates) != "")
for (i in pendientes_idx) {
  r <- intentar_sin_hemisferio(df$verbatimCoordinates[i], prov_norm_df[i])
  if (!is.na(r["lat"])) {
    df$lat_final[i] <- as.numeric(r["lat"]); df$lon_final[i] <- as.numeric(r["lon"])
    df$metodo_correccion[i] <- paste0("sin_hemisferio_", r["metodo"])
  }
}

# ---- 8c. Reasignación a zona 18S ----
# Corrección de coordenadas UTM de Sucumbíos/Orellana erróneamente asignadas a la zona 17S.
convertir_zona18 <- function(raw) {
  raw_clean <- gsub("\\s", "", raw)
  partes <- strsplit(raw_clean, "/")[[1]]
  easting <- as.numeric(partes[1]); northing <- abs(as.numeric(partes[2]))
  if (!utm_easting_valido(easting)) return(c(lat = NA, lon = NA))
  pt <- sf::st_sfc(sf::st_point(c(easting, northing)), crs = 32718)
  coords <- sf::st_coordinates(sf::st_transform(pt, crs = 4326))
  c(lat = coords[2], lon = coords[1])
}
idx_zona <- which(df$metodo_correccion == "utm_zona_32717" &
                    df$stateProvince %in% c("Sucumbíos", "Orellana"))
for (i in idx_zona) {
  r <- convertir_zona18(df$verbatimCoordinates[i])
  if (!is.na(r["lat"])) {
    df$lat_final[i] <- as.numeric(r["lat"]); df$lon_final[i] <- as.numeric(r["lon"])
    df$metodo_correccion[i] <- "utm_zona_32718_corregido_de_32717"
  }
}

# ---- 9. Centroides de referencia provinciales ----
dist_km <- function(lat1, lon1, lat2, lon2) {
  sqrt(((lat1 - lat2) * 111.32)^2 + ((lon1 - lon2) * 111.32 * cos(lat1 * pi / 180))^2)
}
centroides <- df %>%
  filter(metodo_correccion %in% c("original", "dms_directo"), !is.na(lat_final)) %>%
  group_by(stateProvince) %>%
  summarise(n_ref = n(), lat_c = median(lat_final), lon_c = median(lon_final), .groups = "drop") %>%
  filter(n_ref >= 5, stateProvince != "", !is.na(stateProvince))

coherente_con_centroide <- function(lat, lon, prov, umbral_km = 150) {
  if (is.na(lat) || is.na(prov) || !(prov %in% centroides$stateProvince)) return(NA)
  cc <- centroides[centroides$stateProvince == prov, ]
  dist_km(lat, lon, cc$lat_c, cc$lon_c) <= umbral_km
}

df$dist_centroide_km <- mapply(function(la, lo, p) {
  if (is.na(la) || is.na(p) || !(p %in% centroides$stateProvince)) return(NA_real_)
  cc <- centroides[centroides$stateProvince == p, ]
  round(dist_km(la, lo, cc$lat_c, cc$lon_c), 1)
}, df$lat_final, df$lon_final, df$stateProvince)

# ---- 10. Recuperación de coordenadas irreparables (validación doble) ----
# Intenta recuperar northings UTM truncados (6 dígitos) y decimales corruptos.
recuperar_northing_truncado <- function(raw, prov) {
  raw_clean <- gsub("[ENSWensw]", "", gsub("[[:space:]]", "", raw))
  partes <- strsplit(raw_clean, "[/,|]")[[1]]
  if (length(partes) != 2) return(NULL)
  e <- suppressWarnings(as.numeric(partes[1]))
  n <- suppressWarnings(abs(as.numeric(partes[2])))
  if (!utm_easting_valido(e) || is.na(n)) return(NULL)
  if (nchar(as.character(trunc(n))) != 6) return(NULL)
  n10 <- n * 10
  for (epsg in c(32717, 32718)) {
    if (!utm_northing_valido(n10, epsg)) next
    pt <- sf::st_sfc(sf::st_point(c(e, n10)), crs = epsg)
    co <- sf::st_coordinates(sf::st_transform(pt, crs = 4326))
    if (in_bbox(co[2], co[1]) && isTRUE(coherente_con_centroide(co[2], co[1], prov)))
      return(list(lat = co[2], lon = co[1], metodo = paste0("utm_northing_truncado_", epsg)))
  }
  NULL
}

recuperar_decimal_corrupto <- function(raw, prov) {
  m <- regmatches(raw, regexec("^(-?[0-9]+\\.[0-9]+)\\s+(-?[0-9,]+)$", raw))[[1]]
  if (length(m) != 3) return(NULL)
  lat <- suppressWarnings(as.numeric(m[2]))
  lon <- suppressWarnings(as.numeric(gsub(",", "", m[3])))
  if (is.na(lat) || is.na(lon)) return(NULL)
  intentos <- 0
  while (abs(lon) > 180 && intentos < 8) { lon <- lon / 10; intentos <- intentos + 1 }
  lon <- -abs(lon)
# La validacion doble confundia dos cosas distintas: si la reconstruccion es
# aritmeticamente correcta y si la provincia declarada es correcta. Cuando
# discrepan, la fila se descartaba y se publicaba como "ilegible", que es falso.
# El criterio correcto es el mismo que el script aplica a las otras 231
# discordantes: reconstruir, publicar y dejar que el bloque 14 la marque.
  if (in_bbox(lat, lon))
    return(list(lat = lat, lon = lon,
                metodo = if (isTRUE(coherente_con_centroide(lat, lon, prov)))
                           "decimal_separador_corrupto"
                         else
                           "decimal_separador_corrupto_prov_discordante"))
  NULL
}

df$metodo_correccion[df$metodo_correccion == "vacio" & is.na(df$lat_final)] <- "irreparable"
irr_idx <- which(df$metodo_correccion == "irreparable" &
                   !is.na(df$verbatimCoordinates) & trimws(df$verbatimCoordinates) != "")
n_rec <- 0
for (i in irr_idx) {
  r <- recuperar_northing_truncado(df$verbatimCoordinates[i], df$stateProvince[i])
  if (is.null(r)) r <- recuperar_decimal_corrupto(df$verbatimCoordinates[i], df$stateProvince[i])
  if (!is.null(r)) {
    df$lat_final[i] <- r$lat; df$lon_final[i] <- r$lon
    df$metodo_correccion[i] <- r$metodo; n_rec <- n_rec + 1
  }
}
cat("Filas recuperadas del bloque irreparable:", n_rec, "\n")

# Clasificación de la causa de ausencia de coordenada (sin origen vs. fuera de rango).
sin_verbatim <- is.na(df$verbatimCoordinates) | trimws(df$verbatimCoordinates) == ""
sin_decimal  <- is.na(df$decimalLatitude_num)
df$metodo_correccion[df$metodo_correccion == "irreparable" & sin_verbatim & sin_decimal] <-
  "sin_dato_origen"
df$metodo_correccion[df$metodo_correccion == "irreparable" & sin_verbatim & !sin_decimal] <-
  "descartada_fuera_de_rango"

# Bandera para elección de signo no resuelta por el polígono.
df$signo_ambiguo <- !is.na(df$metodo_correccion) & grepl("_ambiguo$", df$metodo_correccion)
cat("Filas con signo ambiguo no resuelto por poligono:", sum(df$signo_ambiguo), "\n")

# ---- 11. Asignación de nivel de confianza de la coordenada ----
df$confianza_coordenada <- dplyr::case_when(
  is.na(df$lat_final) ~ "sin_coordenada",
  df$metodo_correccion %in% c("original", "original_transfronterizo",
                              "dms_directo", "verbatim_transfronterizo") ~ "leida",
  grepl("^utm_zona_", df$metodo_correccion) ~ "convertida",
  grepl("^utm_northing_truncado|^decimal_separador_corrupto", df$metodo_correccion) ~ "reconstruida",
  TRUE ~ "inferida"
)

# ---- 12. Precisión original (verbatimCoordinates) ----
# Se determina con base en el número de decimales declarados en el origen, no por descarte.
precision_verbatim <- function(raw, dec_lat_txt, tipo) {
  if (!is.na(raw) && trimws(raw) != "") {
    m <- regmatches(raw, regexec("^\\s*-?([0-9]{1,3})[.,]([0-9]+)\\s*°?(\\s|$)",
                                 paste0(raw, " ")))[[1]]
    if (length(m) >= 3 && !grepl("[´'\"]", raw) && as.numeric(m[2]) <= 180) {
      return(paste0("decimal_", min(nchar(m[3]), 8), "d"))
    }
    s <- gsub("''", '"', gsub("´´", '"', raw))
    if (grepl('"', s)) {
      if (grepl('[0-9]+[.,][0-9]+\\s*"', s)) return("dms_segundo_decimal")
      return("dms_segundo_entero")
    }
    if (grepl("°", s)) {
      if (grepl("[0-9]+[.,][0-9]+\\s*[´']", s)) return("dms_minuto_decimal")
      return("dms_minuto")
    }
    # Precisión de par decimal con separador no estándar (ej. 2.12/79.11).
    md <- regmatches(raw, regexec("^\\s*-?[0-9]{1,3}[.,]([0-9]+)\\s*[/, ]", raw))[[1]]
    if (length(md) >= 2) return(paste0("decimal_", min(nchar(md[2]), 8), "d"))
    if (!is.na(tipo) && tipo == "utm_o_similar") return("utm_metro")
    # Heredar precisión del campo decimalLatitude original si el verbatim no la determina.
    if (!is.na(dec_lat_txt) && trimws(dec_lat_txt) != "" && grepl("\\.", dec_lat_txt)) {
      return(paste0("decimal_", min(nchar(sub("^.*\\.", "", dec_lat_txt)), 8), "d"))
    }
    return(NA_character_)
  }
  if (!is.na(dec_lat_txt) && trimws(dec_lat_txt) != "" && grepl("\\.", dec_lat_txt)) {
    return(paste0("decimal_", min(nchar(sub("^.*\\.", "", dec_lat_txt)), 8), "d"))
  }
  NA_character_
}
df$precision_origen <- mapply(precision_verbatim,
                              df$verbatimCoordinates, df$verbatimLatitude, df$coord_tipo)

# ---- 12b. Reclasificación de precisión para formatos híbridos/DMS sin comillas ----
reclasificar_precision <- function(raw, actual) {
  if (is.na(raw) || !grepl("\u00b0", raw)) return(actual)
  if (!actual %in% c("dms_minuto", "dms_segundo_entero")) return(actual)
  n <- regmatches(raw, gregexpr("[0-9]+(?:[.,][0-9]+)?", raw))[[1]]
  n <- gsub(",", ".", n)
  dec <- function(x) {
    p <- regmatches(x, regexpr("\\.[0-9]+$", x))
    if (length(p) == 0) 0L else nchar(p) - 1L
  }
  nd <- vapply(n, dec, integer(1))
  # decimal disfrazado de DMS: dos (o cuatro) campos y al menos uno con >= 4 decimales
  if (length(n) %in% c(2L, 4L) && any(nd >= 4L)) return("decimal_6d")
  if (length(n) >= 6L) {
    return(if (any(nd[c(3L, 6L)] > 0L)) "dms_segundo_decimal" else "dms_segundo_entero")
  }
  if (length(n) == 4L && any(nd > 0L)) return("dms_minuto_decimal")
  actual
}
prev <- df$precision_origen
df$precision_origen <- mapply(reclasificar_precision,
                              df$verbatimCoordinates, prev, USE.NAMES = FALSE)
cat("  filas reclasificadas por el parche 12b:",
    sum(prev != df$precision_origen, na.rm = TRUE), "\n")

# ---- 12c. Limpieza: sin coordenada no hay precisión original ----
df$precision_origen[is.na(df$lat_final)] <- NA_character_

# ---- 13. coordinateUncertaintyInMeters estimada ----
df$coordinateUncertaintyInMeters <- dplyr::case_when(
  is.na(df$lat_final) ~ NA_character_,
  df$precision_origen == "utm_metro"                                 ~ "100",
  df$precision_origen %in% c("dms_segundo_decimal",
                             "dms_segundo_entero")                   ~ "30",
  df$precision_origen == "dms_minuto_decimal"                        ~ "100",
  df$precision_origen == "dms_minuto"                                ~ "1900",
  df$precision_origen %in% c("decimal_6d","decimal_7d","decimal_8d") ~ "10",
  df$precision_origen == "decimal_5d"                                ~ "30",
  df$precision_origen == "decimal_4d"                                ~ "100",
  df$precision_origen == "decimal_3d"                                ~ "200",
  df$precision_origen %in% c("decimal_2d","decimal_1d","decimal_0d") ~ "2000",
  TRUE ~ NA_character_
)
# ---- 13b. Piso tecnológico de incertidumbre ----
# Se aplica un piso de incertidumbre (100 m pre-2000, 30 m post-2000) considerando 
# las limitaciones tecnológicas de la época de colecta (GPS availability).
anio_evento <- suppressWarnings(as.integer(substr(df$eventDate, 1, 4)))
piso_m <- ifelse(is.na(anio_evento) | anio_evento < 2000, 100, 30)

unc_num  <- suppressWarnings(as.numeric(df$coordinateUncertaintyInMeters))
unc_piso <- pmax(unc_num, piso_m)
df$piso_incertidumbre_aplicado <- !is.na(unc_num) & unc_piso > unc_num
df$coordinateUncertaintyInMeters <- ifelse(is.na(unc_piso), NA_character_,
                                           as.character(as.integer(unc_piso)))

df$incertidumbre_criterio <- ifelse(
  is.na(df$coordinateUncertaintyInMeters), NA_character_,
  paste0("estimada_desde_precision_origen:", df$precision_origen,
         ifelse(df$piso_incertidumbre_aplicado,
                paste0(";piso_tecnologico_", piso_m, "m"), "")))

cat("  incertidumbre elevada al piso tecnologico:",
    sum(df$piso_incertidumbre_aplicado, na.rm = TRUE), "\n")

# ================================================================
# 14. Coherencia con la provincia por contención en polígono
# ================================================================
df$coherencia_provincia    <- NA_character_
df$criterio_coherencia     <- NA_character_
df$dist_fuera_provincia_m  <- NA_real_
df$dist_fuera_provincia_km <- NA_real_

tiene_coord <- !is.na(df$lat_final)

if (!is.null(gadm)) {
  df$criterio_coherencia[tiene_coord] <- "poligono_gadm"
  pts <- sf::st_as_sf(
    data.frame(idx = which(tiene_coord),
               lon = df$lon_final[tiene_coord],
               lat = df$lat_final[tiene_coord]),
    coords = c("lon", "lat"), crs = 4326)
  pts$prov_norm <- prov_norm_df[tiene_coord]
  
  for (p in unique(pts$prov_norm)) {
    sel <- which(pts$prov_norm == p)
    if (p == "") {
      df$coherencia_provincia[pts$idx[sel]] <- "no_evaluable"
      df$criterio_coherencia[pts$idx[sel]]  <- "sin_provincia_declarada"
      next
    }
    if (!p %in% names(poly_cache)) {
      df$coherencia_provincia[pts$idx[sel]] <- "no_evaluable"
      df$criterio_coherencia[pts$idx[sel]]  <- "sin_poligono_de_referencia"
      next
    }
    d_m <- as.numeric(sf::st_distance(pts[sel, ], poly_cache[[p]]))
    df$dist_fuera_provincia_m[pts$idx[sel]]  <- round(d_m, 1)
    df$dist_fuera_provincia_km[pts$idx[sel]] <- round(d_m / 1000, 2)
    df$coherencia_provincia[pts$idx[sel]] <-
      ifelse(d_m <= TOLERANCIA_BORDE_M, "coherente", "discordante")
  }
  
  # Tolerancia ampliada para registros marinos identificables (fuera de polígonos terrestres GADM).
  TOLERANCIA_MARINA_M <- 50000
  contexto_marino <- (df$stateProvince == "Galápagos" & !is.na(df$stateProvince)) |
    grepl("c[eé]ano|Pac[ií]fico", df$locationRemarks, ignore.case = TRUE)
  
  reclasificar <- !is.na(df$coherencia_provincia) &
    df$coherencia_provincia == "discordante" &
    contexto_marino &
    !is.na(df$dist_fuera_provincia_km) &
    df$dist_fuera_provincia_km * 1000 <= TOLERANCIA_MARINA_M
  
  df$coherencia_provincia[reclasificar] <- "fuera_de_tierra_firme"
  cat("  reclasificadas como fuera_de_tierra_firme:", sum(reclasificar), "\n")
} else {
  stop("Error: No se pudieron cargar los poligonos de GADM. Ejecucion abortada para proteger la integridad metodologica (evita el uso del respaldo estadistico no validado).")
}

# ---- 14b. Clasificación de discordancias mecánicas vs sin explicación ----
# Verifica si invertir signos o transponer ejes devuelve el punto al polígono provincial.
df$discordancia_explicada <- NA_character_
for (i in which(df$coherencia_provincia == "discordante")) {
  p  <- prov_norm_df[i]
  la <- df$lat_final[i]; lo <- df$lon_final[i]
  df$discordancia_explicada[i] <-
    if (isTRUE(en_provincia(-la,  lo, p)))                       "signo_latitud"
    else if (isTRUE(en_provincia( la, -lo, p)))                  "signo_longitud"
    else if (abs(lo) <= 90 && isTRUE(en_provincia(lo, la, p)))   "swap_lat_lon"
    else                                                         "sin_explicacion_mecanica"
}
cat("\n=== REPARTO DE LAS DISCORDANCIAS ===\n")
print(table(df$discordancia_explicada, useNA = "no"))
print(table(df$stateProvince, df$discordancia_explicada))

# ---- 14c. Hipótesis de errata de un dígito en northings UTM discordantes ----
df$hipotesis_northing <- NA_character_
idx <- which(df$coherencia_provincia == "discordante" &
               df$discordancia_explicada == "sin_explicacion_mecanica" &
               grepl("^utm_zona_", df$metodo_correccion))
for (i in idx) {
  nums <- as.numeric(regmatches(df$verbatimCoordinates[i],
            gregexpr("[0-9]+\\.?[0-9]*", df$verbatimCoordinates[i]))[[1]])
  if (length(nums) < 2) next
  e <- min(nums[(length(nums)-1):length(nums)]); n <- max(nums[(length(nums)-1):length(nums)])
  epsg <- as.integer(sub("^utm_zona_", "", df$metodo_correccion[i]))
  s <- strsplit(as.character(n), "")[[1]]
  for (pos in seq_along(s)) for (d in as.character(0:9)) {
    if (s[pos] == d) next
    s2 <- s; s2[pos] <- d; nuevo_northing <- as.numeric(paste(s2, collapse = ""))
    if (nuevo_northing < 9000000 || nuevo_northing > 10000000) next
    p <- sf::st_transform(sf::st_sfc(sf::st_point(c(e, nuevo_northing)), crs = epsg), 4326)
    cc <- sf::st_coordinates(p)
    if (isTRUE(en_provincia(cc[2], cc[1], prov_norm_df[i]))) {
      df$hipotesis_northing[i] <- sprintf("northing %s -> %s (digito %d) cae en la provincia declarada",
                                          n, nuevo_northing, as.integer(d))
      break
    }
  }
}
# ---- 14d. Contradicción de signo entre filas con el mismo verbatim ----
# Detecta tuplas idénticas en origen que resuelven en hemisferios distintos.
tupla_verbatim <- function(x) {
  if (is.na(x) || trimws(x) == "") return(NA_character_)
  n <- regmatches(x, gregexpr("[0-9]+(?:[.,][0-9]+)?", x))[[1]]
  if (length(n) < 4) return(NA_character_)
  paste(sprintf("%.6f", as.numeric(gsub(",", ".", n))), collapse = "|")
}
df$tupla_verbatim <- vapply(df$verbatimCoordinates, tupla_verbatim,
                            character(1), USE.NAMES = FALSE)
df$flag_signo_contradice_hermanas <- FALSE
for (tt in unique(df$tupla_verbatim[!is.na(df$tupla_verbatim)])) {
  idx <- which(df$tupla_verbatim == tt & !is.na(df$lat_final))
  if (length(idx) < 2) next
  if (length(unique(round(df$lat_final[idx], 6))) > 1 ||
      length(unique(round(df$lon_final[idx], 6))) > 1) {
    df$flag_signo_contradice_hermanas[idx] <- TRUE
  }
}
cat("  filas con la misma tupla verbatim y resultado divergente:",
    sum(df$flag_signo_contradice_hermanas), "\n")

# ---- 14e. Tolerancia de borde explicitada ----
# Bandera para métricas: puntos fuera del polígono provincial pero aceptados por tolerancia.
# La bandera se calcula sobre la distancia sin redondear. El redondeo a dos
# decimales de km tiene un suelo de 10 m: un punto a 3 m fuera del poligono se
# guardaba como 0.00 y quedaba fuera del conteo.
df$dentro_tolerancia_borde <- !is.na(df$lat_final) &
  df$coherencia_provincia == "coherente" &
  !is.na(df$dist_fuera_provincia_m) & df$dist_fuera_provincia_m > 0
cat("  coherentes por tolerancia de borde (fuera del poligono, <=5 km):",
    sum(df$dentro_tolerancia_borde, na.rm = TRUE), "\n")

# ---- 14f. PARCHE: coordenada minoritaria dentro de la propia localidad.
# El bloque 14 mide contencion en la PROVINCIA y el bloque de coordenada
# compartida compara PROVINCIAS entre si. Ninguno de los dos ve el caso en que
# varias filas declaran la misma localidad y una cae a decenas de kilometros de
# las demas dentro de la misma provincia: el poligono las acepta a todas. Es el
# criterio del parche 14d subido un nivel: alli las hermanas se definian por
# tupla verbatim identica, aqui por localidad declarada identica. Se exige que
# la mayoria sea mayoria de verdad (>=80 % del grupo en un mismo punto) para no
# marcar transectos ni localidades genericas dispersas. NO corrige: mide y marca.
# Insertar despues del bloque 14e.
df$flag_coord_minoritaria_en_localidad <- FALSE
df$dist_a_mayoria_localidad_km         <- NA_real_

idx_loc <- which(!is.na(df$lat_final) &
                   !is.na(df$locality) & trimws(df$locality) != "")
grupos <- split(idx_loc,
                paste(df$stateProvince[idx_loc], df$locality[idx_loc], sep = "||"))

for (g in grupos) {
  if (length(g) < 5) next
  k  <- paste(round(df$lat_final[g], 4), round(df$lon_final[g], 4))
  tb <- sort(table(k), decreasing = TRUE)
  if (length(tb) < 2)            next          # un solo punto: nada que comparar
  if (tb[1] / length(g) < 0.80)  next          # sin mayoria clara no se decide
  may <- as.numeric(strsplit(names(tb)[1], " ")[[1]])
  d   <- dist_km(df$lat_final[g], df$lon_final[g], may[1], may[2])
  df$dist_a_mayoria_localidad_km[g]         <- round(d, 1)
  df$flag_coord_minoritaria_en_localidad[g] <- d > 10
}
cat("  coordenada minoritaria dentro de la propia localidad:",
    sum(df$flag_coord_minoritaria_en_localidad, na.rm = TRUE), "\n")


# ================================================================
# Coordenada compartida vs provincia minoritaria
# ================================================================
# Se identifica si una misma coordenada aparece en múltiples provincias y se marca solo la minoría.
clave <- ifelse(is.na(df$lat_final), NA_character_,
                paste(round(df$lat_final, 5), round(df$lon_final, 5)))
df$clave_coord <- clave

resumen_clave <- df %>%
  filter(!is.na(clave_coord), !is.na(stateProvince), stateProvince != "") %>%
  count(clave_coord, stateProvince, name = "n_filas") %>%
  group_by(clave_coord) %>%
  mutate(n_prov = n_distinct(stateProvince), n_max = max(n_filas)) %>%
  ungroup()

claves_compartidas <- unique(resumen_clave$clave_coord[resumen_clave$n_prov > 1])
pares_mayoritarios <- resumen_clave %>%
  filter(n_filas == n_max) %>%
  transmute(par = paste(clave_coord, stateProvince, sep = "||")) %>%
  pull(par)

df$coordenada_compartida <- !is.na(df$clave_coord) & df$clave_coord %in% claves_compartidas
# El criterio de mayoria por conteo no decide cuando dos provincias declaran el
# mismo punto con el mismo numero de filas: n_filas == n_max en ambas y ninguna
# queda marcada. Son 7 claves y 14 filas. Se anade el desempate por contencion
# en el poligono, que es el mismo criterio que ya gobierna el bloque 14 y que en
# las 7 resuelve. En dos de ellas resuelve contra las dos provincias a la vez:
# el punto no pertenece a ninguna de las declaradas.
claves_empatadas <- resumen_clave %>%
  filter(n_filas == n_max) %>%
  count(clave_coord, name = "n_lideres") %>%
  filter(n_lideres > 1) %>%
  pull(clave_coord)

df$provincia_minoritaria <- df$coordenada_compartida & ifelse(
  df$clave_coord %in% claves_empatadas,
  !is.na(df$coherencia_provincia) & df$coherencia_provincia == "discordante",
  !(paste(df$clave_coord, df$stateProvince, sep = "||") %in% pares_mayoritarios))

# ---- 15. Anulación de precisión en coordenadas sospechosas ----
# No se estima incertidumbre para coordenadas discordantes, ambiguas o fuera de rango.
if (!is.null(gadm)) {
  sospechosa <- (!is.na(df$coherencia_provincia) & df$coherencia_provincia == "discordante") |
    df$signo_ambiguo |
    df$provincia_minoritaria |
    df$flag_signo_contradice_hermanas |
    (df$dms_rango_invalido & tiene_coord) |
    df$flag_coord_minoritaria_en_localidad
} else {
  sospechosa <- (!is.na(df$coherencia_provincia) & df$coherencia_provincia == "discordante") |
    df$provincia_minoritaria |
    df$flag_signo_contradice_hermanas |
    df$signo_ambiguo |
    (df$dms_rango_invalido & tiene_coord) |
    df$flag_coord_minoritaria_en_localidad
}
df$coordinateUncertaintyInMeters[sospechosa] <- NA_character_
df$incertidumbre_criterio[sospechosa] <- "no_estimable_coordenada_marcada_para_revision"
df$georeferenceVerificationStatus <- dplyr::case_when(
  is.na(df$lat_final) ~ NA_character_,
  sospechosa          ~ "requires verification",
  TRUE                ~ "unverified"
)

# ---- 15b. Exportación de bandera minoritaria al Darwin Core (georeferenceRemarks) ----
df$georeferenceRemarks <- ifelse(
  df$provincia_minoritaria & !is.na(df$lat_final),
  "coordenada compartida con registros de otra provincia; este registro esta en la minoria",
  df$georeferenceRemarks)
cat("  georeferenceRemarks poblado por provincia minoritaria:",
    sum(df$provincia_minoritaria & !is.na(df$lat_final), na.rm = TRUE), "\n")

# ---- 15c. Exportación de avisos de coherencia no concluyente o registros marinos ----
marca <- rep(NA_character_, nrow(df))
marca[!is.na(df$lat_final) & df$coherencia_provincia == "fuera_de_tierra_firme"] <-
  "coordenada fuera del poligono terrestre de la provincia declarada; no verificada contra tierra firme"
marca[!is.na(df$lat_final) & df$coherencia_provincia == "no_evaluable"] <-
  "coherencia con la provincia no evaluable: el registro no declara provincia"

df$georeferenceRemarks <- ifelse(
  is.na(marca), df$georeferenceRemarks,
  ifelse(is.na(df$georeferenceRemarks) | df$georeferenceRemarks == "",
         marca, paste(df$georeferenceRemarks, marca, sep = "; ")))

cat("  georeferenceRemarks poblado por coherencia no concluyente:",
    sum(!is.na(marca)), "\n")

# ---- 15d. Exportación del motivo específico de revisión (georeferenceRemarks) ----
motivo <- rep(NA_character_, nrow(df))

motivo[!is.na(df$lat_final) & df$coherencia_provincia == "discordante" &
         df$discordancia_explicada == "signo_latitud"] <-
  "punto fuera del poligono de la provincia declarada; invertir el signo de la latitud lo devuelve dentro (no aplicado: pendiente de verificacion curatorial)"

motivo[!is.na(df$lat_final) & df$coherencia_provincia == "discordante" &
         df$discordancia_explicada == "sin_explicacion_mecanica"] <-
  "punto fuera del poligono de la provincia declarada; no se explica por signo ni por transposicion de ejes"

motivo[!is.na(df$lat_final) & df$signo_ambiguo] <- ifelse(
  is.na(motivo[!is.na(df$lat_final) & df$signo_ambiguo]),
  "el origen no declara hemisferio y el poligono provincial no desempato entre las lecturas posibles",
  paste(motivo[!is.na(df$lat_final) & df$signo_ambiguo],
        "el origen no declara hemisferio y el poligono provincial no desempato", sep = "; "))

motivo[!is.na(df$lat_final) & df$dms_rango_invalido] <- ifelse(
  is.na(motivo[!is.na(df$lat_final) & df$dms_rango_invalido]),
  "el sexagesimal de origen declara minutos o segundos >= 60; el valor se parseo pero el punto esta desplazado",
  paste(motivo[!is.na(df$lat_final) & df$dms_rango_invalido],
        "sexagesimal de origen con minutos o segundos >= 60", sep = "; "))

motivo[!is.na(df$lat_final) & df$flag_signo_contradice_hermanas] <- ifelse(
  is.na(motivo[!is.na(df$lat_final) & df$flag_signo_contradice_hermanas]),
  "otro registro con el mismo verbatim numerico resuelve en un punto distinto; contradiccion no detectable por contencion en poligono",
  paste(motivo[!is.na(df$lat_final) & df$flag_signo_contradice_hermanas],
        "verbatim numerico identico a otra fila con resultado distinto", sep = "; "))

motivo[!is.na(df$lat_final) & df$flag_coord_minoritaria_en_localidad] <- ifelse(
  is.na(motivo[!is.na(df$lat_final) & df$flag_coord_minoritaria_en_localidad]),
  paste("la mayoria de los registros que declaran esta misma localidad se situa en otro",
        "punto, a mas de 10 km; la contradiccion no es detectable por contencion en el",
        "poligono provincial porque ambos puntos caen en la provincia declarada"),
  paste(motivo[!is.na(df$lat_final) & df$flag_coord_minoritaria_en_localidad],
        "coordenada minoritaria dentro de su propia localidad", sep = "; "))

df$georeferenceRemarks <- ifelse(
  is.na(motivo), df$georeferenceRemarks,
  ifelse(is.na(df$georeferenceRemarks) | df$georeferenceRemarks == "",
         motivo, paste(df$georeferenceRemarks, motivo, sep = "; ")))

cat("  georeferenceRemarks poblado por motivo de revision:", sum(!is.na(motivo)), "\n")

# ---- 15d-bis. PARCHE: anotacion de las filas sin coordenada final que SI
# traian un dato de origen. La invariante exige que toda celda modificada quede
# anotada; el catalogo 5170 traia decimalLatitude/Longitude en el portal y sale
# con el campo vacio, hoy indistinguible en Darwin Core de los 183 que nunca
# tuvieron coordenada. Las 66 irreparables tampoco declaran que existe un
# verbatim ilegible. Se anota sin publicar coordenada: no es imputacion, es
# trazabilidad.  Insertar justo despues del bloque 15d, antes de 15e.
motivo_sin <- rep(NA_character_, nrow(df))

motivo_sin[is.na(df$lat_final) &
             df$metodo_correccion == "descartada_fuera_de_rango"] <-
  paste("el portal declaraba una coordenada decimal fuera del ambito geografico de la",
        "coleccion y ninguna permutacion de signo o de eje la devuelve dentro; el valor",
        "de origen se conserva en verbatimLatitude/verbatimLongitude y no se publica")

motivo_sin[is.na(df$lat_final) &
             df$metodo_correccion == "irreparable"] <-
  paste("el registro declara verbatimCoordinates pero su formato no permite reconstruir",
        "un par valido; el texto de origen se conserva integro en verbatimCoordinates")

df$georeferenceRemarks <- ifelse(is.na(motivo_sin), df$georeferenceRemarks, motivo_sin)
cat("  georeferenceRemarks poblado en filas sin coordenada final:",
    sum(!is.na(motivo_sin)), "\n")

# ---- 15e. Documentación del origen de la incertidumbre estimada ----
nota_unc <- ifelse(
  is.na(df$coordinateUncertaintyInMeters), NA_character_,
  paste0("incertidumbre no medida en campo: estimada desde la precision ",
         "declarada en el origen (", df$precision_origen, ")",
         ifelse(!is.na(df$piso_incertidumbre_aplicado) & df$piso_incertidumbre_aplicado,
                "; elevada al piso tecnologico segun el anio del evento", "")))
df$georeferenceRemarks <- ifelse(
  is.na(nota_unc), df$georeferenceRemarks,
  ifelse(is.na(df$georeferenceRemarks) | df$georeferenceRemarks == "",
         nota_unc, paste(df$georeferenceRemarks, nota_unc, sep = "; ")))
cat("  georeferenceRemarks poblado por incertidumbre estimada:",
    sum(!is.na(nota_unc)), "\n")

# ---- 15e-bis. Anotacion del redondeo a 6 decimales.
# La condicion no puede ser "el origen declaraba mas de 6 decimales": un valor
# como -0.8712700 declara siete y redondea a si mismo. Hay que comparar el
# VALOR, no la longitud de la cadena. Con la condicion por longitud se anotaban
# 551 filas de las que 203 no habian cambiado.
# Se exige (a) que exista diferencia real y (b) que esa diferencia desaparezca
# al redondear ambos a 6 decimales, para no capturar las filas que cambiaron
# por correccion de signo o de eje, que ya tienen su propio motivo.
lat_o <- suppressWarnings(as.numeric(df$verbatimLatitude))
lon_o <- suppressWarnings(as.numeric(df$verbatimLongitude))
# lat_final AUN NO esta redondeado en este punto: el redondeo ocurre en el
# volcado. Hay que comparar el valor QUE SE VA A PUBLICAR (redondeado a 6)
# contra el de origen, no el interno contra el de origen: para las filas
# 'original' los dos son el mismo numero y la diferencia da 0 siempre.
lat_r <- round(df$lat_final, 6)
lon_r <- round(df$lon_final, 6)
redondeada <- !is.na(df$lat_final) & !is.na(lat_o) & !is.na(lon_o) &
  (abs(lat_r - lat_o) > 1e-12 | abs(lon_r - lon_o) > 1e-12) &
  abs(lat_r - round(lat_o, 6)) < 1e-9 &
  abs(lon_r - round(lon_o, 6)) < 1e-9
nota_red <- ifelse(redondeada,
  "coordenada redondeada a 6 decimales desde el valor del portal; desplazamiento < 0.1 m; valor integro en verbatimLatitude/verbatimLongitude",
  NA_character_)
df$georeferenceRemarks <- ifelse(
  is.na(nota_red), df$georeferenceRemarks,
  ifelse(is.na(df$georeferenceRemarks) | df$georeferenceRemarks == "",
         nota_red, paste(df$georeferenceRemarks, nota_red, sep = "; ")))
cat("  georeferenceRemarks poblado por redondeo a 6 decimales:",
    sum(redondeada), "\n")

# Declaración de protocolo de georreferenciación.
df$georeferenceProtocol <- ifelse(
  !is.na(df$lat_final) & !df$metodo_correccion %in% c("original", "original_transfronterizo"),
  paste0(ifelse(df$confianza_coordenada == "leida",
                "lectura programatica de verbatimCoordinates; metodo=",
                "reconstruccion programatica desde verbatimCoordinates; metodo="),
         df$metodo_correccion),
  df$georeferenceProtocol)

# ---- 15f. Declaración de georeferenceSources ----
df$georeferenceSources <- dplyr::case_when(
  is.na(df$lat_final) ~ NA_character_,
  df$metodo_correccion %in% c("original", "original_transfronterizo") ~
    "decimalLatitude/decimalLongitude del portal BNDB (MECN-DP)",
  TRUE ~ "verbatimCoordinates del registro (MECN-DP)"
)
cat("  georeferenceSources declarado:", sum(!is.na(df$georeferenceSources)), "\n")

# ---- 15g. Autoria de la georreferencia producida por el pipeline.
# Darwin Core atribuye georeferencedBy a quien DETERMINA la georreferencia.
# En 1606 filas la determino este script desde verbatimCoordinates, no una
# persona del portal. Dejar el campo vacio en esas filas hace indistinguible
# "no consta quien georreferencio" (1071 filas del portal, duda C6) de
# "lo georreferencio el pipeline" (1606 filas, dato conocido).
df$georeferencedBy <- ifelse(
  !is.na(df$lat_final) &
    !df$metodo_correccion %in% c("original", "original_transfronterizo") &
    (is.na(df$georeferencedBy) | df$georeferencedBy == ""),
  "Said Cotacachi (pipeline de limpieza MECN-DP)",
  df$georeferencedBy)
cat("  georeferencedBy atribuido al pipeline:",
    sum(!is.na(df$lat_final) &
        !df$metodo_correccion %in% c("original","original_transfronterizo")), "\n")

# ================================================================
# Volcado de resultados a los campos Darwin Core definitivos
# ================================================================
fmt_coord <- function(x) {
  s <- formatC(x, format = "f", digits = 7)
  s <- sub("0+$", "", s); s <- sub("\\.$", "", s)
  ifelse(is.na(x), NA_character_, s)
}
# Formateo a 6 decimales máximo (límite de GBIF sin advertencia COORDINATE_ROUNDED).
lat_pub <- fmt_coord(round(df$lat_final, 6))
lon_pub <- fmt_coord(round(df$lon_final, 6))
identico <- !is.na(df$lat_final) &
  !is.na(df$decimalLatitude_num) &
  abs(round(df$lat_final, 6) - round(df$decimalLatitude_num,  6)) < 1e-9 &
  abs(round(df$lon_final, 6) - round(df$decimalLongitude_num, 6)) < 1e-9
solo_formato <- !is.na(df$lat_final) & identico &
  (lat_pub != df$verbatimLatitude | lon_pub != df$verbatimLongitude)

df$decimalLatitude  <- ifelse(is.na(df$lat_final),  "", fmt_coord(round(df$lat_final,  6)))
df$decimalLongitude <- ifelse(is.na(df$lon_final), "", fmt_coord(round(df$lon_final, 6)))
# Asignación de datum (WGS84) exclusivamente para conversiones UTM.
justifica_datum <- !is.na(df$lat_final) & grepl("^utm_", df$metodo_correccion)
n_datum_nuevo   <- sum(justifica_datum &
                       (is.na(df$geodeticDatum) | df$geodeticDatum == ""))
df$geodeticDatum <- ifelse(justifica_datum & (is.na(df$geodeticDatum) | df$geodeticDatum == ""),
                           "WGS84", df$geodeticDatum)
cat("  geodeticDatum escrito por conversion UTM:", n_datum_nuevo,
    "de", sum(justifica_datum), "filas convertidas\n")

# Retiro de geodeticDatum huérfano en filas sin coordenada final.
n_datum_huerfano <- sum(is.na(df$lat_final) &
                        !is.na(df$geodeticDatum) & df$geodeticDatum != "")
df$geodeticDatum[is.na(df$lat_final)] <- NA_character_
cat("  geodeticDatum retirado por falta de coordenada:", n_datum_huerfano, "\n")

cat("\nVolcado a Darwin Core:\n")
cat("  decimalLatitude poblado :", sum(df$decimalLatitude != ""), "\n")
cat("  filas donde cambió el valor  :", sum(!identico & !is.na(df$lat_final)), "\n")
cat("  filas donde cambió solo el formato:", sum(solo_formato, na.rm = TRUE), "\n")
cat("  origen preservado en verbatimLatitude/verbatimLongitude\n")

# ---- 16. Resumen ----
cat("\n=== MÉTODO DE CORRECCIÓN ===\n");  print(table(df$metodo_correccion, useNA = "ifany"))
cat("\n=== NIVEL DE CONFIANZA ===\n");    print(table(df$confianza_coordenada))
cat("\n=== COHERENCIA CON LA PROVINCIA ===\n")
print(table(df$coherencia_provincia, df$criterio_coherencia, useNA = "ifany"))
cat("\n=== BANDERAS ===\n")
cat("  coordenada compartida entre provincias:", sum(df$coordenada_compartida, na.rm = TRUE), "\n")
cat("  de ellas, en provincia minoritaria    :", sum(df$provincia_minoritaria, na.rm = TRUE), "\n")
cat("  signo ambiguo no resuelto             :", sum(df$signo_ambiguo, na.rm = TRUE), "\n")
cat("  DMS con minuto o segundo >= 60        :", sum(df$dms_rango_invalido & tiene_coord, na.rm = TRUE), "\n")
cat("  marcadas para revisión (sospechosas)  :", sum(sospechosa, na.rm = TRUE), "\n")
cat("  con coordenada y sin incertidumbre    :",
    sum(!is.na(df$lat_final) & is.na(df$coordinateUncertaintyInMeters)), "\n")
cat("\n=== COBERTURA ===\n")
cat("  con coordenada:", sum(!is.na(df$lat_final)),
    sprintf("(%.1f%%)\n", 100 * mean(!is.na(df$lat_final))))
cat("  sin coordenada:", sum(is.na(df$lat_final)), "\n")

# ---- 17. Exportación ----
# Exportación de reporte final de coordenadas.
df_export <- df %>% select(-decimalLatitude_num, -decimalLongitude_num, -clave_coord)

# ---- 17b. Aplicación de formato (6 decimales) al CSV exportado ----
df_export$lat_final <- ifelse(is.na(df$lat_final), "", fmt_coord(round(df$lat_final, 6)))
df_export$lon_final <- ifelse(is.na(df$lon_final), "", fmt_coord(round(df$lon_final, 6)))

write_csv(df_export, ARCHIVO_SALIDA, na = "")
cat("\nGuardado en", ARCHIVO_SALIDA, "\n")