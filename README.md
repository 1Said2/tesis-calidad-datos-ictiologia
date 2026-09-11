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
   - En Windows: `.\venv\Scripts\activate`
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

## Datos

Los datos originales provienen del portal Symbiota del INABIO (exportación DwC-A).
Los CSVs intermedios no se versionan; se regeneran ejecutando el pipeline.
Los shapefiles GADM se descargan automáticamente la primera vez.

## Licencia

Pendiente de definición.
