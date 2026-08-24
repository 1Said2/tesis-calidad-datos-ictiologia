# Limpieza de datos — Colección ictiológica MECN-DP (INABIO)

Pipeline completo de limpieza y validación de calidad para el dataset Darwin Core
de la colección ictiológica del Museo Ecuatoriano de Ciencias Naturales (MECN-DP),
administrada por el Instituto Nacional de Biodiversidad (INABIO).

Trabajo de titulación — Ingeniería de Software.

## Estructura del repositorio

```
.
├── docs/                   Documentación de la tesis
│   ├── cuestionario-inabio.md   Preguntas pendientes para el curador
│   └── bitacora-limpieza.md     Bitácora completa de 10 iteraciones
│
├── pipeline-r/             Proyecto RStudio (abrir pipeline-r.Rproj)
│   ├── scripts/            Scripts R del pipeline
│   ├── datos/
│   │   ├── 01_crudos/      Dataset DwCA original (CSVs + XML)
│   │   └── 02_intermedios/ Salidas de cada fase (gitignored)
│   ├── reportes_y_revisiones/  CSVs de reporte para el curador
│   └── renv.lock           Lockfile de dependencias R
│
├── openrefine/             Recetas JSON de OpenRefine (reproducibilidad)
├── dashboard/              Reporte HTML + reglas de validación
└── diagramas/              Diagramas de arquitectura (.drawio)
```

## Cómo reproducir

### Requisitos

- R ≥ 4.x con [renv](https://rstudio.github.io/renv/)
- RStudio (recomendado)
- Python 3.x (solo para `build_dwca_gbif.py`)
- OpenRefine (solo si se necesita re-ejecutar la fase de limpieza textual)

### Pasos

1. Abrir `pipeline-r/pipeline-r.Rproj` en RStudio.
2. Ejecutar `renv::restore()` para instalar dependencias.
3. Ejecutar los scripts en orden:
   - `scripts/UnirIdentificationsOcurrences.R`
   - Importar a OpenRefine y aplicar los JSON de `openrefine/`
   - `scripts/Coordenadas.R`
   - `scripts/Fishbase.R`
   - `scripts/ValidacionPlausibilidad.R`
4. Para validar con GBIF: `cd pipeline-r/datos/01_crudos && python build_dwca_gbif.py`

## Datos

Los datos originales provienen del portal Symbiota del INABIO (exportación DwC-A).
Los CSVs intermedios no se versionan; se regeneran ejecutando el pipeline.
Los shapefiles GADM se descargan automáticamente la primera vez.

## Licencia

Pendiente de definición.
