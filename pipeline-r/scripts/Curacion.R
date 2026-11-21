# =============================================================================
# AplicarCorrecciones.R  ·  Curación y resolución de discrepancias
# =============================================================================
# Aplica sobre el core las correcciones ya decididas con sustento suficiente.
# Corre DESPUES de ValidacionPlausibilidad.R y ANTES del empaquetado del DwCA.
#
# Principio: esta etapa es la UNICA que escribe correcciones sobre el core.
# Toda celda modificada queda anotada. Ninguna celda vacia se rellena con un
# valor estimado. El valor de origen se conserva siempre, en el término verbatim
# oficial de Darwin Core cuando existe, o en una columna propia de auditoría cuando no.
#
# Reglas aplicadas en esta version (6):
#   R1  Altitud puntual escrita en el campo maximo            191 filas
#   R2  Toponimo escrito en locationRemarks con locality vacia 289 filas
#   R3  Coordenada y altitud embebidas en el texto de locality  23 filas
#   R4  locationRemarks identico a locality (campo espejo)        500 filas
#   R5  dia fabricado por el portal (01 sobre verbatim ano-mes)   169 filas
#   R6  geodeticDatum ausente en filas con coordenada            460 filas
#
# Reglas NO aplicadas y su razon: ver bloque final del script.
# =============================================================================

library(readr)
library(dplyr)
library(stringr)

# --- Rutas -------------------------------------------------------------------
ARCHIVO_ENTRADA <- "datos/02_intermedios/ocurrences_con_identifications.csv"
ARCHIVO_SALIDA  <- "datos/02_intermedios/ocurrences_curado.csv"
ARCHIVO_REPORTE <- "reportes_y_revisiones/reporte_correcciones.csv"

# --- Carga -------------------------------------------------------------------
df <- read_csv(ARCHIVO_ENTRADA, col_types = cols(.default = col_character()),
               na = character())
df[is.na(df)] <- ""

n_inicial <- nrow(df)
cat("Filas cargadas:", n_inicial, "\n")

# --- Columnas de anotacion ---------------------------------------------------
# Se crean solo si no existen, para que el script sea reejecutable.
nuevos_campos <- c("verbatimLocality",
                   "locationRemarks_verbatim",
                   "verbatimElevation",
                   "metodo_correccion_curacion",
                   "regla_curacion",
                   "ronda_curacion",
                   "eventDate_portal",
                   "datum_asumido")

for (col in nuevos_campos) {
  if (!col %in% names(df)) df[[col]] <- ""
}

# Unificar las columnas de auditoria si vienen de ejecuciones previas antiguas
if ("metodo_correccion_etapa6" %in% names(df)) {
  df$metodo_correccion_curacion <- ifelse(df$metodo_correccion_etapa6 != "", df$metodo_correccion_etapa6, df$metodo_correccion_curacion)
  df$metodo_correccion_etapa6 <- NULL
}
if ("metodo_correccion_etapa7" %in% names(df)) {
  df$metodo_correccion_curacion <- ifelse(df$metodo_correccion_etapa7 != "", paste(df$metodo_correccion_curacion, df$metodo_correccion_etapa7, sep=" | "), df$metodo_correccion_curacion)
  df$metodo_correccion_curacion <- sub("^ \\| ", "", df$metodo_correccion_curacion)
  df$metodo_correccion_etapa7 <- NULL
}
if ("regla_etapa6" %in% names(df)) {
  df$regla_curacion <- ifelse(df$regla_etapa6 != "", df$regla_etapa6, df$regla_curacion)
  df$regla_etapa6 <- NULL
}
if ("regla_etapa7" %in% names(df)) {
  df$regla_curacion <- ifelse(df$regla_etapa7 != "", paste(df$regla_curacion, df$regla_etapa7, sep=" | "), df$regla_curacion)
  df$regla_curacion <- sub("^ \\| ", "", df$regla_curacion)
  df$regla_etapa7 <- NULL
}

# Acumulador del reporte de cambios
cambios <- tibble(id = character(), catalogNumber = character(),
                  regla = character(), campo = character(),
                  valor_anterior = character(), valor_nuevo = character())

registrar <- function(cambios_df, sub, regla, campo, antes, despues) {
  bind_rows(cambios_df, tibble(
    id = sub$id, catalogNumber = sub$catalogNumber,
    regla = regla, campo = campo,
    valor_anterior = antes, valor_nuevo = despues))
}

anotar <- function(df, filtro, metodo, regla, ronda) {
  df$metodo_correccion_curacion[filtro] <- ifelse(
    df$metodo_correccion_curacion[filtro] == "", metodo,
    paste(df$metodo_correccion_curacion[filtro], metodo, sep = " | "))
  
  df$regla_curacion[filtro] <- ifelse(
    df$regla_curacion[filtro] == "", regla,
    paste(df$regla_curacion[filtro], regla, sep = " | "))
    
  df$ronda_curacion[filtro] <- as.character(ronda)
  df
}

# =============================================================================
# Tabla de Reglas de Curación
# =============================================================================

reglas_curacion <- tibble::tribble(
  ~id_regla, ~ronda, ~campo_objetivo, ~condicion, ~accion, ~respaldo, ~metodo, ~regla_plausibilidad, ~n_esperado, ~sustento,
  
  "R1", 1, "maximumElevationInMeters", 
  quote(minimumElevationInMeters == "" & maximumElevationInMeters != ""),
  function(df, cond) list(minimumElevationInMeters = df$maximumElevationInMeters[cond], maximumElevationInMeters = ""),
  "verbatimElevation", "altitud_movida_max_a_min", "altitud maxima declarada sin altitud minima", 191,
  "En esta coleccion no existe ningun rango real de altitud: 4.519 registros declaran solo el minimo, 191 solo el maximo, y los 2 unicos con ambos los tienen iguales. Las 191 son la misma altitud puntual escrita en el campo equivocado.",

  "R2", 1, "locationRemarks",
  quote(locality == "" & locationRemarks != ""),
  function(df, cond) list(locality = df$locationRemarks[cond], locationRemarks = ""),
  "locationRemarks_verbatim", "locality_promovida_desde_locationRemarks", "locality vacia con locationRemarks poblada", 289,
  "locality estaba vacia y locationRemarks contenia un toponimo inequivoco (Laguna Canangueno, Rio Napo, Sacha Lodge). El propio archivo demuestra que locationRemarks funciona como campo espejo.",

  "R3", 1, "locality",
  quote(str_detect(locality, regex("\\s+\\d{1,2}[NS]\\s+\\d+\\s*/\\s*\\d+\\s+\\d+\\s*msnm\\s*$", ignore_case = TRUE))),
  function(df, cond) list(locality = str_replace(df$locality[cond], regex("\\s+\\d{1,2}[NS]\\s+\\d+\\s*/\\s*\\d+\\s+\\d+\\s*msnm\\s*$", ignore_case = TRUE), "")),
  "verbatimLocality", "locality_recortada_coordenada_embebida", "coordenada o altitud embebida en el texto de localidad", 23,
  "Las 23 filas ya tienen coordenada y altitud en sus campos propios. El texto embebido genera siete valores distintos de locality para el mismo sitio. Se recorta el sufijo.",

  "R4", 1, "locationRemarks",
  quote(locality != "" & locality == locationRemarks & locationRemarks_verbatim == ""),
  function(df, cond) list(locationRemarks = ""),
  "locationRemarks_verbatim", "locationRemarks_espejo_vaciado", "locality y locationRemarks identicos", 500,
  "El campo repetia literalmente el texto de locality. No es informacion adicional sobre el sitio: es una copia.",

  "R5", 1, "eventDate",
  quote(str_detect(verbatimEventDate, "^\\d{4}-\\d{1,2}$") & str_detect(eventDate, "^\\d{4}-\\d{2}-01$")),
  function(df, cond) list(eventDate = str_sub(df$eventDate[cond], 1, 7), day = "", startDayOfYear = ""),
  "eventDate_portal", "dia_fabricado_retirado", "dia fabricado por el portal (01 sobre verbatim ano-mes)", 169,
  "El verbatimEventDate solo trae ano y mes (por ejemplo 2003-8) y el portal completo el dia con 01. Ese 01 no viene de la ficha. Se trunco eventDate al grano probado y se vaciaron day y startDayOfYear.",

  # Diez casos con DMS inválido o signo ambiguo quedaron sin coordenadas en Fase 2.
  "R6", 1, "geodeticDatum",
  quote(decimalLatitude != "" & geodeticDatum == ""),
  function(df, cond) list(
    geodeticDatum = "WGS84", 
    datum_asumido = "TRUE", 
    georeferenceRemarks = ifelse(df$georeferenceRemarks[cond] == "", 
                                 "datum no declarado en el origen: se asume WGS84 por ser el unico datum presente en la coleccion y el de la reproyeccion UTM", 
                                 paste(df$georeferenceRemarks[cond], "datum no declarado en el origen: se asume WGS84 por ser el unico datum presente en la coleccion y el de la reproyeccion UTM", sep = "; "))
  ),
  "", "datum_declarado_por_supuesto", "GEODETIC_DATUM_ASSUMED_WGS84 (validador de GBIF)", 460,
  "La entrada corregida declara WGS84 o EPSG:4326, que utiliza WGS84. Las filas con coordenada y datum vacio se completan bajo el supuesto ya definido, identificado mediante datum_asumido y georeferenceRemarks. Los casos sin coordenadas utilizables no cumplen esta regla."
)

# =============================================================================
# Motor de Ejecución
# =============================================================================

for (i in seq_len(nrow(reglas_curacion))) {
  regla <- reglas_curacion[i, ]
  
  # 1. Evaluar condicion
  cond <- eval(regla$condicion[[1]], envir = df)
  cond[is.na(cond)] <- FALSE
  
  cat(regla$id_regla, " : ", sum(cond), " filas (esperado ", regla$n_esperado, ")\n", sep="")
  stopifnot(sum(cond) == regla$n_esperado)
  
  sub <- df[cond, ]
  
  # 2. Guardar respaldo (si aplica)
  if (regla$respaldo != "") {
    df[[regla$respaldo]][cond] <- sub[[regla$campo_objetivo]]
  }
  
  # 3. Aplicar accion
  nuevos_valores <- regla$accion[[1]](df, cond)
  
  # 4. Registrar cambio celda a celda y aplicar al df principal
  for (campo in names(nuevos_valores)) {
    antes <- sub[[campo]]
    despues <- nuevos_valores[[campo]]
    
    # Nombre exacto para el reporte de plausibilidad o nombre descriptivo
    nombre_regla_reporte <- if(regla$id_regla == "R1") "altitud puntual movida del maximo al minimo" else
                            if(regla$id_regla == "R2") "toponimo promovido de locationRemarks a locality" else
                            if(regla$id_regla == "R3") "coordenada y altitud recortadas del texto de locality" else
                            if(regla$id_regla == "R4") "locationRemarks espejo vaciado" else
                            if(regla$id_regla == "R5") "dia fabricado por el portal retirado" else
                            if(regla$id_regla == "R6") "geodeticDatum declarado por supuesto" else regla$regla_plausibilidad
                            
    cambios <- registrar(cambios, sub, nombre_regla_reporte, campo, antes, despues)
    df[[campo]][cond] <- despues
  }
  
  # 5. Anotar auditoria
  df <- anotar(df, cond, regla$metodo, regla$regla_plausibilidad, regla$ronda)
}

# =============================================================================
# Invariantes
# =============================================================================
cat("\n--- Verificacion de invariantes ---\n")

stopifnot(nrow(df) == n_inicial)
cat("OK  el numero de filas no cambio:", nrow(df), "\n")

n_anotadas <- sum(df$regla_curacion != "")
n_esperadas <- length(unique(cambios$id))
stopifnot(n_anotadas == n_esperadas)
cat("OK  filas anotadas =", n_anotadas, "= filas con cambio registrado\n")

# Ninguna celda vacia se relleno con un valor estimado sin marca:
vaciadas <- sum(cambios$valor_nuevo == "" & cambios$valor_anterior != "")
pobladas <- sum(cambios$valor_nuevo != "" & cambios$valor_anterior == "")
cat("    celdas vaciadas:", vaciadas, " celdas pobladas:", pobladas, "\n")

# El valor de origen quedo respaldado
stopifnot(all(df$verbatimLocality[str_detect(df$regla_curacion, "coordenada o altitud embebida en el texto de localidad")] != ""))
stopifnot(all(df$locationRemarks_verbatim[str_detect(df$regla_curacion, "locality vacia con locationRemarks poblada|locality y locationRemarks identicos")] != ""))
stopifnot(all(df$verbatimElevation[str_detect(df$regla_curacion, "altitud maxima declarada sin altitud minima")] != ""))
cat("OK  el valor de origen quedo respaldado\n")

# Las seis reglas quedan en cero al reevaluar su propia condicion
for (i in seq_len(nrow(reglas_curacion))) {
  regla <- reglas_curacion[i, ]
  cond <- eval(regla$condicion[[1]], envir = df)
  cond[is.na(cond)] <- FALSE
  stopifnot(sum(cond) == 0)
}
cat("OK  las condiciones de las reglas dan cero tras aplicarse\n")

cat("\nValores distintos de locality en las 23 de Limoncocha:",
    length(unique(df$locality[str_detect(df$regla_curacion, "coordenada o altitud embebida en el texto de localidad")])), "(esperado 4)\n")

# El grano temporal quedo coherente con el verbatim.
cond_R5 <- str_detect(df$regla_curacion, "dia fabricado por el portal")
stopifnot(all(str_detect(df$eventDate[cond_R5], "^\\d{4}-\\d{2}$")))
stopifnot(all(df$day[cond_R5] == "" & df$startDayOfYear[cond_R5] == ""))
stopifnot(all(df$eventDate_portal[cond_R5] != ""))
cat("OK  las 169 fechas quedaron al grano probado por el verbatim\n")

# El supuesto de datum quedo trazable fila a fila.
cond_R6 <- str_detect(df$regla_curacion, "GEODETIC_DATUM_ASSUMED_WGS84")
stopifnot(all(df$datum_asumido[cond_R6] == "TRUE"))
stopifnot(all(str_detect(df$georeferenceRemarks[cond_R6], "se asume WGS84")))
cat("OK ", sum(cond_R6), "filas con datum asumido quedaron marcadas y anotadas\n")

cat("\nCoordenadas sin datum declarado:",
    sum(df$decimalLatitude != "" & df$geodeticDatum == ""), "(esperado 0)\n")

# =============================================================================
# Reglas de destino "propio" que NO se aplican, y por que
# =============================================================================
cat("\n--- Hallazgos de destino propio que quedan abiertos a proposito ---\n")

no_aplicadas <- tibble::tribble(
  ~regla, ~filas, ~razon,

  "parroquia repetida como localidad", 193L,
  "Vaciar locality dejaria al registro sin ningun descriptor de sitio. La redundancia con municipality no es falsedad: el valor es correcto, solo poco informativo. Se documenta como redundancia aceptada.",

  "eventDate parcial sin startDayOfYear (grano no diario)", 403L,
  "Es el comportamiento correcto, no un defecto: si eventDate no tiene dia, no hay dia juliano que declarar. Sube de 234 a 403 precisamente porque R5 retiro 169 dias inventados. El aumento es la prueba de que R5 funciono.",

  "ano de colecta atipico para el colector", 253L,
  "Hallazgo estadistico por IQR, no contradiccion logica. Un colector puede tener una campana fuera de su periodo habitual. Corregir aqui seria imponer un supuesto sobre la historia de la coleccion.",

  "sello dcterms:modified fuera de los lotes de carga conocidos", 2L,
  "Metadato generado por Symbiota, no dato de la coleccion. Reescribirlo falsearia la trazabilidad del lote de carga. Va al cuestionario como K1."
)
print(as.data.frame(no_aplicadas))

# =============================================================================
# CÓMO AÑADIR UNA RONDA
# =============================================================================
# Una respuesta del curador se traduce en una fila nueva de la tabla de reglas
# (reglas_curacion) con ronda = 2, no en un script nuevo. Se añade la condicion,
# la accion a aplicar, el campo de respaldo y el sustento, y el bucle la ejecuta
# registrando todo automaticamente.
# =============================================================================

# =============================================================================
# Salidas
# =============================================================================
write_excel_csv(df, ARCHIVO_SALIDA, na = "")
write_excel_csv(cambios, ARCHIVO_REPORTE, na = "")

cat("\n--- Resumen ---\n")
print(cambios %>% count(regla, campo, name = "celdas"))
cat("\nCore corregido :", ARCHIVO_SALIDA, "\n")
cat("Reporte cambios:", ARCHIVO_REPORTE, "\n")
cat("Total de celdas modificadas:", nrow(cambios), "\n")
cat("Total de registros afectados:", length(unique(cambios$id)), "\n")
