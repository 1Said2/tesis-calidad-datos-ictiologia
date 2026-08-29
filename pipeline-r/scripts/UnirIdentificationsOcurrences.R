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
# La autoria pertenece al NOMBRE, no a la fila. Importarla sin comprobar que las
# dos tablas declaran el mismo nombre mete la autoria de otra especie: son 21 de
# las 803, y en cinco de ellas (4267, 4284, 4327, 4331, 4334) el propio script
# declara dos bloques mas abajo que ese nombre es el ANTERIOR. Medido sobre el
# archivo: la incoherencia de autoria sube de 58 nombres/104 filas a 71/127.
# La comparacion va contra scientificName_verbatim, no contra el nombre limpio,
# por el mismo motivo que el bloque 2: no penalizar las correcciones propias.
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
i_fec <- which(vac(df$dateIdentified) & !vac(id$dateIdentified))
cat("dateIdentified NO importados:", length(i_fec), "->",
    paste(names(table(tolower(nrm(id$dateIdentified[i_fec])))),
          table(tolower(nrm(id$dateIdentified[i_fec]))),
          sep = ": ", collapse = " | "), "\n")
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

# Manejo de casos atípicos: determinaciones posteriores al core o truncamientos.
fecha_posterior <- g_id > 0 & g_cor > 0 & substr(d_id, 1, L) > substr(d_cor, 1, L)
motivo <- add_motivo(motivo, which(nombre_difiere & fecha_posterior),
  "identifications trae una determinacion POSTERIOR: el core seria el desactualizado")
motivo <- add_motivo(motivo, which(nombre_difiere & truncamiento),
  "identifications trae el nombre truncado, no una determinacion anterior")

sin_destino <- setdiff(which(nombre_difiere & is.na(motivo)), i_prev)
if (length(sin_destino)) {
  cat("ATENCION - diferencias sin destino asignado:", length(sin_destino), "\n")
  print(df$catalogNumber[sin_destino])
}
stopifnot(length(sin_destino) == 0)
# Hay filas que resuelven su redeterminacion Y ademas van al oficio por el cualificador.
solo_prev <- setdiff(i_prev, which(!is.na(motivo)))
ambos     <- intersect(i_prev, which(!is.na(motivo)))
solo_ofi  <- setdiff(which(nombre_difiere & !is.na(motivo)), i_prev)
cat("particion de los", sum(nombre_difiere), "nombres distintos:",
    length(solo_prev), "solo previa +", length(ambos), "previa y ademas al oficio +",
    length(solo_ofi), "solo al oficio =",
    length(solo_prev) + length(ambos) + length(solo_ofi), "\n")

# Las cinco filas cuya autoria se rechaza Y ademas resuelven como redeterminacion
# salian del grupo pendiente y no llegaban al curador. Se anaden explicitamente.
i_pend <- sort(union(which(!is.na(motivo)), i_aut_rechazada))
motivo <- add_motivo(motivo, i_aut_rechazada,
  "identifications trae la autoria de un nombre distinto al del core; no se importa")

# ---- 3b. El motivo viaja en el archivo, no solo en el oficio.
# De las 11 columnas del oficio, 9 no existen en el core: 50 de los 71 casos
# son invisibles en ocurrences_con_identifications.csv (los 21 de autoria si se
# ven, por autoria_rechazada_de_identifications). Sin esto el tablero no puede
# contar lo pendiente de INABIO ni hacer drill-through al registro.
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

# ---- 4. Autoria minoritaria dentro del propio NOMBRE (medida DESPUES de la
# importacion). Estaba en Fishbase.R y la union le anade 782 autorias despues,
# de modo que la bandera describia un archivo intermedio y no el publicado.


aut_may <- df %>%
  filter(nz(scientificName) != "", nz(scientificNameAuthorship) != "") %>%
  count(scientificName, scientificNameAuthorship, name = "n_filas") %>%
  group_by(scientificName) %>%
  slice_max(n_filas, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  select(scientificName, autoria_mayoritaria_del_nombre = scientificNameAuthorship)

df <- df %>% left_join(aut_may, by = "scientificName")

# read_csv lee la celda vacia como NA y "NA != ''" devuelve NA, no FALSE: la
# bandera salia NA en 58 filas y el sum() del log imprimia NA. Se normaliza con
# nz() antes de comparar, igual que hace nz() en el resto del script.
df$flag_autoria_minoritaria_en_el_nombre <-
  nz(df$scientificName) != "" & nz(df$scientificNameAuthorship) != "" &
  !is.na(df$autoria_mayoritaria_del_nombre) &
  nz(df$scientificNameAuthorship) != nz(df$autoria_mayoritaria_del_nombre)

sin_acento <- function(x) iconv(x, to = "ASCII//TRANSLIT")
sin_anio   <- function(x) gsub("[0-9]{4}", "AAAA", x)
sin_paren  <- function(x) gsub("[()]", "", x)
sin_guion  <- function(x) trimws(gsub("\\s+", " ", gsub("-", " ", x)))
solo_letras<- function(x) tolower(gsub("[^A-Za-z]", "", sin_acento(x)))

df$tipo_discrepancia_autoria <- NA_character_
k <- which(df$flag_autoria_minoritaria_en_el_nombre)
A <- nz(df$scientificNameAuthorship[k]); B <- nz(df$autoria_mayoritaria_del_nombre[k])
# Distancia de edicion sobre las letras, ya sin anio ni tildes: separa la errata
# de apellido (Ranzanl/Ranzani) de la autoria realmente distinta.
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

# ---- 5. tidInterpreted: prueba del origen de la ambiguedad, no reparacion.
# Se comprobo que el tid NO es una segunda opinion: coincide con el taxonID del
# core en 4.238 de 4.287 filas y las 49 que difieren son exactamente las 49 con
# nombre distinto (cero excepciones en los dos sentidos). Es el mismo campo del
# portal exportado dos veces. Lo que si demuestra es que los 19 taxonID que el
# core usa para mas de un nombre son ambiguos IGUAL en la extension: el defecto
# esta en el tesauro de Symbiota, no en el pipeline. Se mide y se deja escrito.
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