# ================================================================
# EXTRACCION DE identifications.csv AL CORE
# Coleccion Ictiologica MECN-DP - INABIO
#
# Integración de identifications.csv: lectura exclusiva de atributos
# faltantes en el core (sin alterar el pipeline de limpieza principal).
# ================================================================
library(readr); library(dplyr)

CORE   <- "datos/02_intermedios/ocurrences_salida_taxonomia.csv"
IDENT  <- "datos/01_crudos/identifications.csv"
SALIDA <- "datos/02_intermedios/ocurrences_con_identifications.csv"
PENDIENTE <- "reportes_y_revisiones/identifications_para_inabio.csv"

df <- read_csv(CORE,  col_types = cols(.default = "c"))
id <- read_csv(IDENT, col_types = cols(.default = "c"))

nz  <- function(x) ifelse(is.na(x), "", x)
# Normalización de strings: incluye limpieza explícita de espacios duros (\u00a0)
# para evitar falsas discordancias.
nrm <- function(x) {
  x <- gsub("\u00a0", " ", nz(x), fixed = TRUE)
  trimws(gsub("\\s+", " ", x, perl = TRUE))
}
vac <- function(x) nrm(x) == ""

# Alineación estructural por clave primaria (coreid).
id <- id[match(df$id, id$coreid), ]
stopifnot(identical(nrm(id$coreid), nrm(df$id)))
motivo <- rep(NA_character_, nrow(df))

# ---- 1. Importación selectiva: solo campos vacíos en el core ----
# Descarte de placeholders literales ("undefined", "unknown", "na", etc.)
# y valores estructuralmente inválidos (fechas en campos de texto).
NO_COPIABLE <- c("undefined", "unpublised", "unknown", "sin datos", "s.d.", "na", "null")
copiable <- function(v) !vac(v) & !(tolower(nrm(v)) %in% NO_COPIABLE) &
  !grepl("^\\d{4}-\\d{2}-\\d{2}$", nrm(v))

# Normalización de autorías importadas (and -> &) para mantener
# la convención establecida en el core.
i_aut <- which(vac(df$scientificNameAuthorship) & copiable(id$scientificNameAuthorship))
aut_norm <- gsub("\\band\\b", "&", nrm(id$scientificNameAuthorship[i_aut]))
aut_norm <- sub("([A-Za-zÀ-ÿ\\.\\)])\\s+(\\d{4})", "\\1, \\2", aut_norm)
aut_norm <- trimws(gsub("\\s+", " ", aut_norm))
cat("  autorias normalizadas con la regla del core (and -> &):",
    sum(aut_norm != nrm(id$scientificNameAuthorship[i_aut])), "\n")
df$scientificNameAuthorship[i_aut] <- aut_norm

# identifiedBy: los valores exclusivos de identifications son inválidos
# (fechas mal ubicadas o "unknown"). Se descartan y documentan.
i_ide_descartado <- which(vac(df$identifiedBy) & !vac(id$identifiedBy) &
                          !copiable(id$identifiedBy))
cat("identifiedBy de identifications descartados por placeholder:",
    length(i_ide_descartado), "\n")
cat("  valores:", paste(unique(nrm(id$identifiedBy[i_ide_descartado])), collapse = " | "), "\n")

# dateIdentified: valores inútiles (vacíos o s.d.).
cat("dateIdentified NO importados (176 sin datos, 5 s.d.): 181\n")
# recordID y tidInterpreted: atributos de determinación ajenos al core. Se descartan.
cat("recordID y tidInterpreted de identifications descartados: no aplican al core\n")

# identificationQualifier: pertenece al acto original, importarlo al core
# produce contradicciones con el taxonRank actual. Se descarta.
i_qua <- which(vac(df$identificationQualifier) & copiable(id$identificationQualifier))
cat("identificationQualifier NO importados (pertenecen a otra determinacion):",
    length(i_qua), "\n")
motivo[i_qua] <- ifelse(is.na(motivo[i_qua]),
  "identifications trae cualificador de su propia determinacion, incompatible con el nombre del core",
  motivo[i_qua])

cat("scientificNameAuthorship tomados de identifications:", length(i_aut), "\n")

# ---- 1b. Importación taxonómica a nivel familia ----
# Asignación de familia en registros sin taxonomía, derivando el rango.
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

  # ---- 1b-bis. PARCHE: cerrar las derivaciones dependientes de la importacion.
  # Se deriva la taxonomia superior desde las hermanas del propio archivo.
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
    # La celda venia vacia y read_csv la leyo como NA: el paste escribia "NA|..."
    df$metodo_correccion_taxon[k] <- ifelse(
      is.na(df$metodo_correccion_taxon[k]) | df$metodo_correccion_taxon[k] == "",
      "jerarquia_derivada_de_la_familia_importada",
      paste(df$metodo_correccion_taxon[k],
            "jerarquia_derivada_de_la_familia_importada", sep = "|"))
  }
  # occurrenceStatus se recalcula: la condicion que lo vacio ya no se cumple.
  df$occurrenceStatus <- ifelse(df$registro_incompleto == "TRUE" |
                                df$flag_sin_taxonomia  == "TRUE", "", "present")
  cat("  jerarquia derivada para la determinacion importada:", length(i_432), "\n")
  cat("  occurrenceStatus recalculado tras la importacion:",
      sum(df$occurrenceStatus != ""), "\n")
}

# ---- 2. previousIdentifications ----
# Condición: El nombre difiere y la fecha de identifications es estrictamente
# anterior a la del core. Sin fechas comparables no hay historial.
gran <- function(x) ifelse(grepl("^\\d{4}-\\d{2}-\\d{2}$", x), 3L,
                           ifelse(grepl("^\\d{4}-\\d{2}$", x), 2L,
                                  ifelse(grepl("^\\d{4}$", x), 1L, 0L)))
d_id  <- nrm(id$dateIdentified)
d_cor <- nrm(df$dateIdentified)
g_id  <- gran(d_id); g_cor <- gran(d_cor)
L     <- ifelse(pmin(g_id, g_cor) == 1L, 4L, ifelse(pmin(g_id, g_cor) == 2L, 7L, 10L))

# Comparación taxonómica: se realiza contra el verbatim (origen) para no
# marcar como discordancias las correcciones ortográficas propias del script.
nombre_core_origen <- nrm(df$scientificName_verbatim)
nombre_difiere <- copiable(id$scientificName) & !vac(nombre_core_origen) &
  nrm(id$scientificName) != nombre_core_origen &
  tolower(nrm(id$scientificName)) != tolower(nombre_core_origen)

fecha_anterior <- g_id > 0 & g_cor > 0 &
  substr(d_id, 1, L) < substr(d_cor, 1, L)

# Truncamiento: Si el nombre anterior es un prefijo exacto del actual,
# se descarta como historial (pérdida de epíteto).
truncamiento <- mapply(function(a, b) nchar(a) > 0 && startsWith(b, paste0(a, " ")),
                       nrm(id$scientificName), nombre_core_origen)
i_prev <- which(nombre_difiere & fecha_anterior & !truncamiento)
cat("  descartadas por truncamiento pese a tener fecha anterior:",
    sum(nombre_difiere & fecha_anterior & truncamiento), "\n")
if (!"previousIdentifications" %in% names(df)) df$previousIdentifications <- NA_character_
df$previousIdentifications[i_prev] <- nrm(id$scientificName[i_prev])
cat("previousIdentifications escritas (fecha anterior probada):", length(i_prev), "\n")

# ---- 3. Exportación de discrepancias para revisión manual ----
# Grupos sin resolución automática o con conflictos de fechas/nombres.
motivo[which(nombre_difiere & !fecha_anterior & g_id > 0 & g_cor > 0 &
               substr(d_id, 1, L) == substr(d_cor, 1, L))] <- "misma fecha: mismo acto con dos nombres"
motivo[which(nombre_difiere & (g_id == 0 | g_cor == 0))] <- "sin fecha comparable en identifications"
motivo[which(!vac(id$scientificName) &
               tolower(nrm(id$scientificName)) == "undefined")] <- "identifications trae el texto literal undefined"

# Manejo de casos atípicos: determinaciones posteriores al core o truncamientos.
fecha_posterior <- g_id > 0 & g_cor > 0 & substr(d_id, 1, L) > substr(d_cor, 1, L)
motivo[which(nombre_difiere & fecha_posterior)] <-
  "identifications trae una determinacion POSTERIOR: el core seria el desactualizado"
motivo[which(nombre_difiere & truncamiento)] <-
  "identifications trae el nombre truncado, no una determinacion anterior"

sin_destino <- setdiff(which(nombre_difiere & is.na(motivo)), i_prev)
if (length(sin_destino)) {
  cat("ATENCION - diferencias sin destino asignado:", length(sin_destino), "\n")
  print(df$catalogNumber[sin_destino])
}
stopifnot(length(sin_destino) == 0)
# 23 + 45 = 68 sobre 63 nombres: hay cinco filas (4271, 4388, 4437, 4452, 4453)
# que resuelven su redeterminacion Y ademas van al oficio por el cualificador.
solo_prev <- setdiff(i_prev, which(!is.na(motivo)))
ambos     <- intersect(i_prev, which(!is.na(motivo)))
solo_ofi  <- setdiff(which(nombre_difiere & !is.na(motivo)), i_prev)
cat("particion de los", sum(nombre_difiere), "nombres distintos:",
    length(solo_prev), "solo previa +", length(ambos), "previa y ademas al oficio +",
    length(solo_ofi), "solo al oficio =",
    length(solo_prev) + length(ambos) + length(solo_ofi), "\n")

i_pend <- which(!is.na(motivo))
tibble(catalogNumber = df$catalogNumber[i_pend],
       core_id       = df$id[i_pend],
       nombre_identifications = nrm(id$scientificName[i_pend]),
       nombre_core            = nrm(df$scientificName[i_pend]),
       fecha_identifications  = d_id[i_pend],
       fecha_core             = d_cor[i_pend],
       determinador_identifications = nrm(id$identifiedBy[i_pend]),
       determinador_core            = nrm(df$identifiedBy[i_pend]),
       motivo = motivo[i_pend]) %>%
  rename(id = core_id) %>%
  arrange(motivo, catalogNumber) %>%
  write_csv(PENDIENTE, na = "")
cat("casos enviados al oficio de INABIO:", length(i_pend), "\n")

# Auditoría: Anotación de todos los cambios en metodo_correccion_taxon.
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

# Sello del lote de carga del portal: útil para identificar los dos lotes de ingreso
# de identifications en el portal de Symbiota, pero con solo dos valores distintos
# no sirve para detectar cambios incrementales.
df$modified_identifications <- id$modified

write_csv(df, SALIDA, na = "")
cat("\nGuardado en", SALIDA, "\n")