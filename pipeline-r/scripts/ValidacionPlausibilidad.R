# ================================================================
# VALIDACIÓN DE PLAUSIBILIDAD Y CONSISTENCIA INTERNA
# Colección Ictiológica MECN-DP - INABIO
#
# Detecta combinaciones de valores que, siendo válidas campo a campo,
# describen algo imposible o inverosímil al mirarse en conjunto.
# NO CORRIGE NADA. Cada hallazgo se reporta con su severidad y su destino.
#
# Severidad:  alta        = contradicción lógica, no puede ser correcto
#             media       = muy improbable, requiere verificación
#             informativa = patrón a documentar, no necesariamente un error
# Destino:    INABIO      = solo el curador o la etiqueta física lo resuelve
#             propio      = decisión metodológica del autor
#             ya_marcado  = el pipeline ya lo señala, se consolida aquí
# ================================================================
library(readr); library(dplyr); library(tidyr)

ARCHIVO  <- "datos/02_intermedios/ocurrences_con_identifications.csv"
SALIDA   <- "reportes_y_revisiones/reporte_plausibilidad.csv"
RESUMEN  <- "reportes_y_revisiones/reporte_plausibilidad_resumen.csv"
# Fecha de corte fija: con Sys.Date() el reporte deja de ser reproducible y las
# dos colectas de 2027 dejarian de marcarse a partir de ese año.
HOY      <- as.Date("2026-08-23")
ANIO_MIN <- 1900   # limite inferior de plausibilidad para una colecta ecuatoriana documentada.

df <- read_csv(ARCHIVO, col_types = cols(.default = "c"))
num <- function(x) suppressWarnings(as.numeric(x))
vac <- function(x) is.na(x) | trimws(x) == ""
nz  <- function(x) ifelse(is.na(x), "", x)

H <- list()
reg <- function(idx, bloque, regla, campos, valores, severidad, destino) {
  if (!length(idx)) return(invisible())
  H[[length(H) + 1]] <<- tibble(
    catalogNumber = df$catalogNumber[idx], id = df$id[idx],
    bloque = bloque, regla = regla, campos = campos,
    valores = valores, severidad = severidad, destino = destino)
  cat(sprintf("  [%-11s] %-46s %5d\n", severidad, regla, length(idx)))
}

# ---------------------------------------------------------------
# BLOQUE 1 - TEMPORAL
# ---------------------------------------------------------------
cat("\nBLOQUE 1 - Temporal\n")

# Comparación de fechas considerando su granularidad máxima común.
gran <- function(x) ifelse(grepl("^\\d{4}-\\d{2}-\\d{2}$", x), 3L,
                    ifelse(grepl("^\\d{4}-\\d{2}$", x), 2L,
                    ifelse(grepl("^\\d{4}$", x), 1L, 0L)))
ge <- gran(nz(df$eventDate)); gd <- gran(nz(df$dateIdentified))
ok <- ge > 0 & gd > 0
gc <- pmin(ge, gd)
L  <- ifelse(gc == 1L, 4L, ifelse(gc == 2L, 7L, 10L))
idx <- which(ok & substr(nz(df$dateIdentified), 1, L) < substr(nz(df$eventDate), 1, L))
reg(idx, "temporal", "determinado antes de ser colectado",
    "eventDate | dateIdentified",
    paste(df$eventDate[idx], "|", df$dateIdentified[idx]), "alta", "INABIO")

idx <- which(ge > 0 & substr(nz(df$eventDate), 1, 4) > format(HOY, "%Y"))
reg(idx, "temporal", "fecha de colecta en el futuro", "eventDate",
    df$eventDate[idx], "alta", "INABIO")

idx <- which(gd > 0 & substr(nz(df$dateIdentified), 1, 4) > format(HOY, "%Y"))
reg(idx, "temporal", "fecha de determinacion en el futuro", "dateIdentified",
    df$dateIdentified[idx], "alta", "INABIO")

idx <- which(ge > 0 & num(substr(nz(df$eventDate), 1, 4)) < ANIO_MIN)
reg(idx, "temporal", "colecta anterior a la fundacion de la coleccion",
    "eventDate", df$eventDate[idx], "alta", "INABIO")

# Validación temporal: el sello de modificación debe ser posterior a la colecta.
idx <- which(ge > 0 & !vac(df$modified) &
               substr(nz(df$modified), 1, 4) < substr(nz(df$eventDate), 1, 4))
reg(idx, "temporal", "registro modificado antes de la colecta",
    "eventDate | modified",
    paste(df$eventDate[idx], "|", df$modified[idx]), "alta", "INABIO")

# El dcterms:modified de este dataset no es la fecha de modificacion del
# registro: es el sello del lote de exportacion del portal. 4.287 filas comparten
# 2020-01-08 y 1.859 comparten 2025-11-03. La regla producia 1.506 hallazgos, de
# los cuales 1.487 son simplemente registros determinados en 2023 sobre un sello
# de 2020. Se sustituye por la comprobacion que si tiene sentido sobre este campo.
sellos <- table(substr(nz(df$modified), 1, 10))
idx <- which(!vac(df$modified) & !(substr(nz(df$modified), 1, 10) %in%
                                   names(sellos)[sellos >= 10]))
reg(idx, "registro", "sello dcterms:modified fuera de los lotes de carga conocidos",
    "modified", df$modified[idx], "informativa", "propio")

# Discrepancia de año entre eventDate y verbatimEventDate.
av <- ifelse(grepl("^\\d{4}", nz(df$verbatimEventDate)),
             substr(nz(df$verbatimEventDate), 1, 4),
             ifelse(grepl("\\d{4}$", nz(df$verbatimEventDate)),
                    substr(nz(df$verbatimEventDate), nchar(nz(df$verbatimEventDate)) - 3,
                           nchar(nz(df$verbatimEventDate))), NA))
idx <- which(ge > 0 & !is.na(av) & av != substr(nz(df$eventDate), 1, 4))
reg(idx, "temporal", "eventDate y verbatimEventDate con anos distintos",
    "eventDate | verbatimEventDate",
    paste(df$eventDate[idx], "|", df$verbatimEventDate[idx]), "alta", "INABIO")

# Detección de imputación de día (01) por el portal fuente.
idx <- which(grepl("^\\d{4}-\\d{1,2}$", nz(df$verbatimEventDate)) &
               grepl("^\\d{4}-\\d{2}-01$", nz(df$eventDate)))
reg(idx, "temporal", "dia fabricado por el portal (01 sobre verbatim ano-mes)",
    "eventDate | verbatimEventDate | day",
    paste(df$eventDate[idx], "|", df$verbatimEventDate[idx]), "media", "propio")

idx <- which(ge > 0 & vac(df$startDayOfYear))
reg(idx, "temporal", "eventDate parcial sin startDayOfYear (grano no diario)",
    "eventDate | startDayOfYear", df$eventDate[idx], "informativa", "propio")

# Detección estadística de año de colecta atípico por colector (IQR).
tmp <- df %>% mutate(.i = row_number(), anio = num(substr(nz(eventDate), 1, 4))) %>%
  filter(!vac(recordedBy), !is.na(anio)) %>% group_by(recordedBy) %>%
  filter(n() >= 15) %>%
  mutate(q1 = quantile(anio, .25), q3 = quantile(anio, .75),
         r = pmax(q3 - q1, 1)) %>%
  filter(anio < q1 - 1.5 * r | anio > q3 + 1.5 * r) %>% ungroup()
reg(tmp$.i, "temporal", "ano de colecta atipico para el colector",
    "eventDate | recordedBy",
    paste(tmp$eventDate, "|", tmp$recordedBy), "informativa", "propio")

# ---------------------------------------------------------------
# BLOQUE 2 - JERARQUIA GEOGRAFICA
# ---------------------------------------------------------------
cat("\nBLOQUE 2 - Jerarquia geografica\n")

# Función auxiliar para marcar solo filas minoritarias en discrepancias jerárquicas.
min_fila <- function(clave, valor) {
  may <- df %>% filter(!vac(.data[[clave]]), !vac(.data[[valor]])) %>%
    count(.data[[clave]], .data[[valor]], name = "n") %>%
    arrange(.data[[clave]], desc(n)) %>% group_by(.data[[clave]]) %>%
    slice_head(n = 1) %>% ungroup() %>% setNames(c(clave, "may", "n"))
  j <- left_join(df[c(clave, valor)], may[c(clave, "may")], by = clave)
  which(!vac(j[[valor]]) & !is.na(j$may) & j[[valor]] != j$may)
}

# Excepciones de jerarquía geográfica por reasignación territorial histórica (ej. La Concordia).
VIGENCIA <- tibble::tribble(
  ~county,         ~stateProvince,                   ~anio_hasta, ~anio_desde,
  "La Concordia",  "Esmeraldas",                     2007L,       NA_integer_,
  "La Concordia",  "Santo Domingo de los Tsáchilas", NA_integer_, 2007L)

anio_col <- num(substr(nz(df$eventDate), 1, 4))
vigente  <- rep(FALSE, nrow(df))
for (k in seq_len(nrow(VIGENCIA))) {
  sel <- df$county == VIGENCIA$county[k] & df$stateProvince == VIGENCIA$stateProvince[k] &
         !is.na(anio_col)
  if (!is.na(VIGENCIA$anio_hasta[k])) sel <- sel & anio_col <= VIGENCIA$anio_hasta[k]
  if (!is.na(VIGENCIA$anio_desde[k])) sel <- sel & anio_col >= VIGENCIA$anio_desde[k]
  vigente[which(sel)] <- TRUE
}
idx <- setdiff(min_fila("county", "stateProvince"), which(vigente))
reg(idx, "geografia", "canton asociado a dos provincias distintas",
    "county | stateProvince",
    paste(df$county[idx], "|", df$stateProvince[idx]), "alta", "INABIO")

idx <- which(!vac(df$municipality) & vac(df$county))
reg(idx, "geografia", "parroquia declarada sin canton", "municipality | county",
    df$municipality[idx], "media", "INABIO")

# Orellana es cabecera cantonal de su propia provincia (Puerto Francisco de
# Orellana). Su ausencia generaba 196 falsos positivos de severidad media.
CANTON_HOMONIMO_LEGITIMO <- c("Pastaza", "Esmeraldas", "Sucumbíos", "Loja", "Orellana",
                              "Cañar", "Santa Elena", "Bolívar", "Carchi", "Napo")

idx <- which(!vac(df$county) & df$county == df$stateProvince &
             !(df$county %in% CANTON_HOMONIMO_LEGITIMO))
reg(idx, "geografia", "nombre de provincia usado como canton",
    "county | stateProvince", df$county[idx], "media", "INABIO")

idx <- which(!vac(df$county) & df$county == df$stateProvince &
             df$county %in% CANTON_HOMONIMO_LEGITIMO)
reg(idx, "geografia", "canton homonimo de su provincia (verificado, no es error)",
    "county | stateProvince", df$county[idx], "informativa", "propio")

idx <- which(!vac(df$county) & df$county == df$municipality)
reg(idx, "geografia", "mismo valor en canton y parroquia",
    "county | municipality", df$county[idx], "informativa", "INABIO")

idx <- which(!vac(df$municipality) & df$municipality == df$locality)
reg(idx, "geografia", "parroquia repetida como localidad",
    "municipality | locality", df$municipality[idx], "informativa", "propio")

idx <- which(!vac(df$locality) & df$locality == df$locationRemarks)
reg(idx, "geografia", "locality y locationRemarks identicos",
    "locality | locationRemarks", df$locality[idx], "informativa", "propio")

# Detección de descripción de sitio desplazada al campo locationRemarks.
idx <- which(vac(df$locality) & !vac(df$locationRemarks))
reg(idx, "geografia", "locality vacia con locationRemarks poblada",
    "locality|locationRemarks", df$locationRemarks[idx], "media", "propio")

# Detección de coordenadas UTM o altitud (msnm) embebidas en la localidad.
idx <- which(grepl("\\d{1,2}\\s*[NS]\\s*\\d{5,7}\\s*/\\s*\\d{6,8}", nz(df$locality)) |
             grepl("msnm", nz(df$locality), ignore.case = TRUE))
reg(idx, "geografia", "coordenada o altitud embebida en el texto de localidad",
    "locality", df$locality[idx], "media", "propio")

# ---------------------------------------------------------------
# BLOQUE 3 - ECOLOGIA Y BIOGEOGRAFIA
# Validación de combinaciones inverosímiles (campos válidos individualmente).
# ---------------------------------------------------------------
cat("\nBLOQUE 3 - Ecologia y biogeografia\n")

# Detección de familias marinas reportadas en provincias amazónicas.
FAM_MARINAS <- c("Sphyrnidae","Gempylidae","Scorpaenidae","Muraenesocidae",
                 "Paralichthyidae","Haemulidae","Serranidae","Epinephelidae","Carangidae",
                 "Scombridae","Lutjanidae","Centropomidae","Aulopidae","Urotrygonidae",
                 "Narcinidae","Triglidae","Bothidae","Cynoglossidae","Trichiuridae",
                 "Priacanthidae","Sparidae","Polynemidae","Muraenidae","Ophichthidae",
                 "Balistidae","Diodontidae","Ostraciidae","Acanthuridae","Kyphosidae",
                 "Mullidae","Holocentridae","Apogonidae","Blenniidae","Labrisomidae",
                 "Antennariidae","Fistulariidae","Albulidae","Elopidae","Batrachoididae",
                 "Syngnathidae","Chaetodontidae","Labridae","Pomacentridae","Monacanthidae",
                 "Gerreidae","Sphyraenidae","Stromateidae","Malacanthidae","Coryphaenidae")
AMAZONIA <- c("Orellana","Sucumbios","Sucumbíos","Napo","Pastaza",
              "Morona Santiago","Zamora Chinchipe")
PACIFICO <- c("Esmeraldas","Manabi","Manabí","Guayas","El Oro","Santa Elena",
              "Los Rios","Los Ríos","Santo Domingo de los Tsachilas",
              "Santo Domingo de los Tsáchilas")

idx <- which(df$family %in% FAM_MARINAS & df$stateProvince %in% AMAZONIA)
reg(idx, "ecologia", "familia estrictamente marina en provincia amazonica",
    "family | stateProvince | scientificName",
    paste(df$scientificName[idx], "|", df$family[idx], "|", df$stateProvince[idx]),
    "alta", "INABIO")

# Registro solitario de una especie transandina en una vertiente anómala.
tmp <- df %>% mutate(.i = row_number(),
                     vert = ifelse(stateProvince %in% AMAZONIA, "amazonia",
                                   ifelse(stateProvince %in% PACIFICO, "pacifico", NA))) %>%
  filter(taxonRank == "species", !is.na(vert)) %>% group_by(scientificName) %>%
  filter(n_distinct(vert) == 2) %>%
  ungroup() %>%
  mutate(n_v = n(), .by = c(scientificName, vert)) %>%
  filter(n_v == 1)
reg(tmp$.i, "ecologia", "unico registro de la especie en esa vertiente",
    "scientificName | stateProvince",
    paste(tmp$scientificName, "|", tmp$stateProvince), "media", "INABIO")

# Detección estadística de altitud anómala para la especie (cálculo de MAD).
tmp <- df %>% mutate(.i = row_number(), el = num(minimumElevationInMeters)) %>%
  filter(taxonRank == "species", !is.na(el)) %>% group_by(scientificName) %>%
  filter(n() >= 12) %>%
  mutate(med = median(el), mad = pmax(median(abs(el - med)), 50)) %>%
  filter(abs(el - med) > 6 * mad) %>% ungroup()
reg(tmp$.i, "ecologia", "altitud fuera del rango de la especie en la coleccion",
    "scientificName | minimumElevationInMeters",
    paste(tmp$scientificName, "|", tmp$el, "m | mediana", round(tmp$med), "m"),
    "media", "INABIO")

# ---------------------------------------------------------------
# BLOQUE 4 - INTEGRIDAD DE LA JERARQUIA TAXONOMICA
# ---------------------------------------------------------------
cat("\nBLOQUE 4 - Integridad taxonomica\n")

# Eliminado el cálculo redundante de familia u orden minoritario 
# (ya cubierto por las banderas de LimpiezaFishbase.R).

tm <- df %>% filter(!vac(taxonID), !vac(scientificName)) %>%
  distinct(taxonID, scientificName) %>% count(taxonID) %>% filter(n > 1) %>% pull(taxonID)
nm <- df %>% filter(!vac(taxonID), !vac(scientificName)) %>%
  distinct(taxonID, scientificName) %>% count(scientificName) %>% filter(n > 1) %>%
  pull(scientificName)

idx_tm <- which(df$taxonID %in% tm)
idx_nm <- which(df$scientificName %in% nm)
idx_tax <- union(idx_tm, idx_nm)

if (length(idx_tax)) {
  sub_tax <- rep("", length(idx_tax))
  sub_tax[idx_tax %in% idx_tm & idx_tax %in% idx_nm] <- "ambos (cruce multiple)"
  sub_tax[idx_tax %in% idx_tm & !(idx_tax %in% idx_nm)] <- "taxonID apunta a varios nombres"
  sub_tax[idx_tax %in% idx_nm & !(idx_tax %in% idx_tm)] <- "nombre con varios taxonID"
  
  # Reporte unificado de colisiones entre taxonID y scientificName.
  reg(idx_tax, "taxonomia", "inconsistencia (cruce) entre taxonID y scientificName",
      "taxonID | scientificName | subtipo",
      paste(df$taxonID[idx_tax], "|", df$scientificName[idx_tax], "|", sub_tax), "media", "INABIO")
}

# Detección de cualificador "sp." acompañando a un binomio completo.
idx <- which(df$identificationQualifier == "sp." & df$taxonRank == "species")
reg(idx, "taxonomia", "cualificador sp. sobre un binomio completo",
    "scientificName|identificationQualifier|taxonRank",
    paste(df$scientificName[idx], "+", df$identificationQualifier[idx]), "media", "INABIO")

# Consolidacion de las banderas que el pipeline ya produce.
# Colapsar solapes anidados de jerarquia (3.3b)
if (all(c("flag_family_minoritaria", "flag_family_orden_discrepante", "flag_orden_minoritario_en_familia", "flag_family_minoritaria_en_el_nombre") %in% names(df))) {
  idx_fm <- which(toupper(nz(df$flag_family_minoritaria)) == "TRUE")
  idx_fo <- which(toupper(nz(df$flag_family_orden_discrepante)) == "TRUE")
  idx_of <- which(toupper(nz(df$flag_orden_minoritario_en_familia)) == "TRUE")
  idx_fn <- which(toupper(nz(df$flag_family_minoritaria_en_el_nombre)) == "TRUE")
  
  idx_fam <- union(idx_fm, union(idx_fo, union(idx_of, idx_fn)))
  if (length(idx_fam)) {
    sub_f <- rep("", length(idx_fam))
    sub_f[idx_fam %in% idx_fo] <- "familia minoritaria de otro orden"
    sub_f[idx_fam %in% idx_fm & !(idx_fam %in% idx_fo)] <- "familia minoritaria del mismo orden"
    sub_f[idx_fam %in% idx_of & !(idx_fam %in% idx_fm)] <- "orden minoritario en la familia"
    sub_f[idx_fam %in% idx_fn & !(idx_fam %in% c(idx_fm, idx_fo, idx_of))] <- "familia minoritaria en el nombre"
    
    reg(idx_fam, "taxonomia", "jerarquia superior minoritaria o discrepante",
        "scientificName | subtipo", paste(nz(df$scientificName[idx_fam]), "|", sub_f),
        "media", "ya_marcado")
  }
}

banderas <- c(flag_genus_no_coincide_con_nombre    = "genus no coincide con el binomio",
              flag_epiteto_no_coincide_con_nombre  = "epiteto no coincide con el binomio",
              flag_sin_taxonomia                   = "registro sin ningun dato taxonomico",
              registro_incompleto                  = "registro sin metadatos de colecta")
for (b in names(banderas)) {
  if (!b %in% names(df)) next
  idx <- which(toupper(nz(df[[b]])) == "TRUE")
  reg(idx, "taxonomia", banderas[[b]], b, nz(df$scientificName[idx]),
      "media", "ya_marcado")
}

# ---------------------------------------------------------------
# BLOQUE 5 - REGISTRO Y COLECTA
# ---------------------------------------------------------------
cat("\nBLOQUE 5 - Registro y colecta\n")

idx <- which(vac(df$individualCount))
reg(idx, "registro", "sin numero de individuos", "individualCount", "", "media", "INABIO")

# Detección de tipos nomenclaturales sin datos de colecta (ej. holotipos huecos).
idx <- which(nz(df$typeStatus) != "" &
             (vac(df$recordedBy) | vac(df$eventDate) | vac(df$locality)))
reg(idx, "registro", "tipo nomenclatural sin datos de colecta",
    "typeStatus|recordedBy|eventDate|locality", df$typeStatus[idx], "alta", "INABIO")

idx <- which(!vac(df$individualCount) & num(df$individualCount) == 0)
reg(idx, "registro", "numero de individuos igual a cero", "individualCount",
    df$individualCount[idx], "alta", "INABIO")

ic <- num(df$individualCount)
lim <- quantile(ic, .75, na.rm = TRUE) + 3 * IQR(ic, na.rm = TRUE)
idx <- which(!is.na(ic) & ic > max(lim, 200))
reg(idx, "registro", "lote con numero de individuos atipicamente alto",
    "individualCount", df$individualCount[idx], "informativa", "INABIO")

idx <- which(!vac(df$maximumElevationInMeters) & vac(df$minimumElevationInMeters))
reg(idx, "registro", "altitud maxima declarada sin altitud minima",
    "minimumElevationInMeters | maximumElevationInMeters",
    df$maximumElevationInMeters[idx], "media", "propio")

idx <- which(!vac(df$minimumElevationInMeters) & !vac(df$maximumElevationInMeters) &
               num(df$minimumElevationInMeters) > num(df$maximumElevationInMeters))
reg(idx, "registro", "altitud minima mayor que la maxima",
    "minimumElevationInMeters | maximumElevationInMeters",
    paste(df$minimumElevationInMeters[idx], "|", df$maximumElevationInMeters[idx]),
    "alta", "INABIO")

# Detección de instituciones o proyectos ingresados en recordedBy.
NO_PERSONAS <- c("QCAZ","GLOWS","Gueppi","Simbioe","Indigenas","Indígenas","JVDC")
patron <- paste0("(^|\\| )(", paste(NO_PERSONAS, collapse = "|"), ")( \\||$)")
idx <- which(grepl(patron, nz(df$recordedBy)))
reg(idx, "registro", "institucion o proyecto en el campo de colector",
    "recordedBy", df$recordedBy[idx], "media", "INABIO")

# Detección de colectores reducidos a iniciales, sin nombre desarrollado.
idx <- which(grepl("(^|\\| )[A-Z]\\.([A-Z]\\.)+( \\||$)", nz(df$recordedBy)))
reg(idx, "registro", "colector reducido a iniciales sin nombre desarrollado",
    "recordedBy", df$recordedBy[idx], "media", "INABIO")

# Detección de registros con igual punto, fecha y especie (posible lote o duplicación).
tmp <- df %>% mutate(.i = row_number()) %>%
  filter(!vac(decimalLatitude), !vac(eventDate), !vac(scientificName)) %>%
  group_by(decimalLatitude, decimalLongitude, eventDate, scientificName) %>%
  filter(n() > 1) %>% ungroup()
reg(tmp$.i, "registro", "mismo punto, fecha y especie en varios catalogos",
    "decimalLatitude | eventDate | scientificName",
    paste(tmp$scientificName, "|", tmp$eventDate), "informativa", "INABIO")

# ---------------------------------------------------------------
# BLOQUE 5b - VOCABULARIOS CONTROLADOS DE DARWIN CORE
# Detección de términos fuera de vocabularios controlados (para evitar descartes silenciosos).
# ---------------------------------------------------------------
cat("\nBLOQUE 5b - Vocabularios controlados\n")

VOC <- list(
  establishmentMeans = c("native","nativeReintroduced","introduced",
                         "introducedAssistedColonisation","vagrant","uncertain"),
  basisOfRecord      = c("PreservedSpecimen","FossilSpecimen","LivingSpecimen",
                         "MaterialSample","HumanObservation","MachineObservation",
                         "MaterialCitation","Occurrence"),
  occurrenceStatus   = c("present","absent"),
  taxonRank          = c("kingdom","phylum","class","order","family","subfamily",
                         "genus","subgenus","species","subspecies","variety","form"),
  sex                = c("female","male","hermaphrodite","undetermined"))

for (campo in names(VOC)) {
  if (!campo %in% names(df)) next
  v <- nz(df[[campo]])
  # Los campos multivalor se evaluan termino a termino.
  fuera <- vapply(strsplit(v, "\\s*\\|\\s*"), function(p) {
    p <- p[p != ""]
    length(p) > 0 && any(!(p %in% VOC[[campo]]))
  }, logical(1))
  idx <- which(fuera)
  reg(idx, "vocabulario",
      paste0(campo, " fuera del vocabulario controlado de Darwin Core"),
      campo, df[[campo]][idx], "media", "propio")
}

# ---------------------------------------------------------------
# BLOQUE 6 - COORDENADAS (consolidacion, no recalculo)
# ---------------------------------------------------------------
cat("\nBLOQUE 6 - Coordenadas\n")
if ("coherencia_provincia" %in% names(df)) {
  idx <- which(df$coherencia_provincia == "discordante")
  reg(idx, "coordenadas", "coordenada fuera de la provincia declarada",
      "coherencia_provincia | dist_fuera_provincia_km",
      paste(df$stateProvince[idx], "|", nz(df$dist_fuera_provincia_km[idx]), "km"),
      "alta", "INABIO")
  idx <- which(toupper(nz(df$signo_ambiguo)) == "TRUE")
  reg(idx, "coordenadas", "signo de la coordenada no resuelto", "signo_ambiguo",
      nz(df$verbatimCoordinates[idx]), "alta", "INABIO")
  idx <- which(toupper(nz(df$dms_rango_invalido)) == "TRUE" & !vac(df$decimalLatitude))
  reg(idx, "coordenadas", "coordenada derivada de un DMS fuera de rango",
      "dms_rango_invalido", nz(df$verbatimCoordinates[idx]), "alta", "INABIO")
  idx <- which(df$metodo_correccion %in% c("irreparable", "descartada_fuera_de_rango"))
  reg(idx, "coordenadas", "coordenada irrecuperable", "metodo_correccion",
      nz(df$verbatimCoordinates[idx]), "media", "INABIO")
      
  # Consolidación de coordenada compartida en provincia minoritaria.
  if ("provincia_minoritaria" %in% names(df)) {
    idx <- which(df$provincia_minoritaria == "TRUE")
    reg(idx, "coordenadas", "coordenada compartida y provincia minoritaria",
        "stateProvince|decimalLatitude|decimalLongitude",
        paste(df$stateProvince[idx], df$decimalLatitude[idx], df$decimalLongitude[idx]), "alta", "INABIO")
  }
}

# Detección de puntos marinos con continente declarado (aviso esperado en GBIF).
idx <- which(!vac(df$continent) & df$coherencia_provincia == "fuera_de_tierra_firme")
reg(idx, "coordenadas", "continent declarado sobre coordenada marina (aviso GBIF esperado)",
    "continent | coherencia_provincia", df$continent[idx], "informativa", "propio")

# ---------------------------------------------------------------
# OPCIONAL - Altitud declarada contra el modelo digital de elevacion.
# Requiere internet y el paquete elevatr.
# ---------------------------------------------------------------
USAR_DEM <- FALSE
if (USAR_DEM) {
  library(elevatr); library(sf)
  sub <- df %>% mutate(.i = row_number()) %>%
    filter(!vac(decimalLatitude), !vac(minimumElevationInMeters))
  pts <- st_as_sf(sub, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)
  pts <- get_elev_point(pts, src = "aws", z = 10)
  d   <- abs(num(sub$minimumElevationInMeters) - pts$elevation)
  reg(sub$.i[which(d > 300)], "ecologia",
      "altitud declarada discrepa del DEM en mas de 300 m",
      "minimumElevationInMeters | DEM",
      paste(sub$minimumElevationInMeters[which(d > 300)], "vs",
            round(pts$elevation[which(d > 300)]), "m"), "media", "INABIO")
}

# ---------------------------------------------------------------
# BLOQUE 7 - SIMILITUD ORTOGRAFICA DENTRO DE LA MISMA COLUMNA
# Detección de posibles erratas (distancia Levenshtein = 1) con frecuencias dispares.
# ---------------------------------------------------------------
cat("\nBLOQUE 7 - Similitud ortografica\n")

norm_txt <- function(x) tolower(iconv(x, to = "ASCII//TRANSLIT"))
lev1 <- function(a, b) abs(nchar(a) - nchar(b)) <= 1 &&
                       adist(a, b, ignore.case = TRUE)[1, 1] <= 1

# La clave se construye con sort(), asi que los pares tienen que ir en orden
# alfabetico. Tres de los cinco no coincidian y seguian generando 34 filas.
PARES_VERIFICADOS <- c("mera~mira", "cynodontidae~synodontidae", "conodon~cynodon",
                       "anodus~knodus", "taracoa~tarapoa",
                       # pares nuevos verificados en las columnas anadidas al bloque 7
                       "noreste de taracoa~noreste de tarapoa",
                       "sureste de dureno~suroeste de dureno",
                       "antes del armadillo a 18m~antes del armadillo b 18m",
                       "rio mindo~rio pindo",
                       "chaetostoma marginatum~chaetostoma marginatus",
                       "loricariidae~loricariinae")
par_verificado <- function(a, b) {
  paste(sort(c(norm_txt(a), norm_txt(b))), collapse = "~") %in% PARES_VERIFICADOS
}

# scientificName es la columna donde estaban los 15 pares de epiteto corregidos:
# ejecutar la regla despues de la correccion devuelve solo los 3 casos declarados
# no decidibles, lo que verifica el parche. locality, locationRemarks y
# recordedBy necesitan el filtro de digito, porque las series numeradas de
# estacion (Pindo 2 ~ Pindo 4, Yuca Sur 1 ~ Yuca Sur 2) inundan el resultado.
solo_digito <- function(a, b) gsub("[0-9]", "#", a) == gsub("[0-9]", "#", b)

for (col in c("genus", "family", "scientificName", "county", "municipality",
              "stateProvince", "locality", "locationRemarks", "recordedBy")) {
  v <- table(df[[col]][!vac(df[[col]])])
  u <- names(v)
  if (length(u) < 2) next
  for (i in seq_along(u)) for (j in seq_len(i - 1)) {
    if (norm_txt(u[i]) == norm_txt(u[j])) next
    if (par_verificado(u[i], u[j])) next
    if (solo_digito(u[i], u[j])) next
    if (!lev1(norm_txt(u[i]), norm_txt(u[j]))) next
    raro <- if (v[[i]] <= v[[j]]) u[i] else u[j]
    comun <- if (v[[i]] <= v[[j]]) u[j] else u[i]
    idx <- which(df[[col]] == raro)
    reg(idx, "ortografia", paste0("valor a una letra de otro valor de ", col),
        col, paste0(raro, " (", v[[raro]], ") ~ ", comun, " (", v[[comun]], ")"),
        "media", "INABIO")
  }
}

# ---------------------------------------------------------------
# SALIDA
# ---------------------------------------------------------------
rep <- bind_rows(H) %>%
  mutate(severidad = factor(severidad, c("alta", "media", "informativa"))) %>%
  arrange(severidad, bloque, regla, catalogNumber)

# Exportación separada de reglas verificadas (falsos positivos documentados).
reglas_verificadas <- c("canton homonimo de su provincia (verificado, no es error)",
                        "continent declarado sobre coordenada marina (aviso GBIF esperado)")

rep_verificadas <- rep %>% filter(regla %in% reglas_verificadas)
rep <- rep %>% filter(!(regla %in% reglas_verificadas))

write_csv(rep_verificadas, "reportes_y_revisiones/reporte_plausibilidad_verificadas.csv", na = "")
write_csv(rep, SALIDA, na = "")

# Agrupación de filas en casos únicos para el reporte de curación.
resumen_regla <- rep %>%
  group_by(bloque, regla, severidad, destino) %>%
  summarise(filas = n(),
            registros = n_distinct(catalogNumber),
            casos = n_distinct(valores),
            .groups = "drop") %>%
  arrange(destino, desc(severidad), desc(casos))

write_csv(resumen_regla, "reportes_y_revisiones/reporte_plausibilidad_resumen.csv", na = "")
cat("\n=== RESUMEN POR REGLA ===\n"); print(as.data.frame(resumen_regla))
cat("\nRegistros con al menos un hallazgo:", n_distinct(rep$catalogNumber),
    sprintf("(%.1f%% de la coleccion)\n", 100 * n_distinct(rep$catalogNumber) / nrow(df)))
cat("Reglas distintas:", n_distinct(rep$regla),
    "| casos distintos a resolver:", n_distinct(paste(rep$regla, rep$valores)), "\n")
cat("\nGuardado en", SALIDA, "\n")