# ================================================================
# 2/4 - CORRECCIÓN TAXONÓMICA - Colección Ictiológica MECN-DP INABIO
#
# Entrada:  ocurrences_salida_coordenadas.csv (salida de Coordenadas.R)
# Salida:   ocurrences_salida_taxonomia.csv   -> UnirIdentificationsOcurrences.R
#           gbif_nombres_difusos.csv          -> oficio al curador
#           gbif_contraste_completo.csv       -> tablero
#
# Corrección de errores objetivos (rangos, ortografía, jerarquía).
# Conserva las reclasificaciones previas como propuestas pendientes del curador.
# ================================================================

library(readr); library(dplyr); library(rfishbase)

ARCHIVO_ENTRADA <- Sys.getenv("FISHBASE_ENTRADA", "datos/02_intermedios/ocurrences_salida_coordenadas.csv")
ARCHIVO_SALIDA <- Sys.getenv("FISHBASE_SALIDA", "datos/02_intermedios/ocurrences_salida_taxonomia.csv")
DIR_REPORTES <- Sys.getenv("FISHBASE_REPORTES", "reportes_y_revisiones")
DIR_REFERENCIAS <- Sys.getenv("FISHBASE_SNAPSHOT", "datos/00_referencia/taxonomia")
ACTUALIZAR_REFERENCIAS <- identical(Sys.getenv("FISHBASE_ACTUALIZAR"), "TRUE")
archivo_taxa <- file.path(DIR_REFERENCIAS, "fishbase_taxa.rds")
archivo_gbif <- file.path(DIR_REFERENCIAS, "gbif_respuestas.rds")
archivo_manifest <- file.path(DIR_REFERENCIAS, "manifest.json")
nz <- function(x) ifelse(is.na(x), "", x)

# La actualización es explícita, requiere versión concreta y un directorio nuevo.
if (ACTUALIZAR_REFERENCIAS) {
  version_fb <- Sys.getenv("FISHBASE_VERSION")
  if (!nzchar(version_fb) || version_fb == "latest") stop("Indique FISHBASE_VERSION concreta.")
  if (any(file.exists(c(archivo_taxa, archivo_gbif, archivo_manifest)))) {
    stop("Use FISHBASE_SNAPSHOT con un directorio nuevo para actualizar referencias.")
  }
  taxa_snapshot <- rfishbase::load_taxa(version = version_fb)
  gbif_snapshot <- NULL
  manifest <- list(fishbase = list(version = version_fb,
    rfishbase = as.character(packageVersion("rfishbase")),
    fecha_consulta = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
    parametros = list(server = "fishbase", version = version_fb)))
} else {
  if (!all(file.exists(c(archivo_taxa, archivo_gbif, archivo_manifest)))) {
    stop("Snapshot incompleto. No se consultan referencias nuevas automáticamente.")
  }
  manifest <- jsonlite::read_json(archivo_manifest, simplifyVector = TRUE)
  hashes <- unlist(manifest$archivos_md5, use.names = TRUE)
  for (f in c(archivo_taxa, archivo_gbif)) {
    esperado <- hashes[basename(f)]
    if (length(esperado) != 1L || is.na(esperado) ||
        unname(tools::md5sum(f)) != esperado) stop(paste("Snapshot alterado:", f))
  }
  taxa_snapshot <- readRDS(archivo_taxa)
  gbif_snapshot <- readRDS(archivo_gbif)
}
if (!is.data.frame(taxa_snapshot) || nrow(taxa_snapshot) == 0L ||
    !all(c("Genus", "Family", "Order", "Class") %in% names(taxa_snapshot))) {
  stop("FishBase devolvió una referencia vacía o sin los campos necesarios.")
}
jerarquias <- taxa_snapshot %>% select(Genus, Family, Order, Class) %>% distinct()
# Si un género tiene varias jerarquías, ninguna se elige por posición.
backbone <- jerarquias %>% group_by(Genus) %>% filter(n() == 1L) %>% ungroup()
generos_ambiguos <- setdiff(jerarquias$Genus, backbone$Genus)

df <- read_csv(ARCHIVO_ENTRADA, col_types = cols(.default = "c"))
if (anyDuplicated(df$id) || anyNA(df$id) || any(df$id == "")) stop("Identificadores id no únicos o vacíos.")
entrada_original <- df
cat("Filas:", nrow(df), "\n")

if (!"metodo_correccion_taxon" %in% names(df)) df$metodo_correccion_taxon <- ""
anotar <- function(i, txt) {
  df$metodo_correccion_taxon[i] <<- ifelse(df$metodo_correccion_taxon[i] == "", txt,
                                    paste(df$metodo_correccion_taxon[i], txt, sep = "|"))
}
# Preservar el valor de origen antes de cualquier modificación.
for (col in c("kingdom","phylum","class","order","family","scientificName","higherClassification",
              "genus","specificEpithet","taxonRank")) {
  vb <- paste0(col, "_verbatim")
  if (!vb %in% names(df)) df[[vb]] <- df[[col]]
}



# Homologación de clases (Teleostei -> Actinopterygii).
clase_dwc <- function(x) dplyr::case_when(
  x == "Teleostei"      ~ "Actinopterygii",
  x == "Actinopterygii" ~ "Actinopterygii",
  x == "Elasmobranchii" ~ "Elasmobranchii",
  x == "Holocephali"    ~ "Holocephali",
  TRUE ~ NA_character_)

# ---- 1. kingdom = Plantae: colisión de homónimos ----
idx_plantae <- which(df$kingdom == "Plantae")
for (i in idx_plantae) {
  fb <- backbone %>% filter(Genus == df$genus[i])
  if (nrow(fb) != 1) { warning(sprintf("fila %d: género '%s' sin resolver", i, df$genus[i])); next }
  cl <- clase_dwc(fb$Class[1]); if (is.na(cl)) next
  df$kingdom[i] <- "Animalia"; df$phylum[i] <- "Chordata"
  df$class[i]   <- cl;         df$order[i]  <- fb$Order[1]
  if (!identical(df$family[i], fb$Family[1])) df$family[i] <- fb$Family[1]
  anotar(i, "jerarquia_superior_corregida_homonimo")
}
cat("kingdom=Plantae corregidos:", length(idx_plantae), "\n")

# ---- 2. Rango equivocado en el campo family ----
rango_erroneo <- c(
  "Characinae"        = "Characidae",
  "Tetragonopterinae" = "Characidae",
  "Loricariinae"      = "Loricariidae",
  "Clupeiformes"      = "Engraulidae"
)
for (mal in names(rango_erroneo)) {
  idx <- which(df$family == mal)
  if (!length(idx)) next
  df$family[idx] <- rango_erroneo[[mal]]
  for (i in idx) anotar(i, if (mal == "Clupeiformes")
    "family_nivel_orden_corregido_por_regla_fija" else "family_rango_incorrecto_corregido")
  cat("  ", mal, "->", rango_erroneo[[mal]], ":", length(idx), "fila(s)\n")
}

# ---- 3. Grafías de familia y cambio de clasificación pendiente ----
grafia_familia <- c(
  "Archiridae"    = "Achiridae",
  "Scorpanidae"   = "Scorpaenidae",
  "Triporthidae"  = "Triportheidae",
  "Characidiidae" = "Crenuchidae",
  "Asprenidae"    = "Aspredinidae",
  "Gemplylidae"   = "Gempylidae"
)
for (mal in names(grafia_familia)) {
  idx <- which(df$family == mal)
  if (!length(idx)) next
  df$family[idx] <- grafia_familia[[mal]]
  for (i in idx) anotar(i, if (mal == "Characidiidae")
    "family_cambio_clasificacion_Crenuchidae_pendiente_curador" else "family_grafia_corregida")
  cat("  ", mal, "->", grafia_familia[[mal]], ":", length(idx), "fila(s)\n")
}

# ---- 3b. family con valor que no es denominación de familia ----
idx <- which(df$family != "" & !is.na(df$family) &
             !grepl("^[A-Z][a-z]+(idae|inae)$", df$family))
if (length(idx)) {
  cat("family con formato inválido (vaciada para derivar del género):\n")
  print(unique(df$family[idx]))
  df$family[idx] <- ""
  for (i in idx) anotar(i, "family_formato_invalido_vaciada")
}

# ---- 4. Capitalización binomial y uninominal ----
cap_nombre <- function(s) {
  if (is.na(s)) return(s)
  x <- trimws(s)
  if (grepl("^\\S+$", x)) {
    return(paste0(toupper(substr(x, 1, 1)), tolower(substr(x, 2, nchar(x)))))
  }
  if (!grepl("^\\S+\\s+\\S+$", x)) return(s)
  p <- strsplit(x, "\\s+")[[1]]
  paste(paste0(toupper(substr(p[1],1,1)), tolower(substr(p[1],2,nchar(p[1])))),
        tolower(p[2]))
}
nuevo <- vapply(df$scientificName, cap_nombre, character(1), USE.NAMES = FALSE)
idx <- which(!is.na(nuevo) & nuevo != df$scientificName)
if (length(idx)) {
  cat("  capitalización binomial corregida:", length(idx), "fila(s)\n")
  print(unique(data.frame(de = df$scientificName[idx], a = nuevo[idx])))
  df$scientificName[idx] <- nuevo[idx]
  for (i in idx) anotar(i, "scientificName_capitalizacion_corregida")
}

# ---- 4a. Grafía incorrecta de género ----
grafia_genero <- c(
  "Symbranchus"    = "Synbranchus",
  "Astroblepu"     = "Astroblepus",
  "Andinocara"     = "Andinoacara",
  "Limatulichtys"  = "Limatulichthys",
  "Lesbiasina"     = "Lebiasina",
  "Mylosomma"      = "Mylossoma",
  "Hipostomus"     = "Hypostomus",
  "Hypomostus"     = "Hypostomus",
  "Chaestostoma"   = "Chaetostoma",
  "Cichlosoma"     = "Cichlasoma",
  "Cenicichla"     = "Crenicichla",
  "Hypetecara"     = "Hypselecara",
  "Hemmigrammus"   = "Hemigrammus",
  "Moekhausia"     = "Moenkhausia",
  "Creagutus"      = "Creagrutus",
  "Brachycalcinus" = "Brachychalcinus",
  "Phyrulina"      = "Pyrrhulina",
  "Shyrna"         = "Sphyrna",
  "Hyphopthalmus"  = "Hypophthalmus",
  "Paradon"        = "Parodon",
  "Amphyocharax"   = "Aphyocharax",
  "Carcharthinus"  = "Carcharhinus"
)
n_gg <- 0
for (mal in names(grafia_genero)) {
  bien <- grafia_genero[[mal]]
  idx <- which(df$genus == mal |
               grepl(paste0("^", mal, "\\b"), df$scientificName))
  if (!length(idx)) next
  df$genus[idx] <- ifelse(df$genus[idx] == mal, bien, df$genus[idx])
  df$scientificName[idx] <- sub(paste0("^", mal, "\\b"), bien, df$scientificName[idx])
  for (i in idx) anotar(i, "genus_grafia_corregida")
  n_gg <- n_gg + length(idx)
  cat("  ", mal, "->", bien, ":", length(idx), "fila(s)\n")
}
cat("grafía de género corregida:", n_gg, "fila(s)\n")

# ---- 4a-bis. Grafía no corroborada: no decidir por mayoría interna ----
idx <- which(df$genus == "Saxatalia" | grepl("^Saxatalia\\b", df$scientificName))
for (i in idx) anotar(i, "genero_grafia_pendiente_sin_respaldo_externo")

# ---- 4a-ter. Grafía incorrecta de epíteto específico ----
grafia_epiteto <- c(
  "Astroblepus vailanti"        = "Astroblepus vaillanti",
  "Astroblepus vaillauti"       = "Astroblepus vaillanti",
  "Astroblepus micresens"       = "Astroblepus micrescens",
  "Astroblepus theresinae"      = "Astroblepus theresiae",
  "Aphyocharax pusillos"        = "Aphyocharax pusillus",
  "Auchenipterus ambiacus"      = "Auchenipterus ambyiacus",
  "Characidium fasciatus"       = "Characidium fasciatum",
  "Pseudoplatystoma fasciatus"  = "Pseudoplatystoma fasciatum",
  "Moenkhausia colletti"        = "Moenkhausia collettii",
  "Potamotrygon motora"         = "Potamotrygon motoro",
  "Loricaria clavipina"         = "Loricaria clavipinna",
  "Paratrygon ajereba"          = "Paratrygon aiereba",
  "Selene orstedii"             = "Selene oerstedii",
  "Hemigrammus bellotii"        = "Hemigrammus bellottii"
  # Farlowella oxyrryncha se conserva: FishBase y Catalog of Fishes respaldan el original.
)
n_ge <- 0
for (mal in names(grafia_epiteto)) {
  idx <- which(df$scientificName == mal)
  if (!length(idx)) next
  df$scientificName[idx] <- grafia_epiteto[[mal]]
  df$specificEpithet[idx] <- sub("^\\S+\\s+", "", grafia_epiteto[[mal]])
  for (i in idx) anotar(i, "epiteto_grafia_corregida")
  cat("  ", mal, "->", grafia_epiteto[[mal]], ":", length(idx), "fila(s)\n")
  n_ge <- n_ge + length(idx)
}
cat("grafia de epiteto corregida:", n_ge, "fila(s)\n")

# ---- 4b. Derivación de genus y specificEpithet desde el binomio ----
bin <- regmatches(df$scientificName,
                  regexec("^\\s*([A-Z][a-z]+)\\s+([a-z][a-z\\-]+)\\s*$", df$scientificName))

idx_g <- which((is.na(df$genus) | df$genus == "") & lengths(bin) == 3)
for (i in idx_g) { df$genus[i] <- bin[[i]][2]; anotar(i, "genus_derivado_de_scientificName") }
cat("genus derivado del binomio:", length(idx_g), "fila(s)\n")

idx_e <- which((is.na(df$specificEpithet) | df$specificEpithet == "") & lengths(bin) == 3)
for (i in idx_e) { df$specificEpithet[i] <- bin[[i]][3]; anotar(i, "specificEpithet_derivado_de_scientificName") }
cat("specificEpithet derivado del binomio:", length(idx_e), "fila(s)\n")

# ---- 4b2. Derivar genus desde nombres genéricos o incompletos ----
solo_genero <- grepl("^\\s*[A-Z][a-z]+( sp\\.?[0-9]*)?\\s*$", df$scientificName) &
               !grepl("(idae|inae)\\s*$", df$scientificName)
idx <- which((is.na(df$genus) | df$genus == "") & solo_genero)
for (i in idx) {
  df$genus[i] <- sub("^\\s*([A-Z][a-z]+).*$", "\\1", df$scientificName[i])
  anotar(i, "genus_derivado_de_nombre_generico")
}
cat("genus derivado de nombre de rango genérico:", length(idx), "fila(s)\n")

# ---- 4b3. Género en nombres con cualificadores (cf., aff., sp.) ----
cualificado <- grepl("\\b(cf\\.?|aff\\.?|gr\\.?|complex|sp\\.? ?nov\\.?)",
                     df$scientificName, ignore.case = TRUE)
idx <- which(cualificado & (is.na(df$genus) | df$genus == "") &
             grepl("^[A-Z][a-z]+\\b", df$scientificName))
for (i in idx) {
  df$genus[i] <- sub("^\\s*([A-Z][a-z]+).*$", "\\1", df$scientificName[i])
  anotar(i, "genus_derivado_de_nombre_con_cualificador")
}
cat("genus derivado de nombre con cualificador:", length(idx), "fila(s)\n")


# ---- 4d. Retirar cualificador del scientificName (ya existe en identificationQualifier) ----
idx <- which(grepl("\\bsp\\.?\\s*[0-9]*\\s*$", df$scientificName) &
             df$identificationQualifier != "")
if (length(idx)) {
  df$scientificName[idx] <- trimws(sub("\\s*\\bsp\\.?\\s*[0-9]*\\s*$", "", df$scientificName[idx]))
  for (i in idx) anotar(i, "cualificador_retirado_del_nombre")
  cat("cualificador retirado de scientificName:", length(idx), "fila(s)\n")
}

# Insertar espacio tras cualificador abreviado (cf.batesii -> cf. batesii).
idx <- which(grepl("\\b(cf|aff|gr)\\.\\S", df$scientificName))
if (length(idx)) {
  df$scientificName[idx] <- sub("\\b(cf|aff|gr)\\.(\\S)", "\\1. \\2", df$scientificName[idx])
  for (i in idx) anotar(i, "espacio_tras_cualificador")
  cat("espacio insertado tras el cualificador:", length(idx), "fila(s)\n")
}

# ---- 4c. Correcciones ortográficas puntuales ----
idx_cren <- which(df$scientificName == "Crenicichlla sedentaria")
if (length(idx_cren)) {
  df$scientificName[idx_cren] <- "Crenicichla sedentaria"
  df$genus[idx_cren] <- "Crenicichla"
  for (i in idx_cren) anotar(i, "scientificName_grafia_corregida_manualmente")
}

idx_asp <- which(df$scientificName == "Asprenidae")
if (length(idx_asp)) {
  df$scientificName[idx_asp] <- "Aspredinidae"
  for (i in idx_asp) anotar(i, "scientificName_grafia_familia_corregida")
}

idx_hyp <- which(df$family == "Hyphopthalmidae")
if (length(idx_hyp)) {
  df$family[idx_hyp] <- ""
  for (i in idx_hyp) anotar(i, "family_inexistente_vaciada")
}

# Validación de coherencia genus/epíteto vs scientificName (post-correcciones).
bin <- regmatches(df$scientificName,
                  regexec("^\\s*([A-Z][a-z]+)\\s+([a-z][a-z\\-]+)\\s*$", df$scientificName))
prim <- vapply(bin, function(x) if (length(x) == 3) x[2] else NA_character_, "")
segu <- vapply(bin, function(x) if (length(x) == 3) x[3] else NA_character_, "")
uni  <- regmatches(df$scientificName, regexec("^\\s*([A-Z][a-z]+)\\s*$", df$scientificName))
unig <- vapply(uni, function(x) if (length(x) == 2) x[2] else NA_character_, "")

df$flag_genus_no_coincide_con_nombre <-
  (!is.na(prim) & df$genus != "" & df$genus != prim) |
  (!is.na(unig) & df$genus != "" & !grepl("(idae|inae)\\s*$", df$scientificName) &
     df$genus != unig)
df$flag_epiteto_no_coincide_con_nombre <-
  !is.na(segu) & df$specificEpithet != "" & df$specificEpithet != segu

cat("ATENCION - genus no coincide con el nombre:",
    sum(df$flag_genus_no_coincide_con_nombre), "fila(s)\n")
print(df[df$flag_genus_no_coincide_con_nombre,
         c("catalogNumber","scientificName","genus")], n = 20)
cat("ATENCION - specificEpithet no coincide con el nombre:",
    sum(df$flag_epiteto_no_coincide_con_nombre), "fila(s)\n")
print(df[df$flag_epiteto_no_coincide_con_nombre,
         c("catalogNumber","scientificName","genus","specificEpithet")], n = 20)

# ---- 4e. Indicios de inconsistencia interna ----
# Estos indicios proceden de la misma colección, no de autoridades independientes.
# Se conserva testigos_contra_scientificName por compatibilidad; no autoriza correcciones.
df$nombre_reconstruido_de_atomicos <- ifelse(
  df$genus != "" & df$specificEpithet != "",
  paste(df$genus, df$specificEpithet), NA_character_)

tid_nombre <- df %>% filter(taxonID != "", scientificName != "") %>%
  count(taxonID, scientificName, name = "n") %>%
  group_by(taxonID) %>% filter(n == max(n)) %>% filter(n() == 1L) %>%
  ungroup() %>% select(taxonID, nombre_mayoritario_del_taxonID = scientificName)

aut_ref <- df %>% filter(scientificName != "", scientificNameAuthorship != "") %>%
  count(scientificName, scientificNameAuthorship, name = "n") %>%
  group_by(scientificName) %>% filter(n == max(n)) %>% filter(n() == 1L) %>%
  ungroup() %>% select(scientificName, autoria_ref = scientificNameAuthorship)

df <- df %>% left_join(tid_nombre, by = "taxonID") %>%
             left_join(aut_ref,    by = "scientificName")

df$flag_nombre_contradice_atomicos <- !is.na(df$nombre_reconstruido_de_atomicos) &
  df$scientificName != "" &
  df$nombre_reconstruido_de_atomicos != df$scientificName

t_tid <- df$flag_nombre_contradice_atomicos &
         !is.na(df$nombre_mayoritario_del_taxonID) &
         df$nombre_mayoritario_del_taxonID == df$nombre_reconstruido_de_atomicos
t_aut <- df$flag_nombre_contradice_atomicos &
         df$scientificNameAuthorship != "" & !is.na(df$autoria_ref) &
         df$scientificNameAuthorship != df$autoria_ref

df$testigos_contra_scientificName <-
  as.integer(df$flag_nombre_contradice_atomicos) +
  as.integer(t_tid %in% TRUE) + as.integer(t_aut %in% TRUE)

cat("scientificName contradicho por los campos atomizados:",
    sum(df$flag_nombre_contradice_atomicos), "fila(s)\n")
cat("  con 3 indicios internos (atomicos + taxonID + autoria):",
    sum(df$testigos_contra_scientificName == 3), "\n")
cat("  con 2 indicios internos:", sum(df$testigos_contra_scientificName == 2), "\n")
print(df %>% filter(flag_nombre_contradice_atomicos) %>%
        select(catalogNumber, scientificName, nombre_reconstruido_de_atomicos,
               taxonID, nombre_mayoritario_del_taxonID,
               scientificNameAuthorship, autoria_ref,
               testigos_contra_scientificName), n = 30)
df <- df %>% select(-nombre_mayoritario_del_taxonID, -autoria_ref)

# ---- 5. Completar class y order desde el backbone ----
falta <- which((is.na(df$class) | df$class == "") & !is.na(df$genus) & df$genus != "")
n_cl <- 0
for (i in falta) {
  fb <- backbone %>% filter(Genus == df$genus[i]); if (nrow(fb) != 1) next
  cl <- clase_dwc(fb$Class[1]); if (is.na(cl)) next
  df$class[i] <- cl; n_cl <- n_cl + 1
  if (is.na(df$order[i]) || df$order[i] == "") df$order[i] <- fb$Order[1]
  anotar(i, "class_derivada_de_genus")
}
cat("class completada:", n_cl, "| sin resolver:", length(falta) - n_cl, "\n")

# Segundo intento: derivar class desde family.
fam_cls <- backbone %>% distinct(Family, Class)
falta2 <- which((is.na(df$class) | df$class == "") & df$family != "")
for (i in falta2) {
  fb <- fam_cls %>% filter(Family == df$family[i]); if (nrow(fb) != 1) next
  cl <- clase_dwc(fb$Class[1]); if (is.na(cl)) next
  df$class[i] <- cl; anotar(i, "class_derivada_de_family")
}

# ---- 5b. Derivar kingdom y phylum desde class conocida ----
idx <- which(df$class %in% c("Actinopterygii","Elasmobranchii","Holocephali") &
             (is.na(df$kingdom) | df$kingdom == ""))
if (length(idx)) {
  df$kingdom[idx] <- "Animalia"; df$phylum[idx] <- "Chordata"
  for (i in idx) anotar(i, "kingdom_phylum_derivados_de_class")
  cat("kingdom/phylum completados:", length(idx), "fila(s)\n")
}

# Derivar family: priorizar mayoría interna, luego FishBase como respaldo.
fam_en_archivo <- df %>%
  filter(genus != "", family != "") %>%
  count(genus, family, name = "n") %>%
  arrange(genus, desc(n), family) %>%
  group_by(genus) %>% filter(n == max(n)) %>% filter(n() == 1L) %>%
  ungroup() %>% select(genus, family_en_archivo = family)

idx <- which((is.na(df$family) | df$family == "") & !is.na(df$genus) & df$genus != "")
n_f <- 0; n_fb <- 0
for (i in idx) {
  fa <- fam_en_archivo$family_en_archivo[fam_en_archivo$genus == df$genus[i]]
  if (length(fa) == 1) {
    df$family[i] <- fa; n_f <- n_f + 1
    anotar(i, "family_inferida_mayoria_interna_no_verificada")
  } else {
    fb <- backbone %>% filter(Genus == df$genus[i]); if (nrow(fb) != 1) next
    df$family[i] <- fb$Family[1]; n_fb <- n_fb + 1
    anotar(i, "family_derivada_de_genus_backbone")
  }
}
cat("family completada desde el archivo:", n_f, "| desde el backbone:", n_fb, "fila(s)\n")

# Normalizar clados informales (ej. "Perciformes/Percoidei" -> "Perciformes").
if (!"order_fishbase_informal" %in% names(df)) df$order_fishbase_informal <- ""
idx <- which(grepl("/", df$order))
if (length(idx)) {
  df$order_fishbase_informal[idx] <- df$order[idx]
  raiz <- sub("/.*$", "", df$order[idx])
  origen_formal <- grepl("^[A-Z][a-z]+iformes$", df$order_verbatim[idx])
  valido <- grepl("^[A-Z][a-z]+iformes$", raiz) & !origen_formal
  df$order[idx] <- ifelse(valido, raiz, df$order_verbatim[idx])
  for (i in idx) anotar(i, if (identical(df$order[i], df$order_verbatim[i]))
                          "order_revertido_al_verbatim_clado_informal"
                        else
                          "order_informal_reducido_a_orden_valido")
  cat("ordenes informales normalizados:", length(idx),
      "| revertidos al verbatim:", sum(!valido), "\n")
}

# ---- 5c. Unificación de órdenes por género ----
gen_multi <- df %>% filter(genus != "", order != "") %>%
  count(genus, order) %>% count(genus) %>% filter(n > 1) %>% pull(genus)
for (g in gen_multi) {
  fb <- backbone %>% filter(Genus == g); if (nrow(fb) != 1) next
  idx <- which(df$genus == g & df$order != fb$Order[1])
  if (!length(idx)) next
  cat("  ", g, ": unificado a", fb$Order[1], "(", length(idx), "fila(s), antes",
      paste(unique(df$order[idx]), collapse = "/"), ")\n")
  df$order[idx] <- fb$Order[1]
  for (i in idx) anotar(i, "order_unificado_por_genero_desde_backbone")
}

# ---- 5c-bis. Orden propuesto por el snapshot FishBase (provisional) ----
idx <- which(df$genus != "")
n_ord <- 0
for (i in idx) {
  fb <- backbone %>% filter(Genus == df$genus[i]); if (nrow(fb) != 1) next
  if (!is.na(df$order[i]) && df$order[i] == fb$Order[1]) next
  df$order[i] <- fb$Order[1]; n_ord <- n_ord + 1
  anotar(i, "order_desde_snapshot_FishBase_provisional")
}
cat("order alineado al backbone (provisional, antes de revertir clados):",
    n_ord, "fila(s)\n")

# Segunda pasada de normalización de clados informales post-asignación.
idx <- which(grepl("/", df$order))
if (length(idx)) {
  df$order_fishbase_informal[idx] <- df$order[idx]
  raiz <- sub("/.*$", "", df$order[idx])
  origen_formal <- grepl("^[A-Z][a-z]+iformes$", df$order_verbatim[idx])
  valido <- grepl("^[A-Z][a-z]+iformes$", raiz) & !origen_formal
  df$order[idx] <- ifelse(valido, raiz, df$order_verbatim[idx])
  for (i in idx) anotar(i, if (identical(df$order[i], df$order_verbatim[i]))
                "order_revertido_al_verbatim_clado_informal"
              else
                "order_informal_reducido_a_orden_valido")
  cat("ordenes informales normalizados:", length(idx),
      "| revertidos al verbatim:", sum(!valido), "\n")
}

# ---- 5c-quinquies. Retirar anotación de autoridad única si la celda quedó igual al verbatim ----
idx_rev <- which(grepl("order_desde_snapshot_FishBase_provisional", df$metodo_correccion_taxon,
                   fixed = TRUE) & df$order == df$order_verbatim)
df$metodo_correccion_taxon[idx_rev] <- gsub(
  "\\|?order_desde_snapshot_FishBase_provisional", "", df$metodo_correccion_taxon[idx_rev])
df$metodo_correccion_taxon[idx_rev] <- sub("^\\|", "", df$metodo_correccion_taxon[idx_rev])
cat("  anotaciones de autoridad unica retiradas por reversion:", length(idx_rev), "\n")

df$metodo_correccion_taxon <- vapply(strsplit(df$metodo_correccion_taxon, "|", fixed = TRUE),
  function(v) paste(unique(v), collapse = "|"), character(1))

cat("  order alineado al backbone (NETO tras reversiones):",
    sum(grepl("order_desde_snapshot_FishBase_provisional",
              df$metodo_correccion_taxon, fixed = TRUE)), "fila(s)\n")

# ---- 5c-ter. Respaldo familia -> orden para géneros sin backbone ----
fam_ord <- taxa_snapshot %>% select(Family, Order) %>% distinct() %>%
  group_by(Family) %>% filter(n() == 1L) %>% ungroup()
gen_fam_unico <- df %>% filter(genus != "", family != "") %>%
  distinct(genus, family) %>% count(genus) %>% filter(n == 1) %>% pull(genus)

idx <- which(df$genus %in% gen_fam_unico & !(df$genus %in% backbone$Genus) & df$family != "")
n_o <- 0
for (i in idx) {
  fb <- fam_ord %>% filter(Family == df$family[i]); if (nrow(fb) != 1) next
  ord <- sub("/.*$", "", fb$Order[1])
  if (!grepl("^[A-Z][a-z]+iformes$", ord)) next
  if (!is.na(df$order[i]) && df$order[i] == ord) next
  df$order[i] <- ord; n_o <- n_o + 1
  anotar(i, "order_derivado_de_family_genero_fuera_del_backbone")
}
cat("order derivado de la familia (genero fuera del backbone):", n_o, "fila(s)\n")

# ---- 5c-quater. Orden para determinaciones a nivel de familia ----
fam_ord_archivo <- df %>% filter(family != "", order != "") %>%
  distinct(family, order) %>% add_count(family) %>% filter(n == 1) %>% select(-n)

idx <- which(df$family != "" & (is.na(df$order) | df$order == "") &
             (is.na(df$genus)  | df$genus  == ""))
n_q <- 0
for (i in idx) {
  fa <- fam_ord_archivo$order[fam_ord_archivo$family == df$family[i]]
  if (length(fa) == 1) {
    df$order[i] <- fa; n_q <- n_q + 1
    anotar(i, "order_derivado_de_family_en_archivo"); next
  }
  fb <- fam_ord %>% filter(Family == df$family[i]); if (nrow(fb) != 1) next
  ord <- sub("/.*$", "", fb$Order[1])
  if (!grepl("^[A-Z][a-z]+iformes$", ord)) next
  df$order[i] <- ord; n_q <- n_q + 1
  anotar(i, "order_derivado_de_family_backbone")
}
cat("order derivado para determinaciones a nivel de familia:", n_q, "fila(s)\n")

# El orden previo siempre permanece en order_verbatim; no equivale a aprobación curatorial.
df$order_fishbase <- backbone$Order[match(df$genus, backbone$Genus)]
for (i in which(!is.na(df$order_verbatim) & df$order_verbatim != "" &
                  !is.na(df$order) & df$order != df$order_verbatim)) {
  anotar(i, "order_reclasificacion_provisional_requiere_aprobacion")
}
for (i in which((is.na(df$order_verbatim) | df$order_verbatim == "") &
                  !is.na(df$order) & df$order != "")) {
  anotar(i, "order_completado_desde_referencia_no_verificado")
}

# ---- 5d. taxonRank derivado de la forma del nombre ----
vacio <- is.na(df$taxonRank) | df$taxonRank == ""
sn <- trimws(df$scientificName)
es_familia <- grepl("^[A-Z][a-z]+idae$", sn)
es_subfamilia <- grepl("^[A-Z][a-z]+inae$", sn)
es_binomio <- grepl("^[A-Z][a-z]+ [a-z][a-z-]+$", sn)
es_genero  <- grepl("^[A-Z][a-z]+( sp\\.?[0-9]*)?$", sn) & !es_familia & !es_subfamilia

df$taxonRank[vacio & es_binomio] <- "species"
df$taxonRank[vacio & es_genero]  <- "genus"
df$taxonRank[vacio & es_familia] <- "family"
df$taxonRank[vacio & es_subfamilia] <- "subfamily"
for (i in which(vacio & (es_binomio | es_familia | es_subfamilia | es_genero)))
  anotar(i, "taxonRank_derivado_de_scientificName")
cat("taxonRank derivado:", sum(vacio & (es_binomio | es_familia | es_subfamilia | es_genero)),
    "| sin resolver:", sum(is.na(df$taxonRank) | df$taxonRank == ""), "\n")

# ---- 5d-bis. Corregir taxonRank erróneo preexistente ----
incoh_rank <- which(!vacio & es_binomio & df$taxonRank == "genus")
if (length(incoh_rank)) {
  cat("taxonRank='genus' sobre un binomio, corregido a 'species':",
      length(incoh_rank), "fila(s):", paste(df$catalogNumber[incoh_rank], collapse = ", "), "\n")
  df$taxonRank[incoh_rank] <- "species"
  for (i in incoh_rank) anotar(i, "taxonRank_corregido_por_forma_del_nombre")
}

# taxonRank="subfamily" para nombres terminados en -inae.
es_subfamilia <- grepl("^[A-Z][a-z]+inae$", sn)
idx <- which(es_subfamilia & df$taxonRank %in% c("family", ""))
if (length(idx)) {
  df$taxonRank[idx] <- "subfamily"
  for (i in idx) anotar(i, "taxonRank_subfamilia")
  cat("taxonRank=subfamily:", length(idx), "fila(s)\n")
}

# ---- 6. Regenerar higherClassification ----
corte <- function(rank) switch(as.character(rank),
  "species"   = c("kingdom","phylum","class","order","family","genus"),
  "genus"     = c("kingdom","phylum","class","order","family"),
  "subfamily" = c("kingdom","phylum","class","order","family"),
  "family"    = c("kingdom","phylum","class","order"),
  c("kingdom","phylum","class","order","family"))
df$higherClassification <- vapply(seq_len(nrow(df)), function(i) {
  cols <- corte(df$taxonRank[i])
  v <- unlist(df[i, cols], use.names = FALSE)
  paste(v[!is.na(v) & v != ""], collapse = "|")
}, character(1))

idx_hc <- which((is.na(df$higherClassification_verbatim) & df$higherClassification != "") |
                (!is.na(df$higherClassification_verbatim) & df$higherClassification != df$higherClassification_verbatim))
if (length(idx_hc)) {
  for (i in idx_hc) anotar(i, "higherClassification_regenerado")
}

# ---- 7. Marcar registros sin metadatos ----
df$registro_incompleto <- with(df,
  (is.na(recordedBy)|recordedBy=="") & (is.na(eventDate)|eventDate=="") &
  (is.na(locality)|locality=="")     & (is.na(country)|country==""))
cat("registros incompletos marcados:", sum(df$registro_incompleto), "\n")

# ---- 7b. Filas sin ningún dato taxonómico ----
df$flag_sin_taxonomia <- with(df,
  (is.na(scientificName) | scientificName == "") &
  (is.na(genus)  | genus  == "") &
  (is.na(family) | family == "") &
  (is.na(class)  | class  == ""))
cat("filas sin ningún dato taxonómico:", sum(df$flag_sin_taxonomia), "\n")

# ---- 8. Marcar scientificName que contiene un nombre de familia ----
df$flag_nombre_es_familia <- grepl("^\\s*\\w+(idae|inae)\\s*$", df$scientificName)
cat("scientificName con nombre de familia:", sum(df$flag_nombre_es_familia), "\n")

# ---- 8b. Familia minoritaria dentro del género ----
sub <- df %>% filter(genus != "", family != "")
# Desempate determinista usando FishBase.
fam_cuenta <- sub %>% count(genus, family, name = "n_filas")
fam_may <- fam_cuenta %>%
  group_by(genus) %>%
  mutate(n_max = max(n_filas), empate = sum(n_filas == n_max) > 1) %>%
  filter(n_filas == n_max) %>%
  left_join(backbone %>% select(genus = Genus, family_backbone = Family), by = "genus") %>%
  mutate(prioridad = ifelse(empate & !is.na(family_backbone) &
                            family == family_backbone, 0L, 1L)) %>%
  arrange(genus, prioridad) %>%
  slice(1) %>%
  ungroup() %>%
  select(genus, family_mayoritaria = family)

n_emp <- fam_cuenta %>% group_by(genus) %>%
  summarise(empate = sum(n_filas == max(n_filas)) > 1, .groups = "drop") %>%
  filter(empate) %>% pull(genus)
if (length(n_emp))
  cat("géneros con empate en la familia mayoritaria (desempatados por backbone):",
      paste(n_emp, collapse = ", "), "\n")
ord_fam <- sub %>% filter(order != "") %>% count(family, order) %>%
  group_by(family) %>% filter(n == max(n)) %>% filter(n() == 1L) %>% ungroup() %>%
  select(family, orden_de_la_familia = order)

df <- df %>%
  left_join(fam_may, by = "genus") %>%
  left_join(ord_fam, by = "family") %>%
  left_join(ord_fam %>% rename(family_mayoritaria = family,
                               orden_mayoritario = orden_de_la_familia),
            by = "family_mayoritaria")

df$flag_family_minoritaria <- with(df,
  genus != "" & family != "" & !is.na(family_mayoritaria) &
  family != family_mayoritaria)
df$flag_family_orden_discrepante <- with(df,
  flag_family_minoritaria & !is.na(orden_de_la_familia) &
  !is.na(orden_mayoritario) & orden_de_la_familia != orden_mayoritario)

cat("familia minoritaria en el género:", sum(df$flag_family_minoritaria), "fila(s)\n")
cat("  de ellas, de otro orden (error probable):",
    sum(df$flag_family_orden_discrepante), "fila(s)\n")
if (any(df$flag_family_orden_discrepante))
  print(df[df$flag_family_orden_discrepante,
           c("catalogNumber","scientificName","genus","family","family_mayoritaria")])

df <- df %>% select(-orden_de_la_familia, -orden_mayoritario, -family_mayoritaria)

# ---- 8b-bis. Familia minoritaria dentro del propio NOMBRE ----
fam_may_nombre <- df %>%
  filter(scientificName != "", family != "") %>%
  count(scientificName, family, name = "n_filas") %>%
  group_by(scientificName) %>%
  slice_max(n_filas, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  select(scientificName, family_mayoritaria_nombre = family)

df <- df %>% left_join(fam_may_nombre, by = "scientificName")
df$flag_family_minoritaria_en_el_nombre <- with(df,
  scientificName != "" & family != "" & !is.na(family_mayoritaria_nombre) &
  family != family_mayoritaria_nombre)
df <- df %>% select(-family_mayoritaria_nombre)

n_nom <- df %>% filter(scientificName != "", family != "") %>%
  group_by(scientificName) %>% summarise(k = n_distinct(family), .groups = "drop") %>%
  filter(k > 1) %>% nrow()
cat("nombres cientificos con mas de una familia:", n_nom,
    "| filas en la minoria del nombre:", sum(df$flag_family_minoritaria_en_el_nombre), "\n")


# ---- 8c. Familia con más de un orden ----
ord_may_fam <- df %>% filter(family != "", order != "") %>%
  count(family, order, name = "n") %>%
  arrange(family, desc(n), order) %>%
  group_by(family) %>% filter(n == max(n)) %>% filter(n() == 1L) %>%
  ungroup() %>% select(family, orden_mayoritario_familia = order)

df <- df %>% left_join(ord_may_fam, by = "family")
df$flag_orden_minoritario_en_familia <- !is.na(df$family) & df$family != "" &
  !is.na(df$order) & df$order != "" & !is.na(df$orden_mayoritario_familia) &
  df$order != df$orden_mayoritario_familia
df <- df %>% select(-orden_mayoritario_familia)
cat("filas con orden minoritario dentro de su familia:",
    sum(df$flag_orden_minoritario_en_familia), "fila(s)\n")
if (any(df$flag_orden_minoritario_en_familia))
  print(df[df$flag_orden_minoritario_en_familia,
           c("catalogNumber","scientificName","genus","family","order")])

df$identificado_a_nivel_familia <- df$flag_nombre_es_familia
df$flag_nombre_es_familia <- NULL

# ---- 8d. Segunda opinión sobre family contra el backbone ----
df <- df %>% left_join(backbone %>% select(Genus, Family) %>%
                         rename(genus = Genus, family_backbone = Family), by = "genus")
df$flag_family_discrepa_backbone <- !is.na(df$family_backbone) &
  df$family != "" & df$family != df$family_backbone

cat("family distinta a la del backbone para el mismo genero:",
    sum(df$flag_family_discrepa_backbone), "fila(s) |",
    "de ellas nuevas (sin flag_family_minoritaria):",
    sum(df$flag_family_discrepa_backbone & !df$flag_family_minoritaria), "\n")
print(df %>% filter(flag_family_discrepa_backbone & !flag_family_minoritaria) %>%
        count(genus, family, family_backbone, name = "filas") %>% arrange(desc(filas)),
      n = 50)

# ---- 8e. occurrenceStatus: evidencia biológica, separada de la calidad ----
# Los campos geográficos, incluido continent, pertenecen a la Fase 2 y se preservan.

# Presencia se deriva de la evidencia del espécimen, no de la completitud taxonómica.
if (!"occurrenceStatus" %in% names(df)) df$occurrenceStatus <- NA_character_
sin_estado <- is.na(df$occurrenceStatus) | trimws(df$occurrenceStatus) == ""
evidencia_especimen <- df$basisOfRecord %in% c("PreservedSpecimen", "FossilSpecimen", "LivingSpecimen") &
  nz(df$catalogNumber) != "" & nz(df$id) != ""
derivar_presencia <- sin_estado & evidencia_especimen
df$occurrenceStatus[derivar_presencia] <- "present"
cat("occurrenceStatus derivado de evidencia de especimen:", sum(derivar_presencia), "\n")

# Anotar únicamente la presencia derivada en esta fase.
for (i in which(derivar_presencia)) anotar(i, "occurrenceStatus_derivado_de_especimen")
cat("  anotaciones de presencia derivada:",
    sum(grepl("occurrenceStatus_derivado",
              df$metodo_correccion_taxon)), "\n")

# ---- Contraste contra GBIF: snapshot por defecto; actualización sólo explícita ----
nombres <- df %>% filter(!is.na(scientificName), scientificName != "") %>%
  select(name = scientificName, scientificNameAuthorship, kingdom, phylum, class, order, family, genus) %>%
  distinct()
# No seleccionar silenciosamente una jerarquía de consulta entre registros contradictorios.
# El snapshot normalizado se enlaza por nombre; las contradicciones permanecen en el core.
nombres_consulta <- nombres %>% select(name) %>% distinct()
if (ACTUALIZAR_REFERENCIAS) {
  respuesta_gbif <- rgbif::name_backbone_checklist(nombres_consulta, kingdom = "Animalia",
                                                 strict = TRUE, verbose = FALSE)
  requeridos <- c("verbatim_name", "matchType")
  if (!all(requeridos %in% names(respuesta_gbif))) stop("Respuesta GBIF incompleta.")
  if ("processingFlags" %in% names(respuesta_gbif) &&
      grepl("ERROR|TIMEOUT", jsonlite::toJSON(respuesta_gbif$processingFlags), ignore.case = TRUE)) {
    stop("GBIF comunicó errores de procesamiento; no se publica una salida parcial.")
  }
  campo <- function(nombre) if (nombre %in% names(respuesta_gbif)) as.character(respuesta_gbif[[nombre]]) else rep(NA_character_, nrow(respuesta_gbif))
  campo_aceptado <- intersect(c("accepted", "acceptedScientificName", "acceptedCanonicalName"),
                             names(respuesta_gbif))
  aceptado <- if (length(campo_aceptado)) campo(campo_aceptado[1]) else rep(NA_character_, nrow(respuesta_gbif))
  mb <- tibble(verbatim_name = campo("verbatim_name"), matchType = campo("matchType"),
    confidence = campo("confidence"), rank = campo("rank"), status = campo("status"),
    canonicalName = campo("canonicalName"), accepted_gbif = aceptado,
    family_gbif = campo("family"), genus_gbif = campo("genus"))
} else {
  mb <- gbif_snapshot
}
columnas_gbif <- c("verbatim_name", "matchType", "confidence", "rank", "status",
                  "canonicalName", "accepted_gbif", "family_gbif", "genus_gbif")
if (!all(columnas_gbif %in% names(mb)) || anyDuplicated(mb$verbatim_name)) {
  stop("Snapshot GBIF sin estructura o identidad de nombres válidas.")
}
faltantes <- setdiff(nombres_consulta$name, mb$verbatim_name)
if (length(faltantes)) stop(paste("Faltan respuestas GBIF; no se publica una salida parcial:", paste(faltantes, collapse = ", ")))
mb <- mb[match(nombres_consulta$name, mb$verbatim_name), ]
if (anyNA(mb$matchType) || any(mb$matchType == "")) stop("GBIF devolvió respuestas incompletas.")
con_match <- mb$matchType != "NONE"
if (any(con_match & (nz(mb$canonicalName) == "" | nz(mb$rank) == "" | nz(mb$status) == ""))) {
  stop("GBIF informó una correspondencia sin los campos taxonómicos necesarios.")
}
# Un taxón aceptado no necesita puntero a otro: su canónico es el aceptado.
aceptado_sin_puntero <- mb$status %in% "ACCEPTED" & nz(mb$accepted_gbif) == ""
mb$accepted_gbif[aceptado_sin_puntero] <- mb$canonicalName[aceptado_sin_puntero]
if (any(mb$status %in% "SYNONYM" & nz(mb$accepted_gbif) == "")) {
  stop("GBIF informó sinónimos sin nombre aceptado; respuesta incompleta.")
}
erratas <- mb %>% filter(matchType %in% c("FUZZY", "VARIANT")) %>%
  transmute(nombre_archivo = verbatim_name, nombre_gbif = canonicalName,
    nombre_aceptado_gbif = accepted_gbif, tipo = matchType, confianza = confidence,
    estado_gbif = status, revisar = case_when(
      status %in% "SYNONYM" ~ "sinonimo; confirmar combinacion aceptada con el curador",
      rank %in% c("FAMILY", "SUBFAMILY") | grepl("inae$", verbatim_name) ~
        "variante_nomenclatural_o_rango; no concluir errata",
      status %in% "ACCEPTED" & rank %in% c("SPECIES", "GENUS") ~
        "posible_errata_ortografica; sugerencia no aplicada",
      TRUE ~ "no_concluyente; revisar correspondencia")) %>%
  left_join(df %>% count(scientificName, name = "filas"),
            by = c("nombre_archivo" = "scientificName")) %>% arrange(desc(filas))
df <- df %>% left_join(erratas %>% select(scientificName = nombre_archivo,
  grafia_sugerida_gbif = nombre_gbif, revisar_gbif = revisar), by = "scientificName") %>%
  left_join(mb %>% transmute(scientificName = verbatim_name, gbif_matchtype = matchType,
    gbif_estado = status, gbif_nombre_aceptado = accepted_gbif), by = "scientificName")
df$flag_grafia_variante_gbif <- df$gbif_matchtype %in% c("FUZZY", "VARIANT")
for (col in c("grafia_sugerida_gbif", "revisar_gbif", "gbif_matchtype", "gbif_estado", "gbif_nombre_aceptado")) {
  df[[col]] <- nz(df[[col]])
}
df$genero_fuera_de_backbone_fishbase <- nz(df$genus) != "" & !(df$genus %in% backbone$Genus)

# flag_family_discrepa_backbone sólo compara con FishBase; no declara un error.
familia_gbif <- mb$family_gbif[match(df$scientificName, mb$verbatim_name)]
tipo_gbif <- mb$matchType[match(df$scientificName, mb$verbatim_name)]
concluyente <- tipo_gbif %in% c("EXACT", "FUZZY", "VARIANT") & nz(familia_gbif) != ""
fb_discrepa <- df$flag_family_discrepa_backbone %in% TRUE
gbif_respalda <- concluyente & nz(familia_gbif) == nz(df$family)
ambas_discrepan <- fb_discrepa & concluyente & !gbif_respalda
fuentes_contradicen <- concluyente & nz(df$family_backbone) != "" &
  nz(familia_gbif) != nz(df$family_backbone)
df$clasificacion_discrepancia_family <- case_when(
  fb_discrepa & gbif_respalda ~ "familia_registro_respaldada_por_GBIF",
  ambas_discrepan ~ "familia_discrepante_ambas_referencias",
  !concluyente | nz(df$family_backbone) == "" | nz(df$family) == "" ~ "sin_correspondencia_concluyente",
  gbif_respalda ~ "familia_concordante",
  TRUE ~ "familia_registro_respaldada_por_FishBase")
df$clasificacion_discrepancia_family[fuentes_contradicen] <- paste0(
  df$clasificacion_discrepancia_family[fuentes_contradicen], ";fuentes_externas_contradictorias")
historica <- fb_discrepa & gbif_respalda
df$clasificacion_discrepancia_family[historica] <- paste0(
  df$clasificacion_discrepancia_family[historica], ";evaluar_clasificacion_historica")
for (i in which(df$catalogNumber %in% c("209", "1591", "3069"))) {
  anotar(i, "Farlowella_grafia_original_respaldada_FishBase_Catalogo_GBIF")
}
for (i in which(df$genus %in% generos_ambiguos)) anotar(i, "genero_con_jerarquias_externas_ambiguas")

if (ACTUALIZAR_REFERENCIAS) {
  dir.create(DIR_REFERENCIAS, recursive = TRUE, showWarnings = FALSE)
  saveRDS(taxa_snapshot, archivo_taxa)
  saveRDS(mb, archivo_gbif)
  saveRDS(list(parametros = list(kingdom = "Animalia", strict = TRUE, verbose = FALSE),
               nombres = nombres_consulta, respuesta = respuesta_gbif),
          file.path(DIR_REFERENCIAS, "gbif_respuesta_completa.rds"))
  manifest$gbif <- list(version_backbone = NA_character_,
    fecha_consulta = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
    parametros = list(kingdom = "Animalia", strict = TRUE, verbose = FALSE),
    advertencia_version = "La respuesta no identifica una version del backbone; se fija por snapshot y hash.")
  manifest$archivos_md5 <- as.list(setNames(unname(tools::md5sum(c(archivo_taxa, archivo_gbif))),
                                           basename(c(archivo_taxa, archivo_gbif))))
  jsonlite::write_json(manifest, archivo_manifest, auto_unbox = TRUE, pretty = TRUE, na = "null")
}
# Metadatos de ejecución fuera del core: no repetir versiones en miles de filas.
dir.create(DIR_REPORTES, recursive = TRUE, showWarnings = FALSE)
manifest$ejecucion <- list(fecha = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
  entrada = ARCHIVO_ENTRADA, entrada_md5 = unname(tools::md5sum(ARCHIVO_ENTRADA)),
  snapshot = DIR_REFERENCIAS, Fishbase_R_md5 = unname(tools::md5sum("scripts/Fishbase.R")),
  rfishbase = as.character(packageVersion("rfishbase")), rgbif = as.character(packageVersion("rgbif")))
stopifnot(nrow(df) == nrow(entrada_original), identical(df$id, entrada_original$id), !anyDuplicated(df$id))
write_csv(erratas, file.path(DIR_REPORTES, "gbif_nombres_difusos.csv"), na = "")
write_csv(mb, file.path(DIR_REPORTES, "gbif_contraste_completo.csv"), na = "")
# jsonlite convierte NULL/listas vacías en {}; NA conserva el desconocido como null.
for (campo in c("version_backbone", "fecha_consulta")) {
  if (length(manifest$gbif[[campo]]) == 0L) manifest$gbif[[campo]] <- NA_character_
}
jsonlite::write_json(manifest, file.path(DIR_REPORTES, "referencias_taxonomicas.json"),
                     auto_unbox = TRUE, pretty = TRUE, na = "null")

write_csv(df, ARCHIVO_SALIDA, na = "")
cat("\nGuardado en", ARCHIVO_SALIDA, "— el archivo de entrada no se modificó.\n")
cat("\n=== CORRECCIONES APLICADAS ===\n")
print(table(df$metodo_correccion_taxon[df$metodo_correccion_taxon != ""]))
