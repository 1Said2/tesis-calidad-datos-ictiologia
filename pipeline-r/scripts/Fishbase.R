# ================================================================
# CORRECCIÓN TAXONÓMICA - Colección Ictiológica MECN-DP INABIO
#
# Corrección de errores objetivos (rangos, ortografía, jerarquía).
# No realiza reclasificaciones taxonómicas de especies.
# ================================================================

library(readr); library(dplyr); library(rfishbase)

ARCHIVO_ENTRADA <- "datos/02_intermedios/ocurrences_salida_coordenadas.csv"
ARCHIVO_SALIDA  <- "datos/02_intermedios/ocurrences_salida_taxonomia.csv"

df <- read_csv(ARCHIVO_ENTRADA, col_types = cols(.default = "c"))
cat("Filas:", nrow(df), "\n")

if (!"metodo_correccion_taxon" %in% names(df)) df$metodo_correccion_taxon <- ""
anotar <- function(i, txt) {
  df$metodo_correccion_taxon[i] <<- ifelse(df$metodo_correccion_taxon[i] == "", txt,
                                    paste(df$metodo_correccion_taxon[i], txt, sep = "|"))
}
# Preservar el valor de origen ANTES de tocar nada
for (col in c("kingdom","phylum","class","order","family","scientificName","higherClassification")) {
  vb <- paste0(col, "_verbatim")
  if (!vb %in% names(df)) df[[vb]] <- df[[col]]
}

backbone <- load_taxa() %>% select(Genus, Family, Order, Class) %>%
  distinct(Genus, .keep_all = TRUE)

# Homologación de clases (Teleostei -> Actinopterygii) para evitar conflictos con GBIF.
clase_dwc <- function(x) dplyr::case_when(
  x == "Teleostei"      ~ "Actinopterygii",
  x == "Actinopterygii" ~ "Actinopterygii",
  x == "Elasmobranchii" ~ "Elasmobranchii",
  x == "Holocephali"    ~ "Holocephali",
  TRUE ~ NA_character_)

# ---- 1. kingdom = Plantae: colisión de homónimos ----
# Corrección de géneros zoológicos clasificados erróneamente como botánicos.
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
# Desplazamiento de subfamilias u órdenes ingresados en la columna family.
rango_erroneo <- c(
  "Characinae"        = "Characidae",      # subfamilia
  "Tetragonopterinae" = "Characidae",      # subfamilia
  "Loricariinae"      = "Loricariidae",    # subfamilia
  "Clupeiformes"      = "Engraulidae"      # orden
)
for (mal in names(rango_erroneo)) {
  idx <- which(df$family == mal)
  if (!length(idx)) next
  df$family[idx] <- rango_erroneo[[mal]]
  for (i in idx) anotar(i, "family_rango_incorrecto_corregido")
  cat("  ", mal, "->", rango_erroneo[[mal]], ":", length(idx), "fila(s)\n")
}

# ---- 3. Grafía incorrecta de familia ----
# Normalización ortográfica para familias válidas (distancia de Levenshtein corta).
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
  for (i in idx) anotar(i, "family_grafia_corregida")
  cat("  ", mal, "->", grafia_familia[[mal]], ":", length(idx), "fila(s)\n")
}

# ---- 3b. family con valor que no es una denominación de familia ----
# Vaciado del campo si no cumple con la terminación -idae o -inae.
idx <- which(df$family != "" & !is.na(df$family) &
             !grepl("^[A-Z][a-z]+(idae|inae)$", df$family))
if (length(idx)) {
  cat("family con formato inválido (vaciada para derivar del género):\n")
  print(unique(df$family[idx]))
  df$family[idx] <- ""
  for (i in idx) anotar(i, "family_formato_invalido_vaciada")
}

# ---- 4. Capitalización binomial y uninominal ----
# Aplicación de mayúscula inicial para el género y minúscula para el epíteto.
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
# Normalización ortográfica para géneros documentados en el propio dataset.
grafia_genero <- c(
  "Symbranchus"    = "Synbranchus",     # Synbranchidae
  "Astroblepu"     = "Astroblepus",     # Astroblepidae
  "Andinocara"     = "Andinoacara",     # Cichlidae
  "Limatulichtys"  = "Limatulichthys",  # Loricariidae
  "Lesbiasina"     = "Lebiasina",       # Lebiasinidae
  "Mylosomma"      = "Mylossoma",       # Serrasalmidae
  "Hipostomus"     = "Hypostomus",      # Loricariidae
  "Hypomostus"     = "Hypostomus",      # Loricariidae
  "Chaestostoma"   = "Chaetostoma",     # Loricariidae
  "Cichlosoma"     = "Cichlasoma",      # Cichlidae
  "Cenicichla"     = "Crenicichla",     # Cichlidae
  "Hypetecara"     = "Hypselecara",     # Cichlidae
  "Hemmigrammus"   = "Hemigrammus",     # Characidae
  "Moekhausia"     = "Moenkhausia",     # Characidae
  "Creagutus"      = "Creagrutus",      # Characidae
  "Brachycalcinus" = "Brachychalcinus", # Characidae
  "Phyrulina"      = "Pyrrhulina",      # Lebiasinidae
  "Shyrna"         = "Sphyrna",         # Sphyrnidae
  "Hyphopthalmus"  = "Hypophthalmus",   # Pimelodidae
  "Paradon"        = "Parodon",         # Parodontidae; 6 filas
  "Amphyocharax"   = "Aphyocharax",     # Characidae; 1 fila
  "Carcharthinus"  = "Carcharhinus"     # Carcharhinidae; 2 filas
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

# ---- 4a-bis. Inferencia por mayoría interna ----
# Unificación de géneros no resueltos en FishBase mediante frecuencia interna.
idx <- which(df$genus == "Saxatalia" | grepl("^Saxatalia\\b", df$scientificName))
if (length(idx)) {
  df$genus[idx] <- ifelse(df$genus[idx] == "Saxatalia", "Saxatilia", df$genus[idx])
  df$scientificName[idx] <- sub("^Saxatalia\\b", "Saxatilia", df$scientificName[idx])
  for (i in idx) anotar(i, "genus_grafia_unificada_por_mayoria_interna")
  cat("Saxatalia -> Saxatilia (inferencia por mayoria interna):", length(idx), "fila(s)\n")
}

# ---- 4a-ter. Grafía incorrecta de epíteto específico ----
# Corrección manual de epítetos para pares ortográficos a distancia 1.
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
  "Hemigrammus bellotii"        = "Hemigrammus bellottii",
  "Farlowella oxyrryncha"       = "Farlowella oxyrhyncha"
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

# ---- 4b. Derivación de genus y specificEpithet ----
# Extracción mecánica de términos desde binomios completos.
bin <- regmatches(df$scientificName,
                  regexec("^\\s*([A-Z][a-z]+)\\s+([a-z][a-z\\-]+)\\s*$", df$scientificName))

idx_g <- which((is.na(df$genus) | df$genus == "") & lengths(bin) == 3)
for (i in idx_g) { df$genus[i] <- bin[[i]][2]; anotar(i, "genus_derivado_de_scientificName") }
cat("genus derivado del binomio:", length(idx_g), "fila(s)\n")

idx_e <- which((is.na(df$specificEpithet) | df$specificEpithet == "") & lengths(bin) == 3)
for (i in idx_e) { df$specificEpithet[i] <- bin[[i]][3]; anotar(i, "specificEpithet_derivado_de_scientificName") }
cat("specificEpithet derivado del binomio:", length(idx_e), "fila(s)\n")

# ---- 4b2. Derivar genus desde nombres genéricos o incompletos ----
# Extracción del primer término en determinaciones a nivel de género o con cualificadores.
solo_genero <- grepl("^\\s*[A-Z][a-z]+( sp\\.?[0-9]*)?\\s*$", df$scientificName) &
               !grepl("(idae|inae)\\s*$", df$scientificName)
idx <- which((is.na(df$genus) | df$genus == "") & solo_genero)
for (i in idx) {
  df$genus[i] <- sub("^\\s*([A-Z][a-z]+).*$", "\\1", df$scientificName[i])
  anotar(i, "genus_derivado_de_nombre_generico")
}
cat("genus derivado de nombre de rango genérico:", length(idx), "fila(s)\n")

# ---- 4b3. Genero en nombres con cualificadores (cf., aff., sp.) ----
cualificado <- grepl("\\b(cf\\.?|aff\\.?|gr\\.?|complex|sp\\.? ?nov\\.?)",
                     df$scientificName, ignore.case = TRUE)
idx <- which(cualificado & (is.na(df$genus) | df$genus == "") &
             grepl("^[A-Z][a-z]+\\b", df$scientificName))
for (i in idx) {
  df$genus[i] <- sub("^\\s*([A-Z][a-z]+).*$", "\\1", df$scientificName[i])
  anotar(i, "genus_derivado_de_nombre_con_cualificador")
}
cat("genus derivado de nombre con cualificador:", length(idx), "fila(s)\n")

# Validación de coherencia: genus vs. primer término del binomio.
incoh <- which(lengths(bin) == 3 & df$genus != "" &
               df$genus != vapply(seq_along(bin),
                                  function(i) if (length(bin[[i]]) == 3) bin[[i]][2] else NA_character_,
                                  character(1)))
df$flag_genus_no_coincide_con_nombre <- FALSE
if (length(incoh)) {
  df$flag_genus_no_coincide_con_nombre[incoh] <- TRUE
  cat("ATENCIÓN — genus no coincide con el binomio:", length(incoh), "fila(s)\n")
  print(head(unique(df[incoh, c("scientificName","genus")]), 10))
}

# Validación de coherencia para nombres uninominales frente al campo genus.
uni <- regmatches(df$scientificName,
                  regexec("^\\s*([A-Z][a-z]+)\\s*$", df$scientificName))
incoh_uni <- which(lengths(uni) == 2 & df$genus != "" &
                   !grepl("(idae|inae)\\s*$", df$scientificName) &
                   df$genus != vapply(uni,
                     function(x) if (length(x) == 2) x[2] else NA_character_, ""))
if (length(incoh_uni)) {
  df$flag_genus_no_coincide_con_nombre[incoh_uni] <- TRUE
  cat("ATENCIÓN — genus no coincide con el nombre uninominal:",
      length(incoh_uni), "fila(s)\n")
  print(unique(df[incoh_uni, c("catalogNumber","scientificName","genus")]))
}

incoh_ep <- which(lengths(bin) == 3 & df$specificEpithet != "" &
                  df$specificEpithet != vapply(bin, function(x) if (length(x)==3) x[3] else NA_character_, ""))
df$flag_epiteto_no_coincide_con_nombre <- FALSE
df$flag_epiteto_no_coincide_con_nombre[incoh_ep] <- TRUE

# ---- 4d. Limpieza de cualificadores dentro del scientificName ----
# Se retira el cualificador del nombre (ya existe en identificationQualifier).
idx <- which(grepl("\\bsp\\.?\\s*[0-9]*\\s*$", df$scientificName) &
             df$identificationQualifier != "")
if (length(idx)) {
  df$scientificName[idx] <- trimws(sub("\\s*\\bsp\\.?\\s*[0-9]*\\s*$", "", df$scientificName[idx]))
  for (i in idx) anotar(i, "cualificador_retirado_del_nombre")
  cat("cualificador retirado de scientificName:", length(idx), "fila(s)\n")
}

# Inserción de espacio obligatorio tras el cualificador abreviado (ej. cf. batesii).
idx <- which(grepl("\\b(cf|aff|gr)\\.\\S", df$scientificName))
if (length(idx)) {
  df$scientificName[idx] <- sub("\\b(cf|aff|gr)\\.(\\S)", "\\1. \\2", df$scientificName[idx])
  for (i in idx) anotar(i, "espacio_tras_cualificador")
  cat("espacio insertado tras el cualificador:", length(idx), "fila(s)\n")
}

# ---- 4c. Correcciones ortográficas específicas ----
idx_cren <- which(df$scientificName == "Crenicichlla sedentaria")
if (length(idx_cren)) {
  df$scientificName[idx_cren] <- "Crenicichla sedentaria"
  df$genus[idx_cren] <- "Crenicichla"
  for (i in idx_cren) anotar(i, "scientificName_grafia_corregida_manualmente")
}

# Sincronización de grafías de familia dentro del campo scientificName.
idx_asp <- which(df$scientificName == "Asprenidae")
if (length(idx_asp)) {
  df$scientificName[idx_asp] <- "Aspredinidae"
  for (i in idx_asp) anotar(i, "scientificName_grafia_familia_corregida")
}

# Vaciado manual de familias irremediables para forzar su derivación posterior.
idx_hyp <- which(df$family == "Hyphopthalmidae")
if (length(idx_hyp)) {
  df$family[idx_hyp] <- ""
  for (i in idx_hyp) anotar(i, "family_inexistente_vaciada")
}

# ---- 5. Completar class y order desde el backbone ----
# Derivación desde una fuente autoritativa a partir del género. No es
# imputación: el valor se recupera, no se estima. Los géneros que no
# resuelven quedan vacíos y se reportan.
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

# Segundo intento: si el genero no esta en el backbone, la clase se sigue
# de la familia. Es la misma derivacion, un nivel mas arriba.
fam_cls <- backbone %>% distinct(Family, Class)
falta2 <- which((is.na(df$class) | df$class == "") & df$family != "")
for (i in falta2) {
  fb <- fam_cls %>% filter(Family == df$family[i]); if (nrow(fb) != 1) next
  cl <- clase_dwc(fb$Class[1]); if (is.na(cl)) next
  df$class[i] <- cl; anotar(i, "class_derivada_de_family")
}

# ---- 5b. Cerrar huecos de coherencia interna ----
# Derivación mecánica de reino y filo a partir de clase conocida.
idx <- which(df$class %in% c("Actinopterygii","Elasmobranchii","Holocephali") &
             (is.na(df$kingdom) | df$kingdom == ""))
if (length(idx)) {
  df$kingdom[idx] <- "Animalia"; df$phylum[idx] <- "Chordata"
  for (i in idx) anotar(i, "kingdom_phylum_derivados_de_class")
  cat("kingdom/phylum completados:", length(idx), "fila(s)\n")
}

# Derivación de familia: se prioriza la familia predominante del mismo
# género dentro del archivo, usando FishBase solo como respaldo.
fam_en_archivo <- df %>%
  filter(genus != "", family != "") %>%
  count(genus, family, name = "n") %>%
  arrange(genus, desc(n), family) %>%          # desempate determinista
  group_by(genus) %>% slice_max(n, n = 1, with_ties = FALSE) %>%
  ungroup() %>% select(genus, family_en_archivo = family)

idx <- which((is.na(df$family) | df$family == "") & !is.na(df$genus) & df$genus != "")
n_f <- 0; n_fb <- 0
for (i in idx) {
  fa <- fam_en_archivo$family_en_archivo[fam_en_archivo$genus == df$genus[i]]
  if (length(fa) == 1) {
    df$family[i] <- fa; n_f <- n_f + 1
    anotar(i, "family_derivada_de_genus_en_archivo")
  } else {
    fb <- backbone %>% filter(Genus == df$genus[i]); if (nrow(fb) != 1) next
    df$family[i] <- fb$Family[1]; n_fb <- n_fb + 1
    anotar(i, "family_derivada_de_genus_backbone")
  }
}
cat("family completada desde el archivo:", n_f, "| desde el backbone:", n_fb, "fila(s)\n")

# Clados informales: se extrae el orden válido antes de la barra; 
# los clados sin sufijo -iformes se revierten al valor original.
if (!"order_fishbase_informal" %in% names(df)) df$order_fishbase_informal <- ""
idx <- which(grepl("/", df$order))
if (length(idx)) {
  df$order_fishbase_informal[idx] <- df$order[idx]
  raiz <- sub("/.*$", "", df$order[idx])
  origen_formal <- grepl("^[A-Z][a-z]+iformes$", df$order_verbatim[idx])
  valido <- grepl("^[A-Z][a-z]+iformes$", raiz) & !origen_formal
  df$order[idx] <- ifelse(valido, raiz, df$order_verbatim[idx])
  for (i in idx) anotar(i, "order_informal_reducido_a_orden_valido")
  cat("ordenes informales normalizados:", length(idx),
      "| revertidos al verbatim:", sum(!valido), "\n")
}

# ---- 5c. Unificación de órdenes por género ----
# Consolidación del orden mediante FishBase para géneros con discrepancias.
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

# ---- 5c-bis. Autoridad única para order ----
# Imposición sistemática del orden desde FishBase para todos los géneros resueltos.
idx <- which(df$genus != "")
n_ord <- 0
for (i in idx) {
  fb <- backbone %>% filter(Genus == df$genus[i]); if (nrow(fb) != 1) next
  if (!is.na(df$order[i]) && df$order[i] == fb$Order[1]) next
  df$order[i] <- fb$Order[1]; n_ord <- n_ord + 1
  anotar(i, "order_desde_backbone_autoridad_unica")
}
cat("order alineado al backbone:", n_ord, "fila(s)\n")

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

# ---- 5c-quinquies. Retiro de anotación de autoridad única revertida ----
# Una celda que termina igual que como entró no puede declarar que fue alineada al backbone.
idx_rev <- which(grepl("order_desde_backbone_autoridad_unica", df$metodo_correccion_taxon,
                   fixed = TRUE) & df$order == df$order_verbatim)
df$metodo_correccion_taxon[idx_rev] <- gsub(
  "\\|?order_desde_backbone_autoridad_unica", "", df$metodo_correccion_taxon[idx_rev])
df$metodo_correccion_taxon[idx_rev] <- sub("^\\|", "", df$metodo_correccion_taxon[idx_rev])
cat("  anotaciones de autoridad unica retiradas por reversion:", length(idx_rev), "\n")

df$metodo_correccion_taxon <- vapply(strsplit(df$metodo_correccion_taxon, "|", fixed = TRUE),
  function(v) paste(unique(v), collapse = "|"), character(1))

# ---- 5c-ter. Respaldo familia -> orden para géneros sin backbone ----
# Derivación de orden a partir de la familia (solo si la familia es única para el género).
fam_ord <- load_taxa() %>% select(Family, Order) %>% distinct(Family, .keep_all = TRUE)
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
# Derivación directa de orden desde la familia, evaluando primero
# la consistencia interna y luego FishBase.
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

# ---- 5d. taxonRank derivado de la forma del nombre ----
# El orden importa: es_genero también captura los nombres terminados en
# idae/inae, así que la familia se evalúa DESPUÉS y con exclusión explícita.
vacio <- is.na(df$taxonRank) | df$taxonRank == ""
sn <- trimws(df$scientificName)
es_familia <- grepl("^[A-Z][a-z]+(idae|inae)$", sn)
es_binomio <- grepl("^[A-Z][a-z]+ [a-z][a-z-]+$", sn)
es_genero  <- grepl("^[A-Z][a-z]+( sp\\.?[0-9]*)?$", sn) & !es_familia

df$taxonRank[vacio & es_binomio] <- "species"
df$taxonRank[vacio & es_genero]  <- "genus"
df$taxonRank[vacio & es_familia] <- "family"
for (i in which(vacio & (es_binomio | es_familia | es_genero)))
  anotar(i, "taxonRank_derivado_de_scientificName")
cat("taxonRank derivado:", sum(vacio & (es_binomio | es_familia | es_genero)),
    "| sin resolver:", sum(is.na(df$taxonRank) | df$taxonRank == ""), "\n")

# ---- 5d-bis. Corrección de taxonRank erróneo preexistente ----
# Si el origen trae 'genus' pero el nombre es un binomio completo, se corrige a 'species'.
incoh_rank <- which(!vacio & es_binomio & df$taxonRank == "genus")
if (length(incoh_rank)) {
  cat("taxonRank='genus' sobre un binomio, corregido a 'species':",
      length(incoh_rank), "fila(s):", paste(df$catalogNumber[incoh_rank], collapse = ", "), "\n")
  df$taxonRank[incoh_rank] <- "species"
  for (i in incoh_rank) anotar(i, "taxonRank_corregido_por_forma_del_nombre")
}

# Asignación de taxonRank="subfamily" para nombres terminados en -inae.
es_subfamilia <- grepl("^[A-Z][a-z]+inae$", sn)
idx <- which(es_subfamilia & df$taxonRank %in% c("family", ""))
if (length(idx)) {
  df$taxonRank[idx] <- "subfamily"
  for (i in idx) anotar(i, "taxonRank_subfamilia")
  cat("taxonRank=subfamily:", length(idx), "fila(s)\n")
}

# ---- 6. Regenerar higherClassification ----
# Reconstrucción de la jerarquía completa a partir de los campos atómicos curados.
# Darwin Core: higherClassification termina en el rango inmediatamente superior al taxon del registro.
corte <- function(rank) switch(as.character(rank),
  "species"   = c("kingdom","phylum","class","order","family","genus"),
  "genus"     = c("kingdom","phylum","class","order","family"),
  "subfamily" = c("kingdom","phylum","class","order","family"),
  "family"    = c("kingdom","phylum","class","order"),
  c("kingdom","phylum","class","order","family","genus"))
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

# ---- 7. Marcar registros sin metadatos (no se eliminan) ----
df$registro_incompleto <- with(df,
  (is.na(recordedBy)|recordedBy=="") & (is.na(eventDate)|eventDate=="") &
  (is.na(locality)|locality=="")     & (is.na(country)|country==""))
cat("registros incompletos marcados:", sum(df$registro_incompleto), "\n")

# ---- 7b. Filas sin ningún dato taxonómico ----
# Marcado de ejemplares no determinados (sin nombre ni jerarquía taxonómica).
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
# Detección de familias minoritarias. Se distingue entre diferencias
# intra-orden (desdoblamiento taxonómico) e inter-orden (error probable).
sub <- df %>% filter(genus != "", family != "")
# Desempate determinista usando FishBase para evitar aleatoriedad en modas empatadas.
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
  group_by(family) %>% slice_max(n, n = 1, with_ties = FALSE) %>% ungroup() %>%
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
# Mide y marca nombres (binomios) que terminan con múltiples familias distintas.
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
# Detección de inconsistencias cruzadas (órdenes minoritarios dentro de una familia).
ord_may_fam <- df %>% filter(family != "", order != "") %>%
  count(family, order, name = "n") %>%
  arrange(family, desc(n), order) %>%
  group_by(family) %>% slice_max(n, n = 1, with_ties = FALSE) %>%
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

# Conversión de etiqueta de anomalía a clasificación explícita de nivel de familia.
df$identificado_a_nivel_familia <- df$flag_nombre_es_familia
df$flag_nombre_es_familia <- NULL

# ---- 9. Géneros sin correspondencia en el backbone ----
# Exportación de géneros no resueltos para revisión de erratas vs. géneros válidos ausentes.
gen_no_resuelto <- df %>%
  filter(genus != "", !(genus %in% backbone$Genus)) %>%
  count(genus, family, name = "filas") %>% arrange(desc(filas))
if (nrow(gen_no_resuelto)) {
  write_csv(gen_no_resuelto,
            "reportes_y_revisiones/generos_no_resueltos_backbone.csv", na = "")
  cat("\ngéneros sin correspondencia en el backbone:", nrow(gen_no_resuelto), "\n")
  print(gen_no_resuelto)
}

# ---- 8d. Segunda opinion sobre family: el backbone, no la mayoria del genero ----
# NO corrige: L3 sigue vigente, solo se derivan las familias vacias. Marca.
# Esperar que dispare tambien sobre los eventos de reclasificacion conocidos
# (Characidae/Iguanodectidae, Triportheidae/Characidae): la informacion nueva
# esta en las filas que NO lleven ya flag_family_minoritaria.
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
df <- df %>% select(-family_backbone)

# ---- 8. Cierre Darwin Core ----
# Derivación de campos obligatorios del estándar ausentes en el origen.

# 8a. Mapeo de "nativeEndemic" a "native" y preservación en dynamicProperties.
idx <- which(df$establishmentMeans == "nativeEndemic")
df$dynamicProperties[idx] <- '{"establishmentMeansVerbatim":"nativeEndemic","endemismo":"endemico"}'
df$establishmentMeans[idx] <- "native"
cat("establishmentMeans nativeEndemic reasignados a native:", length(idx), "\n")

# 8b. Derivación de continente condicionada a la existencia de país o coordenada.
tiene_anclaje <- (df$country != "" & !is.na(df$country)) |
                 (df$decimalLatitude != "" & !is.na(df$decimalLatitude))
# GBIF flaguea CONTINENT_COORDINATE_MISMATCH en los 24 registros de Galapagos
# porque el archipielago queda fuera de su poligono continental. Se omite el
# termino para ellos: no se afirma lo que la fuente no sostiene.
# stateProvince vacio se lee como NA y "NA == 'Galapagos'" devuelve NA, que el
# ifelse propaga: seis registros con pais o coordenada perdian el continente.
insular <- df$stateProvince %in% "Galápagos"
df$continent <- ifelse(tiene_anclaje & !insular, "South America", "")
cat("continent escrito:", sum(tiene_anclaje & !insular),
    "| omitido por falta de anclaje:", sum(!tiene_anclaje),
    "| omitido por insularidad:", sum(insular), "\n")

# 8c. Asignación de occurrenceStatus (condicionado a completitud del registro).
df$occurrenceStatus <- ifelse(df$registro_incompleto | df$flag_sin_taxonomia,
                              "", "present")
cat("occurrenceStatus escrito:", sum(df$occurrenceStatus != ""),
    "| omitido por falta de taxon o de anclaje:", sum(df$occurrenceStatus == ""), "\n")

write_csv(df, ARCHIVO_SALIDA, na = "")
cat("\nGuardado en", ARCHIVO_SALIDA, "— el archivo de entrada no se modificó.\n")
cat("\n=== CORRECCIONES APLICADAS ===\n")
print(table(df$metodo_correccion_taxon[df$metodo_correccion_taxon != ""]))