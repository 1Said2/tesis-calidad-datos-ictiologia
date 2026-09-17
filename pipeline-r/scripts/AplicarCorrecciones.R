# =============================================================================
# AplicarCorrecciones.R  ·  Etapa 6 del pipeline
# =============================================================================
# Aplica sobre el core las correcciones ya decididas con sustento suficiente.
# Corre DESPUES de ValidacionPlausibilidad.R y ANTES del empaquetado del DwCA.
#
# Principio: esta etapa es la UNICA que escribe correcciones sobre el core.
# Toda celda modificada queda anotada. Ninguna celda vacia se rellena con un
# valor estimado. El valor de origen se conserva siempre en una columna propia.
#
# Reglas aplicadas en esta version (3):
#   R1  Altitud puntual escrita en el campo maximo            191 filas
#   R2  Toponimo escrito en locationRemarks con locality vacia 289 filas
#   R3  Coordenada y altitud embebidas en el texto de locality  23 filas
# =============================================================================

library(readr)
library(dplyr)
library(stringr)

# --- Rutas -------------------------------------------------------------------
ARCHIVO_ENTRADA <- "datos/02_intermedios/ocurrences_con_identifications.csv"
ARCHIVO_SALIDA  <- "datos/02_intermedios/ocurrences_corregido.csv"
ARCHIVO_REPORTE <- "reportes_y_revisiones/reporte_etapa6.csv"

# --- Carga -------------------------------------------------------------------
df <- read_csv(ARCHIVO_ENTRADA, col_types = cols(.default = col_character()),
               na = character())
df[is.na(df)] <- ""

n_inicial <- nrow(df)
cat("Filas cargadas:", n_inicial, "\n")

# --- Columnas de anotacion ---------------------------------------------------
# Se crean solo si no existen, para que el script sea reejecutable.
nuevas <- c("locality_verbatim",
            "locationRemarks_verbatim",
            "maximumElevationInMeters_verbatim",
            "metodo_correccion_etapa6",
            "regla_etapa6")
for (col in nuevas) if (!col %in% names(df)) df[[col]] <- ""

# Acumulador del reporte de cambios
cambios <- tibble(id = character(), catalogNumber = character(),
                  regla = character(), campo = character(),
                  valor_anterior = character(), valor_nuevo = character())

registrar <- function(cambios, sub, regla, campo, antes, despues) {
  bind_rows(cambios, tibble(
    id = sub$id, catalogNumber = sub$catalogNumber,
    regla = regla, campo = campo,
    valor_anterior = antes, valor_nuevo = despues))
}

anotar <- function(df, filtro, metodo, regla) {
  df$metodo_correccion_etapa6[filtro] <- ifelse(
    df$metodo_correccion_etapa6[filtro] == "", metodo,
    paste(df$metodo_correccion_etapa6[filtro], metodo, sep = " | "))
  df$regla_etapa6[filtro] <- ifelse(
    df$regla_etapa6[filtro] == "", regla,
    paste(df$regla_etapa6[filtro], regla, sep = " | "))
  df
}

# =============================================================================
# R1 · Altitud puntual escrita en el campo maximo
# -----------------------------------------------------------------------------
# Sustento: en esta coleccion no existe ningun rango de altitud. 4.519 registros
# declaran solo el minimo, 191 solo el maximo, y los 2 unicos con ambos campos
# los tienen iguales. La convencion interna, con 4.519 casos de respaldo, es
# escribir la altitud puntual en minimumElevationInMeters. Las 191 son la misma
# altitud puntual en el campo equivocado.
# Accion: mover el valor al campo minimo y vaciar el maximo.
# =============================================================================
R1 <- df$minimumElevationInMeters == "" & df$maximumElevationInMeters != ""
cat("R1 altitud       :", sum(R1), "filas (esperado 191)\n")
stopifnot(sum(R1) == 191)

sub <- df[R1, ]
cambios <- registrar(cambios, sub, "altitud puntual movida del maximo al minimo",
                     "minimumElevationInMeters", "", sub$maximumElevationInMeters)
cambios <- registrar(cambios, sub, "altitud puntual movida del maximo al minimo",
                     "maximumElevationInMeters", sub$maximumElevationInMeters, "")

df$maximumElevationInMeters_verbatim[R1] <- df$maximumElevationInMeters[R1]
df$minimumElevationInMeters[R1]          <- df$maximumElevationInMeters[R1]
df$maximumElevationInMeters[R1]          <- ""
df <- anotar(df, R1, "altitud_movida_max_a_min",
             "altitud maxima declarada sin altitud minima")

# =============================================================================
# R2 · Toponimo escrito en locationRemarks con locality vacia
# -----------------------------------------------------------------------------
# Sustento: los 89 valores distintos de locationRemarks en estas filas son
# toponimos inequivocos (Laguna Canangueno, Rio Napo, Sacha Lodge). Ademas el
# propio archivo demuestra que locationRemarks es un campo espejo: 500 registros
# lo tienen identico a locality y 193 repiten la parroquia.
# Accion: promover el valor a locality y vaciar locationRemarks.
# =============================================================================
R2 <- df$locality == "" & df$locationRemarks != ""
cat("R2 locality      :", sum(R2), "filas (esperado 289)\n")
stopifnot(sum(R2) == 289)

sub <- df[R2, ]
cambios <- registrar(cambios, sub, "toponimo promovido de locationRemarks a locality",
                     "locality", "", sub$locationRemarks)
cambios <- registrar(cambios, sub, "toponimo promovido de locationRemarks a locality",
                     "locationRemarks", sub$locationRemarks, "")

df$locationRemarks_verbatim[R2] <- df$locationRemarks[R2]
df$locality[R2]                 <- df$locationRemarks[R2]
df$locationRemarks[R2]          <- ""
df <- anotar(df, R2, "locality_promovida_desde_locationRemarks",
             "locality vacia con locationRemarks poblada")

# =============================================================================
# R3 · Coordenada y altitud embebidas en el texto de locality
# -----------------------------------------------------------------------------
# Sustento: las 23 filas ya tienen decimalLatitude, verbatimCoordinates y
# minimumElevationInMeters poblados con el mismo valor que aparece en el texto,
# de modo que no hay nada que extraer. El texto embebido genera siete valores
# distintos de locality para cuatro sitios reales de la Reserva Biologica
# Limoncocha.
# Accion: recortar el sufijo de coordenada UTM y altitud. No se toca ningun
# otro campo.
# =============================================================================
PATRON_UTM <- "\\s+\\d{1,2}[NS]\\s+\\d+\\s*/\\s*\\d+\\s+\\d+\\s*msnm\\s*$"

R3 <- str_detect(df$locality, regex(PATRON_UTM, ignore_case = TRUE))
cat("R3 embebidas     :", sum(R3), "filas (esperado 23)\n")
stopifnot(sum(R3) == 23)

sub <- df[R3, ]
recortado <- str_replace(sub$locality, regex(PATRON_UTM, ignore_case = TRUE), "")
cambios <- registrar(cambios, sub, "coordenada y altitud recortadas del texto de locality",
                     "locality", sub$locality, recortado)

df$locality_verbatim[R3] <- df$locality[R3]
df$locality[R3]          <- recortado
df <- anotar(df, R3, "locality_recortada_coordenada_embebida",
             "coordenada o altitud embebida en el texto de localidad")

# =============================================================================
# Invariantes
# =============================================================================
cat("\n--- Verificacion de invariantes ---\n")

stopifnot(nrow(df) == n_inicial)
cat("OK  el numero de filas no cambio:", nrow(df), "\n")

n_anotadas <- sum(df$regla_etapa6 != "")
n_esperadas <- length(unique(cambios$id))
stopifnot(n_anotadas == n_esperadas)
cat("OK  filas anotadas =", n_anotadas, "= filas con cambio registrado\n")

# Ninguna celda vacia se relleno con un valor estimado: los tres unicos campos
# que pasan de vacio a poblado lo hacen copiando un valor que ya existia en la
# misma fila, no estimandolo.
vaciadas <- sum(cambios$valor_nuevo == "" & cambios$valor_anterior != "")
pobladas <- sum(cambios$valor_nuevo != "" & cambios$valor_anterior == "")
cat("    celdas vaciadas:", vaciadas, " celdas pobladas desde otra celda:", pobladas, "\n")

stopifnot(all(df$locality_verbatim[R3] != ""))
stopifnot(all(df$locationRemarks_verbatim[R2] != ""))
stopifnot(all(df$maximumElevationInMeters_verbatim[R1] != ""))
cat("OK  el valor de origen quedo respaldado en las tres reglas\n")

cat("\nValores distintos de locality en las 23 de Limoncocha:",
    length(unique(df$locality[R3])), "(esperado 4)\n")

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