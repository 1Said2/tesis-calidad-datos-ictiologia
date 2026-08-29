# ================================================================
# 2/4 - CORRECCIÓN TAXONÓMICA - Colección Ictiológica MECN-DP INABIO
#
# Entrada:  ocurrences_salida_coordenadas.csv (salida de Coordenadas.R)
# Salida:   ocurrences_salida_taxonomia.csv   -> UnirIdentificationsOcurrences.R
#           gbif_nombres_difusos.csv          -> oficio al curador
#           gbif_contraste_completo.csv       -> tablero
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
# Preservar el valor de origen antes de cualquier modificación.
for (col in c("kingdom","phylum","class","order","family","scientificName","higherClassification")) {
  vb <- paste0(col, "_verbatim")
  if (!vb %in% names(df)) df[[vb]] <- df[[col]]
}

backbone <- load_taxa() %>% select(Genus, Family, Order, Class) %>%
  distinct(Genus, .keep_all = TRUE)

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
  for (i in idx) anotar(i, "family_rango_incorrecto_corregido")
  cat("  ", mal, "->", rango_erroneo[[mal]], ":", length(idx), "fila(s)\n")
}

# ---- 3. Grafía incorrecta de familia ----
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

# ---- 4a-bis. Inferencia por mayoría interna (géneros no resueltos en FishBase) ----
idx <- which(df$genus == "Saxatalia" | grepl("^Saxatalia\\b", df$scientificName))
if (length(idx)) {
  df$genus[idx] <- ifelse(df$genus[idx] == "Saxatalia", "Saxatilia", df$genus[idx])
  df$scientificName[idx] <- sub("^Saxatalia\\b", "Saxatilia", df$scientificName[idx])
  for (i in idx) anotar(i, "genus_grafia_unificada_por_mayoria_interna")
  cat("Saxatalia -> Saxatilia (inferencia por mayoria interna):", length(idx), "fila(s)\n")
}

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

# ---- 4e. Testigos independientes contra el scientificName ----
# NO corrige: cuenta testigos (genus+epíteto, taxonID, autoría) y los escribe.
df$nombre_reconstruido_de_atomicos <- ifelse(
  df$genus != "" & df$specificEpithet != "",
  paste(df$genus, df$specificEpithet), NA_character_)

tid_nombre <- df %>% filter(taxonID != "", scientificName != "") %>%
  count(taxonID, scientificName, name = "n") %>%
  group_by(taxonID) %>% slice_max(n, n = 1, with_ties = FALSE) %>%
  ungroup() %>% select(taxonID, nombre_mayoritario_del_taxonID = scientificName)

aut_ref <- df %>% filter(scientificName != "", scientificNameAuthorship != "") %>%
  count(scientificName, scientificNameAuthorship, name = "n") %>%
  group_by(scientificName) %>% slice_max(n, n = 1, with_ties = FALSE) %>%
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
cat("  con 3 testigos (atomicos + taxonID + autoria):",
    sum(df$testigos_contra_scientificName == 3), "\n")
cat("  con 2 testigos:", sum(df$testigos_contra_scientificName == 2), "\n")
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

# ---- 5c-bis. Autoridad única para order (FishBase) ----
idx <- which(df$genus != "")
n_ord <- 0
for (i in idx) {
  fb <- backbone %>% filter(Genus == df$genus[i]); if (nrow(fb) != 1) next
  if (!is.na(df$order[i]) && df$order[i] == fb$Order[1]) next
  df$order[i] <- fb$Order[1]; n_ord <- n_ord + 1
  anotar(i, "order_desde_backbone_autoridad_unica")
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
idx_rev <- which(grepl("order_desde_backbone_autoridad_unica", df$metodo_correccion_taxon,
                   fixed = TRUE) & df$order == df$order_verbatim)
df$metodo_correccion_taxon[idx_rev] <- gsub(
  "\\|?order_desde_backbone_autoridad_unica", "", df$metodo_correccion_taxon[idx_rev])
df$metodo_correccion_taxon[idx_rev] <- sub("^\\|", "", df$metodo_correccion_taxon[idx_rev])
cat("  anotaciones de autoridad unica retiradas por reversion:", length(idx_rev), "\n")

df$metodo_correccion_taxon <- vapply(strsplit(df$metodo_correccion_taxon, "|", fixed = TRUE),
  function(v) paste(unique(v), collapse = "|"), character(1))

cat("  order alineado al backbone (NETO tras reversiones):",
    sum(grepl("order_desde_backbone_autoridad_unica",
              df$metodo_correccion_taxon, fixed = TRUE)), "fila(s)\n")

# ---- 5c-ter. Respaldo familia -> orden para géneros sin backbone ----
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
df <- df %>% select(-family_backbone)

# ---- 8e. Cierre Darwin Core: continent y occurrenceStatus ----
tiene_anclaje <- (df$country != "" & !is.na(df$country)) |
                 (df$decimalLatitude != "" & !is.na(df$decimalLatitude))
# Omitir continent en registros insulares (Galápagos) para evitar CONTINENT_COORDINATE_MISMATCH.
la_ <- suppressWarnings(as.numeric(df$decimalLatitude))
lo_ <- suppressWarnings(as.numeric(df$decimalLongitude))
insular <- df$stateProvince %in% "Galápagos" |
           (!is.na(la_) & !is.na(lo_) &
            la_ >= -1.5 & la_ <= 1.9 & lo_ >= -92.5 & lo_ <= -89)
df$continent <- ifelse(tiene_anclaje & !insular, "South America", "")
cat("continent escrito:", sum(tiene_anclaje & !insular),
    "| omitido por falta de anclaje:", sum(!tiene_anclaje),
    "| omitido por insularidad:", sum(insular), "\n")

df$occurrenceStatus <- ifelse(df$registro_incompleto | df$flag_sin_taxonomia,
                              "", "present")
cat("occurrenceStatus escrito:", sum(df$occurrenceStatus != ""),
    "| omitido por registro incompleto o falta de taxonomia:", sum(df$occurrenceStatus == ""), "\n")

# Anotar cierre Darwin Core.
for (i in which(df$continent != ""))         anotar(i, "continent_derivado_de_pais_o_coordenada")
for (i in which(df$occurrenceStatus != ""))  anotar(i, "occurrenceStatus_derivado_present")
cat("  anotaciones del cierre Darwin Core:",
    sum(grepl("continent_derivado|occurrenceStatus_derivado",
              df$metodo_correccion_taxon)), "\n")

# ---- Contraste contra el backbone de GBIF ----
USAR_API_GBIF <- TRUE
if (USAR_API_GBIF) {
  library(rgbif); library(dplyr); library(readr)

  nombres <- df %>% filter(scientificName != "") %>%
    distinct(scientificName, .keep_all = TRUE) %>%
    select(name = scientificName, scientificNameAuthorship,
           kingdom, phylum, class, order, family, genus)
  stopifnot(!any(duplicated(nombres$name)))

  # Enviar en bloques de 100 para evitar timeout de la API.
  mb_list <- list()
  for (i in seq(1, nrow(nombres), by = 100)) {
    cat(sprintf("  GBIF: procesando %d a %d de %d...\n", i, min(i+99, nrow(nombres)), nrow(nombres)))
    mb_list[[length(mb_list) + 1]] <- name_backbone_checklist(nombres[i:min(i+99, nrow(nombres)), ])
    Sys.sleep(1)
  }
  
  nz <- function(x) ifelse(is.na(x), "", x)
  mb <- bind_rows(mb_list) %>%
    select(verbatim_name, matchType, confidence, rank, status,
           canonicalName,
           accepted_gbif = any_of(c("accepted", "acceptedScientificName",
                                    "acceptedCanonicalName")),
           family_gbif = family, genus_gbif = genus)
  stopifnot("accepted_gbif" %in% names(mb))

  cat("\n=== CONTRASTE CON EL BACKBONE DE GBIF ===\n")
  print(table(mb$matchType))

  # Clasificar variantes y fuzzy matches.
  erratas <- mb %>% filter(matchType %in% c("FUZZY", "VARIANT")) %>%
    transmute(nombre_archivo = verbatim_name, nombre_gbif = canonicalName,
              nombre_aceptado_gbif = accepted_gbif,
              tipo = matchType, confianza = confidence, estado_gbif = status,
              revisar = dplyr::case_when(
                status != "ACCEPTED"
                  ~ "GBIF emparejo con un sinonimo; falta confirmar el nombre aceptado",
                grepl("inae$", verbatim_name)
                  ~ "nombre de rango subfamiliar: GBIF lo resuelve a la familia",
                canonicalName %in% names(grafia_epiteto) |
                sub("^([A-Z][a-z]+ [a-z-]+).*$", "\\1", nz(accepted_gbif)) %in% names(grafia_epiteto)
                  ~ "GBIF propone la grafia que el bloque 4a-ter ya corrigio",
                TRUE ~ "")) %>%
    left_join(df %>% count(scientificName, name = "filas"),
              by = c("nombre_archivo" = "scientificName")) %>%
    arrange(desc(filas))
    
  write_csv(erratas, "reportes_y_revisiones/gbif_nombres_difusos.csv", na = "")

  altos <- mb %>% filter(matchType == "HIGHERRANK") %>%
    transmute(nombre_archivo = verbatim_name, resuelve_a = canonicalName, rango = rank)
  
  cat("nombres con grafia variante:", nrow(erratas),
      "| nombres que solo resuelven al rango superior:", nrow(altos), "\n")

  # Incorporar contraste al archivo de salida.
  df <- df %>%
    left_join(erratas %>%
                select(scientificName = nombre_archivo,
                       grafia_sugerida_gbif = nombre_gbif,
                       revisar_gbif = revisar),
              by = "scientificName")
  df$flag_grafia_variante_gbif <- !is.na(df$grafia_sugerida_gbif) &
                                  nz(df$revisar_gbif) == ""
  df$grafia_sugerida_gbif <- nz(df$grafia_sugerida_gbif)
  
  cat("  filas marcadas con grafia variante segun GBIF:",
      sum(df$flag_grafia_variante_gbif), "\n")

  df <- df %>%
    left_join(mb %>% transmute(scientificName = verbatim_name,
                               gbif_matchtype      = matchType,
                               gbif_estado         = status,
                               gbif_nombre_aceptado = accepted_gbif),
              by = "scientificName")
  df$gbif_matchtype[is.na(df$gbif_matchtype)]           <- ""
  df$gbif_estado[is.na(df$gbif_estado)]                 <- ""
  df$gbif_nombre_aceptado[is.na(df$gbif_nombre_aceptado)] <- ""
  df$genero_fuera_de_backbone_fishbase <-
    !is.na(df$genus) & df$genus != "" & !(df$genus %in% backbone$Genus)

  cat("  contraste GBIF incorporado al archivo:",
      sum(df$gbif_matchtype != ""), "filas |",
      "generos fuera del backbone de FishBase:",
      sum(df$genero_fuera_de_backbone_fishbase), "filas\n")

  write_csv(mb, "reportes_y_revisiones/gbif_contraste_completo.csv", na = "")
  cat("contraste completo exportado:", nrow(mb), "nombres |",
      paste(names(table(mb$matchType)), table(mb$matchType), sep = ": ",
            collapse = " | "), "\n")
}

write_csv(df, ARCHIVO_SALIDA, na = "")
cat("\nGuardado en", ARCHIVO_SALIDA, "— el archivo de entrada no se modificó.\n")
cat("\n=== CORRECCIONES APLICADAS ===\n")
print(table(df$metodo_correccion_taxon[df$metodo_correccion_taxon != ""]))