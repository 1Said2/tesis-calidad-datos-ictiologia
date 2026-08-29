# ================================================================
# 3/4 - INTEGRACIÓN DE identifications.csv AL CORE
# Colección Ictiológica MECN-DP - INABIO
#
# Entrada:  ocurrences_salida_taxonomia.csv  (salida de Fishbase.R)
#           identifications.csv              (crudo de Symbiota)
# Salida:   ocurrences_con_identifications.csv  -> ValidacionPlausibilidad.R
#           identifications_para_inabio.csv     -> oficio al curador
# ================================================================
library(readr); library(dplyr)

CORE   <- "datos/02_intermedios/ocurrences_salida_taxonomia.csv"
IDENT  <- "datos/01_crudos/identifications.csv"
SALIDA <- "datos/02_intermedios/ocurrences_con_identifications.csv"
PENDIENTE <- "reportes_y_revisiones/identifications_para_inabio.csv"

df <- read_csv(CORE,  col_types = cols(.default = "c"))
id <- read_csv(IDENT, col_types = cols(.default = "c"))

nz  <- function(x) ifelse(is.na(x), "", x)
# Normaliza strings: reemplaza espacios duros (\u00a0) y colapsa blancos.
nrm <- function(x) {
  x <- gsub("\u00a0", " ", nz(x), fixed = TRUE)
  trimws(gsub("\\s+", " ", x, perl = TRUE))
}
vac <- function(x) nrm(x) == ""

# Alinear identifications al core por clave primaria (coreid -> id).
id <- id[match(df$id, id$coreid), ]
stopifnot(identical(nrm(id$coreid), nrm(df$id)))
motivo <- rep(NA_character_, nrow(df))

# ---- 1. Importación selectiva: solo campos vacíos en el core ----
# Descarta placeholders ("undefined", "unknown", etc.) y fechas en campos de texto.
NO_COPIABLE <- c("undefined", "unpublised", "unknown", "sin datos", "s.d.", "na", "null")
copiable <- function(v) !vac(v) & !(tolower(nrm(v)) %in% NO_COPIABLE) &
  !grepl("^\\d{4}-\\d{2}-\\d{2}$", nrm(v))

# Solo importar autoría si ambas tablas declaran el mismo nombre científico.
# Compara contra scientificName_verbatim para no penalizar correcciones propias.
mismo_nombre <- tolower(nrm(id$scientificName)) ==
                tolower(nrm(df$scientificName_verbatim))

i_aut <- which(vac(df$scientificNameAuthorship) &
               copiable(id$scientificNameAuthorship) & mismo_nombre)
i_aut_rechazada <- which(vac(df$scientificNameAuthorship) &
                         copiable(id$scientificNameAuthorship) & !mismo_nombre)

df$autoria_rechazada_de_identifications <- ""
df$autoria_rechazada_de_identifications[i_aut_rechazada] <-
  nrm(id$scientificNameAuthorship[i_aut_rechazada])
df$nombre_de_esa_autoria <- ""
df$nombre_de_esa_autoria[i_aut_rechazada] <- nrm(id$scientificName[i_aut_rechazada])

cat("autorias NO importadas por pertenecer a otro nombre:",
    length(i_aut_rechazada), "\n")
print(tibble(catalogNumber = df$catalogNumber[i_aut_rechazada],
             core  = nrm(df$scientificName_verbatim[i_aut_rechazada]),
             ident = nrm(id$scientificName[i_aut_rechazada]),
             autoria = nrm(id$scientificNameAuthorship[i_aut_rechazada])), n = 25)

# Normalizar autorías importadas (and -> &, insertar coma antes del año).
aut_norm <- gsub("\\band\\b", "&", nrm(id$scientificNameAuthorship[i_aut]))
aut_norm <- sub("([A-Za-zÀ-ÿ\\.\\)])\\s+(\\d{4})", "\\1, \\2", aut_norm)
aut_norm <- trimws(gsub("\\s+", " ", aut_norm))
cat("  autorias normalizadas con la regla del core (and -> &):",
    sum(aut_norm != nrm(id$scientificNameAuthorship[i_aut])), "\n")
df$scientificNameAuthorship[i_aut] <- aut_norm

# identifiedBy: descartar valores no copiables.
i_ide_descartado <- which(vac(df$identifiedBy) & !vac(id$identifiedBy) &
                          !copiable(id$identifiedBy))
cat("identifiedBy de identifications descartados por placeholder:",
    length(i_ide_descartado), "\n")
cat("  valores:", paste(unique(nrm(id$identifiedBy[i_ide_descartado])), collapse = " | "), "\n")

# dateIdentified: valores inútiles, no se importan.
i_fec <- which(vac(df$dateIdentified) & !vac(id$dateIdentified))
cat("dateIdentified NO importados:", length(i_fec), "->",
    paste(names(table(tolower(nrm(id$dateIdentified[i_fec])))),
          table(tolower(nrm(id$dateIdentified[i_fec]))),
          sep = ": ", collapse = " | "), "\n")
cat("recordID y tidInterpreted de identifications descartados: no aplican al core\n")

# identificationQualifier: pertenece al acto de determinación original, no al core.
i_qua <- which(vac(df$identificationQualifier) & copiable(id$identificationQualifier))
cat("identificationQualifier NO importados (pertenecen a otra determinacion):",
    length(i_qua), "\n")
motivo[i_qua] <- ifelse(is.na(motivo[i_qua]),
  "identifications trae cualificador de su propia determinacion, incompatible con el nombre del core",
  motivo[i_qua])

cat("scientificNameAuthorship tomados de identifications:", length(i_aut), "\n")

# ---- 1b. Importar determinación a nivel familia si el core está vacío ----
i_432 <- which(vac(df$scientificName) & copiable(id$scientificName) &
               grepl("(idae|inae)$", nrm(id$scientificName)))
if (length(i_432)) {
  df$scientificName[i_432] <- nrm(id$scientificName[i_432])
  df$family[i_432]         <- nrm(id$scientificName[i_432])
  df$taxonRank[i_432]      <- "family"
  df$identificado_a_nivel_familia[i_432] <- "TRUE"
  df$flag_sin_taxonomia[i_432]           <- "FALSE"
  cat("determinacion a nivel de familia tomada de identifications:",
      length(i_432), "-> catalogos", paste(df$catalogNumber[i_432], collapse = ", "), "\n")

  # Derivar jerarquía superior desde filas hermanas de la misma familia.
  for (k in i_432) {
    fam <- df$family[k]
    hn  <- which(df$family == fam & df$order != "" & seq_len(nrow(df)) != k)
    if (!length(hn)) next
    moda <- function(v) names(sort(table(v[v != ""]), decreasing = TRUE))[1]
    df$order[k]   <- moda(df$order[hn])
    df$class[k]   <- moda(df$class[hn])
    df$kingdom[k] <- moda(df$kingdom[hn])
    df$phylum[k]  <- moda(df$phylum[hn])
    v <- c(df$kingdom[k], df$phylum[k], df$class[k], df$order[k])
    df$higherClassification[k] <- paste(v[v != ""], collapse = "|")
    df$metodo_correccion_taxon[k] <- ifelse(
      is.na(df$metodo_correccion_taxon[k]) | df$metodo_correccion_taxon[k] == "",
      "jerarquia_derivada_de_la_familia_importada",
      paste(df$metodo_correccion_taxon[k],
            "jerarquia_derivada_de_la_familia_importada", sep = "|"))
  }
  # Recalcular occurrenceStatus tras la importación.
  df$occurrenceStatus <- ifelse(df$registro_incompleto == "TRUE" |
                                df$flag_sin_taxonomia  == "TRUE", "", "present")
  cat("  jerarquia derivada para la determinacion importada:", length(i_432), "\n")
  cat("  occurrenceStatus recalculado tras la importacion:",
      sum(df$occurrenceStatus != ""), "\n")
}

# ---- 2. previousIdentifications ----
# Condición: nombre difiere Y fecha de identifications es estrictamente anterior.
gran <- function(x) ifelse(grepl("^\\d{4}-\\d{2}-\\d{2}$", x), 3L,
                           ifelse(grepl("^\\d{4}-\\d{2}$", x), 2L,
                                  ifelse(grepl("^\\d{4}$", x), 1L, 0L)))
d_id  <- nrm(id$dateIdentified)
d_cor <- nrm(df$dateIdentified)
g_id  <- gran(d_id); g_cor <- gran(d_cor)
L     <- ifelse(pmin(g_id, g_cor) == 1L, 4L, ifelse(pmin(g_id, g_cor) == 2L, 7L, 10L))

# Compara contra verbatim para no penalizar correcciones ortográficas propias.
nombre_core_origen <- nrm(df$scientificName_verbatim)
nombre_difiere <- copiable(id$scientificName) & !vac(nombre_core_origen) &
  nrm(id$scientificName) != nombre_core_origen &
  tolower(nrm(id$scientificName)) != tolower(nombre_core_origen)

fecha_anterior <- g_id > 0 & g_cor > 0 &
  substr(d_id, 1, L) < substr(d_cor, 1, L)

# Descartar truncamientos (nombre anterior es prefijo del actual).
truncamiento <- mapply(function(a, b) nchar(a) > 0 && startsWith(b, paste0(a, " ")),
                       nrm(id$scientificName), nombre_core_origen)
i_prev <- which(nombre_difiere & fecha_anterior & !truncamiento)
cat("  descartadas por truncamiento pese a tener fecha anterior:",
    sum(nombre_difiere & fecha_anterior & truncamiento), "\n")
if (!"previousIdentifications" %in% names(df)) df$previousIdentifications <- NA_character_
df$previousIdentifications[i_prev] <- nrm(id$scientificName[i_prev])
cat("previousIdentifications escritas (fecha anterior probada):", length(i_prev), "\n")

# ---- 3. Exportación de discrepancias para revisión manual (oficio INABIO) ----
add_motivo <- function(v, idx, txt) {
  if (!length(idx)) return(v)
  v[idx] <- ifelse(is.na(v[idx]), txt, paste(v[idx], txt, sep = "; ")); v
}
motivo <- add_motivo(motivo,
  which(nombre_difiere & !fecha_anterior & g_id > 0 & g_cor > 0 &
        substr(d_id, 1, L) == substr(d_cor, 1, L)),
  "misma fecha: mismo acto con dos nombres")
motivo <- add_motivo(motivo, which(nombre_difiere & (g_id == 0 | g_cor == 0)),
  "sin fecha comparable en identifications")
motivo <- add_motivo(motivo,
  which(!vac(id$scientificName) & tolower(nrm(id$scientificName)) == "undefined"),
  "identifications trae el texto literal undefined")

fecha_posterior <- g_id > 0 & g_cor > 0 & substr(d_id, 1, L) > substr(d_cor, 1, L)
motivo <- add_motivo(motivo, which(nombre_difiere & fecha_posterior),
  "identifications trae una determinacion POSTERIOR: el core seria el desactualizado")
motivo <- add_motivo(motivo, which(nombre_difiere & truncamiento),
  "identifications trae el nombre truncado, no una determinacion anterior")

# Verificación: toda diferencia debe tener un destino (previousIdentifications o motivo).
sin_destino <- setdiff(which(nombre_difiere & is.na(motivo)), i_prev)
if (length(sin_destino)) {
  cat("ATENCION - diferencias sin destino asignado:", length(sin_destino), "\n")
  print(df$catalogNumber[sin_destino])
}
stopifnot(length(sin_destino) == 0)

solo_prev <- setdiff(i_prev, which(!is.na(motivo)))
ambos     <- intersect(i_prev, which(!is.na(motivo)))
solo_ofi  <- setdiff(which(nombre_difiere & !is.na(motivo)), i_prev)
cat("particion de los", sum(nombre_difiere), "nombres distintos:",
    length(solo_prev), "solo previa +", length(ambos), "previa y ademas al oficio +",
    length(solo_ofi), "solo al oficio =",
    length(solo_prev) + length(ambos) + length(solo_ofi), "\n")

# Incluir autorías rechazadas en el grupo pendiente para el curador.
i_pend <- sort(union(which(!is.na(motivo)), i_aut_rechazada))
motivo <- add_motivo(motivo, i_aut_rechazada,
  "identifications trae la autoria de un nombre distinto al del core; no se importa")

# ---- 3b. Incorporar motivo al archivo de salida (para drill-through en tablero) ----
en_pend <- seq_len(nrow(df)) %in% i_pend
df$flag_pendiente_identifications <- en_pend
df$motivo_identifications         <- ifelse(is.na(motivo), "", motivo)
df$nombre_de_identifications      <- ifelse(en_pend, nrm(id$scientificName), "")
cat("  motivo de identifications incorporado al archivo:", sum(en_pend), "filas\n")
tibble(catalogNumber = df$catalogNumber[i_pend],
       core_id       = df$id[i_pend],
       nombre_identifications = nrm(id$scientificName[i_pend]),
       nombre_core            = nrm(df$scientificName[i_pend]),
       fecha_identifications  = d_id[i_pend],
       fecha_core             = d_cor[i_pend],
       determinador_identifications = nrm(id$identifiedBy[i_pend]),
       determinador_core            = nrm(df$identifiedBy[i_pend]),
       autoria_rechazada            = df$autoria_rechazada_de_identifications[i_pend],
       nombre_de_esa_autoria        = df$nombre_de_esa_autoria[i_pend],
       motivo = motivo[i_pend]) %>%
  rename(id = core_id) %>%
  arrange(motivo, catalogNumber) %>%
  write_csv(PENDIENTE, na = "")
cat("casos enviados al oficio de INABIO:", length(i_pend), "\n")

# ---- Auditoría: anotar todos los cambios en metodo_correccion_taxon ----
marcar <- function(v, idx, txt) {
  if (!length(idx)) return(v)
  v[idx] <- ifelse(nz(v[idx]) == "", txt, paste(v[idx], txt, sep = "|")); v
}
df$metodo_correccion_taxon <- marcar(df$metodo_correccion_taxon, i_aut,
  "scientificNameAuthorship_tomado_de_identifications")
df$metodo_correccion_taxon <- marcar(df$metodo_correccion_taxon, i_prev,
  "previousIdentifications_desde_identifications")
if (exists("i_432")) df$metodo_correccion_taxon <- marcar(df$metodo_correccion_taxon, i_432,
  "determinacion_familia_tomada_de_identifications")

# Sello del lote de carga del portal Symbiota.
df$modified_identifications <- id$modified

# ---- 4. Detección de autoría minoritaria por nombre (post-importación) ----
aut_may <- df %>%
  filter(nz(scientificName) != "", nz(scientificNameAuthorship) != "") %>%
  count(scientificName, scientificNameAuthorship, name = "n_filas") %>%
  group_by(scientificName) %>%
  slice_max(n_filas, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  select(scientificName, autoria_mayoritaria_del_nombre = scientificNameAuthorship)

df <- df %>% left_join(aut_may, by = "scientificName")

# nz() evita que NA != "" devuelva NA en la bandera.
df$flag_autoria_minoritaria_en_el_nombre <-
  nz(df$scientificName) != "" & nz(df$scientificNameAuthorship) != "" &
  !is.na(df$autoria_mayoritaria_del_nombre) &
  nz(df$scientificNameAuthorship) != nz(df$autoria_mayoritaria_del_nombre)

sin_acento <- function(x) iconv(x, to = "ASCII//TRANSLIT")
sin_anio   <- function(x) gsub("[0-9]{4}", "AAAA", x)
sin_paren  <- function(x) gsub("[()]", "", x)
sin_guion  <- function(x) trimws(gsub("\\s+", " ", gsub("-", " ", x)))
solo_letras<- function(x) tolower(gsub("[^A-Za-z]", "", sin_acento(x)))

# Clasificar el tipo de discrepancia de autoría.
df$tipo_discrepancia_autoria <- NA_character_
k <- which(df$flag_autoria_minoritaria_en_el_nombre)
A <- nz(df$scientificNameAuthorship[k]); B <- nz(df$autoria_mayoritaria_del_nombre[k])
dlev <- mapply(function(x, y) adist(solo_letras(sin_anio(x)),
                                    solo_letras(sin_anio(y)))[1, 1], A, B)
df$tipo_discrepancia_autoria[k] <- dplyr::case_when(
  sin_paren(A) == sin_paren(B)                       ~ "solo_el_parentesis",
  sin_anio(A)  == sin_anio(B)                        ~ "solo_el_anio",
  solo_letras(sin_guion(sin_anio(A))) ==
    solo_letras(sin_guion(sin_anio(B)))              ~ "solo_tildes_guion_o_espaciado",
  dlev <= 2                                          ~ "errata_ortografica_del_apellido",
  TRUE                                               ~ "autoria_distinta")

n_aut <- df %>% filter(nz(scientificName) != "", nz(scientificNameAuthorship) != "") %>%
  group_by(scientificName) %>%
  summarise(k = n_distinct(scientificNameAuthorship), .groups = "drop") %>%
  filter(k > 1) %>% nrow()
cat("nombres cientificos con mas de una autoria:", n_aut,
    "| filas en la autoria minoritaria:",
    sum(df$flag_autoria_minoritaria_en_el_nombre), "\n")
print(table(df$tipo_discrepancia_autoria, useNA = "no"))
df <- df %>% select(-autoria_mayoritaria_del_nombre)

# ---- 5. tidInterpreted: medir ambigüedad del taxonID del portal ----
df$tid_identifications <- nrm(id$tidInterpreted)
amb <- df$tid_identifications != "" & nz(df$taxonID) != ""
cat("\ntidInterpreted vs taxonID del core:\n")
cat("  ambos poblados:", sum(amb),
    "| coinciden:", sum(amb & df$tid_identifications == nz(df$taxonID)),
    "| difieren:",  sum(amb & df$tid_identifications != nz(df$taxonID)), "\n")

ambig_core <- df %>% filter(nz(taxonID) != "", nz(scientificName) != "") %>%
  group_by(taxonID) %>% summarise(k = n_distinct(scientificName), .groups = "drop") %>%
  filter(k > 1) %>% pull(taxonID)
ambig_ext <- tibble(tid = df$tid_identifications, nom = nrm(id$scientificName)) %>%
  filter(tid != "", nom != "", tolower(nom) != "undefined") %>%
  group_by(tid) %>% summarise(k = n_distinct(nom), .groups = "drop") %>%
  filter(k > 1) %>% pull(tid)
cat("  taxonID ambiguos en el core:", length(ambig_core),
    "| de ellos, tambien ambiguos en identifications:",
    length(intersect(ambig_core, ambig_ext)),
    "| resueltos por la extension:",
    length(setdiff(ambig_core, ambig_ext)), "\n")
cat("  >> la ambiguedad se reproduce en las dos exportaciones: es del portal.\n")
cat("  >> la dimension Taxon debe llevar clave sustituta sobre el nombre canonico.\n")

write_csv(df, SALIDA, na = "")
cat("\nGuardado en", SALIDA, "\n")