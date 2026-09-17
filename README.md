# Limpieza de datos — Colección ictiológica MECN-DP (INABIO)

Pipeline completo de limpieza y validación de calidad para el dataset Darwin Core
de la colección ictiológica del Museo Ecuatoriano de Ciencias Naturales (MECN-DP),
administrada por el Instituto Nacional de Biodiversidad (INABIO).

Trabajo de titulación — Ingeniería de Software.

## Estructura del repositorio

```
.
├── cuestionario-inabio.md        Preguntas y decisiones pendientes para el curador
├── herramientas.py               Orquestador del pipeline
├── requirements.txt              Dependencias de Python
├── LICENSE                       Licencia MIT del codigo
│
├── diagramas/                    ArchiMate, flujo de datos y ecosistema Power BI
├── gbif-validacion/              Informes del validador de GBIF, original y limpio
├── openrefine/Reglas.json        Receta de operaciones de OpenRefine
│
└── pipeline-r/                   Proyecto RStudio (abrir pipeline-r.Rproj)
    ├── scripts/                  Los cuatro scripts de R
    ├── renv.lock                 Lockfile de dependencias de R
    ├── datos/                    No versionado. Se genera localmente
    │   ├── 01_crudos/            Dataset DwC-A original (CSVs + XML)
    │   └── 02_intermedios/       Salidas de cada fase del pipeline
    └── reportes_y_revisiones/    No versionado. CSVs de reporte para el curador
```

## Cómo reproducir

Este proyecto ha sido completamente automatizado usando un script maestro en Python que orquesta todo el pipeline (descargas, limpieza en OpenRefine, ejecución de R, y empaquetado final).

### Requisitos previos

- **Python 3.8+** instalado.
- **R 4.x** instalado.
- **OpenRefine 3.x+** descargado y ejecutándose en tu máquina (debe estar abierto en el puerto 3333).

### Pasos (Flujo automatizado)

1. **Abre una terminal** en la raíz del proyecto.
2. **Prepara tu entorno** instalando todas las dependencias necesarias de Python y R:
   ```bash
   python herramientas.py setup
   ```
   *(Nota: Este comando creará automáticamente un entorno virtual `venv` y restaurará los paquetes de R).*
3. **Activa el entorno virtual** de Python:
   - En Windows: `.\\venv\\Scripts\\activate`
   - En Mac/Linux: `source venv/bin/activate`
4. **¡Ejecuta el pipeline completo!**
   Asegúrate de que OpenRefine esté abierto y corre:
   ```bash
   python herramientas.py all
   ```
   Esto realizará automáticamente las siguientes tareas en estricto orden:
   - Descarga de datos crudos desde Symbiota.
   - Descarga y parseo de división política (DPA INEC).
   - Limpieza automatizada usando el API de OpenRefine.
   - Ejecución de limpieza taxonómica, espacial y plausibilidad usando los scripts de R.
   - Empaquetado final en un archivo Darwin Core Archive (`dataset_dwca.zip`).

*(Si lo prefieres, puedes ejecutar `python herramientas.py` sin argumentos para abrir un menú interactivo y correr cada paso individualmente).*

## Orden de ejecucion

El pipeline se ejecuto en siete etapas. Cada una lee la salida de la anterior.

| Etapa | Herramienta | Archivo que produce |
|---|---|---|
| 1 | OpenRefine, aplicando `openrefine/Reglas.json` | `ocurrences_openrefine.csv` |
| 2 | `Coordenadas.R` | `ocurrences_salida_coordenadas.csv` |
| 3 | `Fishbase.R` | `ocurrences_salida_taxonomia.csv` |
| 4 | `UnirIdentificationsOcurrences.R` | `ocurrences_con_identifications.csv` |
| 5 | `ValidacionPlausibilidad.R` | `reporte_plausibilidad.csv` |
| 6 | `AplicarCorrecciones.R` | `ocurrences_corregido.csv` |
| 7 | `herramientas.py` | `dataset_dwca.zip` (Darwin Core Archive) |

La etapa 5 es de deteccion: mide la calidad del core y produce un reporte de hallazgos, pero no modifica ninguna celda del conjunto de datos. La etapa 6 aplica correcciones según lo hallado. La etapa 7 empaqueta el Darwin Core Archive a partir de la salida de la etapa 6.

## Que no esta en este repositorio y por que

- **Datos crudos e intermedios.** Los datos originales provienen del portal Symbiota del INABIO (exportacion DwC-A). Los CSVs intermedios se regeneran ejecutando el pipeline y ocupan megabytes que no aportan al historial de versiones.
- **Reportes CSV para el curador.** Se publican congelados en el release.
- **Shapefiles de GADM.** Se descargan automaticamente la primera vez que se ejecuta el pipeline.
- **El archivo .pbix.** Es un avance de trabajo, no el entregable de la tesis.

El paquete de evidencia fechado se publica como release del repositorio bajo el tag `v1.0-MECN-DP`.

## Licencia

El codigo de este repositorio, que comprende los scripts de R, la receta de OpenRefine y el orquestador en Python, se publica bajo licencia MIT. Los datos pertenecen al INABIO y se rigen por la licencia declarada en el `eml.xml` del Darwin Core Archive.
