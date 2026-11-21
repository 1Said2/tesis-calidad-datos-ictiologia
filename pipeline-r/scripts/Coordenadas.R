# ================================================================
# 1/4 - LIMPIEZA DE COORDENADAS - Colección Ictiológica MECN-DP INABIO
#
# Entrada: ocurrences_openrefine.csv
# Salida:  ocurrences_salida_coordenadas.csv -> Fishbase.R
#
# Funciones principales:
# 1. Recuperación de coordenadas desde campo verbatim (DMS, UTM truncadas, erratas de signo).
# 2. Validación espacial contra polígonos GADM y jerarquía administrativa.
# 3. Estimación de incertidumbre en función del formato original.
#    Las estimaciones son auxiliares y no se publican como incertidumbre DwC.
# ================================================================

library(readr)
library(dplyr)
library(parzer)
library(sf)

sf::sf_use_s2(TRUE)

# ---- 0. Configuración ----
ARCHIVO_ENTRADA <- Sys.getenv("COORDENADAS_ENTRADA", "datos/02_intermedios/ocurrences_openrefine.csv")
ARCHIVO_SALIDA <- Sys.getenv("COORDENADAS_SALIDA", "datos/02_intermedios/ocurrences_salida_coordenadas.csv")

norm_nombre <- function(x) {
  x <- iconv(x, to = "ASCII//TRANSLIT")
  x <- tolower(gsub("[^A-Za-z ]", "", x))
  trimws(gsub("\\s+", " ", x))
}

# ---- Polígonos administrativos de nivel 1 (GADM 4.1) ----
DIR_REFERENCIA <- Sys.getenv("COORDENADAS_REFERENCIA", "datos/00_referencia")
PAISES_GADM    <- c("ECU", "PER", "VEN")
TOLERANCIA_BORDE_M <- 5000

dir.create(DIR_REFERENCIA, recursive = TRUE, showWarnings = FALSE)

cargar_gadm <- function(paises, dir_cache) {
  if (!requireNamespace("geodata", quietly = TRUE) ||
      !requireNamespace("terra",   quietly = TRUE)) {
    stop("Se requieren geodata y terra para validar las jurisdicciones.")
  }
  piezas <- list()
  for (p in paises) {
    v <- geodata::gadm(country = p, level = 1, path = dir_cache, version = "4.1")
    if (is.null(v)) stop(paste("No se pudo obtener GADM 4.1 para", p))
    g <- sf::st_transform(sf::st_as_sf(v), 4326)
    piezas[[p]] <- sf::st_sf(prov_norm = norm_nombre(g$NAME_1),
                             pais = as.character(g$GID_0),
                             geometry  = sf::st_geometry(g))
  }
  if (length(piezas) == 0) return(NULL)
  do.call(rbind, piezas)
}

df <- read_csv(ARCHIVO_ENTRADA, col_types = cols(.default = "c"))
if (anyDuplicated(df$id) || anyNA(df$id) || any(df$id == "")) {
  stop("La entrada requiere identificadores id únicos y no vacíos.")
}
cat("Filas cargadas:", nrow(df), "\n")

# ---- 1. Preservación de valores de origen (verbatim) ----
campos_origen <- c("decimalLatitude", "decimalLongitude", "geodeticDatum",
                   "coordinateUncertaintyInMeters", "georeferencedBy",
                   "georeferenceRemarks", "georeferenceProtocol",
                   "georeferenceSources", "georeferenceVerificationStatus")
origen <- df[campos_origen]
if (!"verbatimLatitude" %in% names(df)) df$verbatimLatitude <- df$decimalLatitude
if (!"verbatimLongitude" %in% names(df)) df$verbatimLongitude <- df$decimalLongitude

df$coordenadas_candidatas <- NA_character_
criterio_resolucion <- rep(NA_character_, nrow(df))
fuente_coordenada <- rep(NA_character_, nrow(df))
epsg_transformacion <- rep(NA_integer_, nrow(df))
datum_interpretacion_asumido <- rep(NA_character_, nrow(df))
utm_ambiguo <- rep(FALSE, nrow(df))

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

# ---- 2b. DMS: no normalizar componentes imposibles como coordenadas válidas ----
dms_componentes_invalidos <- function(x) {
  if (is.na(x) || !grepl("[°'\"´]", x)) return(NA_character_)
  s <- gsub("´´|''", '"', x)
  s <- gsub("´", "'", s)
  vals <- regmatches(s, gregexpr("-?[0-9]+([.,][0-9]+)?\\s*['\"]", s))[[1]]
  num <- suppressWarnings(as.numeric(gsub("[^0-9.-]", "", gsub(",", ".", vals))))
  mal <- which(!is.na(num) & (num >= 60 | num < 0))
  # También se interpretan DMS con segundos sin comillas: validar esos componentes.
  if (!length(mal) && grepl("°", s)) {
    n <- suppressWarnings(as.numeric(gsub(",", ".", regmatches(s,
      gregexpr("-?[0-9]+(?:[.,][0-9]+)?", s))[[1]])))
    idx <- if (length(n) == 6L) c(2L, 3L, 5L, 6L) else if (length(n) == 4L) c(2L, 4L) else integer()
    grados <- if (length(idx)) n[c(1L, length(n) / 2L + 1L)] else numeric()
    # Un texto mixto UTM + decimal no es un DMS de cuatro componentes.
    if (length(grados) && any(abs(grados) > 180)) idx <- integer()
    invalidos <- idx[n[idx] < 0 | n[idx] >= 60]
    if (length(invalidos)) {
      return(paste(paste0("componente_DMS_", invalidos, "=", n[invalidos]), collapse = "; "))
    }
  }
  if (!length(mal)) return(NA_character_)
  paste(paste0(ifelse(grepl('"', vals[mal]), "segundos", "minutos"),
               "=", num[mal], " (componente ", mal, ")"), collapse = "; ")
}
dms_rango_invalido <- function(x) !is.na(dms_componentes_invalidos(x))
dms_componente_invalido <- vapply(df$verbatimCoordinates, dms_componentes_invalidos, character(1))
df$dms_rango_invalido <- !is.na(dms_componente_invalido)

# ---- 3. Ámbito y jurisdicción: los alias pertenecen a un país ----
in_bbox <- function(lat, lon) {
  continental <- !is.na(lat) & !is.na(lon) & lat >= -5.5 & lat <= 1.5 & lon >= -81.5 & lon <= -75
  galapagos <- !is.na(lat) & !is.na(lon) & lat >= -1.5 & lat <= 1.9 & lon >= -92.5 & lon <= -89
  continental | galapagos
}
par_valido <- function(lat, lon) {
  is.finite(lat) & is.finite(lon) & abs(lat) <= 90 & abs(lon) <= 180
}
normalizar_pais <- function(x) {
  n <- norm_nombre(x)
  alias <- c(ecuador = "ECU", ecu = "ECU", ec = "ECU",
             peru = "PER", per = "PER", pe = "PER",
             venezuela = "VEN", ven = "VEN", ve = "VEN")
  unname(alias[n])
}
clave_jurisdiccion <- function(pais, provincia) {
  p <- norm_nombre(provincia)
  p[!is.na(pais) & pais == "PER" & !is.na(p) & p == "maynas"] <- "loreto"
  ifelse(is.na(pais) | is.na(p) | p == "", "", paste(pais, p, sep = "::"))
}
pais_df <- normalizar_pais(df$country)
prov_norm_df <- norm_nombre(df$stateProvince)
jurisdiccion_df <- clave_jurisdiccion(pais_df, df$stateProvince)
gadm <- cargar_gadm(PAISES_GADM, DIR_REFERENCIA)
if (is.null(gadm)) stop("No hay polígonos GADM para validar jurisdicciones.")
gadm$clave <- clave_jurisdiccion(gadm$pais, gadm$prov_norm)
poly_cache <- lapply(split(seq_len(nrow(gadm)), gadm$clave), function(idx) {
  stopifnot(length(unique(gadm$pais[idx])) == 1)
  if (length(idx) == 1L) return(sf::st_geometry(gadm[idx, ]))
  sf::st_union(sf::st_geometry(gadm[idx, ]))
})
bbox_cache <- lapply(poly_cache, sf::st_bbox)


cache_contencion <- new.env(parent = emptyenv())
en_provincia <- function(lat, lon, prov_norm, pais = NA_character_) {
  if (!par_valido(lat, lon)) return(NA)
  clave <- clave_jurisdiccion(pais, prov_norm)
  if (!nzchar(clave) || !clave %in% names(poly_cache)) return(NA)
  clave_punto <- paste(clave, sprintf("%.10f", lat), sprintf("%.10f", lon), sep = "|")
  if (exists(clave_punto, cache_contencion, inherits = FALSE)) return(cache_contencion[[clave_punto]])
  # Rechazo rápido conservador; la caja nunca acredita contención.
  caja <- bbox_cache[[clave]]
  margen_lat <- TOLERANCIA_BORDE_M / 110000
  margen_lon <- margen_lat / cos(max(abs(caja[c("ymin", "ymax")])) * pi / 180)
  if (lat < caja["ymin"] - margen_lat || lat > caja["ymax"] + margen_lat ||
      lon < caja["xmin"] - margen_lon || lon > caja["xmax"] + margen_lon) {
    cache_contencion[[clave_punto]] <- FALSE
    return(FALSE)
  }
  pt <- sf::st_sfc(sf::st_point(c(lon, lat)), crs = 4326)
  dentro <- as.numeric(sf::st_distance(pt, poly_cache[[clave]])) <= TOLERANCIA_BORDE_M
  cache_contencion[[clave_punto]] <- dentro
  dentro
}
en_ambito <- function(lat, lon, pais) {
  if (!par_valido(lat, lon)) return(FALSE)
  if (identical(pais, "ECU")) return(in_bbox(lat, lon))
  # Sin país sólo se conserva la fuente decimal independiente; no se infieren signos.
  !is.na(pais) && pais %in% PAISES_GADM
}

# ---- 4-5. Hipótesis completas; publicar sólo una resolución respaldada ----
resultado_coord <- function(lat = NA_real_, lon = NA_real_, metodo = "irreparable",
                            candidatos = NA_character_, estado = "pendiente",
                            criterio = "sin_interpretacion_respaldada", zona = NA_character_,
                            datum_asumido = NA_character_, evidencia = NA_character_) {
  valores <- c(lat, lon, metodo, candidatos, estado, criterio, zona, datum_asumido, evidencia)
  setNames(unname(valores), c("lat", "lon", "metodo", "candidatos", "estado",
                             "criterio", "zona", "datum_asumido", "evidencia"))
}
describir_candidatos <- function(candidatos, prov_norm, pais) {
  paste(vapply(names(candidatos), function(n) {
    c <- candidatos[[n]]
    sprintf("%s:lat=%.9f,lon=%.9f,rango=%s,provincia=%s",
            n, c[1], c[2], par_valido(c[1], c[2]), en_provincia(c[1], c[2], prov_norm, pais))
  }, character(1)), collapse = " | ")
}
elegir_candidato <- function(candidatos, prov_norm, pais, permitir_directo = FALSE) {
  detalle <- describir_candidatos(candidatos, prov_norm, pais)
  if (permitir_directo && en_ambito(candidatos[[1]][1], candidatos[[1]][2], pais)) {
    return(resultado_coord(candidatos[[1]][1], candidatos[[1]][2], names(candidatos)[1],
                           detalle, "resuelta", "lectura_explicita_sin_inferencia"))
  }
  respaldo <- vapply(candidatos, function(c) {
    en_ambito(c[1], c[2], pais) && isTRUE(en_provincia(c[1], c[2], prov_norm, pais))
  }, logical(1))
  pares <- vapply(candidatos, function(c) paste(round(c, 9), collapse = ","), character(1))
  elegibles <- which(respaldo & !duplicated(pares))
  if (length(elegibles) == 1) {
    j <- elegibles[1]
    return(resultado_coord(candidatos[[j]][1], candidatos[[j]][2], names(candidatos)[j],
                           detalle, "resuelta", "unica_hipotesis_en_jurisdiccion"))
  }
  plausibles <- vapply(candidatos, function(c) {
    if (is.na(pais)) par_valido(c[1], c[2]) else en_ambito(c[1], c[2], pais)
  }, logical(1))
  ambiguo <- length(unique(pares[plausibles])) > 1
  resultado_coord(metodo = if (ambiguo) "signo_ambiguo" else "irreparable",
                  candidatos = detalle, estado = if (ambiguo) "ambigua" else "pendiente",
                  criterio = if (length(elegibles) > 1) "multiples_hipotesis_en_jurisdiccion"
                             else "sin_respaldo_territorial")
}
fix_coord <- function(lat, lon, prov_norm = "", pais = NA_character_, original = TRUE) {
  if (!is.finite(lat) || !is.finite(lon)) return(resultado_coord(metodo = "vacio"))
  candidatos <- list(original = c(lat, lon), swap = c(lon, lat),
    neg_lon = c(lat, -lon), neg_lat = c(-lat, lon), neg_ambos = c(-lat, -lon),
    swap_neg_lon = c(lon, -lat), swap_neg_lat = c(-lon, lat), swap_neg_ambos = c(-lon, -lat))
  if (original && par_valido(lat, lon) &&
      (is.na(pais) || !identical(pais, "ECU") || in_bbox(lat, lon))) {
    return(resultado_coord(lat, lon, if (!is.na(pais) && pais != "ECU") "original_transfronterizo" else "original",
                           NA_character_, "resuelta", "decimal_original_independiente"))
  }
  elegir_candidato(candidatos, prov_norm, pais)
}

# ---- 6-7. Registrar la calidad de cada fuente de forma independiente ----
df$lat_final <- NA_real_
df$lon_final <- NA_real_
df$metodo_correccion <- "sin_dato_origen"
df$signo_ambiguo <- FALSE
registrar_resultado <- function(i, r, fuente) {
  detalle <- if (is.na(r["candidatos"])) NA_character_ else paste0(fuente, "{", r["candidatos"], "}")
  if (!is.na(detalle)) {
    df$coordenadas_candidatas[i] <<- paste(na.omit(c(df$coordenadas_candidatas[i], detalle)), collapse = " || ")
  }
  hay_ambiguedad <- identical(unname(r["estado"]), "ambigua") ||
    isTRUE(unname(r["ambiguedad_signo"]) == "TRUE")
  if (hay_ambiguedad && !grepl("^utm", r["metodo"])) {
    df$signo_ambiguo[i] <<- TRUE
  }
  if (is.na(df$lat_final[i])) {
    criterio_resolucion[i] <<- unname(r["criterio"])
    df$metodo_correccion[i] <<- unname(r["metodo"])
    if (!is.na(r["lat"])) {
      df$lat_final[i] <<- as.numeric(r["lat"])
      df$lon_final[i] <<- as.numeric(r["lon"])
      fuente_coordenada[i] <<- fuente
    }
  }
}
for (i in seq_len(nrow(df))) {
  la <- df$decimalLatitude_num[i]
  lo <- df$decimalLongitude_num[i]
  if (is.na(la) && is.na(lo)) next
  registrar_resultado(i, fix_coord(la, lo, prov_norm_df[i], pais_df[i]), "decimal")
}

dist_km <- function(lat1, lon1, lat2, lon2) {
  sqrt(((lat1 - lat2) * 111.32)^2 + ((lon1 - lon2) * 111.32 * cos(lat1 * pi / 180))^2)
}

# La referencia local reutiliza el criterio existente de D14 (>=5 y mayoría >=80%).
referencias_localidad <- list()
idx_local <- which(!is.na(df$lat_final) & !is.na(df$locality) &
                     df$locality != "" & df$locality != "Varios Sitios" & jurisdiccion_df != "" &
                     df$metodo_correccion %in% c("original", "original_transfronterizo"))
for (g in split(idx_local, paste(jurisdiccion_df[idx_local], df$locality[idx_local], sep = "||"))) {
  if (length(g) < 5) next
  g <- g[vapply(g, function(i) isTRUE(en_provincia(df$lat_final[i], df$lon_final[i],
                                                  prov_norm_df[i], pais_df[i])), logical(1))]
  if (length(g) < 5) next
  pares <- paste(round(df$lat_final[g], 4), round(df$lon_final[g], 4))
  tb <- sort(table(pares), decreasing = TRUE)
  if (as.numeric(tb[1]) / length(g) < 0.80) next
  clave <- paste(jurisdiccion_df[g[1]], df$locality[g[1]], sep = "||")
  referencias_localidad[[clave]] <- as.numeric(strsplit(names(tb)[1], " ")[[1]])
}

# ---- 8. DMS: respetar signos/letras; nunca sustituir dígitos ----
normalize_dms <- function(x) {
  x <- gsub("´´|''", '"', x)
  x <- gsub("´", "'", x)
  x <- gsub("(\\d),(\\d)", "\\1.\\2", x)
  x <- gsub("O\\s*$", "W", trimws(x))
  gsub("\\s*/\\s*", " ", x)
}
intentar_sin_hemisferio <- function(raw, prov_norm = "", pais = NA_character_,
                                   respaldo_decimal = NULL) {
  x <- normalize_dms(raw)
  nums <- regmatches(x, gregexpr("-?[0-9]+(?:\\.[0-9]+)?", x))[[1]]
  n <- suppressWarnings(as.numeric(nums))
  if (!length(n) || anyNA(n) || !length(n) %in% c(2L, 4L, 6L)) return(resultado_coord())
  k <- length(n) / 2
  if (k > 1 && any(abs(n[c(1L, k + 1L)]) > 180)) {
    return(resultado_coord(criterio = "formato_mixto_no_interpretado_como_DMS"))
  }
  idx_componentes <- if (k == 3L) c(2L, 3L, 5L, 6L) else if (k == 2L) c(2L, 4L) else integer()
  invalido_sin_unidades <- any(n[idx_componentes] < 0 | n[idx_componentes] >= 60)
  magnitud <- function(v) {
    abs(v[1]) + if (length(v) == 1) 0 else v[2] / 60 + if (length(v) == 3) v[3] / 3600 else 0
  }
  la <- magnitud(n[seq_len(k)])
  lo <- magnitud(n[k + seq_len(k)])
  invertido <- la > 90 || (la > lo && lo < 6)
  if (invertido) { tmp <- la; la <- lo; lo <- tmp }
  signo_lat <- if (grepl("[Ss]", x)) -1 else if (grepl("[Nn]", x)) 1 else c(1, -1)
  signo_lon <- if (grepl("[WwOo]", x)) -1 else if (grepl("[Ee]", x)) 1 else c(1, -1)
  # Un signo negativo explícito sigue siendo evidencia aunque no haya letra.
  if (!invertido && n[1] < 0) signo_lat <- -1
  if (!invertido && n[k + 1] < 0) signo_lon <- -1
  cs <- list()
  for (a in signo_lat) for (b in signo_lon) cs[[paste0("dms_signos_", a, "_", b)]] <- c(la * a, lo * b)
  r <- elegir_candidato(cs, prov_norm, pais, length(cs) == 1)
  if (!is.null(respaldo_decimal)) {
    coincide <- vapply(cs, function(c) all(round(c, 6) == round(respaldo_decimal, 6)), logical(1))
    if (sum(coincide) == 1L) {
      c <- cs[[which(coincide)]]
      r <- resultado_coord(c[1], c[2], names(cs)[coincide], r["candidatos"],
                           "resuelta", "corroborada_por_decimal_original_independiente")
    }
  }
  r["ambiguedad_signo"] <- as.character(r["estado"] == "ambigua")
  if (dms_rango_invalido(raw) || invalido_sin_unidades) {
    r[c("lat", "lon")] <- NA_character_
    r["metodo"] <- "dms_invalido_pendiente"
    r["estado"] <- "dms_invalido"
    r["criterio"] <- if (dms_rango_invalido(raw)) dms_componentes_invalidos(raw) else
      "componentes_DMS_sin_unidades_fuera_de_rango"
  }
  r
}
resolve_dms <- function(raw, es_transf = FALSE, prov_norm = "", pais = NA_character_,
                        respaldo_decimal = NULL) {
  x <- normalize_dms(raw)
  # parzer sólo recibe un par con ambos hemisferios, nunca valores DMS inválidos.
  partes <- regmatches(x, regexec("^(.*[NnSs])\\s+(.*[EeWwOo])$", x))[[1]]
  if (!dms_rango_invalido(raw) && length(partes) == 3) {
    la <- suppressWarnings(parzer::parse_lat(partes[2]))
    lo <- suppressWarnings(parzer::parse_lon(partes[3]))
    if (length(la) == 1 && length(lo) == 1 && en_ambito(la, lo, pais)) {
      return(resultado_coord(la, lo, "dms_directo",
        describir_candidatos(list(dms_directo = c(la, lo)), prov_norm, pais),
        "resuelta", "hemisferios_explicitos"))
    }
  }
  intentar_sin_hemisferio(raw, prov_norm, pais, respaldo_decimal)
}

# ---- 8b. UTM: enumerar zona, hemisferio y escala; resolver por jurisdicción ----
utm_easting_valido <- function(e) is.finite(e) && e >= 160000 && e <= 840000
utm_northing_valido <- function(n, epsg) {
  is.finite(n) && n >= 0 && n <= 10000000 &&
    epsg %in% c(32601:32660, 32701:32760)
}
extraer_epsg <- function(x) {
  m <- regmatches(x, regexpr("(326|327)[0-9]{2}(?![0-9])", x, perl = TRUE))
  if (!length(m)) return(NA_integer_)
  as.integer(m)
}
convertir_utm2 <- function(raw, pais = NA_character_, prov_norm = "",
                           datum = NA_character_, localidad = NA_character_, srs = NA_character_) {
  if (is.na(raw)) return(resultado_coord())
  texto <- gsub("\\s", "", raw)
  zona_declarada <- regmatches(texto, regexec("^([0-9]{1,2})([NSns])[:; ]?", texto))[[1]]
  zona <- NA_integer_
  hemi <- NA_character_
  if (length(zona_declarada) == 3) {
    zona <- as.integer(zona_declarada[2])
    hemi <- toupper(zona_declarada[3])
    texto <- substring(texto, nchar(zona_declarada[1]) + 1)
  }
  partes <- strsplit(gsub("[ENSWensw]", "", texto), "[/,|]")[[1]]
  if (length(partes) != 2) return(resultado_coord())
  e <- suppressWarnings(as.numeric(partes[1]))
  n <- suppressWarnings(as.numeric(partes[2]))
  if (!utm_easting_valido(e) || !is.finite(n) || n < 0) {
    return(resultado_coord(criterio = "utm_fuera_de_rango_o_formato_no_soportado"))
  }
  if (is.na(hemi) && grepl("[Ss]$", texto)) hemi <- "S"
  etiquetas_e_n <- grepl("[Ee][/,|]", texto) && grepl("[Nn]$", texto)
  if (is.na(hemi) && grepl("[Nn]$", texto) && !etiquetas_e_n) hemi <- "N"
  # El datum declarado y el sistema operativo de transformación son campos distintos.
  declarado <- if (!is.na(srs) && nzchar(srs)) srs else datum
  epsg_declarado <- if (!is.na(declarado)) extraer_epsg(declarado) else NA_integer_
  es_wgs <- !is.na(declarado) && grepl("^(WGS[ _-]*84|EPSG[: ]*4326)$", trimws(declarado), ignore.case = TRUE)
  sin_datum <- is.na(declarado) || trimws(declarado) == ""
  if (!sin_datum && !es_wgs && is.na(epsg_declarado)) {
    return(resultado_coord(criterio = "srs_declarado_no_soportado_sin_transformacion"))
  }
  zonas <- switch(ifelse(is.na(pais), "", pais), ECU = c(15L, 16L, 17L, 18L),
                  PER = 17L:19L, VEN = 18L:21L, integer())
  if (!is.na(zona)) zonas <- intersect(zonas, zona)
  epsgs <- c(32600L + zonas, 32700L + zonas)
  if (!is.na(hemi)) epsgs <- epsgs[(epsgs >= 32700) == (hemi == "S")]
  if (!is.na(epsg_declarado)) epsgs <- intersect(epsgs, epsg_declarado)
  cs <- list()
  detalle_rechazos <- character()
  for (mult in c(1, 10, 100)) for (epsg in epsgs) {
    n2 <- n * mult
    nombre <- paste0("utm_", epsg, "_northing_x", mult)
    if (!utm_northing_valido(n2, epsg)) {
      detalle_rechazos <- c(detalle_rechazos, paste0(nombre, ":northing_fuera_de_rango"))
      next
    }
    pt <- sf::st_sfc(sf::st_point(c(e, n2)), crs = epsg)
    co <- sf::st_coordinates(sf::st_transform(pt, 4326))
    lat <- co[1, 2]; lon <- co[1, 1]
    if (!par_valido(lat, lon) || (epsg >= 32700 && (lat > 0 || lat < -80)) ||
        (epsg < 32700 && (lat < 0 || lat > 84))) {
      detalle_rechazos <- c(detalle_rechazos, paste0(nombre, ":fuera_zona_uso"))
      next
    }
    cs[[nombre]] <- c(lat, lon)
  }
  if (!length(cs)) return(resultado_coord(candidatos = paste(detalle_rechazos, collapse = " | "),
                                         criterio = "sin_transformacion_utm_evaluable"))
  clave_local <- paste(clave_jurisdiccion(pais, prov_norm), localidad, sep = "||")
  ref <- referencias_localidad[[clave_local]]
  evidencia <- if (is.na(localidad) || !nzchar(localidad)) "sin_localidad" else
    "localidad_textual_sin_referencia_geografica_independiente"
  seleccion <- cs
  if (!is.null(ref)) {
    # Diez km es el umbral de contradicción local ya utilizado en D14.
    local_ok <- vapply(cs, function(c) dist_km(c[1], c[2], ref[1], ref[2]) <= 10, logical(1))
    seleccion <- cs[local_ok]
    evidencia <- "mayoria_decimal_independiente_misma_localidad;criterio_D14_10km"
    detalle_rechazos <- c(detalle_rechazos, paste0(names(cs)[!local_ok], ":discordante_localidad"))
  }
  r <- if (length(seleccion)) elegir_candidato(seleccion, prov_norm, pais) else
    resultado_coord(criterio = "ninguna_hipotesis_coherente_con_localidad")
  r["candidatos"] <- describir_candidatos(cs, prov_norm, pais)
  if (r["estado"] == "ambigua") r["metodo"] <- "utm_ambiguo"
  r["candidatos"] <- paste(c(r["candidatos"], detalle_rechazos), collapse = " | ")
  if (!is.na(r["lat"])) {
    epsg <- extraer_epsg(r["metodo"])
    r["zona"] <- as.character(epsg)
    r["metodo"] <- paste0("utm_zona_", sub("^utm_", "", r["metodo"]))
    r["criterio"] <- "unica_transformacion_en_jurisdiccion;zona_y_hemisferio_evaluados"
  }
  r["datum_asumido"] <- if (sin_datum) "WGS84; supuesto_operativo_no_confirmado" else NA_character_
  r["evidencia"] <- evidencia
  r
}
for (i in seq_len(nrow(df))) {
  raw <- df$verbatimCoordinates[i]
  if (is.na(raw) || trimws(raw) == "") next
  # La evaluación de verbatim no reemplaza una coordenada decimal independiente.
  aplicar <- is.na(df$lat_final[i])
  if (df$coord_tipo[i] == "utm_o_similar") {
    datum <- df$geodeticDatum[i]
    srs <- if ("verbatimSRS" %in% names(df)) df$verbatimSRS[i] else NA_character_
    r <- convertir_utm2(raw, pais_df[i], prov_norm_df[i], datum, df$locality[i], srs)
    utm_ambiguo[i] <- r["estado"] == "ambigua"
    datum_interpretacion_asumido[i] <- unname(r["datum_asumido"])
    r["criterio"] <- paste(na.omit(c(r["criterio"], r["evidencia"])), collapse = ";")
    if (aplicar && !is.na(r["lat"])) {
      epsg_transformacion[i] <- as.integer(r["zona"])
    }
  } else {
    respaldo <- if (df$metodo_correccion[i] %in% c("original", "original_transfronterizo")) {
      c(df$lat_final[i], df$lon_final[i])
    } else NULL
    r <- resolve_dms(raw, prov_norm = prov_norm_df[i], pais = pais_df[i], respaldo_decimal = respaldo)
  }
  if (r["estado"] == "dms_invalido") {
    df$dms_rango_invalido[i] <- TRUE
    dms_componente_invalido[i] <- unname(r["criterio"])
  }
  registrar_resultado(i, r, "verbatim")
}

# ---- 9. Referencias empíricas: siempre dentro de la misma jurisdicción ----
centroides <- data.frame(clave = jurisdiccion_df, metodo_correccion = df$metodo_correccion,
                         lat_final = df$lat_final, lon_final = df$lon_final) %>%
  filter(metodo_correccion %in% c("original", "dms_directo"), !is.na(lat_final),
         clave != "") %>%
  group_by(clave) %>%
  summarise(n_ref = n(), lat_c = median(lat_final), lon_c = median(lon_final), .groups = "drop") %>%
  filter(n_ref >= 5)
coherente_con_centroide <- function(lat, lon, clave, umbral_km = 150) {
  if (is.na(lat) || is.na(clave) || !clave %in% centroides$clave) return(NA)
  cc <- centroides[centroides$clave == clave, ]
  dist_km(lat, lon, cc$lat_c, cc$lon_c) <= umbral_km
}
df$dist_centroide_km <- mapply(function(la, lo, p) {
  if (is.na(la) || is.na(p) || !p %in% centroides$clave) return(NA_real_)
  cc <- centroides[centroides$clave == p, ]
  round(dist_km(la, lo, cc$lat_c, cc$lon_c), 1)
}, df$lat_final, df$lon_final, jurisdiccion_df)

# ---- 10. Rescate decimal: conservar la hipótesis y exigir contención ----
recuperar_decimal_corrupto <- function(raw, prov_norm, pais) {
  m <- regmatches(raw, regexec("^(-?[0-9]+\\.[0-9]+)\\s+(-?[0-9,]+)$", raw))[[1]]
  if (length(m) != 3) return(resultado_coord())
  lat <- suppressWarnings(as.numeric(m[2]))
  lon <- suppressWarnings(as.numeric(gsub(",", "", m[3])))
  if (!is.finite(lat) || !is.finite(lon)) return(resultado_coord())
  intentos <- 0
  while (abs(lon) > 180 && intentos < 8) { lon <- lon / 10; intentos <- intentos + 1 }
  r <- elegir_candidato(list(decimal_separador_corrupto = c(lat, -abs(lon))),
                        prov_norm, pais)
  r
}
for (i in which(is.na(df$lat_final) & !is.na(df$verbatimCoordinates))) {
  # No se aplica otro parser para eludir una ambigüedad o un DMS imposible.
  if (df$signo_ambiguo[i] || df$dms_rango_invalido[i] || df$coord_tipo[i] == "utm_o_similar") next
  r <- recuperar_decimal_corrupto(df$verbatimCoordinates[i], prov_norm_df[i], pais_df[i])
  if (!is.na(r["candidatos"])) registrar_resultado(i, r, "verbatim")
}
sin_verbatim <- is.na(df$verbatimCoordinates) | trimws(df$verbatimCoordinates) == ""
sin_decimal <- (is.na(origen$decimalLatitude) | trimws(origen$decimalLatitude) == "") &
  (is.na(origen$decimalLongitude) | trimws(origen$decimalLongitude) == "")
df$metodo_correccion[is.na(df$lat_final) & sin_verbatim & sin_decimal] <- "sin_dato_origen"
df$metodo_correccion[is.na(df$lat_final) & sin_verbatim & !sin_decimal & !df$signo_ambiguo] <-
  "descartada_fuera_de_rango"

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
    md <- regmatches(raw, regexec("^\\s*-?[0-9]{1,3}[.,]([0-9]+)\\s*[/, ]", raw))[[1]]
    if (length(md) >= 2) return(paste0("decimal_", min(nchar(md[2]), 8), "d"))
    if (!is.na(tipo) && tipo == "utm_o_similar") return("utm_metro")
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

# ---- 12c. La precisión textual sigue siendo evidencia aunque el punto esté pendiente ----

# ---- 13. Estimación heurística interna: no es el radio de la localidad ----
df$incertidumbre_estimada_m <- dplyr::case_when(
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

# ---- 13b. Piso tecnológico de incertidumbre (100 m pre-2000, 30 m post-2000) ----
anio_evento <- suppressWarnings(as.integer(substr(df$eventDate, 1, 4)))
piso_m <- ifelse(is.na(anio_evento) | anio_evento < 2000, 100, 30)

unc_num <- suppressWarnings(as.numeric(df$incertidumbre_estimada_m))
unc_piso <- pmax(unc_num, piso_m)
df$piso_incertidumbre_aplicado <- !is.na(unc_num) & unc_piso > unc_num
df$incertidumbre_estimada_m <- ifelse(is.na(unc_piso), NA_character_,
                                           as.character(as.integer(unc_piso)))

df$incertidumbre_criterio <- ifelse(
  is.na(df$incertidumbre_estimada_m), NA_character_,
  paste0("estimada_desde_precision_origen:", df$precision_origen,
         ifelse(df$piso_incertidumbre_aplicado,
                paste0(";piso_tecnologico_", piso_m, "m"), "")))

cat("  incertidumbre elevada al piso tecnologico:",
    sum(df$piso_incertidumbre_aplicado, na.rm = TRUE), "\n")

df$incertidumbre_criterio <- ifelse(is.na(df$incertidumbre_criterio), NA_character_,
  paste0(df$incertidumbre_criterio,
         ";hipotesis_no_validada;sin_evidencia_del_radio_completo_de_localidad"))

# ================================================================
# 14. Coherencia espacial (contención en polígono)
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
  pts$prov_norm <- jurisdiccion_df[tiene_coord]
  
  for (p in unique(pts$prov_norm)) {
    sel <- which(pts$prov_norm == p)
    if (p == "") {
      df$coherencia_provincia[pts$idx[sel]] <- "no_evaluable"
      df$criterio_coherencia[pts$idx[sel]]  <- "sin_pais_o_provincia_declarados"
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
  
  # Tolerancia ampliada para marinos fuera de GADM terrestre.
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
  stop("Error: No se pudieron cargar poligonos GADM. Abortando para mantener la integridad (evita respaldos de menor calidad).")
}

# ---- 14b. Clasificación de discordancias (mecánicas vs incomprensibles) ----
df$discordancia_explicada <- NA_character_
for (i in which(df$coherencia_provincia == "discordante")) {
  p <- prov_norm_df[i]
  pais <- pais_df[i]
  la <- df$lat_final[i]; lo <- df$lon_final[i]
  df$discordancia_explicada[i] <-
    if (isTRUE(en_provincia(-la, lo, p, pais)))                       "signo_latitud"
    else if (isTRUE(en_provincia(la, -lo, p, pais)))                  "signo_longitud"
    else if (abs(lo) <= 90 && isTRUE(en_provincia(lo, la, p, pais)))   "swap_lat_lon"
    else                                                         "sin_explicacion_mecanica"
}
cat("\n=== REPARTO DE LAS DISCORDANCIAS ===\n")
print(table(df$discordancia_explicada, useNA = "no"))
print(table(df$stateProvince, df$discordancia_explicada))

# ---- 14c. Hipótesis de errata de un dígito en northings UTM ----
df$hipotesis_northing <- NA_character_
idx <- which(df$coherencia_provincia == "discordante" &
               df$discordancia_explicada == "sin_explicacion_mecanica" &
               grepl("^utm_zona_", df$metodo_correccion))
for (i in idx) {
  nums <- as.numeric(regmatches(df$verbatimCoordinates[i],
            gregexpr("[0-9]+\\.?[0-9]*", df$verbatimCoordinates[i]))[[1]])
  if (length(nums) < 2) next
  e <- min(nums[(length(nums)-1):length(nums)]); n <- max(nums[(length(nums)-1):length(nums)])
  epsg <- epsg_transformacion[i]
  if (is.na(epsg)) next
  s <- strsplit(as.character(n), "")[[1]]
  for (pos in seq_along(s)) for (d in as.character(0:9)) {
    if (s[pos] == d) next
    s2 <- s; s2[pos] <- d; nuevo_northing <- as.numeric(paste(s2, collapse = ""))
    if (nuevo_northing < 9000000 || nuevo_northing > 10000000) next
    p <- sf::st_transform(sf::st_sfc(sf::st_point(c(e, nuevo_northing)), crs = epsg), 4326)
    cc <- sf::st_coordinates(p)
    if (isTRUE(en_provincia(cc[2], cc[1], prov_norm_df[i], pais_df[i]))) {
      hipotesis <- sprintf("northing %s -> %s (digito %d) cae en la provincia declarada",
                                          n, nuevo_northing, as.integer(d))
      df$hipotesis_northing[i] <- paste(na.omit(c(df$hipotesis_northing[i], hipotesis)), collapse = " | ")
    }
  }
}

# ---- 14d. Contradicción de signo en misma tupla verbatim ----
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
df$dentro_tolerancia_borde <- !is.na(df$lat_final) &
  df$coherencia_provincia == "coherente" &
  !is.na(df$dist_fuera_provincia_m) & df$dist_fuera_provincia_m > 0
cat("  coherentes por tolerancia de borde (fuera del poligono, <=5 km):",
    sum(df$dentro_tolerancia_borde, na.rm = TRUE), "\n")

# ---- 14f. Coordenada minoritaria dentro de la propia localidad ----
df$flag_coord_minoritaria_en_localidad <- FALSE
df$dist_a_mayoria_localidad_km         <- NA_real_

idx_loc <- which(!is.na(df$lat_final) &
                   !is.na(df$locality) & trimws(df$locality) != "")
grupos <- split(idx_loc,
                paste(jurisdiccion_df[idx_loc], df$locality[idx_loc], sep = "||"))

for (g in grupos) {
  if (length(g) < 5) next
  k  <- paste(round(df$lat_final[g], 4), round(df$lon_final[g], 4))
  tb <- sort(table(k), decreasing = TRUE)
  if (length(tb) < 2)            next
  if (tb[1] / length(g) < 0.80)  next
  may <- as.numeric(strsplit(names(tb)[1], " ")[[1]])
  d   <- dist_km(df$lat_final[g], df$lon_final[g], may[1], may[2])
  df$dist_a_mayoria_localidad_km[g]         <- round(d, 1)
  df$flag_coord_minoritaria_en_localidad[g] <- d > 10
}
cat("  coordenada minoritaria dentro de la propia localidad:",
    sum(df$flag_coord_minoritaria_en_localidad, na.rm = TRUE), "\n")


# ---- Coordenada compartida vs provincia minoritaria ----
clave <- ifelse(is.na(df$lat_final), NA_character_,
                paste(pais_df, round(df$lat_final, 5), round(df$lon_final, 5)))
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
claves_empatadas <- resumen_clave %>%
  filter(n_filas == n_max) %>%
  count(clave_coord, name = "n_lideres") %>%
  filter(n_lideres > 1) %>%
  pull(clave_coord)

df$provincia_minoritaria <- df$coordenada_compartida & ifelse(
  df$clave_coord %in% claves_empatadas,
  !is.na(df$coherencia_provincia) & df$coherencia_provincia == "discordante",
  !(paste(df$clave_coord, df$stateProvince, sep = "||") %in% pares_mayoritarios))

# ---- 15. Metadatos: evidencia de origen, procesamiento y revisión separados ----
agregar_nota <- function(actual, nota) {
  ifelse(is.na(nota) | nota == "", actual,
         ifelse(is.na(actual) | actual == "", nota, paste(actual, nota, sep = "; ")))
}
sin_coord <- is.na(df$lat_final)
no_evaluable <- is.na(df$coherencia_provincia) | df$coherencia_provincia == "no_evaluable"
discordante <- !is.na(df$coherencia_provincia) & df$coherencia_provincia == "discordante"
pendiente_origen <- sin_coord & df$metodo_correccion != "sin_dato_origen"


sospechosa <- discordante | df$signo_ambiguo | utm_ambiguo | df$dms_rango_invalido |
  df$provincia_minoritaria | df$flag_signo_contradice_hermanas |
  df$flag_coord_minoritaria_en_localidad | pendiente_origen |
  (!sin_coord & no_evaluable) | !is.na(datum_interpretacion_asumido)
sospechosa[is.na(sospechosa)] <- TRUE

# Una incertidumbre de origen positiva se conserva si sigue referida al mismo punto.
# Los cambios de signo/eje pendientes requieren revisar también ese radio.
unc_original <- suppressWarnings(as.numeric(origen$coordinateUncertaintyInMeters))
mismo_punto <- !sin_coord & !is.na(df$decimalLatitude_num) & !is.na(df$decimalLongitude_num) &
  abs(df$lat_final - df$decimalLatitude_num) < 1e-9 &
  abs(df$lon_final - df$decimalLongitude_num) < 1e-9
publicar_unc <- !is.na(unc_original) & is.finite(unc_original) & unc_original > 0 & mismo_punto
df$coordinateUncertaintyInMeters <- ifelse(publicar_unc,
  origen$coordinateUncertaintyInMeters, NA_character_)


df$georeferenceVerificationStatus <- ifelse(sospechosa, "requires verification",
  ifelse(!is.na(origen$georeferenceVerificationStatus),
         origen$georeferenceVerificationStatus, ifelse(sin_coord, NA_character_, "unverified")))

motivo <- rep(NA_character_, nrow(df))
anotar_motivo <- function(idx, texto) {
  idx <- which(!is.na(idx) & idx)
  motivo[idx] <<- agregar_nota(motivo[idx], rep(texto, length.out = length(idx)))
}
anotar_motivo(df$signo_ambiguo, "hipotesis de signo sin resolucion unica; candidatos conservados en auditoria")
anotar_motivo(utm_ambiguo, "multiples transformaciones UTM plausibles; ninguna elegida por orden")
for (i in which(df$dms_rango_invalido)) {
  motivo[i] <- agregar_nota(motivo[i],
    paste0("DMS de origen invalido: ", dms_componente_invalido[i],
           "; sin correccion de digitos ni publicacion desde esta fuente"))
}
anotar_motivo(discordante, "punto discordante con la jurisdiccion pais/provincia; pendiente de revision curatorial")
anotar_motivo(!sin_coord & no_evaluable, "jurisdiccion no evaluable: pais/provincia ausente o sin poligono")
anotar_motivo(df$provincia_minoritaria, "coordenada compartida; provincia minoritaria; verificar evento de colecta")
anotar_motivo(df$flag_signo_contradice_hermanas, "misma tupla verbatim con resultados divergentes")
anotar_motivo(df$flag_coord_minoritaria_en_localidad, "coordenada minoritaria a mas de 10 km de la mayoria local")
anotar_motivo(df$metodo_correccion == "descartada_fuera_de_rango",
             "decimal original fuera del ambito declarado; preservado en verbatimLatitude/verbatimLongitude")
anotar_motivo(pendiente_origen, "sin par publicable respaldado; texto, pares originales e hipotesis conservados")
anotar_motivo(!is.na(datum_interpretacion_asumido),
             "candidatos UTM transformados a EPSG:4326 bajo supuesto operativo WGS84; datum historico no confirmado")
anotar_motivo(df$coherencia_provincia == "fuera_de_tierra_firme",
             "punto marino fuera de GADM terrestre; no constituye verificacion de la localidad")
df$georeferenceRemarks <- agregar_nota(df$georeferenceRemarks, motivo)
df$georeferenceRemarks <- agregar_nota(df$georeferenceRemarks,
  ifelse(!is.na(unc_original) & !publicar_unc,
         paste0("incertidumbre declarada en origen=", origen$coordinateUncertaintyInMeters,
                "; retenida sin publicar porque falta un par equivalente respaldado"), NA_character_))
df$georeferenceRemarks <- agregar_nota(df$georeferenceRemarks,
  ifelse(!is.na(origen$georeferenceVerificationStatus) &
           origen$georeferenceVerificationStatus != df$georeferenceVerificationStatus,
         paste0("estado de verificacion declarado en origen=",
                origen$georeferenceVerificationStatus), NA_character_))

# La transformación informática no determina la autoría histórica ni una aprobación.
transformada <- !sin_coord & !df$metodo_correccion %in% c("original", "original_transfronterizo")
df$georeferenceProtocol <- agregar_nota(df$georeferenceProtocol,
  ifelse(transformada | pendiente_origen, paste0("interpretacion de coordenadas; metodo=", df$metodo_correccion,
                              "; criterio=", criterio_resolucion), NA_character_))
df$georeferenceSources <- agregar_nota(df$georeferenceSources,
  ifelse(!sin_coord, paste0("fuente procesada: ", fuente_coordenada,
                            "; BNDB MECN-DP; referencia territorial GADM 4.1"), NA_character_))
df$georeferencedBy <- origen$georeferencedBy

# ================================================================
# 16. Volcado a Darwin Core
# ================================================================
fmt_coord <- function(x) {
  s <- formatC(x, format = "f", digits = 7)
  s <- sub("0+$", "", s); s <- sub("\\.$", "", s)
  ifelse(is.na(x), NA_character_, s)
}

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

justifica_datum <- !is.na(df$lat_final) & !is.na(epsg_transformacion)
if (!"geodeticDatum_verbatim" %in% names(df)) df$geodeticDatum_verbatim <- NA_character_
preservar_datum <- justifica_datum & is.na(df$geodeticDatum_verbatim)
df$geodeticDatum_verbatim[preservar_datum] <- origen$geodeticDatum[preservar_datum]
df$datum_asumido <- !is.na(datum_interpretacion_asumido)

df$geodeticDatum[justifica_datum] <- "EPSG:4326"

cat("\nVolcado a Darwin Core:\n")
cat("  decimalLatitude poblado :", sum(df$decimalLatitude != ""), "\n")
cat("  filas donde cambió el valor  :", sum(!identico & !is.na(df$lat_final)), "\n")
cat("  filas donde cambió solo el formato:", sum(solo_formato, na.rm = TRUE), "\n")
cat("  origen preservado en verbatimLatitude/verbatimLongitude\n")

# ---- Resumen ----
cat("\n=== MÉTODO DE CORRECCIÓN ===\n");  print(table(df$metodo_correccion, useNA = "ifany"))
cat("\n=== NIVEL DE CONFIANZA ===\n");    print(table(df$confianza_coordenada))
cat("\n=== COHERENCIA CON LA PROVINCIA ===\n")
print(table(df$coherencia_provincia, df$criterio_coherencia, useNA = "ifany"))
cat("\n=== BANDERAS ===\n")
cat("  coordenada compartida entre provincias:", sum(df$coordenada_compartida, na.rm = TRUE), "\n")
cat("  de ellas, en provincia minoritaria    :", sum(df$provincia_minoritaria, na.rm = TRUE), "\n")
cat("  signo ambiguo no resuelto             :", sum(df$signo_ambiguo, na.rm = TRUE), "\n")
cat("  DMS con minuto o segundo >= 60 (origen):", sum(df$dms_rango_invalido, na.rm = TRUE), "\n")
cat("  marcadas para revisión (sospechosas)  :", sum(sospechosa, na.rm = TRUE), "\n")
cat("  con coordenada y sin incertidumbre    :",
    sum(!is.na(df$lat_final) & is.na(df$coordinateUncertaintyInMeters)), "\n")
cat("\n=== COBERTURA ===\n")
cat("  con coordenada:", sum(!is.na(df$lat_final)),
    sprintf("(%.1f%%)\n", 100 * mean(!is.na(df$lat_final))))
cat("  sin coordenada:", sum(is.na(df$lat_final)), "\n")

# ---- 17. Exportación ----
df_export <- df %>% select(-decimalLatitude_num, -decimalLongitude_num, -clave_coord)

df_export$lat_final <- ifelse(is.na(df$lat_final), "", fmt_coord(round(df$lat_final, 6)))
df_export$lon_final <- ifelse(is.na(df$lon_final), "", fmt_coord(round(df$lon_final, 6)))

write_csv(df_export, ARCHIVO_SALIDA, na = "")
cat("\nGuardado en", ARCHIVO_SALIDA, "\n")
