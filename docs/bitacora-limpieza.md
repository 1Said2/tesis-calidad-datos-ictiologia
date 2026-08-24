> From: https://claude.ai/chat/fb215682-2679-4bdc-9623-9548dcc41687

# you asked

message time: 2026-08-21 15:59:52

Actúa como investigador de calidad de datos del INABIO, especializado en ictiología (colección MECN-DP). Tu tarea es auditar exclusivamente la limpieza de un dataset Darwin Core realizada en OpenRefine.
🚨 RESTRICCIONES ESTRICTAS (LO QUE DEBES IGNORAR COMPLETAMENTE):

* CERO TAXONOMÍA: Ignora de forma absoluta cualquier validación, jerarquía o corrección de nombres científicos, Kingdom, Phylum, Class, Order, Family, Genus, Species, etc. Todo esto se procesará después en RStudio con rfishbase. No generes ni una sola alerta sobre taxonomía.
* CERO COORDENADAS: Ignora coordenadas geográficas (verbatimCoordinates, decimalLatitude, decimalLongitude, geodeticDatum) y cualquier validación espacial.
* CERO ALERTAS DUPLICADAS: No me reportes anomalías que ya estén mapeadas en mi archivo "dudas.md".

🚨 CLÁUSULA DE EXHAUSTIVIDAD EXTREMA (REVISIÓN DEFINITIVA): Esta es la iteración número 10 de limpieza. En las 9 iteraciones previas siempre han aparecido "nuevos" errores que debieron ser detectados desde el principio. Te exijo un barrido absolutamente exhaustivo, microscópico y definitivo. No omitas, resumas, ni guardes ninguna observación para iteraciones futuras. Si existe un error tipográfico, de formato, dobles espacios, espacios al inicio/final, caracteres especiales ocultos, fechas mal formateadas o inconsistencias en cualquier campo (que no esté restringido arriba), debes reportarlos TODOS AHORA, sin excepción. Tu objetivo es garantizar que, tras esta respuesta, no sea necesaria una iteración 11.
📌 HIPÓTESIS BASE DE TRABAJO: Dadas las iteraciones de limpieza previas (contexto en "limpieza.md"), la expectativa técnica es que el dataset ya esté limpio y no queden errores atribuibles a OpenRefine. NO inventes ni fuerces hallazgos solo por contestar. Sin embargo, en virtud de la cláusula de exhaustividad, si encuentras algo real, repórtalo. Si tras tu escrutinio microscópico el barrido está impecable, indícalo directamente como "Dataset limpio / Sin anomalías adicionales".
MATERIAL DE ENTRADA (que te proporcionaré):

* CSV original y CSV limpio.
* JSON de OpenRefine con las reglas aplicadas.
* "limpieza.md" (contexto de errores previos ya solucionados).
* "dudas.md" (mis alertas y dudas actuales).

FASE 1: AUDITORÍA DE LA LIMPIEZA (OPENREFINE)

1. Compara el CSV original vs. el CSV limpio basándote en el JSON de reglas.
2. Verifica que las operaciones no hayan roto datos correctos.
3. Identifica cambios que parezcan excesivos, erróneos o sospechosos. Trabaja con criterio conservador: prioriza la trazabilidad y la exactitud.

FASE 2: REVISIÓN DE DUDAS Y BARRIDO FINAL

1. Revisa mi archivo "dudas.md": evalúa si mis observaciones son correctas y avísame si pasé algo por alto dentro de esas mismas dudas.
2. Realiza el barrido final definitivo buscando TODAS LAS NUEVAS anomalías que sigan existiendo (formatos inconsistentes, errores ortográficos, baja precisión) que no sean taxonómicas, ni espaciales, ni estén en "dudas.md".

FORMATO DE ENTREGA ESPERADO:

* Veredicto Global: ¿La limpieza en OpenRefine fue correcta, parcial o riesgosa?
* Feedback de "dudas.md": Confirmación o corrección de mis dudas documentadas.
* Resumen de Cambios: Qué se modificó por columna y si hubo algún "daño colateral" en la limpieza.
* Nuevas Anomalías Pendientes y Plan de Acción:
   * Si no hay nada nuevo, declara formalmente la etapa de OpenRefine como CERRADA.
   * Si detectas anomalías nuevas reales: genera el bloque de código JSON de OpenRefine para todas aquellas que se puedan solucionar automáticamente. Para los casos ambiguos o complejos que no se puedan automatizar, lístalos detalladamente para enviarlos a revisión manual por parte del equipo de INABIO.

---

# claude response

He auditado el archivo limpio contra el original y contra los 122 pasos del JSON, y después he pasado un barrido completo sobre las 92 columnas. La hipótesis base se sostiene en lo esencial, pero **la etapa no está impecable**: quedan 68 celdas corregibles y una lista de casos nuevos que no están en `Dudas.md`.

---

# 1. VEREDICTO GLOBAL

**LIMPIEZA CORRECTA — cierre condicionado.** Ninguna operación del JSON rompió un dato correcto. Lo que aparece son **residuos de criterios que el propio JSON ya venía aplicando** y **un defecto real de orden de operaciones**.

| Verificación | Resultado |
|---|---|
| Filas × columnas | 6.427 × 92 — idénticas, alineación 100 % por `id` y `catalogNumber` |
| Celdas modificadas | **69.643** en 29 columnas (69.586 de la ronda 9 + 57 nuevas del parche de 84) |
| **Vacío → dato** | **0** — la no imputación se sostiene sin una sola excepción |
| Dato → vacío | 17.079, todas placeholders (17.069 previas + las 10 autorías botánicas) |
| Trazabilidad JSON ↔ celdas | 122 ops → 29 columnas; **0 columnas modificadas sin operación, 0 operaciones sin efecto** |
| Aplicación del parche de la ronda 9 | 84/84 celdas viajaron; 0 residuos de `Afluyente`, `Cormorau`, `Sersacco`, `Bucana`, `Sansahuani`, `Coop.`, `Hda.`, `Pta.`, `CAMP n`, `Schltdl.`, `Wedd.`, `Victor`, `German`, `Alaubí`, `Canonaco`, `Socotoco` |
| Higiene de caracteres (92 col) | 0 mojibake, 0 NBSP, 0 zero-width, 0 controles, 0 espacios dobles/de borde, 0 comillas tipográficas, 0 guiones no estándar, 0 `u0000`, 0 U+FFFD |
| Placeholders residuales (92 col) | **0** |
| Fechas | `eventDate`/`dateIdentified` 100 % ISO; `eventDate ↔ year/month/day ↔ startDayOfYear`: **0 desajustes** |
| Identificadores | `id`, `occurrenceID`, `catalogNumber`, `recordID`, `references` únicos e intactos; `occid == id` en las 6.427 |
| Multivalor `\|` | 0 separadores mal espaciados, 0 duplicados intracelda en 6 columnas |
| Paréntesis/comillas balanceadas | 0 desbalanceos |
| Truncamiento | 0. Las 144 celdas de `recordedBy` con exactamente 200 caracteres son **un solo valor expandido** (175 → 200 al desarrollar los nombres); verificado contra el origen, no es corte de campo |

---

# 2. FEEDBACK DE `Dudas.md`

Todo lo que se pudo contrastar contra el archivo cuadra. Lo que le falta **dentro de sus propias dudas**:

**D10 — la pregunta ya tiene respuesta interna.** Los 2 registros con ambas cotas son el catálogo **4320 (361 / 361)** y el **4452 (224 / 224)**: en los dos, mínimo y máximo son **iguales**. Existe precedente propio para la lectura «altitud puntual». Incorpore las cifras al oficio: la pregunta pasa de abierta a confirmatoria.

**C4 — dos añadidos al bloque de las 23 localidades con coordenada embebida.**
- Los catálogos **2462 y 2463 declaran el mismo par `321429/9957040` con zona distinta: `17N` y `18N`**. Es la misma laguna y el mismo número: una de las dos zonas está mal escrita en el texto. Es una contradicción textual, no un problema de conversión, y conviene preguntarla en el mismo bloque.
- Las 23 celdas escriben `Limoncocha.Laguna`, `Limoncocha.Río`, `Limoncocha.entrada` **sin espacio tras el punto**. Cuando se extraiga la coordenada habrá que normalizar el texto residual; no lo toco ahora porque el bloque entero está pendiente de decisión de INABIO.

**F6 — son cinco registros huecos, no cuatro, y el quinto es el más grave.** El catálogo **4358** no está en su lista y es peor caso que los 4371–4374: declara **`typeStatus = Holotype`** —uno de los dos únicos holotipos de toda la colección— con `stateProvince = Galápagos` y **sin colector, sin fecha, sin localidad, sin número de ejemplares, sin identificador y sin fecha de determinación**. El otro holotipo (cat. 3944, *Microglanis berbixae*, Ibon Tobes) está completo. Un tipo nomenclatural sin datos de colecta es una pregunta curatorial de primer orden, no un hueco más.

**C7 — la familia de códigos embebidos es mayor de lo declarado.** Además de `ICT`, `WAM`, `IC` y `CAMP`, hay `Blq` (57), `OBE` (25), `NPF` (11), `PC24` y `Q/N1`/`Q/N2` (3) dentro de `locality`. Misma pregunta, mismo destino (`fieldNumber` / `eventID`).

**E3 — nota de forma sobre `M. Sánchez`.** Sea cual sea la respuesta de INABIO, hay que fijar convención de espaciado: el archivo escribe `M.E. Sánchez`, `M.G. Sánchez` y `P.A. Buckup` pegadas frente a `J. M. Touzet`, `M. A. Galarza`, `M. H. López`, `J. M. Torres` y `J. P. Reyes` separadas. No colapsa ningún miembro de la dimensión Persona (verificado: 0 grupos), pero es un criterio que hay que declarar.

**Bloque K — le falta una pregunta, y es de las que importan para el ETL.** Ver §4.D.1.

---

# 3. RESUMEN DE CAMBIOS POR COLUMNA

Sin novedad respecto a la ronda anterior salvo el parche de 84 celdas, que se refleja en cinco columnas:

| Columna | Celdas (ronda 9 → hoy) | Qué añadió el parche |
|---|---|---|
| `locality` | 1.075 → **1.103** | 39 abreviaturas/erratas + 4 inferencias toponímicas |
| `locationRemarks` | 1.537 → **1.543** | 4 + 2 por simetría |
| `identifiedBy` | 3.673 → **3.686** | 13 tildes (`Víctor`, `Germán`) |
| `scientificNameAuthorship` | 313 → **323** | 10 autorías botánicas vaciadas |
| `recordedBy` | 3.816 → 3.816 | 14 tildes sobre celdas ya modificadas |

Las 24 columnas restantes están idénticas a la auditoría anterior. **Daño colateral: uno solo**, y es de orden de operaciones (§4.A.1). Dos notas de bitácora que conviene dejar escritas:

1. Las ops **106/107** normalizan `metros` → `m`. Se aplicó a 12 celdas y no queda ni un `metros` residual, pero es una sustitución léxica sobre texto descriptivo libre: debe constar como decisión, no pasar como formato.
2. Las ops **36/37** capitalizan el primer carácter y las **106/107** bajan `Km` → `km`. Las 14 celdas que empiezan en minúscula siguen ahí y **siguen siendo correctas**: gana el criterio de la unidad. Excepción documentada, no deuda.

---

# 4. NUEVAS ANOMALÍAS Y PLAN DE ACCIÓN

## A. Atribuibles a OpenRefine — 4 hallazgos

**1. El único daño colateral real: `río Pitan` (cat. 4949).** La op **77** establece la invariante «genérico en minúscula seguido de nombre propio → capitalizar». La op **96** convierte `ripo` → `río` y **corre después**, así que produjo la única celda del archivo que viola esa invariante. No es un caso especial: es la op 77 que hay que **volver a pasar** al final de la cadena.

**2. `Camp 2 1/2` — 28 celdas.** La op 114 expandió `/\bCAMP\s+(\d)/`, en mayúsculas. `Camp` en caja mixta se le escapó. Mismo criterio, mismo campo, tres veces más celdas que las que sí corrigió.

**3. `Hcda.` — 1 celda (cat. 673).** La op 114 expandió `Hda.` y dejó `Hcda.`. Nota lateral: esa misma celda escribe **«Economista César Quintana» en largo**, lo que resuelve por evidencia interna el `Eco. César Quintana` que la ronda anterior decidió no expandir. Sigue sin expandirse (es tratamiento profesional, criterio ya cerrado), pero ahora el archivo prueba la lectura.

**4. `Campamento 1. Pisorie Setsacco` (cat. 747, 748).** Al corregir `Sersacco` → `Setsacco` el parche dejó estas dos celdas **a un punto de distancia** de las 19 que dicen `Campamento 1 Pisorie Setsacco`. Mismo colector, misma parroquia, mismo `locationRemarks`, fechas 2007-05-23 y 2007-05-25: es el mismo sitio partido en dos miembros de la dimensión Localidad. Precedente directo: la op 50 ya hizo exactamente esto (`Lago Agrio. ` → `Lago Agrio `, `La Balzareña. ` → `La Balzareña `).

## B. Del origen, detectables hoy — 9 hallazgos corregibles

| # | Hallazgo | Celdas | Por qué es seguro corregirlo |
|---|---|---|---|
| 5 | `Laguna Cornorán` → `Cormorán` (cat. 2228–2234) | 7 | Mismo lote, misma provincia, mismo Parque Nacional Sangay–Sardinayacu que las 33 filas que escriben `Cormorán`. Es la `n` por `m`, y el parche anterior ya corrigió `Cormorau` en este mismo cuerpo de agua |
| 6 | `Río Masphi` → `Río Mashpi` (cat. 2214–2219) | 6 | **Contradicción intrarregistro**: la misma fila lleva `locality = Mashpi` y `locationRemarks = Río Masphi`. Idéntico al criterio de `Sansahuani`/`Sansahuari` |
| 7 | `río bulubulu` → `Río Bulubulu` (cat. 2235–2247) | 11 | Nombre propio de río en minúscula. Mismo criterio de la op 108 (`Río blanco` → `Río Blanco`) |
| 8 | `Reserva Producción de Fauna` → `Reserva de Producción de Fauna` (cat. 4508, 4518) | 2 | La op 100 ya fijó la forma canónica al expandir `R.P.F.`; 17 celdas la escriben bien y 2 pierden el «de». Parte la dimensión Localidad en dos miembros |
| 9 | `campamento1` → `Campamento 1` (cat. 1555) | 1 | Sin espacio y en minúscula, criterio de la op 114 |
| 10 | `buenaventura` → `Buenaventura` (cat. 3471) | 1 | Nombre propio en minúscula; el archivo lo capitaliza 15 veces |
| 11 | `granja psicola` → `piscícola` (cat. 2409) | 1 | Errata de palabra común, criterio de la op 61 (`aflunte`, `Artifical`) |
| 12 | `punta km 13+500` → `Punta km` (cat. 5090) | 1 | Trece filas hermanas del mismo sitio escriben `Punta`; la op 77 no dispara porque el siguiente token es minúscula |
| 13 | `NW.Playón` → `NW. Playón` (cat. 2061, 2062) | 2 | Falta el espacio tras la abreviatura |

### JSON — 68 celdas, simulado sobre el archivo limpio

Verificado: **54 celdas en `locality`, 14 en `locationRemarks`**, cero efectos colaterales (`Campo`, `Campamento T.`, `msnm`, `Eco. César Quintana`, `Masphien`, las 23 localidades de C4, `Pacayaku`, `Piñacocha` y los `Cormorán`/`Mashpi` preexistentes quedan intactos; 0 espacios dobles, 0 `Camp n` residual, 0 `Cornorán`, 0 `Masphi`).

```json
[
  {
    "op": "core/text-transform",
    "engineConfig": { "facets": [], "mode": "row-based" },
    "columnName": "locality",
    "expression": "grel:if(isBlank(value), value, value.replace(\"Cornorán\", \"Cormorán\").replace(/\\bMasphi\\b/, \"Mashpi\").replace(/\\bHcda\\.\\s*/, \"Hacienda \").replace(/\\bCamp\\s+(\\d)/, \"Campamento $1\").replace(/\\bcampamento(\\d)/, \"Campamento $1\").replace(/\\bbuenaventura\\b/, \"Buenaventura\").replace(/\\bpsicola\\b/, \"piscícola\").replace(/\\bbulubulu\\b/, \"Bulubulu\").replace(\"Reserva Producción de Fauna\", \"Reserva de Producción de Fauna\").replace(\"Campamento 1. Pisorie Setsacco\", \"Campamento 1 Pisorie Setsacco\").replace(\"NW.Playón\", \"NW. Playón\").replace(/\\bpunta(?=\\s+km)/, \"Punta\").replace(/\\brío(?=\\s+[A-ZÁÉÍÓÚÑ])/, \"Río\"))",
    "onError": "keep-original",
    "repeat": false,
    "repeatCount": 0,
    "description": "locality: residuos de criterios ya aplicados. Cornoran/Masphi por contradiccion intrarregistro y lote; Camp n y Hcda. por simetria con la op 114 (CAMP n, Hda.); Reserva de Produccion de Fauna por la forma canonica que fijo la op 100 al expandir R.P.F.; el punto de Pisorie Setsacco por el precedente de la op 50 (Lago Agrio., La Balzarena.). La ultima regla NO es nueva: es la op 77 reaplicada al final, porque la op 96 (ripo->rio) corre despues y dejo rio Pitan en minuscula."
  },
  {
    "op": "core/text-transform",
    "engineConfig": { "facets": [], "mode": "row-based" },
    "columnName": "locationRemarks",
    "expression": "grel:if(isBlank(value), value, value.replace(\"Cornorán\", \"Cormorán\").replace(/\\bMasphi\\b/, \"Mashpi\").replace(/\\bHcda\\.\\s*/, \"Hacienda \").replace(/\\bCamp\\s+(\\d)/, \"Campamento $1\").replace(/\\bcampamento(\\d)/, \"Campamento $1\").replace(/\\bbuenaventura\\b/, \"Buenaventura\").replace(/\\bpsicola\\b/, \"piscícola\").replace(/\\bbulubulu\\b/, \"Bulubulu\").replace(\"Reserva Producción de Fauna\", \"Reserva de Producción de Fauna\").replace(\"Campamento 1. Pisorie Setsacco\", \"Campamento 1 Pisorie Setsacco\").replace(\"NW.Playón\", \"NW. Playón\").replace(/\\bpunta(?=\\s+km)/, \"Punta\").replace(/\\brío(?=\\s+[A-ZÁÉÍÓÚÑ])/, \"Río\"))",
    "onError": "keep-original",
    "repeat": false,
    "repeatCount": 0,
    "description": "locationRemarks: misma regla por simetria de columna (14 celdas hoy: 7 Cornoran, 6 Masphi, 1 punta km)."
  }
]
```

## C. Para INABIO — sumar al oficio

**C.1 — Catálogo 4358: holotipo sin datos de colecta.** Ver §2. Preguntas: ¿es un tipo real de la colección o un registro de prueba con `typeStatus` mal asignado? ¿Existe la ficha física? Un holotipo sin colector, fecha ni localidad no es publicable en GBIF como tipo.

**C.2 — Dos grafías del mismo río, sin mayoría que decida.** `Río Colimbo` (cat. 3142–3143) y `Río Columbo` (cat. 1653–1655). Mismo país, misma provincia (Morona Santiago), mismo cantón (Morona) y **misma parroquia** (Alshi). 3 contra 2: no unifico por mi cuenta.

**C.3 — `pozo primare` (6) frente a `Pozo Pimare` (5).** Todos en Orellana / Aguarico, Parque Nacional Yasuní, Bloque 31. Mismo pozo escrito de dos formas, una además en minúscula. 6 contra 5 no da mayoría; necesito la denominación oficial del pozo.

**C.4 — `Punta km 13+501` (cat. 5641) frente a `Punta km 13+500` (13 filas).** Todas en Chiruisla, Orellana. Un dígito de diferencia en un lote homogéneo: o son dos puntos reales separados por un metro, o es digitación.

**C.5 — Cinco topónimos que no puedo resolver desde el archivo.**

| Como aparece | Catálogos | Duda |
|---|---|---|
| `Río Mashpi Grande y Chicho` | 3394, 3397 | ¿`Chico`? El archivo tiene `Río Mashpi Grande` suelto (3395) |
| `Masphien` | 2403 | ¿`Mashpi`? Es Pacto, Pichincha, donde está Mashpi, pero no es una errata de una letra |
| `laguna redondo cocha` | 2950–2952 | ¿`Laguna Redondococha`? Son las tres filas peruanas de Maynas |
| `Río átun playa cocha` | 3730–3732 | ¿`Río Atun Playacocha`? Tres palabras kichwas sin unir y con tilde anómala |
| `Salinas.006` | 583 | `0.26-4.66 km de Salinas.006 Puente Palcara`. ¿`.006` es un código de estación pegado al topónimo? |

**C.6 — `Pod` (cat. 59, Orellana) y `ECY` (cat. 5600, 5650).** Localidades de tres letras. `ECY` parece Estación Científica Yasuní; `Pod` no resuelve contra nada del archivo.

**C.7 — Contradicción geográfica nueva (hermana de la de `Numbayme`).** Catálogo **1555**: `locality = Río Aguarico campamento1 Pisorie`, declarado en **Carchi / Tulcán / Tobar Donoso**. El Aguarico y el campamento Pisorie están en Sucumbíos, a más de 300 km, y el resto del lote Pisorie (mismo colector, Juan Francisco Rivadeneira) está en Lago Agrio. O la provincia está mal o la localidad pertenece a otro registro.

## D. Estructural — no es OpenRefine, pero bloquea el modelo

**D.1 — `dcterms:modified` no sirve como marca de agua incremental. 1.506 registros lo prueban.** En 1.506 filas la `dateIdentified` es **posterior** al `modified` del registro: 4.288 registros conservan el sello de 2020 y declaran determinaciones de 2023. El portal no actualiza `modified` cuando cambia el contenido.

Esto le toca directamente el ETL: **descarta `modified` como columna de CDC para la carga incremental del data warehouse**. O se carga completo en cada corrida, o se construye un hash de fila como detector de cambios. Es una decisión de diseño del Capítulo III y conviene que quede escrita con esta cifra detrás. Añádalo al bloque K del oficio: *¿el portal actualiza `dcterms:modified` al redeterminar, o el sello corresponde solo a la carga inicial?*

**D.2 — 289 registros tienen la localidad en el campo equivocado.** `locality` vacía y `locationRemarks` poblada (`Laguna Canangueno` 39, `Laguna Mateococha` 36, `Laguna Aucacocha` 33, `Cuyabeno Lodge` 19…). Sumado a las 491 filas donde ambas columnas son idénticas, la dimensión Localidad no puede construirse sobre `locality` sola: se queda sin 289 miembros que sí existen. Hay que decidir la regla de precedencia (`locality` → si vacía, `locationRemarks`) y documentarla. Solo **224 filas** están realmente sin ninguna descripción de sitio.

**D.3 — `occurrenceID` y `recordID` son idénticos en las 6.427 filas.** No es defecto, es redundancia: en el modelo dimensional basta una, y conviene declarar cuál es la clave natural del hecho.

**D.4 — `country = 'Perú'` en 11 filas.** El criterio L2 llevó los vocabularios controlados a inglés; `country` se quedó en español y solo `Perú` difiere de la forma inglesa. Además **no existe columna `countryCode`**, que es la que GBIF usa para resolver el país sin depender de la coordenada. Decisión suya: o se declara `country` como campo en español (y entonces L2 debe decirlo), o se normaliza y se añade `countryCode`.

## E. Menores — decisión suya, no las toco

- **`min.` (13 celdas) frente a `min` (46).** Misma abreviatura, dos formas. No colapsa ningún miembro porque son localidades distintas.
- **Espaciado de iniciales dobles** (§2, bloque E3).
- **`A 99,4 km NW. Playón`** usa coma decimal; las otras 18 celdas con decimal en texto libre usan punto.
- **`2.5 m. Norte Río Nashiño`** (cat. con `Parque Nacional Yasuní`): la unidad `m.` para una distancia de 2,5 es inverosímil, probablemente `km`. No lo infiero.

## F. Verificado y descartado — para que no vuelva a salir en una ronda 11

Estos cinco parecían hallazgos y **no lo son**. Los dejo escritos con su evidencia para que ningún barrido futuro los reabra:

- **`Pacayaku` (2, Pastaza) vs `Pacayacu` (102, Sucumbíos/Lago Agrio)** — dos parroquias reales distintas, una en Arajuno y otra en Lago Agrio. No se unifican.
- **`Piñacocha` (cat. 6132) vs `Pañacocha` (86)** — el 6132 es Pastaza, `locationRemarks = Río Rutuno`, con coordenada propia en Pastaza. Pañacocha es Sucumbíos. Lugares distintos.
- **`Río Mindo` (Pichincha) vs `Río Pindo` (Pastaza/El Oro)** — dos ríos, no una errata.
- **Las 33 celdas de `scientificNameAuthorship` con `.,`** (`Orcés V., 1967`) — formato ICZN correcto, no puntuación duplicada.
- **Las 144 celdas de `recordedBy` de exactamente 200 caracteres** — un único valor expandido por la limpieza (175 → 200), no truncamiento de campo.

---

## CIERRE

**La etapa de OpenRefine queda CERRADA una vez aplicado el bloque JSON de §4.B — 68 celdas.** Después de eso no queda nada más atribuible a esta fase que sea detectable desde dentro del archivo.

Lo que resta está fuera del alcance de OpenRefine por naturaleza: §4.C es autoridad curatorial, §4.D son decisiones de modelado que corresponden al Capítulo III, y §4.E son criterios de estilo que solo hace falta declarar en la bitácora.

Sigue abierto el único hueco de método que ya declaré: los 116 valores de `county` y los 167 de `municipality` **no están validados contra la codificación DPA vigente del INEC**. Es la última familia de defecto detectable por máquina que no puedo cerrar sin ese CSV externo.

---

# you asked

message time: 2026-08-21 16:59:59

> source("~/Limpieza de datos/Limpieza_Ictiologia/scripts/Limpiar_Coordenadas.R", echo = TRUE)

> # ================================================================
> # LIMPIEZA DE COORDENADAS - Colección Ictiológica MECN-DP INABIO
> # Versión 4  .... [TRUNCATED] 

> library(dplyr)

Adjuntando el paquete: ‘dplyr’

The following objects are masked from ‘package:stats’:

    filter, lag

The following objects are masked from ‘package:base’:

    intersect, setdiff, setequal, union

> library(parzer)

> library(sf)
Linking to GEOS 3.14.1, GDAL 3.12.1, PROJ 9.7.1; sf_use_s2() is TRUE

> sf::sf_use_s2(TRUE)   # necesario para que st_distance devuelva metros en EPSG:4326

> # ---- 0. Configuración ----
> ARCHIVO_ENTRADA <- "datos/02_intermedios/ocurrences_openrefine.csv"

> ARCHIVO_SALIDA  <- "datos/02_intermedios/ocurrences_salida_coordenadas.csv"

> ARCHIVO_REPORTE <- "reportes_y_revisiones/reporte_coordenadas_revision.csv"

> norm_nombre <- function(x) {
+   x <- iconv(x, to = "ASCII//TRANSLIT")
+   x <- tolower(gsub("[^A-Za-z ]", "", x))
+   trimws(gsub("\\s+", " ", x))
 .... [TRUNCATED] 

> # ---- Polígonos administrativos de nivel 1 (GADM 4.1) ----
> # Se descargan una sola vez y quedan cacheados en DIR_REFERENCIA. Requiere
> # los paq .... [TRUNCATED] 

> PAISES_GADM    <- c("ECU", "PER", "VEN")   # Ecuador + los dos transfronterizos

> TOLERANCIA_BORDE_M <- 5000

> dir.create(DIR_REFERENCIA, recursive = TRUE, showWarnings = FALSE)

> cargar_gadm <- function(paises, dir_cache) {
+   if (!requireNamespace("geodata", quietly = TRUE) ||
+       !requireNamespace("terra",   quietly =  .... [TRUNCATED] 

> df <- read_csv(ARCHIVO_ENTRADA, col_types = cols(.default = "c"))
                                                                                                                     
> cat("Filas cargadas:", nrow(df), "\n")
Filas cargadas: 6427 

> # ---- 1. Preservar el origen ANTES de tocar nada (CAMBIO 1) ----
> df$verbatimLatitude  <- df$decimalLatitude

> df$verbatimLongitude <- df$decimalLongitude

> df$decimalLatitude_num  <- suppressWarnings(as.numeric(df$decimalLatitude))

> df$decimalLongitude_num <- suppressWarnings(as.numeric(df$decimalLongitude))

> # ---- 2. Clasificar tipo de verbatimCoordinates ----
> classify_coord <- function(x) {
+   if (is.na(x) || trimws(x) == "") return("vacio")
+   if  .... [TRUNCATED] 

> df$coord_tipo <- sapply(df$verbatimCoordinates, classify_coord)

> es_utm_con_letra <- function(x) !grepl("°", x) & grepl("[0-9](\\.[0-9]+)?\\s*[ENSWensw]", x)

> df$coord_tipo[df$coord_tipo == "dms" & es_utm_con_letra(df$verbatimCoordinates)] <- "utm_o_similar"

> # ---- 2b. CAMBIO C: validación de rango en minutos y segundos ----
> # Un DMS con 075'' o 80' es aritméticamente parseable pero está mal escrito
>  .... [TRUNCATED] 

> df$dms_rango_invalido <- vapply(df$verbatimCoordinates, dms_rango_invalido, logical(1))

> cat("Filas con minutos o segundos >= 60 en el origen:", sum(df$dms_rango_invalido), "\n")
Filas con minutos o segundos >= 60 en el origen: 12 

> # ---- 3. Bounding box: Ecuador continental + Galápagos ----
> in_bbox <- function(lat, lon) {
+   continental <- !is.na(lat) & !is.na(lon) & lat >= .... [TRUNCATED] 

> # ---- 4. Validación de rangos UTM ----
> utm_easting_valido <- function(e) !is.na(e) && e >= 160000 && e <= 840000

> utm_northing_valido <- function(n, epsg) {
+   if (is.na(n)) return(FALSE)
+   if (epsg %in% c(32717, 32718)) return(n >= 9380000 && n <= 10000000)
 .... [TRUNCATED] 

> # ================================================================
> # CAMBIO A (1/2): los polígonos se cargan ANTES del corrector de signo,
> # por .... [TRUNCATED] 

> gadm <- cargar_gadm(PAISES_GADM, DIR_REFERENCIA)
probando la URL 'https://geodata.ucdavis.edu/gadm/gadm4.1/pck/gadm41_ECU_1_pk.rds'
Content type 'unknown' length 7117075 bytes (6.8 MB)
downloaded 6.8 MB

Cached as: datos/00_referencia/gadm/gadm41_ECU_1_pk.rds
probando la URL 'https://geodata.ucdavis.edu/gadm/gadm4.1/pck/gadm41_PER_1_pk.rds'
Content type 'unknown' length 1932917 bytes (1.8 MB)
downloaded 1.8 MB

Cached as: datos/00_referencia/gadm/gadm41_PER_1_pk.rds
probando la URL 'https://geodata.ucdavis.edu/gadm/gadm4.1/pck/gadm41_VEN_1_pk.rds'
Content type 'unknown' length 1101735 bytes (1.1 MB)
downloaded 1.1 MB

Cached as: datos/00_referencia/gadm/gadm41_VEN_1_pk.rds

> if (!is.null(gadm)) {
+   # Alias: stateProvince que no son nivel 1 en su pais.
+   # "Maynas" es provincia peruana dentro del departamento de Loret .... [TRUNCATED] 

> prov_norm_df[is.na(prov_norm_df)] <- ""

> # Union por provincia, calculada una sola vez y reutilizada tanto por el
> # desempate de signo como por la evaluación de coherencia del bloque 14.
 .... [TRUNCATED] 

> if (!is.null(gadm)) {
+   for (p in unique(prov_norm_df[prov_norm_df != ""])) {
+     sel <- gadm[gadm$prov_norm == p, ]
+     if (nrow(sel) > 0) po .... [TRUNCATED] 
Poligonos cargados: 75 | provincias con union: 26 

> # Devuelve TRUE/FALSE si hay polígono para la provincia declarada, NA si no
> # se puede evaluar. NA nunca se interpreta como aprobación.
> en_provi .... [TRUNCATED] 

> # ---- 5. Corrector de swap/signo (CAMBIO A 2/2) ----
> # Regla de precedencia:
> #   1. Si la coordenada de origen ya cae en el bbox, se respeta ta .... [TRUNCATED] 

> # ---- 6. Guardián transfronterizo ----
> regiones_transfronterizas <- c("Apure", "Maynas", "Loreto")

> es_transfronterizo <- df$stateProvince %in% regiones_transfronterizas |
+   (!is.na(df$country) & !df$country %in% c("Ecuador", ""))

> cat("Registros transfronterizos identificados:", sum(es_transfronterizo), "\n")
Registros transfronterizos identificados: 13 

> # ---- 7. Filas con decimalLatitude/Longitude ya pobladas ----
> df$lat_final <- NA_real_; df$lon_final <- NA_real_; df$metodo_correccion <- NA_char .... [TRUNCATED] 

> for (i in seq_len(nrow(df))) {
+   la <- df$decimalLatitude_num[i]; lo <- df$decimalLongitude_num[i]
+   if (is.na(la) || is.na(lo)) { df$metodo_cor .... [TRUNCATED] 

> # ---- 8. Parsers para reconstruir desde verbatimCoordinates ----
> normalize_dms <- function(x) {
+   x <- gsub("´´", '"', x); x <- gsub("''", '"', .... [TRUNCATED] 

> # CAMBIO 2: el northing manda sobre la letra.
> # En UTM el falso norte de 10.000.000 m solo existe en el hemisferio sur, así
> # que un northing >= .... [TRUNCATED] 

> convertir_utm2 <- function(raw) {
+   if (is.na(raw)) return(c(lat = NA, lon = NA, zona = NA))
+   hemisferio <- detectar_hemisferio(raw)
+   raw_cl .... [TRUNCATED] 

> resolve_dms <- function(raw, es_transf, prov_norm = "") {
+   raw_norm <- normalize_dms(raw)
+   partes <- regmatches(raw_norm, regexec("^(.*[NnSs]) ..." ... [TRUNCATED] 

> vacio_idx <- which(df$metodo_correccion == "vacio")

> for (i in vacio_idx) {
+   tipo <- df$coord_tipo[i]; raw <- df$verbatimCoordinates[i]
+   if (is.na(raw) || trimws(raw) == "") next
+   if (tipo ==  .... [TRUNCATED] 

> # ---- 8b. Respaldo: coordenadas sin letra de hemisferio (signo inferido) ----
> intentar_sin_hemisferio <- function(raw, prov_norm = "") {
+   x <- .... [TRUNCATED] 

> pendientes_idx <- which(is.na(df$lat_final) & !is.na(df$verbatimCoordinates) &
+                           trimws(df$verbatimCoordinates) != "")

> for (i in pendientes_idx) {
+   r <- intentar_sin_hemisferio(df$verbatimCoordinates[i], prov_norm_df[i])
+   if (!is.na(r["lat"])) {
+     df$lat_fi .... [TRUNCATED] 

> # ---- 8c. Zona UTM 17S mal asignada en Sucumbíos/Orellana ----
> # Verificado con pyproj y reverificado en la auditoría de la v2: para el mismo
> # .... [TRUNCATED] 

> idx_zona <- which(df$metodo_correccion == "utm_zona_32717" &
+                     df$stateProvince %in% c("Sucumbíos", "Orellana"))

> for (i in idx_zona) {
+   r <- convertir_zona18(df$verbatimCoordinates[i])
+   if (!is.na(r["lat"])) {
+     df$lat_final[i] <- as.numeric(r["lat"]) .... [TRUNCATED] 

> # ---- 9. Centroides de referencia por provincia (solo informativo) ----
> dist_km <- function(lat1, lon1, lat2, lon2) {
+   sqrt(((lat1 - lat2) * 1 .... [TRUNCATED] 

> centroides <- df %>%
+   filter(metodo_correccion %in% c("original", "dms_directo"), !is.na(lat_final)) %>%
+   group_by(stateProvince) %>%
+   summ .... [TRUNCATED] 

> coherente_con_centroide <- function(lat, lon, prov, umbral_km = 150) {
+   if (is.na(lat) || is.na(prov) || !(prov %in% centroides$stateProvince)) r .... [TRUNCATED] 

> df$dist_centroide_km <- mapply(function(la, lo, p) {
+   if (is.na(la) || is.na(p) || !(p %in% centroides$stateProvince)) return(NA_real_)
+   cc <- .... [TRUNCATED] 

> # ---- 10. Recuperación de irreparables con doble validación ----
> # CAMBIO 7: clase de caracteres explícita. En TRE (gsub sin perl=TRUE) la
> # se .... [TRUNCATED] 

> recuperar_decimal_corrupto <- function(raw, prov) {
+   m <- regmatches(raw, regexec("^(-?[0-9]+\\.[0-9]+)\\s+(-?[0-9,]+)$", raw))[[1]]
+   if (leng .... [TRUNCATED] 

> df$metodo_correccion[df$metodo_correccion == "vacio" & is.na(df$lat_final)] <- "irreparable"

> irr_idx <- which(df$metodo_correccion == "irreparable" &
+                    !is.na(df$verbatimCoordinates) & trimws(df$verbatimCoordinates) != "")

> n_rec <- 0

> for (i in irr_idx) {
+   r <- recuperar_northing_truncado(df$verbatimCoordinates[i], df$stateProvince[i])
+   if (is.null(r)) r <- recuperar_decimal .... [TRUNCATED] 

> cat("Filas recuperadas del bloque irreparable:", n_rec, "\n")
Filas recuperadas del bloque irreparable: 6 

> # CAMBIO 6: tres causas distintas de ausencia de coordenada.
> sin_verbatim <- is.na(df$verbatimCoordinates) | trimws(df$verbatimCoordinates) == ""

> sin_decimal  <- is.na(df$decimalLatitude_num)

> df$metodo_correccion[df$metodo_correccion == "irreparable" & sin_verbatim & sin_decimal] <-
+   "sin_dato_origen"

> df$metodo_correccion[df$metodo_correccion == "irreparable" & sin_verbatim & !sin_decimal] <-
+   "descartada_fuera_de_rango"

> # CAMBIO A: bandera explícita de elección de signo no resuelta por polígono.
> df$signo_ambiguo <- !is.na(df$metodo_correccion) & grepl("_ambiguo$", .... [TRUNCATED] 

> cat("Filas con signo ambiguo no resuelto por poligono:", sum(df$signo_ambiguo), "\n")
Filas con signo ambiguo no resuelto por poligono: 14 

> # ---- 11. Nivel de confianza por fila ----
> df$confianza_coordenada <- dplyr::case_when(
+   is.na(df$lat_final) ~ "sin_coordenada",
+   df$metodo .... [TRUNCATED] 

> # ---- 12. Precisión leída del ORIGEN (CAMBIO B) ----
> # La v3 cerraba con return("utm_metro") y convertía en UTM cualquier cadena
> # no reconocid .... [TRUNCATED] 

> df$precision_origen <- mapply(precision_verbatim,
+                               df$verbatimCoordinates, df$verbatimLatitude, df$coord_tipo)

> # ---- 13. coordinateUncertaintyInMeters estimada ----
> df$coordinateUncertaintyInMeters <- dplyr::case_when(
+   is.na(df$lat_final) ~ NA_characte .... [TRUNCATED] 

> # ---- 13b. PARCHE 2: piso tecnologico de la incertidumbre ----
> # Seis decimales son 11 cm y el bloque 13 los traducia a 10 m en 4.249
> # filas.  .... [TRUNCATED] 

> piso_m <- ifelse(is.na(anio_evento) | anio_evento < 2000, 100, 30)

> unc_num  <- suppressWarnings(as.numeric(df$coordinateUncertaintyInMeters))

> unc_piso <- pmax(unc_num, piso_m)

> df$piso_incertidumbre_aplicado <- !is.na(unc_num) & unc_piso > unc_num

> df$coordinateUncertaintyInMeters <- ifelse(is.na(unc_piso), NA_character_,
+                                            as.character(as.integer(unc_ .... [TRUNCATED] 

> df$incertidumbre_criterio <- ifelse(
+   is.na(df$coordinateUncertaintyInMeters), NA_character_,
+   paste0("estimada_desde_precision_origen:", df$p .... [TRUNCATED] 

> cat("  incertidumbre elevada al piso tecnologico:",
+     sum(df$piso_incertidumbre_aplicado, na.rm = TRUE), "\n")
  incertidumbre elevada al piso tecnologico: 4535 

> # ================================================================
> # 14. Coherencia con la provincia por contención en polígono
> # (CAMBIO 3 y 5  .... [TRUNCATED] 

> df$criterio_coherencia     <- NA_character_

> df$dist_fuera_provincia_km <- NA_real_

> df$umbral_km               <- NA_real_

> tiene_coord <- !is.na(df$lat_final)

> if (!is.null(gadm)) {
+   df$criterio_coherencia[tiene_coord] <- "poligono_gadm"
+   pts <- sf::st_as_sf(
+     data.frame(idx = which(tiene_coord), .... [TRUNCATED] 
  reclasificadas como fuera_de_tierra_firme: 9 

> # ---- 14b. Reparto de las discordancias: mecanicas vs. sin explicacion.
> # No corrige ninguna coordenada. Solo responde: ¿invertir el signo de la
 .... [TRUNCATED] 

> for (i in which(df$coherencia_provincia == "discordante")) {
+   p  <- prov_norm_df[i]
+   la <- df$lat_final[i]; lo <- df$lon_final[i]
+   df$disco .... [TRUNCATED] 

> cat("\n=== REPARTO DE LAS DISCORDANCIAS ===\n")

=== REPARTO DE LAS DISCORDANCIAS ===

> print(table(df$discordancia_explicada, useNA = "no"))

           signo_latitud sin_explicacion_mecanica 
                      85                      146 

> print(table(df$stateProvince, df$discordancia_explicada))
                                
                                 signo_latitud sin_explicacion_mecanica
  Apure                                      0                        0
  Azuay                                      0                        0
  Bolívar                                    0                        3
  Cañar                                      0                        0
  Carchi                                     0                        1
  Chimborazo                                 0                        0
  Cotopaxi                                   0                        2
  El Oro                                     0                       11
  Esmeraldas                                80                       13
  Galápagos                                  0                        0
  Guayas                                     0                        1
  Imbabura                                   1                        1
  Loja                                       0                        0
  Loreto                                     0                        0
  Los Ríos                                   0                        0
  Manabí                                     0                        5
  Maynas                                     0                        0
  Morona Santiago                            0                        7
  Napo                                       0                        7
  Orellana                                   2                       14
  Pastaza                                    0                       19
  Pichincha                                  2                       12
  Santa Elena                                0                        0
  Santo Domingo de los Tsáchilas             0                        3
  Sucumbíos                                  0                       44
  Tungurahua                                 0                        3
  Zamora Chinchipe                           0                        0

> # ---- 14c. Northing fuera de rango: ¿un solo digito lo explica? Se prueba solo
> # en las discordancias que produjo nuestra propia conversion UTM.  .... [TRUNCATED] 

> idx <- which(df$coherencia_provincia == "discordante" &
+                df$discordancia_explicada == "sin_explicacion_mecanica" &
+                 .... [TRUNCATED] 

> for (i in idx) {
+   nums <- as.numeric(regmatches(df$verbatimCoordinates[i],
+             gregexpr("[0-9]+\\.?[0-9]*", df$verbatimCoordinates[i])) .... [TRUNCATED] 

> cat("Discordancias con hipotesis de un digito en el northing:",
+     sum(!is.na(df$hipotesis_northing)), "de", length(idx), "\n")
Discordancias con hipotesis de un digito en el northing: 13 de 15 

> # ================================================================
> # CAMBIO 4: coordenada compartida vs provincia minoritaria
> # ================ .... [TRUNCATED] 

> df$clave_coord <- clave

> resumen_clave <- df %>%
+   filter(!is.na(clave_coord), !is.na(stateProvince), stateProvince != "") %>%
+   count(clave_coord, stateProvince, name = .... [TRUNCATED] 

> claves_compartidas <- unique(resumen_clave$clave_coord[resumen_clave$n_prov > 1])

> pares_mayoritarios <- resumen_clave %>%
+   filter(n_filas == n_max) %>%
+   transmute(par = paste(clave_coord, stateProvince, sep = "||")) %>%
+    .... [TRUNCATED] 

> df$coordenada_compartida <- !is.na(df$clave_coord) & df$clave_coord %in% claves_compartidas

> df$provincia_minoritaria <- df$coordenada_compartida &
+   !(paste(df$clave_coord, df$stateProvince, sep = "||") %in% pares_mayoritarios)

> # ---- 15. No declarar precisión sobre una coordenada contradictoria ----
> # Con poligono disponible, la contencion geografica es el criterio; la m .... [TRUNCATED] 

> df$coordinateUncertaintyInMeters[sospechosa] <- NA_character_

> df$incertidumbre_criterio[sospechosa] <- "no_estimable_coordenada_marcada_para_revision"

> df$georeferenceVerificationStatus <- dplyr::case_when(
+   is.na(df$lat_final) ~ NA_character_,
+   sospechosa          ~ "requires verification",
+ .... [TRUNCATED] 

> # ---- 15b. PARCHE 4: la bandera minoritaria viaja al Darwin Core ----
> # El bloque 15 la excluye de "sospechosa" a proposito y esta bien: con
> #  .... [TRUNCATED] 

> cat("  georeferenceRemarks poblado por provincia minoritaria:",
+     sum(df$provincia_minoritaria & !is.na(df$lat_final), na.rm = TRUE), "\n")
  georeferenceRemarks poblado por provincia minoritaria: 56 

> # ---- 15c. La evaluacion de coherencia que no se pudo hacer, o que dio fuera
> # de tierra firme, tambien tiene que viajar. Un registro marino en u .... [TRUNCATED] 

> marca[!is.na(df$lat_final) & df$coherencia_provincia == "fuera_de_tierra_firme"] <-
+   "coordenada fuera del poligono terrestre de la provincia dec ..." ... [TRUNCATED] 

> marca[!is.na(df$lat_final) & df$coherencia_provincia == "no_evaluable"] <-
+   "coherencia con la provincia no evaluable: el registro no declara pro ..." ... [TRUNCATED] 

> df$georeferenceRemarks <- ifelse(
+   is.na(marca), df$georeferenceRemarks,
+   ifelse(is.na(df$georeferenceRemarks) | df$georeferenceRemarks == "", .... [TRUNCATED] 

> cat("  georeferenceRemarks poblado por coherencia no concluyente:",
+     sum(!is.na(marca)), "\n")
  georeferenceRemarks poblado por coherencia no concluyente: 13 

> # ---- 15d. El motivo de la marca tambien tiene que viajar. El bloque 15 pone
> # "requires verification" en 238 filas y el bloque 14b ya sabe por q .... [TRUNCATED] 

> motivo[!is.na(df$lat_final) & df$coherencia_provincia == "discordante" &
+          df$discordancia_explicada == "signo_latitud"] <-
+   "punto fuer ..." ... [TRUNCATED] 

> motivo[!is.na(df$lat_final) & df$coherencia_provincia == "discordante" &
+          df$discordancia_explicada == "sin_explicacion_mecanica"] <-
+    .... [TRUNCATED] 

> motivo[!is.na(df$lat_final) & df$signo_ambiguo] <- ifelse(
+   is.na(motivo[!is.na(df$lat_final) & df$signo_ambiguo]),
+   "el origen no declara hem ..." ... [TRUNCATED] 

> motivo[!is.na(df$lat_final) & df$dms_rango_invalido] <- ifelse(
+   is.na(motivo[!is.na(df$lat_final) & df$dms_rango_invalido]),
+   "el sexagesimal ..." ... [TRUNCATED] 

> df$georeferenceRemarks <- ifelse(
+   is.na(motivo), df$georeferenceRemarks,
+   ifelse(is.na(df$georeferenceRemarks) | df$georeferenceRemarks == "" .... [TRUNCATED] 

> cat("  georeferenceRemarks poblado por motivo de revision:", sum(!is.na(motivo)), "\n")
  georeferenceRemarks poblado por motivo de revision: 238 

> # CAMBIO 8: declarar el protocolo solo donde hubo reconstrucción.
> df$georeferenceProtocol <- ifelse(
+   !is.na(df$lat_final) & !df$metodo_correcc .... [TRUNCATED] 

> # ================================================================
> # CAMBIO 1: volcar el resultado a los campos Darwin Core
> # ================== .... [TRUNCATED] 

> # Seis decimales es el techo que GBIF acepta sin marcar COORDINATE_ROUNDED, y
> # recortar los ceros de cola evita afirmar una resolucion que la fic .... [TRUNCATED] 

> df$decimalLatitude  <- ifelse(is.na(df$lat_final),  "", fmt_coord(round(df$lat_final,  6)))

> df$decimalLongitude <- ifelse(is.na(df$lon_final), "", fmt_coord(round(df$lon_final, 6)))

> # El datum solo se declara donde el script lo determinó: la conversión UTM usa
> # EPSG:327xx/326xx, que son WGS84 por definición. En las filas que  .... [TRUNCATED] 

> n_datum_nuevo   <- sum(justifica_datum &
+                        (is.na(df$geodeticDatum) | df$geodeticDatum == ""))

> df$geodeticDatum <- ifelse(justifica_datum & (is.na(df$geodeticDatum) | df$geodeticDatum == ""),
+                            "WGS84", df$geodeticDa .... [TRUNCATED] 

> cat("  geodeticDatum escrito por conversion UTM:", n_datum_nuevo,
+     "de", sum(justifica_datum), "filas convertidas\n")
  geodeticDatum escrito por conversion UTM: 492 de 1013 filas convertidas

> # PARCHE 1: un datum sin coordenada no significa nada. 51 filas traian
> # WGS84 desde el portal y se quedaron sin punto (49 irreparables, 1
> # des .... [TRUNCATED] 

> df$geodeticDatum[is.na(df$lat_final)] <- NA_character_

> cat("  geodeticDatum retirado por falta de coordenada:", n_datum_huerfano, "\n")
  geodeticDatum retirado por falta de coordenada: 51 

> cat("\nVolcado a Darwin Core:\n")

Volcado a Darwin Core:

> cat("  decimalLatitude poblado :", sum(df$decimalLatitude != ""), "\n")
  decimalLatitude poblado : 6177 

> cat("  filas donde cambió      :", sum(!identico & !is.na(df$lat_final)), "\n")
  filas donde cambió      : 1605 

> cat("  origen preservado en verbatimLatitude/verbatimLongitude\n")
  origen preservado en verbatimLatitude/verbatimLongitude

> # ---- 16. Resumen ----
> cat("\n=== MÉTODO DE CORRECCIÓN ===\n");  print(table(df$metodo_correccion, useNA = "ifany"))

=== MÉTODO DE CORRECCIÓN ===

         decimal_separador_corrupto         decimal_sin_signo_neg_ambos   decimal_sin_signo_neg_lon_ambiguo 
                                  1                                   6                                   2 
          descartada_fuera_de_rango                         dms_directo                       dms_neg_ambos 
                                  1                                 234                                  47 
                        dms_neg_lon                 dms_neg_lon_ambiguo                  dms_swap_neg_ambos 
                                 15                                   2                                   8 
                   dms_swap_neg_lon                         irreparable                           neg_ambos 
                                  8                                  66                                   7 
                            neg_lon                     neg_lon_ambiguo                            original 
                                  1                                   4                                4562 
           original_transfronterizo                     sin_dato_origen            sin_hemisferio_neg_ambos 
                                 10                                 183                                  33 
             sin_hemisferio_neg_lon      sin_hemisferio_neg_lon_ambiguo             sin_hemisferio_original 
                                  1                                   4                                  16 
      sin_hemisferio_swap_neg_ambos sin_hemisferio_swap_neg_lon_ambiguo                                swap 
                                  1                                   2                                 197 
        utm_northing_truncado_32717         utm_northing_truncado_32718                      utm_zona_32617 
                                  3                                   2                                  27 
                     utm_zona_32717         utm_zona_32717_northing_x10                      utm_zona_32718 
                                 42                                   6                                 899 
  utm_zona_32718_corregido_de_32717        utm_zona_32718_northing_x100            verbatim_transfronterizo 
                                 29                                   5                                   3 

> cat("\n=== NIVEL DE CONFIANZA ===\n");    print(table(df$confianza_coordenada))

=== NIVEL DE CONFIANZA ===

    convertida       inferida          leida   reconstruida sin_coordenada 
          1008            354           4809              6            250 

> cat("\n=== COHERENCIA CON LA PROVINCIA ===\n")

=== COHERENCIA CON LA PROVINCIA ===

> print(table(df$coherencia_provincia, df$criterio_coherencia, useNA = "ifany"))
                       
                        poligono_gadm sin_provincia_declarada <NA>
  coherente                      5933                       0    0
  discordante                     231                       0    0
  fuera_de_tierra_firme             9                       0    0
  no_evaluable                      0                       4    0
  <NA>                              0                       0  250

> cat("\n=== BANDERAS ===\n")

=== BANDERAS ===

> cat("  coordenada compartida entre provincias:", sum(df$coordenada_compartida, na.rm = TRUE), "\n")
  coordenada compartida entre provincias: 525 

> cat("  de ellas, en provincia minoritaria    :", sum(df$provincia_minoritaria, na.rm = TRUE), "\n")
  de ellas, en provincia minoritaria    : 56 

> cat("  signo ambiguo no resuelto             :", sum(df$signo_ambiguo, na.rm = TRUE), "\n")
  signo ambiguo no resuelto             : 14 

> cat("  DMS con minuto o segundo >= 60        :", sum(df$dms_rango_invalido & tiene_coord, na.rm = TRUE), "\n")
  DMS con minuto o segundo >= 60        : 12 

> cat("  marcadas para revisión (sospechosas)  :", sum(sospechosa, na.rm = TRUE), "\n")
  marcadas para revisión (sospechosas)  : 238 

> cat("  con coordenada y sin incertidumbre    :",
+     sum(!is.na(df$lat_final) & is.na(df$coordinateUncertaintyInMeters)), "\n")
  con coordenada y sin incertidumbre    : 238 

> cat("\n=== COBERTURA ===\n")

=== COBERTURA ===

> cat("  con coordenada:", sum(!is.na(df$lat_final)),
+     sprintf("(%.1f%%)\n", 100 * mean(!is.na(df$lat_final))))
  con coordenada: 6177 (96.1%)

> cat("  sin coordenada:", sum(is.na(df$lat_final)), "\n")
  sin coordenada: 250 

> # ---- 17. Exportación ----
> # CAMBIO D: umbral_km solo tiene sentido si corrió la rama de respaldo.
> df_export <- df %>% select(-decimalLatitude_ .... [TRUNCATED] 

> if (!is.null(gadm)) df_export <- df_export %>% select(-umbral_km)

> write_csv(df_export, ARCHIVO_SALIDA, na = "")
                                                                                                                   
> cat("\nGuardado en", ARCHIVO_SALIDA, "\n")

Guardado en datos/02_intermedios/ocurrences_salida_coordenadas.csv 

> # CAMBIO A, C y D: el reporte incorpora signo ambiguo, DMS fuera de rango y
> # los registros marinos reclasificados.
> df %>%
+   filter(coherencia .... [TRUNCATED] 
                                                                                                                   
> cat("Reporte de revisión en", ARCHIVO_REPORTE, "\n")
Reporte de revisión en reportes_y_revisiones/reporte_coordenadas_revision.csv 
Avisos:
1: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  80 38 52 
2: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  80 38 52 
3: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  80 38 52 
4: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 00 57 075  80 42 32
5: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 55 71 54 53 
6: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  80 38 52 
7: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 00 20 27  90 51 35
8: In base::.Call(...) : not within -180/360 range, got: 9994 
9: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  90 38 52 
10: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  80 38 52 
>

ya aplique tu json, corroboralo, no me trates de  usted al decir suya porque me confundo jaja esa clase de decisiones tomalas tu, de una vez te mando la limpieza de coordenadas, hazle la misma auditoria hecha antes pero para coordenadas

---

# claude response

Confirmado: el JSON está aplicado y el script de coordenadas corrió sobre el archivo parcheado.

| Verificación del parche | Resultado |
|---|---|
| Celdas esperadas vs encontradas | `locality` 6.427/6.427 · `locationRemarks` 6.427/6.427 |
| Celdas cambiadas | 54 + 14 = **68**, exactamente lo simulado |
| Residuos | `Cornorán`, `Masphi`, `Hcda.`, `Camp n`, `campamento1`, `buenaventura`, `psicola`, `bulubulu`, `Reserva Producción de Fauna`, `Campamento 1. Pisorie`, `NW.Playón`, `punta km`, `río`+Mayúscula = **0** |
| Columnas heredadas que tocó el script R | 7 espaciales + las 68 celdas del parche. Nada más |

---

# 1. VEREDICTO GLOBAL — `Limpiar_Coordenadas.R` v4

**CORRECTA.** El script no rompe nada, respeta sus propias normas y es reproducible. Todo lo que encontré son dos defectos internos acotados, un hueco de empaquetado y —lo más valioso— hallazgos del origen que reencuadran varios bloques de `Dudas.md`.

| Verificación | Resultado |
|---|---|
| Estructura | 6.427 × 112 (92 heredadas + 20 nuevas), alineación 100 % |
| Preservación del origen | `verbatimLatitude`/`verbatimLongitude` == entrada en 6.427/6.427; `verbatimCoordinates` idéntico al CSV crudo del portal |
| **No imputación** | 183 filas sin decimal ni verbatim → **0** salieron con coordenada |
| **Regla de precedencia** ("si el origen ya cae en bbox, se respeta") | **0 violaciones** en 6.427 filas |
| Las 85 `signo_latitud` | latitud idéntica a la entrada en **85/85**: no se tocó ninguna, como estaba declarado |
| Determinismo del parser | **0** cadenas `verbatimCoordinates` con más de un resultado |
| Formato DwC | 0 fuera del patrón, 0 ceros de cola, 0 notación científica, 0 coma decimal, máx. 6 decimales |
| Rango | lat [−5,063 · 7,878] lon [−92,00 · −67,12]; los 2 fuera de Ecuador son Apure/Venezuela, declarados |
| Banderas huérfanas | 0 filas con datum, incertidumbre, status, protocolo, remarks o coherencia **sin coordenada** |
| `requires verification` = 238 | unión exacta de discordante(231) ∪ signo_ambiguo(14) ∪ dms_rango(12). Verificado |
| Incertidumbre | 238/238 sospechosas sin valor; **0** no-sospechosas con coordenada y sin valor |
| Datum | 492 nuevos, **todos** por conversión UTM; 0 filas UTM sin datum; 51 huérfanos retirados; 470 con coordenada y sin datum = coincide con D9 |
| `coordenada_compartida` 525 / `provincia_minoritaria` 56 | **reproducidas exactamente** recalculando con clave a 5 decimales: 0 discrepancias |
| Reporte de revisión | 328 filas = unión ∪ minoritaria, exacto. 0 catálogos faltantes |
| Cobertura | 6.177 con coordenada (96,1 %), 250 sin |

Los 10 avisos de `parzer` los rastreé uno por uno: **ninguno provocó una coordenada mala**. Nueve son sexagesimales con formato irregular que el respaldo resolvió bien, y el décimo (`9994`) es el `90°51'35.9994''` de Galápagos, que redondea correctamente a −90,86.

---

# 2. FEEDBACK DE `Dudas.md` — bloques D y H

Aquí está lo mejor de la auditoría. **Cinco preguntas abiertas del oficio las resuelve el propio archivo**, y dos cifras están mal.

### 2.1 H3 resuelto: el catálogo 4195 no es una duda, es un dígito

Tu texto dice que el vecino 4183 «tiene el mismo formato de verbatim y sí declara Galápagos». La evidencia real es mucho más fuerte:

| catalogNumber | verbatimCoordinates | Provincia | Resultado | Coherencia |
|---|---|---|---|---|
| 4180, 4181, 4182, 4190 | `00°54'5.8'' / **80**°38'52''` | Manabí | −0,901611 / −80,647778 | coherente |
| 4200 | `0°54'5.8' / **80**°38'52''` | Manabí | −0,901611 / −80,647778 | coherente |
| **4195** | `00°54'5.8'' / **90**°38'52''` | **Manabí** | **+0,901611 / −90,647778** | discordante, 1.090 km |

Grados, minutos y segundos idénticos en las seis filas. Solo cambia el grado de longitud: **90 en vez de 80**. Cinco filas contra una. La provincia declarada (Manabí) está bien; lo que está mal es la coordenada. Reescribe H3 como confirmación, no como pregunta: *«confirmen que el 4195 es 80°38'52''W, igual que sus cinco hermanos de lote»*.

Y de paso: el signo positivo de la latitud del 4195 es artefacto del desempate, que al no poder meter 90° en Manabí probó el hemisferio norte. Corrigiendo el grado, el signo se resuelve solo.

### 2.2 D6bis / 4187: la misma sustitución de dígito, y ahora con testigo

Preguntas si `01°40'45.55 / 71°54'53''` es 91°. El catálogo **4201** trae `01°40'45.551'' / 91°59'53.448''` → 1,67932 / −91,99818, que es **isla Darwin**, coherente. Latitud idéntica hasta el centésimo de segundo. El 71 es un 91: misma clase de error que el 4195, en el mismo lote 4178–4201.

### 2.3 D4: tres de los cinco grupos los cierra el archivo solo

| Caso | Lo que dice D4 | Lo que dice el archivo |
|---|---|---|
| **4184** `00°57'**075**'' / 80°42'32.73''` | «¿075 por 07,5?» | **4196, 4197, 4198** traen `00°57'**0.75**'' / 80°42'32.73''` — longitud idéntica carácter a carácter. Es un **punto decimal perdido**, no una coma. El script lo lee como −0,970833 y el valor correcto es −0,950208: **2,3 km de diferencia** |
| **4151** `077°34'**073**''` | sin hipótesis | **4149** = `077°34'27.7''` y **4150** = `077°34'48.5''`. Los tres están en el mismo minuto 34'. `073''` es `07.3''`; la lectura actual (77°35'13'') se sale del minuto de sus hermanos |
| **5899, 5917, 5923, 5924, 5965, 5989, 6027** `01°**92**'44''S` | «¿92 minutos?» | Toda la serie Bobonaza va de `01°43'` a `01°52'`, y **5904, 5905, 5906, 5916** están en `01°**52**'57.2''`. El 92 es un 52: quedan a 13 segundos de sus hermanas. **Siete filas resueltas con una confirmación** |
| **4212, 4213** `3°55'64''S` | abierto | Sin hermanas internas. Sigue para INABIO |
| **3765** `00°25'28,40'' 75°25'76,40''` | abierto | Ver 2.4 |

### 2.4 El catálogo 3765 está corrupto en dos ejes a la vez

En J1 ya lo tienes marcado porque `identifications` le pone el nombre de sus vecinas. La geografía dice lo mismo:

| catalogNumber | Provincia | verbatimCoordinates | locality |
|---|---|---|---|
| 3762, 3763, 3764 | **Pichincha** | `0°05'28,56''N 78°53'53,04''W` | Quebrada Sune |
| 3944 | **Pichincha** / Pacto | `00°05' 28.56 78°53'53,04` | Quebrada Sune |
| **3765** | **Orellana** | `00°25'28,40'' 75°25'76,40''` | Quebrada Sune |

Quebrada Sune está en Pacto, Pichincha. El 3765 la declara en Orellana con otra coordenada y con segundos imposibles. Ya no son dos dudas sueltas en dos bloques: **es una sola fila contaminada al digitar, y eso responde tu pregunta 2 de J1**.

### 2.5 El holotipo 3944 tiene la latitud en el hemisferio equivocado

Es el único holotipo completo de la colección (*Microglanis berbixae*, Ibon Tobes). Su verbatim son los **mismos seis números** que 3762–3764, que traen `N` explícita y salen a **+0,091267**. El 3944 no trae letra, el portal guardó **−0,091267** y el script lo respetó (correcto: la coordenada de origen caía dentro de Pichincha). Son **20 km** y está en el registro nomenclatural más importante del acervo. No es defecto del script, es del origen, pero hay que corregirlo antes de publicar.

### 2.6 Dos cifras del oficio hay que rehacerlas

**H1 subcuenta.** No son 33 registros en el punto de Guayaquil: son **40** dentro de un metro — 36 Sucumbíos, 2 Orellana, 1 Bolívar, 1 Esmeraldas — y el rango de catálogo va de **5185 a 5658**, no es un lote contiguo. 38 de las 40 no tienen ni `locality` ni `county`.

**D1 subcuenta.** El punto `−0,871270 / −79,858440` no lo comparten 62 filas de Esmeraldas: lo comparten **65 filas de cuatro provincias** (Esmeraldas 62, Orellana 1, Pichincha 1, Bolívar 1). Eso cambia la lectura: si fuera solo el signo invertido del sitio de Atacames, tres registros de provincias del otro lado del país no llevarían el punto idéntico. Es un **punto por defecto**, no un error de signo.

---

# 3. RESUMEN DE CAMBIOS POR COLUMNA

| Columna | Celdas | Qué hizo | Juicio |
|---|---|---|---|
| `georeferenceVerificationStatus` | 6.177 | `unverified` 5.939 / `requires verification` 238 | correcto |
| `coordinateUncertaintyInMeters` | 5.939 | estimada desde `precision_origen` + piso tecnológico | correcto en mecánica, **defectuoso en 28 filas** (§4.A.1) |
| `decimalLongitude` / `decimalLatitude` | 1.937 / 1.780 | 1.605 cambios reales; el resto es redondeo a 6 decimales y recorte de ceros | correcto |
| `georeferenceProtocol` | 1.605 | declarado solo donde hubo reconstrucción | correcto |
| `geodeticDatum` | 543 | 492 escritos por conversión UTM, 51 retirados por falta de coordenada | correcto |
| `georeferenceRemarks` | 261 | minoritaria 56 + coherencia no concluyente 13 + motivo de revisión 238 | correcto, **incompleto** (§4.A.2) |

**Daño colateral: ninguno.** Ni una columna fuera de las siete espaciales, ni una coordenada de origen sobrescrita cuando ya era válida, ni un dato inventado.

---

# 4. NUEVAS ANOMALÍAS Y PLAN DE ACCIÓN

## 4.A Defectos del script — dos parches

### 4.A.1 `precision_verbatim` clasifica por la puntuación, no por la estructura. 28 filas pagan 1.900 m

El clasificador etiqueta `dms_minuto` cualquier sexagesimal cuyos segundos no lleven la comilla doble. Resultado:

- **28 filas reciben 1.900 m de incertidumbre y ninguna lo merece.** Las 28, sin excepción, declaran en su origen segundos o minutos con decimales.
- Entre ellas está el **holotipo 3944** (`00°05' 28.56 78°53'53,04` → segundos con dos decimales, ≈0,3 m, publicado como 1.900 m).
- Dos filas (`-0.137747°/ -75.773864°`) son **decimales puros** degradados a 1.900 m solo por llevar el símbolo de grado.
- Ocho más (`79°51,031 00°45,530`) son minutos decimales, no minutos enteros.

Inserta esto **inmediatamente después** de `df$precision_origen <- mapply(precision_verbatim, ...)`:

```r
# ---- 12b. PARCHE: la precision de un sexagesimal no depende de que los segundos
# lleven comilla doble. El clasificador del bloque 12 etiqueta dms_minuto todo lo
# que no encuentra marcado, y 28 filas terminan con 1900 m cuando su propio
# verbatim declara segundos o minutos con decimales (incluido el holotipo 3944:
# "00°05' 28.56 78°53'53,04"). Dos de esas 28 ni siquiera son sexagesimales: son
# decimales de seis cifras que llevan el simbolo de grado. Aqui la precision se
# decide contando los campos numericos de cada eje, no la puntuacion.
reclasificar_precision <- function(raw, actual) {
  if (is.na(raw) || !grepl("\u00b0", raw)) return(actual)
  if (!actual %in% c("dms_minuto", "dms_segundo_entero")) return(actual)
  n <- regmatches(raw, gregexpr("[0-9]+(?:[.,][0-9]+)?", raw))[[1]]
  n <- gsub(",", ".", n)
  dec <- function(x) {
    p <- regmatches(x, regexpr("\\.[0-9]+$", x))
    if (length(p) == 0) 0L else nchar(p) - 1L
  }
  nd <- vapply(n, dec, integer(1))
  # decimal disfrazado de DMS: dos (o cuatro) campos y al menos uno con >= 4 decimales
  if (length(n) %in% c(2L, 4L) && any(nd >= 4L)) return("decimal_6d")
  if (length(n) >= 6L) {
    return(if (any(nd[c(3L, 6L)] > 0L)) "dms_segundo_decimal" else "dms_segundo_entero")
  }
  if (length(n) == 4L && any(nd > 0L)) return("dms_minuto_decimal")
  actual
}
df$precision_origen <- mapply(reclasificar_precision,
                              df$verbatimCoordinates, df$precision_origen,
                              USE.NAMES = FALSE)
cat("  filas reclasificadas por el parche 12b:",
    sum(df$precision_origen != mapply(precision_verbatim, df$verbatimCoordinates,
                                      df$verbatimLatitude, df$coord_tipo)), "\n")

# ---- 12c. Simetria con el PARCHE 1: si se retira el datum de una fila sin
# coordenada porque "un datum sin coordenada no significa nada", lo mismo vale
# para la precision de origen. Hoy sobrevive en 51 filas sin punto.
df$precision_origen[is.na(df$lat_final)] <- NA_character_
```

### 4.A.2 La incertidumbre estimada viaja al Darwin Core sin decir que es estimada. 4.360 filas

Es el mismo hueco que cerraron los parches 4, 15c y 15d para las otras banderas, y quedó abierto justo en la que más se consume: **4.360 filas publican un `coordinateUncertaintyInMeters` sin `georeferenceProtocol` ni `georeferenceRemarks`** (4.355 son `metodo = original`, es decir, coordenadas leídas tal cual). La justificación existe, pero vive en `incertidumbre_criterio`, que es columna interna y no es término Darwin Core: muere en el borde del estándar. Un revisor externo recibe 5.939 números de precisión que nadie midió, sin una sola pista.

Va **antes** del bloque de `georeferenceProtocol`:

```r
# ---- 15e. PARCHE: la incertidumbre tambien tiene que decir de donde sale.
# 4.360 filas publican coordinateUncertaintyInMeters sin protocolo ni remarks.
# incertidumbre_criterio es columna interna y no viaja en el DwCA. Sin esto, el
# consumidor lee una precision medida donde solo hay una estimacion derivada del
# formato del verbatim, y en 4.535 filas ni siquiera eso: es el piso por fecha.
nota_unc <- ifelse(
  is.na(df$coordinateUncertaintyInMeters), NA_character_,
  paste0("incertidumbre no medida en campo: estimada desde la precision ",
         "declarada en el origen (", df$precision_origen, ")",
         ifelse(!is.na(df$piso_incertidumbre_aplicado) & df$piso_incertidumbre_aplicado,
                "; elevada al piso tecnologico segun el anio del evento", "")))
df$georeferenceRemarks <- ifelse(
  is.na(nota_unc), df$georeferenceRemarks,
  ifelse(is.na(df$georeferenceRemarks) | df$georeferenceRemarks == "",
         nota_unc, paste(df$georeferenceRemarks, nota_unc, sep = "; ")))
cat("  georeferenceRemarks poblado por incertidumbre estimada:",
    sum(!is.na(nota_unc)), "\n")
```

### 4.A.3 Empaquetado: `lat_final` sale con 18 decimales

El export lleva 18 columnas que no son Darwin Core, y dos de ellas (`lat_final`, `lon_final`) contienen la coordenada **sin redondear**, hasta 18 decimales, contradiciendo el techo de 6 que el propio bloque 16 declara. Si alguien aguas abajo lee `lat_final` en vez de `decimalLatitude`, publica una resolución de nanómetros. Una línea en el bloque 17:

```r
# ---- 17b. lat_final/lon_final son la coordenada sin redondear. El bloque 16 fija
# 6 decimales como techo publicable; el CSV intermedio no puede contradecirlo.
df_export$lat_final <- ifelse(is.na(df$lat_final), "", fmt_coord(round(df$lat_final, 6)))
df_export$lon_final <- ifelse(is.na(df$lon_final), "", fmt_coord(round(df$lon_final, 6)))
```

Y deja anotado que al construir el DwCA hay que soltar las 18 columnas internas: solo `verbatimLatitude` y `verbatimLongitude` son términos válidos de las 20 nuevas.

## 4.B Para INABIO — una pregunta que vale por ciento cuarenta y seis

**El bloque QCAZ concentra el 72 % de todas las discordancias.**

| Grupo | Filas con coordenada | Discordantes | Tasa |
|---|---|---|---|
| `recordedBy` contiene **QCAZ** | 598 | **167** | **27,9 %** |
| Resto de la colección | 5.579 | 64 | **1,1 %** |

Veinticinco veces más. Y se localiza: **167 de las 231 discordancias están en los catálogos 5100–5799**. En el tramo 5600–5699, 42 de 100 filas son discordantes y 76 de 100 no tienen `locality`. Treinta de las 56 filas en «provincia minoritaria» están en el rango 5606–5686, cada una con la coordenada que le corresponde a otro grupo: Esmeraldas con puntos de Sucumbíos, Pichincha con puntos de Orellana, Bolívar con el punto de Guayaquil.

Eso reordena D2, D7, H1 y H2 igual que H1 reordenó a D2 en su momento. **Deja de ser 146 revisiones individuales y pasa a ser una sola pregunta:**

> ¿Cómo se cargaron al portal los registros con `recordedBy = QCAZ` (catálogos ≈5100–5799, los mismos del bloque A3)? Sus coordenadas fallan la prueba de contención provincial veinticinco veces más que el resto de la colección, con `locality` y `county` vacíos y coordenadas repetidas entre provincias sin relación geográfica. ¿Fue una migración desde otro sistema, una carga masiva sin georreferenciación propia, o una asignación de punto por lote?

Súmale, como confirmaciones cerradas y no como preguntas abiertas: 4195 (80° por 90°), 4187 (91° por 71°), 4184 (`0.75''` por `075''`), 4151 (`07.3''` por `073''`), las 7 de Bobonaza (`52'` por `92'`), 3765 (Pichincha, no Orellana) y el signo de latitud del holotipo 3944.

**Dos huecos de Darwin Core que la fase de coordenadas deja abiertos y no son suyos:**
- **Galápagos: 24 filas, `island`, `islandGroup` y `waterBody` vacíos al 100 %**, incluidas las 9 capturas marinas. Para una colección ictiológica con material del Pacífico, `waterBody` es el término que falta, y ya tienes la coordenada para poblarlo.
- **Siete filas con `locality = "Varios Sitios"`** llevan un punto único con 100 m de incertidumbre. El propio texto del origen contradice esa precisión. Y hay **401 filas con coordenada y `locality` vacía**.

## 4.C Límite del método — para el capítulo IV, no para el script

Esto no se arregla, se declara: **la prueba de polígono no puede detectar un signo de latitud invertido en 1.579 filas.** Las provincias que cruzan el ecuador aceptan las dos lecturas:

| Provincia | Filas en la zona ciega |
|---|---|
| Sucumbíos | 1.239 |
| Pichincha | 325 |
| Galápagos | 12 |
| Esmeraldas / Manabí | 3 |

El holotipo 3944 es la prueba viva: su latitud está invertida, cae dentro de Pichincha con los dos signos, y el test la da por coherente. La contención provincial resuelve el signo **fuera** de la franja ecuatorial y no dentro; hay que escribirlo así en la discusión, porque el 96,1 % de cobertura no significa 96,1 % de coordenadas verificadas.

Añade una segunda: el bloque 4178–4201 tiene **dos lecturas del mismo sitio separadas 1,4 km** —4179 dice `90°24'46.8''` y 4185/4188/4199 dicen `90°24'4.68''`— y **las cuatro salen «coherentes»**. Un desplazamiento de un punto decimal dentro de la propia provincia es invisible para cualquier test de contención.

## 4.D Verificado y descartado

Para que no reaparezcan en una ronda futura:

- **`coordinateUncertaintyInMeters` colapsa a cuatro valores** (30 / 100 / 200 / 1.900) y 4.535 filas subieron al piso. No es un defecto —es el parche 2 funcionando— pero como atributo del modelo dimensional ya no discrimina precisión: es prácticamente una bandera binaria de «evento anterior o posterior a 2000». Decídelo explícitamente antes de meterlo al DW.
- **La clave de coordenada compartida está a 5 decimales (≈1 m)** y la reproduje exactamente. Probé a 3 decimales (≈110 m): las compartidas pasan de 525 a 559 y las minoritarias de 56 a 60. La cifra es estable, no depende de la granularidad.
- **Tres cadenas verbatim reciben más de una etiqueta de `metodo_correccion`** (`-0.565725° -75.205312°`, `02°10´ 59,8 79°21´2,8`, `0°05'28,56''N 78°53'53,04''W`), pero **el resultado numérico es idéntico en las tres**. La etiqueta depende también del estado del decimal de origen, no solo del verbatim. No es error; sí importa si vas a usar `metodo_correccion` como atributo de una dimensión: no es una función pura del texto de origen.
- **Los 10 avisos de `parzer`**: ninguno produjo coordenada errónea.
- **Los 2 registros fuera del bbox de Ecuador** (4305, 4306): Apure, Venezuela, declarados y con método transfronterizo. Correctos.

---

## CIERRE

Aplica **12b, 12c, 15e y 17b** y vuelve a correr. Espera ver: 28 filas bajando de 1.900 m a su precisión real, 51 `precision_origen` vaciadas, `georeferenceRemarks` pasando de 261 a ~6.200 filas pobladas, y `lat_final`/`lon_final` a 6 decimales. Si sale otra cifra, algo no cuadra y lo revisamos.

Lo demás no es del script: el bloque QCAZ y las seis confirmaciones del §4.B van al oficio, y el límite del test de signo va al capítulo IV.

Una nota de traspaso: me mandaste también `LimpiezaFishbase.R`. No lo abrí — la taxonomía es otra sesión y prefiero no mezclarla con esto. Cuando quieras la auditamos con el mismo formato.

---

# you asked

message time: 2026-08-21 21:36:52

> source("~/Limpieza de datos/Limpieza_Ictiologia/scripts/Coordenadas.R", echo = TRUE)

> # ================================================================
> # LIMPIEZA DE COORDENADAS - Colección Ictiológica MECN-DP INABIO
> # Versión 4  .... [TRUNCATED] 

> library(dplyr)

Adjuntando el paquete: ‘dplyr’

The following objects are masked from ‘package:stats’:

    filter, lag

The following objects are masked from ‘package:base’:

    intersect, setdiff, setequal, union

> library(parzer)

> library(sf)
Linking to GEOS 3.14.1, GDAL 3.12.1, PROJ 9.7.1; sf_use_s2() is TRUE

> sf::sf_use_s2(TRUE)   # necesario para que st_distance devuelva metros en EPSG:4326

> # ---- 0. Configuración ----
> ARCHIVO_ENTRADA <- "datos/02_intermedios/ocurrences_openrefine.csv"

> ARCHIVO_SALIDA  <- "datos/02_intermedios/ocurrences_salida_coordenadas.csv"

> ARCHIVO_REPORTE <- "reportes_y_revisiones/reporte_coordenadas_revision.csv"

> norm_nombre <- function(x) {
+   x <- iconv(x, to = "ASCII//TRANSLIT")
+   x <- tolower(gsub("[^A-Za-z ]", "", x))
+   trimws(gsub("\\s+", " ", x))
 .... [TRUNCATED] 

> # ---- Polígonos administrativos de nivel 1 (GADM 4.1) ----
> # Se descargan una sola vez y quedan cacheados en DIR_REFERENCIA. Requiere
> # los paq .... [TRUNCATED] 

> PAISES_GADM    <- c("ECU", "PER", "VEN")   # Ecuador + los dos transfronterizos

> TOLERANCIA_BORDE_M <- 5000

> dir.create(DIR_REFERENCIA, recursive = TRUE, showWarnings = FALSE)

> cargar_gadm <- function(paises, dir_cache) {
+   if (!requireNamespace("geodata", quietly = TRUE) ||
+       !requireNamespace("terra",   quietly =  .... [TRUNCATED] 

> df <- read_csv(ARCHIVO_ENTRADA, col_types = cols(.default = "c"))
                                                                                                                     
> cat("Filas cargadas:", nrow(df), "\n")
Filas cargadas: 6427 

> # ---- 1. Preservar el origen ANTES de tocar nada (CAMBIO 1) ----
> df$verbatimLatitude  <- df$decimalLatitude

> df$verbatimLongitude <- df$decimalLongitude

> df$decimalLatitude_num  <- suppressWarnings(as.numeric(df$decimalLatitude))

> df$decimalLongitude_num <- suppressWarnings(as.numeric(df$decimalLongitude))

> # ---- 2. Clasificar tipo de verbatimCoordinates ----
> classify_coord <- function(x) {
+   if (is.na(x) || trimws(x) == "") return("vacio")
+   if  .... [TRUNCATED] 

> df$coord_tipo <- sapply(df$verbatimCoordinates, classify_coord)

> es_utm_con_letra <- function(x) !grepl("°", x) & grepl("[0-9](\\.[0-9]+)?\\s*[ENSWensw]", x)

> df$coord_tipo[df$coord_tipo == "dms" & es_utm_con_letra(df$verbatimCoordinates)] <- "utm_o_similar"

> # ---- 2b. CAMBIO C: validación de rango en minutos y segundos ----
> # Un DMS con 075'' o 80' es aritméticamente parseable pero está mal escrito
>  .... [TRUNCATED] 

> df$dms_rango_invalido <- vapply(df$verbatimCoordinates, dms_rango_invalido, logical(1))

> cat("Filas con minutos o segundos >= 60 en el origen:", sum(df$dms_rango_invalido), "\n")
Filas con minutos o segundos >= 60 en el origen: 12 

> # ---- 3. Bounding box: Ecuador continental + Galápagos ----
> in_bbox <- function(lat, lon) {
+   continental <- !is.na(lat) & !is.na(lon) & lat >= .... [TRUNCATED] 

> # ---- 4. Validación de rangos UTM ----
> utm_easting_valido <- function(e) !is.na(e) && e >= 160000 && e <= 840000

> utm_northing_valido <- function(n, epsg) {
+   if (is.na(n)) return(FALSE)
+   if (epsg %in% c(32717, 32718)) return(n >= 9380000 && n <= 10000000)
 .... [TRUNCATED] 

> # ================================================================
> # CAMBIO A (1/2): los polígonos se cargan ANTES del corrector de signo,
> # por .... [TRUNCATED] 

> gadm <- cargar_gadm(PAISES_GADM, DIR_REFERENCIA)

> if (!is.null(gadm)) {
+   # Alias: stateProvince que no son nivel 1 en su pais.
+   # "Maynas" es provincia peruana dentro del departamento de Loret .... [TRUNCATED] 

> prov_norm_df[is.na(prov_norm_df)] <- ""

> # Union por provincia, calculada una sola vez y reutilizada tanto por el
> # desempate de signo como por la evaluación de coherencia del bloque 14.
 .... [TRUNCATED] 

> if (!is.null(gadm)) {
+   for (p in unique(prov_norm_df[prov_norm_df != ""])) {
+     sel <- gadm[gadm$prov_norm == p, ]
+     if (nrow(sel) > 0) po .... [TRUNCATED] 
Poligonos cargados: 75 | provincias con union: 26 

> # Devuelve TRUE/FALSE si hay polígono para la provincia declarada, NA si no
> # se puede evaluar. NA nunca se interpreta como aprobación.
> en_provi .... [TRUNCATED] 

> # ---- 5. Corrector de swap/signo (CAMBIO A 2/2) ----
> # Regla de precedencia:
> #   1. Si la coordenada de origen ya cae en el bbox, se respeta ta .... [TRUNCATED] 

> # ---- 6. Guardián transfronterizo ----
> regiones_transfronterizas <- c("Apure", "Maynas", "Loreto")

> es_transfronterizo <- df$stateProvince %in% regiones_transfronterizas |
+   (!is.na(df$country) & !df$country %in% c("Ecuador", ""))

> cat("Registros transfronterizos identificados:", sum(es_transfronterizo), "\n")
Registros transfronterizos identificados: 13 

> # ---- 7. Filas con decimalLatitude/Longitude ya pobladas ----
> df$lat_final <- NA_real_; df$lon_final <- NA_real_; df$metodo_correccion <- NA_char .... [TRUNCATED] 

> for (i in seq_len(nrow(df))) {
+   la <- df$decimalLatitude_num[i]; lo <- df$decimalLongitude_num[i]
+   if (is.na(la) || is.na(lo)) { df$metodo_cor .... [TRUNCATED] 

> # ---- 8. Parsers para reconstruir desde verbatimCoordinates ----
> normalize_dms <- function(x) {
+   x <- gsub("´´", '"', x); x <- gsub("''", '"', .... [TRUNCATED] 

> # CAMBIO 2: el northing manda sobre la letra.
> # En UTM el falso norte de 10.000.000 m solo existe en el hemisferio sur, así
> # que un northing >= .... [TRUNCATED] 

> convertir_utm2 <- function(raw) {
+   if (is.na(raw)) return(c(lat = NA, lon = NA, zona = NA))
+   hemisferio <- detectar_hemisferio(raw)
+   raw_cl .... [TRUNCATED] 

> resolve_dms <- function(raw, es_transf, prov_norm = "") {
+   raw_norm <- normalize_dms(raw)
+   partes <- regmatches(raw_norm, regexec("^(.*[NnSs]) ..." ... [TRUNCATED] 

> vacio_idx <- which(df$metodo_correccion == "vacio")

> for (i in vacio_idx) {
+   tipo <- df$coord_tipo[i]; raw <- df$verbatimCoordinates[i]
+   if (is.na(raw) || trimws(raw) == "") next
+   if (tipo ==  .... [TRUNCATED] 

> # ---- 8b. Respaldo: coordenadas sin letra de hemisferio (signo inferido) ----
> intentar_sin_hemisferio <- function(raw, prov_norm = "") {
+   x <- .... [TRUNCATED] 

> pendientes_idx <- which(is.na(df$lat_final) & !is.na(df$verbatimCoordinates) &
+                           trimws(df$verbatimCoordinates) != "")

> for (i in pendientes_idx) {
+   r <- intentar_sin_hemisferio(df$verbatimCoordinates[i], prov_norm_df[i])
+   if (!is.na(r["lat"])) {
+     df$lat_fi .... [TRUNCATED] 

> # ---- 8c. Zona UTM 17S mal asignada en Sucumbíos/Orellana ----
> # Verificado con pyproj y reverificado en la auditoría de la v2: para el mismo
> # .... [TRUNCATED] 

> idx_zona <- which(df$metodo_correccion == "utm_zona_32717" &
+                     df$stateProvince %in% c("Sucumbíos", "Orellana"))

> for (i in idx_zona) {
+   r <- convertir_zona18(df$verbatimCoordinates[i])
+   if (!is.na(r["lat"])) {
+     df$lat_final[i] <- as.numeric(r["lat"]) .... [TRUNCATED] 

> # ---- 9. Centroides de referencia por provincia (solo informativo) ----
> dist_km <- function(lat1, lon1, lat2, lon2) {
+   sqrt(((lat1 - lat2) * 1 .... [TRUNCATED] 

> centroides <- df %>%
+   filter(metodo_correccion %in% c("original", "dms_directo"), !is.na(lat_final)) %>%
+   group_by(stateProvince) %>%
+   summ .... [TRUNCATED] 

> coherente_con_centroide <- function(lat, lon, prov, umbral_km = 150) {
+   if (is.na(lat) || is.na(prov) || !(prov %in% centroides$stateProvince)) r .... [TRUNCATED] 

> df$dist_centroide_km <- mapply(function(la, lo, p) {
+   if (is.na(la) || is.na(p) || !(p %in% centroides$stateProvince)) return(NA_real_)
+   cc <- .... [TRUNCATED] 

> # ---- 10. Recuperación de irreparables con doble validación ----
> # CAMBIO 7: clase de caracteres explícita. En TRE (gsub sin perl=TRUE) la
> # se .... [TRUNCATED] 

> recuperar_decimal_corrupto <- function(raw, prov) {
+   m <- regmatches(raw, regexec("^(-?[0-9]+\\.[0-9]+)\\s+(-?[0-9,]+)$", raw))[[1]]
+   if (leng .... [TRUNCATED] 

> df$metodo_correccion[df$metodo_correccion == "vacio" & is.na(df$lat_final)] <- "irreparable"

> irr_idx <- which(df$metodo_correccion == "irreparable" &
+                    !is.na(df$verbatimCoordinates) & trimws(df$verbatimCoordinates) != "")

> n_rec <- 0

> for (i in irr_idx) {
+   r <- recuperar_northing_truncado(df$verbatimCoordinates[i], df$stateProvince[i])
+   if (is.null(r)) r <- recuperar_decimal .... [TRUNCATED] 

> cat("Filas recuperadas del bloque irreparable:", n_rec, "\n")
Filas recuperadas del bloque irreparable: 6 

> # CAMBIO 6: tres causas distintas de ausencia de coordenada.
> sin_verbatim <- is.na(df$verbatimCoordinates) | trimws(df$verbatimCoordinates) == ""

> sin_decimal  <- is.na(df$decimalLatitude_num)

> df$metodo_correccion[df$metodo_correccion == "irreparable" & sin_verbatim & sin_decimal] <-
+   "sin_dato_origen"

> df$metodo_correccion[df$metodo_correccion == "irreparable" & sin_verbatim & !sin_decimal] <-
+   "descartada_fuera_de_rango"

> # CAMBIO A: bandera explícita de elección de signo no resuelta por polígono.
> df$signo_ambiguo <- !is.na(df$metodo_correccion) & grepl("_ambiguo$", .... [TRUNCATED] 

> cat("Filas con signo ambiguo no resuelto por poligono:", sum(df$signo_ambiguo), "\n")
Filas con signo ambiguo no resuelto por poligono: 14 

> # ---- 11. Nivel de confianza por fila ----
> df$confianza_coordenada <- dplyr::case_when(
+   is.na(df$lat_final) ~ "sin_coordenada",
+   df$metodo .... [TRUNCATED] 

> # ---- 12. Precisión leída del ORIGEN (CAMBIO B) ----
> # La v3 cerraba con return("utm_metro") y convertía en UTM cualquier cadena
> # no reconocid .... [TRUNCATED] 

> df$precision_origen <- mapply(precision_verbatim,
+                               df$verbatimCoordinates, df$verbatimLatitude, df$coord_tipo)

> # ---- 12b. PARCHE: la precision de un sexagesimal no depende de que los segundos
> # lleven comilla doble. El clasificador del bloque 12 etiqueta d .... [TRUNCATED] 

> df$precision_origen <- mapply(reclasificar_precision,
+                               df$verbatimCoordinates, df$precision_origen,
+                 .... [TRUNCATED] 

> cat("  filas reclasificadas por el parche 12b:",
+     sum(df$precision_origen != mapply(precision_verbatim, df$verbatimCoordinates,
+               .... [TRUNCATED] 
  filas reclasificadas por el parche 12b: NA 

> # ---- 12c. Simetria con el PARCHE 1: si se retira el datum de una fila sin
> # coordenada porque "un datum sin coordenada no significa nada", lo mi .... [TRUNCATED] 

> # ---- 13. coordinateUncertaintyInMeters estimada ----
> df$coordinateUncertaintyInMeters <- dplyr::case_when(
+   is.na(df$lat_final) ~ NA_characte .... [TRUNCATED] 

> # ---- 13b. PARCHE 2: piso tecnologico de la incertidumbre ----
> # Seis decimales son 11 cm y el bloque 13 los traducia a 10 m en 4.249
> # filas.  .... [TRUNCATED] 

> piso_m <- ifelse(is.na(anio_evento) | anio_evento < 2000, 100, 30)

> unc_num  <- suppressWarnings(as.numeric(df$coordinateUncertaintyInMeters))

> unc_piso <- pmax(unc_num, piso_m)

> df$piso_incertidumbre_aplicado <- !is.na(unc_num) & unc_piso > unc_num

> df$coordinateUncertaintyInMeters <- ifelse(is.na(unc_piso), NA_character_,
+                                            as.character(as.integer(unc_ .... [TRUNCATED] 

> df$incertidumbre_criterio <- ifelse(
+   is.na(df$coordinateUncertaintyInMeters), NA_character_,
+   paste0("estimada_desde_precision_origen:", df$p .... [TRUNCATED] 

> cat("  incertidumbre elevada al piso tecnologico:",
+     sum(df$piso_incertidumbre_aplicado, na.rm = TRUE), "\n")
  incertidumbre elevada al piso tecnologico: 4538 

> # ================================================================
> # 14. Coherencia con la provincia por contención en polígono
> # (CAMBIO 3 y 5  .... [TRUNCATED] 

> df$criterio_coherencia     <- NA_character_

> df$dist_fuera_provincia_km <- NA_real_

> df$umbral_km               <- NA_real_

> tiene_coord <- !is.na(df$lat_final)

> if (!is.null(gadm)) {
+   df$criterio_coherencia[tiene_coord] <- "poligono_gadm"
+   pts <- sf::st_as_sf(
+     data.frame(idx = which(tiene_coord), .... [TRUNCATED] 
  reclasificadas como fuera_de_tierra_firme: 9 

> # ---- 14b. Reparto de las discordancias: mecanicas vs. sin explicacion.
> # No corrige ninguna coordenada. Solo responde: ¿invertir el signo de la
 .... [TRUNCATED] 

> for (i in which(df$coherencia_provincia == "discordante")) {
+   p  <- prov_norm_df[i]
+   la <- df$lat_final[i]; lo <- df$lon_final[i]
+   df$disco .... [TRUNCATED] 

> cat("\n=== REPARTO DE LAS DISCORDANCIAS ===\n")

=== REPARTO DE LAS DISCORDANCIAS ===

> print(table(df$discordancia_explicada, useNA = "no"))

           signo_latitud sin_explicacion_mecanica 
                      85                      146 

> print(table(df$stateProvince, df$discordancia_explicada))
                                
                                 signo_latitud sin_explicacion_mecanica
  Apure                                      0                        0
  Azuay                                      0                        0
  Bolívar                                    0                        3
  Cañar                                      0                        0
  Carchi                                     0                        1
  Chimborazo                                 0                        0
  Cotopaxi                                   0                        2
  El Oro                                     0                       11
  Esmeraldas                                80                       13
  Galápagos                                  0                        0
  Guayas                                     0                        1
  Imbabura                                   1                        1
  Loja                                       0                        0
  Loreto                                     0                        0
  Los Ríos                                   0                        0
  Manabí                                     0                        5
  Maynas                                     0                        0
  Morona Santiago                            0                        7
  Napo                                       0                        7
  Orellana                                   2                       14
  Pastaza                                    0                       19
  Pichincha                                  2                       12
  Santa Elena                                0                        0
  Santo Domingo de los Tsáchilas             0                        3
  Sucumbíos                                  0                       44
  Tungurahua                                 0                        3
  Zamora Chinchipe                           0                        0

> # ---- 14c. Northing fuera de rango: ¿un solo digito lo explica? Se prueba solo
> # en las discordancias que produjo nuestra propia conversion UTM.  .... [TRUNCATED] 

> idx <- which(df$coherencia_provincia == "discordante" &
+                df$discordancia_explicada == "sin_explicacion_mecanica" &
+                 .... [TRUNCATED] 

> for (i in idx) {
+   nums <- as.numeric(regmatches(df$verbatimCoordinates[i],
+             gregexpr("[0-9]+\\.?[0-9]*", df$verbatimCoordinates[i])) .... [TRUNCATED] 

> cat("Discordancias con hipotesis de un digito en el northing:",
+     sum(!is.na(df$hipotesis_northing)), "de", length(idx), "\n")
Discordancias con hipotesis de un digito en el northing: 13 de 15 

> # ================================================================
> # CAMBIO 4: coordenada compartida vs provincia minoritaria
> # ================ .... [TRUNCATED] 

> df$clave_coord <- clave

> resumen_clave <- df %>%
+   filter(!is.na(clave_coord), !is.na(stateProvince), stateProvince != "") %>%
+   count(clave_coord, stateProvince, name = .... [TRUNCATED] 

> claves_compartidas <- unique(resumen_clave$clave_coord[resumen_clave$n_prov > 1])

> pares_mayoritarios <- resumen_clave %>%
+   filter(n_filas == n_max) %>%
+   transmute(par = paste(clave_coord, stateProvince, sep = "||")) %>%
+    .... [TRUNCATED] 

> df$coordenada_compartida <- !is.na(df$clave_coord) & df$clave_coord %in% claves_compartidas

> df$provincia_minoritaria <- df$coordenada_compartida &
+   !(paste(df$clave_coord, df$stateProvince, sep = "||") %in% pares_mayoritarios)

> # ---- 15. No declarar precisión sobre una coordenada contradictoria ----
> # Con poligono disponible, la contencion geografica es el criterio; la m .... [TRUNCATED] 

> df$coordinateUncertaintyInMeters[sospechosa] <- NA_character_

> df$incertidumbre_criterio[sospechosa] <- "no_estimable_coordenada_marcada_para_revision"

> df$georeferenceVerificationStatus <- dplyr::case_when(
+   is.na(df$lat_final) ~ NA_character_,
+   sospechosa          ~ "requires verification",
+ .... [TRUNCATED] 

> # ---- 15b. PARCHE 4: la bandera minoritaria viaja al Darwin Core ----
> # El bloque 15 la excluye de "sospechosa" a proposito y esta bien: con
> #  .... [TRUNCATED] 

> cat("  georeferenceRemarks poblado por provincia minoritaria:",
+     sum(df$provincia_minoritaria & !is.na(df$lat_final), na.rm = TRUE), "\n")
  georeferenceRemarks poblado por provincia minoritaria: 56 

> # ---- 15c. La evaluacion de coherencia que no se pudo hacer, o que dio fuera
> # de tierra firme, tambien tiene que viajar. Un registro marino en u .... [TRUNCATED] 

> marca[!is.na(df$lat_final) & df$coherencia_provincia == "fuera_de_tierra_firme"] <-
+   "coordenada fuera del poligono terrestre de la provincia dec ..." ... [TRUNCATED] 

> marca[!is.na(df$lat_final) & df$coherencia_provincia == "no_evaluable"] <-
+   "coherencia con la provincia no evaluable: el registro no declara pro ..." ... [TRUNCATED] 

> df$georeferenceRemarks <- ifelse(
+   is.na(marca), df$georeferenceRemarks,
+   ifelse(is.na(df$georeferenceRemarks) | df$georeferenceRemarks == "", .... [TRUNCATED] 

> cat("  georeferenceRemarks poblado por coherencia no concluyente:",
+     sum(!is.na(marca)), "\n")
  georeferenceRemarks poblado por coherencia no concluyente: 13 

> # ---- 15d. El motivo de la marca tambien tiene que viajar. El bloque 15 pone
> # "requires verification" en 238 filas y el bloque 14b ya sabe por q .... [TRUNCATED] 

> motivo[!is.na(df$lat_final) & df$coherencia_provincia == "discordante" &
+          df$discordancia_explicada == "signo_latitud"] <-
+   "punto fuer ..." ... [TRUNCATED] 

> motivo[!is.na(df$lat_final) & df$coherencia_provincia == "discordante" &
+          df$discordancia_explicada == "sin_explicacion_mecanica"] <-
+    .... [TRUNCATED] 

> motivo[!is.na(df$lat_final) & df$signo_ambiguo] <- ifelse(
+   is.na(motivo[!is.na(df$lat_final) & df$signo_ambiguo]),
+   "el origen no declara hem ..." ... [TRUNCATED] 

> motivo[!is.na(df$lat_final) & df$dms_rango_invalido] <- ifelse(
+   is.na(motivo[!is.na(df$lat_final) & df$dms_rango_invalido]),
+   "el sexagesimal ..." ... [TRUNCATED] 

> df$georeferenceRemarks <- ifelse(
+   is.na(motivo), df$georeferenceRemarks,
+   ifelse(is.na(df$georeferenceRemarks) | df$georeferenceRemarks == "" .... [TRUNCATED] 

> cat("  georeferenceRemarks poblado por motivo de revision:", sum(!is.na(motivo)), "\n")
  georeferenceRemarks poblado por motivo de revision: 238 

> # ---- 15e. PARCHE: la incertidumbre tambien tiene que decir de donde sale.
> # 4.360 filas publican coordinateUncertaintyInMeters sin protocolo ni  .... [TRUNCATED] 

> df$georeferenceRemarks <- ifelse(
+   is.na(nota_unc), df$georeferenceRemarks,
+   ifelse(is.na(df$georeferenceRemarks) | df$georeferenceRemarks ==  .... [TRUNCATED] 

> cat("  georeferenceRemarks poblado por incertidumbre estimada:",
+     sum(!is.na(nota_unc)), "\n")
  georeferenceRemarks poblado por incertidumbre estimada: 5939 

> # CAMBIO 8: declarar el protocolo solo donde hubo reconstrucción.
> df$georeferenceProtocol <- ifelse(
+   !is.na(df$lat_final) & !df$metodo_correcc .... [TRUNCATED] 

> # ================================================================
> # CAMBIO 1: volcar el resultado a los campos Darwin Core
> # ================== .... [TRUNCATED] 

> # Seis decimales es el techo que GBIF acepta sin marcar COORDINATE_ROUNDED, y
> # recortar los ceros de cola evita afirmar una resolucion que la fic .... [TRUNCATED] 

> df$decimalLatitude  <- ifelse(is.na(df$lat_final),  "", fmt_coord(round(df$lat_final,  6)))

> df$decimalLongitude <- ifelse(is.na(df$lon_final), "", fmt_coord(round(df$lon_final, 6)))

> # El datum solo se declara donde el script lo determinó: la conversión UTM usa
> # EPSG:327xx/326xx, que son WGS84 por definición. En las filas que  .... [TRUNCATED] 

> n_datum_nuevo   <- sum(justifica_datum &
+                        (is.na(df$geodeticDatum) | df$geodeticDatum == ""))

> df$geodeticDatum <- ifelse(justifica_datum & (is.na(df$geodeticDatum) | df$geodeticDatum == ""),
+                            "WGS84", df$geodeticDa .... [TRUNCATED] 

> cat("  geodeticDatum escrito por conversion UTM:", n_datum_nuevo,
+     "de", sum(justifica_datum), "filas convertidas\n")
  geodeticDatum escrito por conversion UTM: 492 de 1013 filas convertidas

> # PARCHE 1: un datum sin coordenada no significa nada. 51 filas traian
> # WGS84 desde el portal y se quedaron sin punto (49 irreparables, 1
> # des .... [TRUNCATED] 

> df$geodeticDatum[is.na(df$lat_final)] <- NA_character_

> cat("  geodeticDatum retirado por falta de coordenada:", n_datum_huerfano, "\n")
  geodeticDatum retirado por falta de coordenada: 51 

> cat("\nVolcado a Darwin Core:\n")

Volcado a Darwin Core:

> cat("  decimalLatitude poblado :", sum(df$decimalLatitude != ""), "\n")
  decimalLatitude poblado : 6177 

> cat("  filas donde cambió      :", sum(!identico & !is.na(df$lat_final)), "\n")
  filas donde cambió      : 1605 

> cat("  origen preservado en verbatimLatitude/verbatimLongitude\n")
  origen preservado en verbatimLatitude/verbatimLongitude

> # ---- 16. Resumen ----
> cat("\n=== MÉTODO DE CORRECCIÓN ===\n");  print(table(df$metodo_correccion, useNA = "ifany"))

=== MÉTODO DE CORRECCIÓN ===

         decimal_separador_corrupto         decimal_sin_signo_neg_ambos   decimal_sin_signo_neg_lon_ambiguo 
                                  1                                   6                                   2 
          descartada_fuera_de_rango                         dms_directo                       dms_neg_ambos 
                                  1                                 234                                  47 
                        dms_neg_lon                 dms_neg_lon_ambiguo                  dms_swap_neg_ambos 
                                 15                                   2                                   8 
                   dms_swap_neg_lon                         irreparable                           neg_ambos 
                                  8                                  66                                   7 
                            neg_lon                     neg_lon_ambiguo                            original 
                                  1                                   4                                4562 
           original_transfronterizo                     sin_dato_origen            sin_hemisferio_neg_ambos 
                                 10                                 183                                  33 
             sin_hemisferio_neg_lon      sin_hemisferio_neg_lon_ambiguo             sin_hemisferio_original 
                                  1                                   4                                  16 
      sin_hemisferio_swap_neg_ambos sin_hemisferio_swap_neg_lon_ambiguo                                swap 
                                  1                                   2                                 197 
        utm_northing_truncado_32717         utm_northing_truncado_32718                      utm_zona_32617 
                                  3                                   2                                  27 
                     utm_zona_32717         utm_zona_32717_northing_x10                      utm_zona_32718 
                                 42                                   6                                 899 
  utm_zona_32718_corregido_de_32717        utm_zona_32718_northing_x100            verbatim_transfronterizo 
                                 29                                   5                                   3 

> cat("\n=== NIVEL DE CONFIANZA ===\n");    print(table(df$confianza_coordenada))

=== NIVEL DE CONFIANZA ===

    convertida       inferida          leida   reconstruida sin_coordenada 
          1008            354           4809              6            250 

> cat("\n=== COHERENCIA CON LA PROVINCIA ===\n")

=== COHERENCIA CON LA PROVINCIA ===

> print(table(df$coherencia_provincia, df$criterio_coherencia, useNA = "ifany"))
                       
                        poligono_gadm sin_provincia_declarada <NA>
  coherente                      5933                       0    0
  discordante                     231                       0    0
  fuera_de_tierra_firme             9                       0    0
  no_evaluable                      0                       4    0
  <NA>                              0                       0  250

> cat("\n=== BANDERAS ===\n")

=== BANDERAS ===

> cat("  coordenada compartida entre provincias:", sum(df$coordenada_compartida, na.rm = TRUE), "\n")
  coordenada compartida entre provincias: 525 

> cat("  de ellas, en provincia minoritaria    :", sum(df$provincia_minoritaria, na.rm = TRUE), "\n")
  de ellas, en provincia minoritaria    : 56 

> cat("  signo ambiguo no resuelto             :", sum(df$signo_ambiguo, na.rm = TRUE), "\n")
  signo ambiguo no resuelto             : 14 

> cat("  DMS con minuto o segundo >= 60        :", sum(df$dms_rango_invalido & tiene_coord, na.rm = TRUE), "\n")
  DMS con minuto o segundo >= 60        : 12 

> cat("  marcadas para revisión (sospechosas)  :", sum(sospechosa, na.rm = TRUE), "\n")
  marcadas para revisión (sospechosas)  : 238 

> cat("  con coordenada y sin incertidumbre    :",
+     sum(!is.na(df$lat_final) & is.na(df$coordinateUncertaintyInMeters)), "\n")
  con coordenada y sin incertidumbre    : 238 

> cat("\n=== COBERTURA ===\n")

=== COBERTURA ===

> cat("  con coordenada:", sum(!is.na(df$lat_final)),
+     sprintf("(%.1f%%)\n", 100 * mean(!is.na(df$lat_final))))
  con coordenada: 6177 (96.1%)

> cat("  sin coordenada:", sum(is.na(df$lat_final)), "\n")
  sin coordenada: 250 

> # ---- 17. Exportación ----
> # CAMBIO D: umbral_km solo tiene sentido si corrió la rama de respaldo.
> df_export <- df %>% select(-decimalLatitude_ .... [TRUNCATED] 

> if (!is.null(gadm)) df_export <- df_export %>% select(-umbral_km)

> # ---- 17b. lat_final/lon_final son la coordenada sin redondear. El bloque 16 fija
> # 6 decimales como techo publicable; el CSV intermedio no puede .... [TRUNCATED] 

> df_export$lon_final <- ifelse(is.na(df$lon_final), "", fmt_coord(round(df$lon_final, 6)))

> write_csv(df_export, ARCHIVO_SALIDA, na = "")
                                                                                                                   
> cat("\nGuardado en", ARCHIVO_SALIDA, "\n")

Guardado en datos/02_intermedios/ocurrences_salida_coordenadas.csv 

> # CAMBIO A, C y D: el reporte incorpora signo ambiguo, DMS fuera de rango y
> # los registros marinos reclasificados.
> df %>%
+   filter(coherencia .... [TRUNCATED] 
                                                                                                                   
> cat("Reporte de revisión en", ARCHIVO_REPORTE, "\n")
Reporte de revisión en reportes_y_revisiones/reporte_coordenadas_revision.csv 
Avisos:
1: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  80 38 52 
2: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  80 38 52 
3: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  80 38 52 
4: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 00 57 075  80 42 32
5: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 55 71 54 53 
6: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  80 38 52 
7: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 00 20 27  90 51 35
8: In base::.Call(...) : not within -180/360 range, got: 9994 
9: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  90 38 52 
10: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  80 38 52 
> source("~/Limpieza de datos/Limpieza_Ictiologia/scripts/Fishbase.R", echo = TRUE)

> # ================================================================
> # CORRECCIÓN TAXONÓMICA - Colección Ictiológica MECN-DP INABIO
> #
> # Solo err .... [TRUNCATED] 

> ARCHIVO_ENTRADA <- "datos/02_intermedios/ocurrences_salida_coordenadas.csv"

> ARCHIVO_SALIDA  <- "datos/02_intermedios/ocurrences_salida_taxonomia.csv"

> df <- read_csv(ARCHIVO_ENTRADA, col_types = cols(.default = "c"))
                                                                                                                     
> cat("Filas:", nrow(df), "\n")
Filas: 6427 

> if (!"metodo_correccion_taxon" %in% names(df)) df$metodo_correccion_taxon <- ""

> anotar <- function(i, txt) {
+   df$metodo_correccion_taxon[i] <<- ifelse(df$metodo_correccion_taxon[i] == "", txt,
+                                .... [TRUNCATED] 

> # Preservar el valor de origen ANTES de tocar nada
> for (col in c("kingdom","phylum","class","order","family","scientificName","higherClassificatio ..." ... [TRUNCATED] 

> backbone <- load_taxa() %>% select(Genus, Family, Order, Class) %>%
+   distinct(Genus, .keep_all = TRUE)
Joining with `by = join_by(Subfamily, GenCode, FamCode)`
Joining with `by = join_by(FamCode)`
Joining with `by = join_by(Order, Ordnum, Class, ClassNum)`
Joining with `by = join_by(Class, ClassNum)`
                     
> # FishBase usa Teleostei como clase; el backbone de publicación usa
> # Actinopterygii. Escribir Teleostei genera conflicto al publicar.
> clase_dwc .... [TRUNCATED] 

> # ---- 1. kingdom = Plantae: colisión de homónimos ----
> # Sicydium y Loricaria existen como género de pez y como género de planta,
> # descritos p .... [TRUNCATED] 

> for (i in idx_plantae) {
+   fb <- backbone %>% filter(Genus == df$genus[i])
+   if (nrow(fb) != 1) { warning(sprintf("fila %d: género '%s' sin reso ..." ... [TRUNCATED] 

> cat("kingdom=Plantae corregidos:", length(idx_plantae), "\n")
kingdom=Plantae corregidos: 10 

> # ---- 2. Rango equivocado en el campo family ----
> # El campo contiene una subfamilia o un orden en lugar de una familia.
> # No es una reasignaci .... [TRUNCATED] 

> for (mal in names(rango_erroneo)) {
+   idx <- which(df$family == mal)
+   if (!length(idx)) next
+   df$family[idx] <- rango_erroneo[[mal]]
+   for .... [TRUNCATED] 
   Characinae -> Characidae : 7 fila(s)
   Tetragonopterinae -> Characidae : 1 fila(s)
   Loricariinae -> Loricariidae : 1 fila(s)
   Clupeiformes -> Engraulidae : 1 fila(s)

> # ---- 3. Grafía incorrecta de familia ----
> # La familia no existe con esa grafía; difiere en una o dos letras de una
> # familia válida y el géne .... [TRUNCATED] 

> for (mal in names(grafia_familia)) {
+   idx <- which(df$family == mal)
+   if (!length(idx)) next
+   df$family[idx] <- grafia_familia[[mal]]
+   f .... [TRUNCATED] 
   Archiridae -> Achiridae : 1 fila(s)
   Scorpanidae -> Scorpaenidae : 1 fila(s)
   Triporthidae -> Triportheidae : 1 fila(s)
   Characidiidae -> Crenuchidae : 1 fila(s)
   Asprenidae -> Aspredinidae : 1 fila(s)
   Gemplylidae -> Gempylidae : 1 fila(s)

> # ---- 3b. family con valor que no es una denominación de familia ----
> # El campo debe contener un nombre de familia. Una cadena de autoría en
> # .... [TRUNCATED] 

> if (length(idx)) {
+   cat("family con formato inválido (vaciada para derivar del género):\n")
+   print(unique(df$family[idx]))
+   df$family[idx]  .... [TRUNCATED] 
family con formato inválido (vaciada para derivar del género):
[1] "(Fels & de Rham, 1981)"

> # ---- 4. Capitalización binomial ----
> # Convención nomenclatural: género en mayúscula inicial, epíteto en
> # minúscula. Es una regla de formato, .... [TRUNCATED] 

> nuevo <- vapply(df$scientificName, cap_nombre, character(1), USE.NAMES = FALSE)

> idx <- which(!is.na(nuevo) & nuevo != df$scientificName)

> if (length(idx)) {
+   cat("  capitalización binomial corregida:", length(idx), "fila(s)\n")
+   print(unique(data.frame(de = df$scientificName[idx] .... [TRUNCATED] 
  capitalización binomial corregida: 5 fila(s)
                       de                       a
1                  knodus                  Knodus
2 Crenicichlla Sedentaria Crenicichlla sedentaria
3    Bujurquina Huallagae    Bujurquina huallagae
4 pyrrhulina semifasciata Pyrrhulina semifasciata

> # ---- 4a. Grafía incorrecta de género ----
> # Mismo criterio que grafia_familia: el nombre no existe con esa grafía,
> # difiere en una o dos letr .... [TRUNCATED] 

> n_gg <- 0

> for (mal in names(grafia_genero)) {
+   bien <- grafia_genero[[mal]]
+   idx <- which(df$genus == mal |
+                grepl(paste0("^", mal, "\\b ..." ... [TRUNCATED] 
   Symbranchus -> Synbranchus : 11 fila(s)
   Astroblepu -> Astroblepus : 6 fila(s)
   Andinocara -> Andinoacara : 4 fila(s)
   Limatulichtys -> Limatulichthys : 2 fila(s)
   Lesbiasina -> Lebiasina : 2 fila(s)
   Mylosomma -> Mylossoma : 2 fila(s)
   Hipostomus -> Hypostomus : 1 fila(s)
   Hypomostus -> Hypostomus : 1 fila(s)
   Chaestostoma -> Chaetostoma : 1 fila(s)
   Cichlosoma -> Cichlasoma : 1 fila(s)
   Cenicichla -> Crenicichla : 1 fila(s)
   Hypetecara -> Hypselecara : 1 fila(s)
   Hemmigrammus -> Hemigrammus : 1 fila(s)
   Moekhausia -> Moenkhausia : 1 fila(s)
   Creagutus -> Creagrutus : 1 fila(s)
   Brachycalcinus -> Brachychalcinus : 1 fila(s)
   Phyrulina -> Pyrrhulina : 1 fila(s)
   Shyrna -> Sphyrna : 1 fila(s)
   Hyphopthalmus -> Hypophthalmus : 1 fila(s)

> cat("grafía de género corregida:", n_gg, "fila(s)\n")
grafía de género corregida: 40 fila(s)

> # ---- 4b. Derivar genus y specificEpithet desde scientificName ----
> # 829 filas traen un binomio completo en scientificName pero tienen genus
> # .... [TRUNCATED] 

> idx_g <- which((is.na(df$genus) | df$genus == "") & lengths(bin) == 3)

> for (i in idx_g) { df$genus[i] <- bin[[i]][2]; anotar(i, "genus_derivado_de_scientificName") }

> cat("genus derivado del binomio:", length(idx_g), "fila(s)\n")
genus derivado del binomio: 819 fila(s)

> idx_e <- which((is.na(df$specificEpithet) | df$specificEpithet == "") & lengths(bin) == 3)

> for (i in idx_e) { df$specificEpithet[i] <- bin[[i]][3]; anotar(i, "specificEpithet_derivado_de_scientificName") }

> cat("specificEpithet derivado del binomio:", length(idx_e), "fila(s)\n")
specificEpithet derivado del binomio: 830 fila(s)

> # ---- 4b2. Derivar genus cuando el nombre es de rango genérico ----
> # Misma descomposición mecánica que el binomio: si el scientificName es un
>  .... [TRUNCATED] 

> idx <- which((is.na(df$genus) | df$genus == "") & solo_genero)

> for (i in idx) {
+   df$genus[i] <- sub("^\\s*([A-Z][a-z]+).*$", "\\1", df$scientificName[i])
+   anotar(i, "genus_derivado_de_nombre_generico")
+ }

> cat("genus derivado de nombre de rango genérico:", length(idx), "fila(s)\n")
genus derivado de nombre de rango genérico: 25 fila(s)

> # ---- 4b3. Genero en nombres con cualificador de incertidumbre ----
> # Colocar inmediatamente despues del bloque 4b2, antes de la derivacion de cl .... [TRUNCATED] 

> idx <- which(cualificado & (is.na(df$genus) | df$genus == "") &
+              grepl("^[A-Z][a-z]+\\b", df$scientificName))

> for (i in idx) {
+   df$genus[i] <- sub("^\\s*([A-Z][a-z]+).*$", "\\1", df$scientificName[i])
+   anotar(i, "genus_derivado_de_nombre_con_cualificad ..." ... [TRUNCATED] 

> cat("genus derivado de nombre con cualificador:", length(idx), "fila(s)\n")
genus derivado de nombre con cualificador: 5 fila(s)

> # Coherencia: el genus declarado debe ser el primer término del binomio
> incoh <- which(lengths(bin) == 3 & df$genus != "" &
+                df$ge .... [TRUNCATED] 

> df$flag_genus_no_coincide_con_nombre <- FALSE

> if (length(incoh)) {
+   df$flag_genus_no_coincide_con_nombre[incoh] <- TRUE
+   cat("ATENCIÓN — genus no coincide con el binomio:", length(incoh),  .... [TRUNCATED] 
ATENCIÓN — genus no coincide con el binomio: 7 fila(s)
# A tibble: 5 × 2
  scientificName              genus          
  <chr>                       <chr>          
1 Pimelodella lateristriga    Pimelodus      
2 Hoplerythrinus unitaeniatus Erythrinus     
3 Astyanax villwocki          Tetragonopterus
4 Anablepsoides urophthalmus  Rivulus        
5 Curimata vittata            Steindachnerina

> # PARCHE D: la coherencia nombre/genus solo se evaluaba sobre binomios,
> # porque bin captura tres grupos. Cinco filas con nombre de rango generico .... [TRUNCATED] 

> incoh_uni <- which(lengths(uni) == 2 & df$genus != "" &
+                    !grepl("(idae|inae)\\s*$", df$scientificName) &
+                    df .... [TRUNCATED] 

> if (length(incoh_uni)) {
+   df$flag_genus_no_coincide_con_nombre[incoh_uni] <- TRUE
+   cat("ATENCIÓN — genus no coincide con el nombre uninominal: ..." ... [TRUNCATED] 
ATENCIÓN — genus no coincide con el nombre uninominal: 5 fila(s)
# A tibble: 5 × 3
  catalogNumber scientificName genus         
  <chr>         <chr>          <chr>         
1 1801          Anablepsoides  Rivulus       
2 1808          Knodus         Bryconamericus
3 1823          Jupiaba        Astyanax      
4 1843          Astyanax       Hemigrammus   
5 2004          Anablepsoides  Rivulus       

> incoh_ep <- which(lengths(bin) == 3 & df$specificEpithet != "" &
+                   df$specificEpithet != vapply(bin, function(x) if (length(x)==3) .... [TRUNCATED] 

> df$flag_epiteto_no_coincide_con_nombre <- FALSE

> df$flag_epiteto_no_coincide_con_nombre[incoh_ep] <- TRUE

> # ---- 4c. Correcciones ortográficas específicas ----
> idx_cren <- which(df$scientificName == "Crenicichlla sedentaria")

> if (length(idx_cren)) {
+   df$scientificName[idx_cren] <- "Crenicichla sedentaria"
+   df$genus[idx_cren] <- "Crenicichla"
+   for (i in idx_cren)  .... [TRUNCATED] 

> # El mapa grafia_familia solo actúa sobre el campo family; cuando la
> # familia mal escrita está además en scientificName hay que corregirla ahí.
> .... [TRUNCATED] 

> if (length(idx_asp)) {
+   df$scientificName[idx_asp] <- "Aspredinidae"
+   for (i in idx_asp) anotar(i, "scientificName_grafia_familia_corregida")
 .... [TRUNCATED] 

> # Hyphopthalmidae no existe con ninguna grafía. Se vacía para que el
> # bloque 5b derive la familia del género, igual que con la cadena de autoría. .... [TRUNCATED] 

> if (length(idx_hyp)) {
+   df$family[idx_hyp] <- ""
+   for (i in idx_hyp) anotar(i, "family_inexistente_vaciada")
+ }

> # ---- 5. Completar class y order desde el backbone ----
> # Derivación desde una fuente autoritativa a partir del género. No es
> # imputación: el  .... [TRUNCATED] 

> n_cl <- 0

> for (i in falta) {
+   fb <- backbone %>% filter(Genus == df$genus[i]); if (nrow(fb) != 1) next
+   cl <- clase_dwc(fb$Class[1]); if (is.na(cl)) nex .... [TRUNCATED] 

> cat("class completada:", n_cl, "| sin resolver:", length(falta) - n_cl, "\n")
class completada: 6288 | sin resolver: 71 

> # Segundo intento: si el genero no esta en el backbone, la clase se sigue
> # de la familia. Es la misma derivacion, un nivel mas arriba.
> fam_cls  .... [TRUNCATED] 

> falta2 <- which((is.na(df$class) | df$class == "") & df$family != "")

> for (i in falta2) {
+   fb <- fam_cls %>% filter(Family == df$family[i]); if (nrow(fb) != 1) next
+   cl <- clase_dwc(fb$Class[1]); if (is.na(cl)) n .... [TRUNCATED] 

> # ---- 5b. Cerrar huecos de coherencia interna ----
> # Si la clase está resuelta, el reino y el filo se siguen necesariamente.
> idx <- which(df$cl .... [TRUNCATED] 

> if (length(idx)) {
+   df$kingdom[idx] <- "Animalia"; df$phylum[idx] <- "Chordata"
+   for (i in idx) anotar(i, "kingdom_phylum_derivados_de_class") .... [TRUNCATED] 
kingdom/phylum completados: 62 fila(s)

> # La familia estaba disponible en el backbone al derivar la clase.
> # PARCHE A2: cuando el género ya tiene familia en el archivo, se usa ESA y no
> .... [TRUNCATED] 

> idx <- which((is.na(df$family) | df$family == "") & !is.na(df$genus) & df$genus != "")

> n_f <- 0; n_fb <- 0

> for (i in idx) {
+   fa <- fam_en_archivo$family_en_archivo[fam_en_archivo$genus == df$genus[i]]
+   if (length(fa) == 1) {
+     df$family[i] <- fa .... [TRUNCATED] 

> cat("family completada desde el archivo:", n_f, "| desde el backbone:", n_fb, "fila(s)\n")
family completada desde el archivo: 27 | desde el backbone: 0 fila(s)

> # FishBase devuelve clados informales con barra ("Perciformes/Serranoidei",
> # "Eupercaria/misc"). El término anterior a la barra sí es un orden vá .... [TRUNCATED] 

> idx <- which(grepl("/", df$order))

> if (length(idx)) {
+   df$order_fishbase_informal[idx] <- df$order[idx]
+   raiz <- sub("/.*$", "", df$order[idx])
+   df$order[idx] <- ifelse(grepl .... [TRUNCATED] 
órdenes informales normalizados: 2 fila(s)

> # ---- 5c. Un género no puede tener dos órdenes en el mismo archivo ----
> # La corrección de homónimos escribió el orden del backbone solo en las
> .... [TRUNCATED] 

> for (g in gen_multi) {
+   fb <- backbone %>% filter(Genus == g); if (nrow(fb) != 1) next
+   idx <- which(df$genus == g & df$order != fb$Order[1])
 .... [TRUNCATED] 
   Ilisha : unificado a Clupeiformes ( 1 fila(s), antes Perciformes )
   Sicydium : unificado a Gobiiformes ( 7 fila(s), antes Perciformes )

> # ---- 5c-bis (v2). Autoridad única para order ----
> # Mezclar la clasificación del origen (Perciformes para todo) con la de
> # FishBase solo en l .... [TRUNCATED] 

> n_ord <- 0

> for (i in idx) {
+   fb <- backbone %>% filter(Genus == df$genus[i]); if (nrow(fb) != 1) next
+   if (!is.na(df$order[i]) && df$order[i] == fb$Order .... [TRUNCATED] 

> cat("order alineado al backbone:", n_ord, "fila(s)\n")
order alineado al backbone: 869 fila(s)

> # Repetir la normalizacion de clados informales DESPUES de asignar el orden
> # desde el backbone. FishBase devuelve "Eupercaria/misc" o
> # "Percif ..." ... [TRUNCATED] 

> if (length(idx)) {
+   df$order_fishbase_informal[idx] <- df$order[idx]
+   raiz <- sub("/.*$", "", df$order[idx])
+   df$order[idx] <- ifelse(grepl .... [TRUNCATED] 
ordenes informales normalizados: 128 fila(s)

> # ---- 5c-ter. Respaldo familia -> orden para generos fuera del backbone ----
> # Mismo patron que el bloque 5 usa para class, un nivel mas arriba y .... [TRUNCATED] 

> gen_fam_unico <- df %>% filter(genus != "", family != "") %>%
+   distinct(genus, family) %>% count(genus) %>% filter(n == 1) %>% pull(genus)

> idx <- which(df$genus %in% gen_fam_unico & !(df$genus %in% backbone$Genus) & df$family != "")

> n_o <- 0

> for (i in idx) {
+   fb <- fam_ord %>% filter(Family == df$family[i]); if (nrow(fb) != 1) next
+   ord <- sub("/.*$", "", fb$Order[1])
+   if (!grep .... [TRUNCATED] 

> cat("order derivado de la familia (genero fuera del backbone):", n_o, "fila(s)\n")
order derivado de la familia (genero fuera del backbone): 7 fila(s)

> # ---- 5c-quater. Orden para las determinaciones a nivel de familia ----
> # Ultimo hueco de la cadena: 5c-bis exige que el genero resuelva en el ba .... [TRUNCATED] 

> idx <- which(df$family != "" & (is.na(df$order) | df$order == "") &
+              (is.na(df$genus)  | df$genus  == ""))

> n_q <- 0

> for (i in idx) {
+   fa <- fam_ord_archivo$order[fam_ord_archivo$family == df$family[i]]
+   if (length(fa) == 1) {
+     df$order[i] <- fa; n_q <-  .... [TRUNCATED] 

> cat("order derivado para determinaciones a nivel de familia:", n_q, "fila(s)\n")
order derivado para determinaciones a nivel de familia: 3 fila(s)

> # ---- 5d. taxonRank derivado de la forma del nombre ----
> # El orden importa: es_genero también captura los nombres terminados en
> # idae/inae, a .... [TRUNCATED] 

> sn <- trimws(df$scientificName)

> es_familia <- grepl("^[A-Z][a-z]+(idae|inae)$", sn)

> es_binomio <- grepl("^[A-Z][a-z]+ [a-z][a-z-]+$", sn)

> es_genero  <- grepl("^[A-Z][a-z]+( sp\\.?[0-9]*)?$", sn) & !es_familia

> df$taxonRank[vacio & es_binomio] <- "species"

> df$taxonRank[vacio & es_genero]  <- "genus"

> df$taxonRank[vacio & es_familia] <- "family"

> for (i in which(vacio & (es_binomio | es_familia | es_genero)))
+   anotar(i, "taxonRank_derivado_de_scientificName")

> cat("taxonRank derivado:", sum(vacio & (es_binomio | es_familia | es_genero)),
+     "| sin resolver:", sum(is.na(df$taxonRank) | df$taxonRank == "" .... [TRUNCATED] 
taxonRank derivado: 847 | sin resolver: 12 

> # PARCHE B2: 5d solo rellena rangos vacíos. Once filas traían taxonRank
> # "genus" desde el origen sobre un binomio completo (531, 1970, 2474, 2497 .... [TRUNCATED] 

> if (length(incoh_rank)) {
+   cat("taxonRank='genus' sobre un binomio, corregido a 'species':",
+       length(incoh_rank), "fila(s):", paste(df$cat .... [TRUNCATED] 
taxonRank='genus' sobre un binomio, corregido a 'species': 11 fila(s): 531, 1970, 2474, 2497, 2559, 2561, 2572, 2576, 2598, 2609, 2834 

> # PARCHE B6: un nombre terminado en -inae es una subfamilia, no una familia.
> # "subfamily" es término válido del vocabulario de rangos. Afecta a c .... [TRUNCATED] 

> idx <- which(es_subfamilia & df$taxonRank %in% c("family", ""))

> if (length(idx)) {
+   df$taxonRank[idx] <- "subfamily"
+   for (i in idx) anotar(i, "taxonRank_subfamilia")
+   cat("taxonRank=subfamily:", length( .... [TRUNCATED] 
taxonRank=subfamily: 1 fila(s)

> # ---- 6. Regenerar higherClassification ----
> # El campo original tiene profundidad variable y en las filas de Plantae
> # conserva la jerarquía v .... [TRUNCATED] 

> df$higherClassification[df$higherClassification == "Organism"] <- ""

> idx_hc <- which((is.na(df$higherClassification_verbatim) & df$higherClassification != "") |
+                 (!is.na(df$higherClassification_verbat .... [TRUNCATED] 

> if (length(idx_hc)) {
+   for (i in idx_hc) anotar(i, "higherClassification_regenerado")
+ }

> # ---- 7. Marcar registros sin metadatos (no se eliminan) ----
> df$registro_incompleto <- with(df,
+   (is.na(recordedBy)|recordedBy=="") & (is.na( .... [TRUNCATED] 

> cat("registros incompletos marcados:", sum(df$registro_incompleto), "\n")
registros incompletos marcados: 4 

> # ---- 7b. PARCHE B4: filas sin ningún dato taxonómico ----
> # Catálogos 1309, 1343, 1455, 1733, 1743, 3794 y 4322 no traen nombre ni
> # jerarquía .... [TRUNCATED] 

> cat("filas sin ningún dato taxonómico:", sum(df$flag_sin_taxonomia), "\n")
filas sin ningún dato taxonómico: 7 

> # ---- 8. Marcar scientificName que contiene un nombre de familia ----
> df$flag_nombre_es_familia <- grepl("^\\s*\\w+(idae|inae)\\s*$", df$scientif .... [TRUNCATED] 

> cat("scientificName con nombre de familia:", sum(df$flag_nombre_es_familia), "\n")
scientificName con nombre de familia: 24 

> # ---- 8b. Familia minoritaria dentro del género ----
> # Se separan dos situaciones que no son lo mismo:
> #  - familia minoritaria del mismo orden .... [TRUNCATED] 

> # El desempate no puede ser arbitrario: cuando dos familias tienen el mismo
> # número de filas, slice_max elige una al azar y la bandera puede acab .... [TRUNCATED] 

> fam_may <- fam_cuenta %>%
+   group_by(genus) %>%
+   mutate(n_max = max(n_filas), empate = sum(n_filas == n_max) > 1) %>%
+   filter(n_filas == n_m .... [TRUNCATED] 

> n_emp <- fam_cuenta %>% group_by(genus) %>%
+   summarise(empate = sum(n_filas == max(n_filas)) > 1, .groups = "drop") %>%
+   filter(empate) %>% pu .... [TRUNCATED] 

> if (length(n_emp))
+   cat("géneros con empate en la familia mayoritaria (desempatados por backbone):",
+       paste(n_emp, collapse = ", "), "\n")
géneros con empate en la familia mayoritaria (desempatados por backbone): Ilisha, Opisthonema, Urotrygon 

> ord_fam <- sub %>% filter(order != "") %>% count(family, order) %>%
+   group_by(family) %>% slice_max(n, n = 1, with_ties = FALSE) %>% ungroup() %> .... [TRUNCATED] 

> df <- df %>%
+   left_join(fam_may, by = "genus") %>%
+   left_join(ord_fam, by = "family") %>%
+   left_join(ord_fam %>% rename(family_mayoritaria  .... [TRUNCATED] 

> df$flag_family_minoritaria <- with(df,
+   genus != "" & family != "" & !is.na(family_mayoritaria) &
+   family != family_mayoritaria)

> df$flag_family_orden_discrepante <- with(df,
+   flag_family_minoritaria & !is.na(orden_de_la_familia) &
+   !is.na(orden_mayoritario) & orden_de_la .... [TRUNCATED] 

> cat("familia minoritaria en el género:", sum(df$flag_family_minoritaria), "fila(s)\n")
familia minoritaria en el género: 93 fila(s)

> cat("  de ellas, de otro orden (error probable):",
+     sum(df$flag_family_orden_discrepante), "fila(s)\n")
  de ellas, de otro orden (error probable): 6 fila(s)

> if (any(df$flag_family_orden_discrepante))
+   print(df[df$flag_family_orden_discrepante,
+            c("catalogNumber","scientificName","genus","f ..." ... [TRUNCATED] 
# A tibble: 6 × 5
  catalogNumber scientificName                  genus              family         family_mayoritaria
  <chr>         <chr>                           <chr>              <chr>          <chr>             
1 5322          Ilisha                          Ilisha             Cichlidae      Pristigasteridae  
2 777           Sternarchorhynchus curvirostris Sternarchorhynchus Astroblepidae  Apteronotidae     
3 1157          Peckoltia                       Peckoltia          Hypopomidae    Loricariidae      
4 3582          Sternopygus macrurus            Sternopygus        Callichthyidae Sternopygidae     
5 3650          Sternopygus macrurus            Sternopygus        Callichthyidae Sternopygidae     
6 4337          Anisotremus                     Anisotremus        Rivulidae      Haemulidae        

> df <- df %>% select(-orden_de_la_familia, -orden_mayoritario, -family_mayoritaria)

> # ---- 8c. PARCHE B3: familia con más de un orden ----
> # flag_family_minoritaria se calcula DENTRO del género, así que un género que
> # aparece u .... [TRUNCATED] 

> df <- df %>% left_join(ord_may_fam, by = "family")

> df$flag_orden_minoritario_en_familia <- !is.na(df$family) & df$family != "" &
+   !is.na(df$order) & df$order != "" & !is.na(df$orden_mayoritario_fa .... [TRUNCATED] 

> df <- df %>% select(-orden_mayoritario_familia)

> cat("filas con orden minoritario dentro de su familia:",
+     sum(df$flag_orden_minoritario_en_familia), "fila(s)\n")
filas con orden minoritario dentro de su familia: 7 fila(s)

> if (any(df$flag_orden_minoritario_en_familia))
+   print(df[df$flag_orden_minoritario_en_familia,
+            c("catalogNumber","scientificName","g ..." ... [TRUNCATED] 
# A tibble: 7 × 5
  catalogNumber scientificName                  genus              family         order        
  <chr>         <chr>                           <chr>              <chr>          <chr>        
1 5322          Ilisha                          Ilisha             Cichlidae      Clupeiformes 
2 777           Sternarchorhynchus curvirostris Sternarchorhynchus Astroblepidae  Gymnotiformes
3 1157          Peckoltia                       Peckoltia          Hypopomidae    Siluriformes 
4 3582          Sternopygus macrurus            Sternopygus        Callichthyidae Gymnotiformes
5 3650          Sternopygus macrurus            Sternopygus        Callichthyidae Gymnotiformes
6 4185          Paranthias colonus              Paranthias         Serrasalmidae  Perciformes  
7 4186          Serranus psittacinus            Serranus           Serrasalmidae  Perciformes  

> # Renombrado: estas filas no son un error, son identificaciones a nivel
> # de familia. La etiqueta anterior sugería anomalía donde no la hay.
> df$ .... [TRUNCATED] 

> df$flag_nombre_es_familia <- NULL

> # ---- 9. PARCHE B1: géneros sin correspondencia en el backbone ----
> # La rama "class_derivada_de_family" es un respaldo correcto, pero absorbe en .... [TRUNCATED] 

> if (nrow(gen_no_resuelto)) {
+   write_csv(gen_no_resuelto,
+             "reportes_y_revisiones/generos_no_resueltos_backbone.csv", na = "")
+   ca .... [TRUNCATED] 
                                                                                                                   
géneros sin correspondencia en el backbone: 20 
# A tibble: 20 × 3
   genus             family          filas
   <chr>             <chr>           <int>
 1 Lipopterichthys   Loricariidae       16
 2 Cochliodon        Loricariidae       13
 3 Piabucina         Lebiasinidae       11
 4 Peckoltichthys    Loricariidae        6
 5 Paradon           Parodontidae        5
 6 Saxatilia         Cichlidae           5
 7 Carcharthinus     Carcharhinidae      2
 8 Pseudocetopsis    Cetopsidae          2
 9 Sciadeops         Ariidae             2
10 Amphyocharax      Characidae          1
11 Cynoponthicus     Muraenesocidae      1
12 Durlanis          Auchenipteridae     1
13 Jurengranulis     Engraulidae         1
14 Orthropristis     Haemulidae          1
15 Paradon           Lebiasinidae        1
16 Parauchenipterus  Auchenipteridae     1
17 Rhandinoloricaria Loricariidae        1
18 Saxatalia         Cichlidae           1
19 Sorubumichthys    Pimelodidae         1
20 Sternachella      Apteronotidae       1

> # ---- 8d. Segunda opinion sobre family: el backbone, no la mayoria del genero ----
> # NO corrige: L3 sigue vigente, solo se derivan las familias v .... [TRUNCATED] 

> df$flag_family_discrepa_backbone <- !is.na(df$family_backbone) &
+   df$family != "" & df$family != df$family_backbone

> cat("family distinta a la del backbone para el mismo genero:",
+     sum(df$flag_family_discrepa_backbone), "fila(s) |",
+     "de ellas nuevas (sin ..." ... [TRUNCATED] 
family distinta a la del backbone para el mismo genero: 1728 fila(s) | de ellas nuevas (sin flag_family_minoritaria): 1658 

> print(df %>% filter(flag_family_discrepa_backbone & !flag_family_minoritaria) %>%
+         count(genus, family, family_backbone, name = "filas") %> .... [TRUNCATED] 
# A tibble: 49 × 4
   genus           family          family_backbone   filas
   <chr>           <chr>           <chr>             <int>
 1 Moenkhausia     Characidae      Acestrorhamphidae   290
 2 Astyanax        Characidae      Acestrorhamphidae   251
 3 Creagrutus      Characidae      Stevardiidae        206
 4 Bryconamericus  Characidae      Stevardiidae        198
 5 Hemigrammus     Characidae      Acestrorhamphidae   107
 6 Knodus          Characidae      Stevardiidae         95
 7 Hyphessobrycon  Characidae      Acestrorhamphidae    87
 8 Rhoadsia        Characidae      Acestrorhamphidae    84
 9 Chrysobrycon    Characidae      Stevardiidae         54
10 Brachychalcinus Characidae      Acestrorhamphidae    53
11 Pseudochalceus  Characidae      Acestrorhamphidae    33
12 Gymnocorymbus   Characidae      Acestrorhamphidae    27
13 Hemibrycon      Characidae      Stevardiidae         21
14 Ceratobranchia  Characidae      Stevardiidae         20
15 Ctenobrycon     Characidae      Acestrorhamphidae    20
16 Triportheus     Characidae      Triportheidae        17
17 Bario           Characidae      Acestrorhamphidae    12
18 Tyttocharax     Characidae      Stevardiidae         10
19 Chilodus        Chilodontidae   Chilodidae            9
20 Eretmobrycon    Characidae      Stevardiidae          8
21 Jupiaba         Characidae      Acestrorhamphidae     6
22 Caenotropus     Chilodontidae   Chilodidae            5
23 Epinephelus     Serranidae      Epinephelidae         4
24 Cyclopsetta     Paralichthyidae Cyclopsettidae        3
25 Hypopygus       Hypopomidae     Rhamphichthyidae      3
26 Poptella        Characidae      Acestrorhamphidae     3
27 Steatogenys     Hypopomidae     Rhamphichthyidae      3
28 Chalceus        Characidae      Chalceidae            2
29 Colossoma       Characidae      Serrasalmidae         2
30 Crenuchus       Characidae      Crenuchidae           2
31 Iotabrycon      Characidae      Stevardiidae          2
32 Rypticus        Serranidae      Grammistidae          2
33 Syacium         Paralichthyidae Cyclopsettidae        2
34 Urobatis        Urolophidae     Urotrygonidae         2
35 Alphestes       Serranidae      Epinephelidae         1
36 Astyanacinus    Characidae      Acestrorhamphidae     1
37 Boehlkea        Characidae      Stevardiidae          1
38 Caulolatilus    Malacanthidae   Latilidae             1
39 Citharichthys   Paralichthyidae Cyclopsettidae        1
40 Gephyrocharax   Characidae      Stevardiidae          1
41 Grundulus       Characidae      Acestrorhamphidae     1
42 Gymnothorax     Ophichthidae    Muraenidae            1
43 Holacanthus     Pomacentridae   Pomacanthidae         1
44 Membras         Atherinidae     Atherinopsidae        1
45 Othonocheirodus Characidae      Stevardiidae          1
46 Paranthias      Serrasalmidae   Epinephelidae         1
47 Phenacobrycon   Characidae      Stevardiidae          1
48 Serranus        Serrasalmidae   Serranidae            1
49 Thayeria        Characidae      Acestrorhamphidae     1

> df <- df %>% select(-family_backbone)

> # ---- 8. Cierre Darwin Core ----
> # Tres campos que el estandar espera y el portal no entrega. Ninguno es
> # imputacion: los tres se derivan de u .... [TRUNCATED] 

> df$dynamicProperties[idx] <- '{"establishmentMeansVerbatim":"nativeEndemic","endemismo":"endemico"}'

> df$establishmentMeans[idx] <- "native"

> cat("establishmentMeans nativeEndemic reasignados a native:", length(idx), "\n")
establishmentMeans nativeEndemic reasignados a native: 148 

> # 8b. La coleccion es ecuatoriana y los 13 registros transfronterizos son
> # de Peru y Venezuela: los 6.427 estan en Sudamerica. GBIF lo deriva de
 .... [TRUNCATED] 

> # 8c. Todo el archivo son especimenes preservados en coleccion: la
> # presencia es un hecho, no una inferencia. GBIF la infiere desde
> # individua .... [TRUNCATED] 

> write_csv(df, ARCHIVO_SALIDA, na = "")
                                                                                                                   
> cat("\nGuardado en", ARCHIVO_SALIDA, "— el archivo de entrada no se modificó.\n")

Guardado en datos/02_intermedios/ocurrences_salida_taxonomia.csv — el archivo de entrada no se modificó.

> cat("\n=== CORRECCIONES APLICADAS ===\n")

=== CORRECCIONES APLICADAS ===

> print(table(df$metodo_correccion_taxon[df$metodo_correccion_taxon != ""]))

                                                                                                                                                                                                                                                                     class_derivada_de_family|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           51 
                                                                                                                                                            class_derivada_de_family|kingdom_phylum_derivados_de_class|order_derivado_de_family_backbone|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                                                                                                      class_derivada_de_genus|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                         4657 
                                                                                                                                                                                                                                 class_derivada_de_genus|order_desde_backbone_autoridad_unica|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                          708 
                                                                                                                                                                                          class_derivada_de_genus|order_desde_backbone_autoridad_unica|order_informal_reducido_a_orden_valido|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           95 
                                                                                                                                                                                                                            class_derivada_de_genus|order_unificado_por_genero_desde_backbone|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            5 
                                               family_formato_invalido_vaciada|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|kingdom_phylum_derivados_de_class|family_derivada_de_genus_en_archivo|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                                                                              family_grafia_corregida|class_derivada_de_genus|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            3 
                                                                                                                                                                  family_grafia_corregida|class_derivada_de_genus|order_desde_backbone_autoridad_unica|order_informal_reducido_a_orden_valido|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                     family_grafia_corregida|genus_derivado_de_nombre_generico|class_derivada_de_genus|kingdom_phylum_derivados_de_class|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                          family_grafia_corregida|scientificName_grafia_familia_corregida|class_derivada_de_family|kingdom_phylum_derivados_de_class|order_derivado_de_family_en_archivo|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                   family_rango_incorrecto_corregido|class_derivada_de_family|kingdom_phylum_derivados_de_class|order_derivado_de_family_en_archivo|taxonRank_derivado_de_scientificName|taxonRank_subfamilia|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                                                                    family_rango_incorrecto_corregido|class_derivada_de_genus|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            9 
                                                                                                                                                                                                                            genus_derivado_de_nombre_con_cualificador|class_derivada_de_genus|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            5 
                                                                                                                                                                                              genus_derivado_de_nombre_generico|class_derivada_de_family|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            4 
                                                                                                                         genus_derivado_de_nombre_generico|class_derivada_de_genus|kingdom_phylum_derivados_de_class|family_derivada_de_genus_en_archivo|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                             genus_derivado_de_nombre_generico|class_derivada_de_genus|kingdom_phylum_derivados_de_class|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                   genus_derivado_de_nombre_generico|class_derivada_de_genus|order_desde_backbone_autoridad_unica|order_informal_reducido_a_orden_valido|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                     genus_derivado_de_nombre_generico|class_derivada_de_genus|order_unificado_por_genero_desde_backbone|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                               genus_derivado_de_nombre_generico|class_derivada_de_genus|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           15 
                                                               genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_family|kingdom_phylum_derivados_de_class|order_derivado_de_family_genero_fuera_del_backbone|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                 genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_family|order_derivado_de_family_genero_fuera_del_backbone|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            6 
                                                                                                                                                    genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_family|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           30 
                                                                               genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|kingdom_phylum_derivados_de_class|family_derivada_de_genus_en_archivo|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           24 
genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|kingdom_phylum_derivados_de_class|order_informal_reducido_a_orden_valido|order_desde_backbone_autoridad_unica|order_informal_reducido_a_orden_valido|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            2 
                                                                                                                   genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|kingdom_phylum_derivados_de_class|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           26 
                                                                         genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|order_desde_backbone_autoridad_unica|order_informal_reducido_a_orden_valido|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           29 
                                                                                                                genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|order_desde_backbone_autoridad_unica|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           23 
                                                                                                           genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|order_unificado_por_genero_desde_backbone|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            2 
                                                                                                                                                     genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                          622 
                                                                                                                                                                             genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           11 
                                                                                                                                   genus_grafia_corregida|genus_derivado_de_nombre_generico|class_derivada_de_genus|order_desde_backbone_autoridad_unica|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                            genus_grafia_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|kingdom_phylum_derivados_de_class|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                         genus_grafia_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|order_desde_backbone_autoridad_unica|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            6 
                                                                                                                              genus_grafia_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           31 
                             genus_grafia_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|family_inexistente_vaciada|class_derivada_de_genus|kingdom_phylum_derivados_de_class|family_derivada_de_genus_en_archivo|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                                                                                                                              higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           16 
                                                                                                                                                                                                                                                        jerarquia_superior_corregida_homonimo|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           10 
                                                                                                                                                                                                                              scientificName_capitalizacion_corregida|class_derivada_de_genus|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            2 
                                                                        scientificName_capitalizacion_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|order_desde_backbone_autoridad_unica|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            2 
                            scientificName_capitalizacion_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|scientificName_grafia_corregida_manualmente|class_derivada_de_genus|order_desde_backbone_autoridad_unica|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                  specificEpithet_derivado_de_scientificName|class_derivada_de_genus|taxonRank_corregido_por_forma_del_nombre|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           11 
> source("~/Limpieza de datos/Limpieza_Ictiologia/scripts/Fishbase.R", echo = TRUE)

> # ================================================================
> # CORRECCIÓN TAXONÓMICA - Colección Ictiológica MECN-DP INABIO
> #
> # Solo err .... [TRUNCATED] 

> ARCHIVO_ENTRADA <- "datos/02_intermedios/ocurrences_salida_coordenadas.csv"

> ARCHIVO_SALIDA  <- "datos/02_intermedios/ocurrences_salida_taxonomia.csv"

> df <- read_csv(ARCHIVO_ENTRADA, col_types = cols(.default = "c"))
                                                                                                                     
> cat("Filas:", nrow(df), "\n")
Filas: 6427 

> if (!"metodo_correccion_taxon" %in% names(df)) df$metodo_correccion_taxon <- ""

> anotar <- function(i, txt) {
+   df$metodo_correccion_taxon[i] <<- ifelse(df$metodo_correccion_taxon[i] == "", txt,
+                                .... [TRUNCATED] 

> # Preservar el valor de origen ANTES de tocar nada
> for (col in c("kingdom","phylum","class","order","family","scientificName","higherClassificatio ..." ... [TRUNCATED] 

> backbone <- load_taxa() %>% select(Genus, Family, Order, Class) %>%
+   distinct(Genus, .keep_all = TRUE)

> # FishBase usa Teleostei como clase; el backbone de publicación usa
> # Actinopterygii. Escribir Teleostei genera conflicto al publicar.
> clase_dwc .... [TRUNCATED] 

> # ---- 1. kingdom = Plantae: colisión de homónimos ----
> # Sicydium y Loricaria existen como género de pez y como género de planta,
> # descritos p .... [TRUNCATED] 

> for (i in idx_plantae) {
+   fb <- backbone %>% filter(Genus == df$genus[i])
+   if (nrow(fb) != 1) { warning(sprintf("fila %d: género '%s' sin reso ..." ... [TRUNCATED] 

> cat("kingdom=Plantae corregidos:", length(idx_plantae), "\n")
kingdom=Plantae corregidos: 10 

> # ---- 2. Rango equivocado en el campo family ----
> # El campo contiene una subfamilia o un orden en lugar de una familia.
> # No es una reasignaci .... [TRUNCATED] 

> for (mal in names(rango_erroneo)) {
+   idx <- which(df$family == mal)
+   if (!length(idx)) next
+   df$family[idx] <- rango_erroneo[[mal]]
+   for .... [TRUNCATED] 
   Characinae -> Characidae : 7 fila(s)
   Tetragonopterinae -> Characidae : 1 fila(s)
   Loricariinae -> Loricariidae : 1 fila(s)
   Clupeiformes -> Engraulidae : 1 fila(s)

> # ---- 3. Grafía incorrecta de familia ----
> # La familia no existe con esa grafía; difiere en una o dos letras de una
> # familia válida y el géne .... [TRUNCATED] 

> for (mal in names(grafia_familia)) {
+   idx <- which(df$family == mal)
+   if (!length(idx)) next
+   df$family[idx] <- grafia_familia[[mal]]
+   f .... [TRUNCATED] 
   Archiridae -> Achiridae : 1 fila(s)
   Scorpanidae -> Scorpaenidae : 1 fila(s)
   Triporthidae -> Triportheidae : 1 fila(s)
   Characidiidae -> Crenuchidae : 1 fila(s)
   Asprenidae -> Aspredinidae : 1 fila(s)
   Gemplylidae -> Gempylidae : 1 fila(s)

> # ---- 3b. family con valor que no es una denominación de familia ----
> # El campo debe contener un nombre de familia. Una cadena de autoría en
> # .... [TRUNCATED] 

> if (length(idx)) {
+   cat("family con formato inválido (vaciada para derivar del género):\n")
+   print(unique(df$family[idx]))
+   df$family[idx]  .... [TRUNCATED] 
family con formato inválido (vaciada para derivar del género):
[1] "(Fels & de Rham, 1981)"

> # ---- 4. Capitalización binomial ----
> # Convención nomenclatural: género en mayúscula inicial, epíteto en
> # minúscula. Es una regla de formato, .... [TRUNCATED] 

> nuevo <- vapply(df$scientificName, cap_nombre, character(1), USE.NAMES = FALSE)

> idx <- which(!is.na(nuevo) & nuevo != df$scientificName)

> if (length(idx)) {
+   cat("  capitalización binomial corregida:", length(idx), "fila(s)\n")
+   print(unique(data.frame(de = df$scientificName[idx] .... [TRUNCATED] 
  capitalización binomial corregida: 5 fila(s)
                       de                       a
1                  knodus                  Knodus
2 Crenicichlla Sedentaria Crenicichlla sedentaria
3    Bujurquina Huallagae    Bujurquina huallagae
4 pyrrhulina semifasciata Pyrrhulina semifasciata

> # ---- 4a. Grafía incorrecta de género ----
> # Mismo criterio que grafia_familia: el nombre no existe con esa grafía,
> # difiere en una o dos letr .... [TRUNCATED] 

> n_gg <- 0

> for (mal in names(grafia_genero)) {
+   bien <- grafia_genero[[mal]]
+   idx <- which(df$genus == mal |
+                grepl(paste0("^", mal, "\\b ..." ... [TRUNCATED] 
   Symbranchus -> Synbranchus : 11 fila(s)
   Astroblepu -> Astroblepus : 6 fila(s)
   Andinocara -> Andinoacara : 4 fila(s)
   Limatulichtys -> Limatulichthys : 2 fila(s)
   Lesbiasina -> Lebiasina : 2 fila(s)
   Mylosomma -> Mylossoma : 2 fila(s)
   Hipostomus -> Hypostomus : 1 fila(s)
   Hypomostus -> Hypostomus : 1 fila(s)
   Chaestostoma -> Chaetostoma : 1 fila(s)
   Cichlosoma -> Cichlasoma : 1 fila(s)
   Cenicichla -> Crenicichla : 1 fila(s)
   Hypetecara -> Hypselecara : 1 fila(s)
   Hemmigrammus -> Hemigrammus : 1 fila(s)
   Moekhausia -> Moenkhausia : 1 fila(s)
   Creagutus -> Creagrutus : 1 fila(s)
   Brachycalcinus -> Brachychalcinus : 1 fila(s)
   Phyrulina -> Pyrrhulina : 1 fila(s)
   Shyrna -> Sphyrna : 1 fila(s)
   Hyphopthalmus -> Hypophthalmus : 1 fila(s)

> cat("grafía de género corregida:", n_gg, "fila(s)\n")
grafía de género corregida: 40 fila(s)

> # ---- 4b. Derivar genus y specificEpithet desde scientificName ----
> # 829 filas traen un binomio completo en scientificName pero tienen genus
> # .... [TRUNCATED] 

> idx_g <- which((is.na(df$genus) | df$genus == "") & lengths(bin) == 3)

> for (i in idx_g) { df$genus[i] <- bin[[i]][2]; anotar(i, "genus_derivado_de_scientificName") }

> cat("genus derivado del binomio:", length(idx_g), "fila(s)\n")
genus derivado del binomio: 819 fila(s)

> idx_e <- which((is.na(df$specificEpithet) | df$specificEpithet == "") & lengths(bin) == 3)

> for (i in idx_e) { df$specificEpithet[i] <- bin[[i]][3]; anotar(i, "specificEpithet_derivado_de_scientificName") }

> cat("specificEpithet derivado del binomio:", length(idx_e), "fila(s)\n")
specificEpithet derivado del binomio: 830 fila(s)

> # ---- 4b2. Derivar genus cuando el nombre es de rango genérico ----
> # Misma descomposición mecánica que el binomio: si el scientificName es un
>  .... [TRUNCATED] 

> idx <- which((is.na(df$genus) | df$genus == "") & solo_genero)

> for (i in idx) {
+   df$genus[i] <- sub("^\\s*([A-Z][a-z]+).*$", "\\1", df$scientificName[i])
+   anotar(i, "genus_derivado_de_nombre_generico")
+ }

> cat("genus derivado de nombre de rango genérico:", length(idx), "fila(s)\n")
genus derivado de nombre de rango genérico: 25 fila(s)

> # ---- 4b3. Genero en nombres con cualificador de incertidumbre ----
> # Colocar inmediatamente despues del bloque 4b2, antes de la derivacion de cl .... [TRUNCATED] 

> idx <- which(cualificado & (is.na(df$genus) | df$genus == "") &
+              grepl("^[A-Z][a-z]+\\b", df$scientificName))

> for (i in idx) {
+   df$genus[i] <- sub("^\\s*([A-Z][a-z]+).*$", "\\1", df$scientificName[i])
+   anotar(i, "genus_derivado_de_nombre_con_cualificad ..." ... [TRUNCATED] 

> cat("genus derivado de nombre con cualificador:", length(idx), "fila(s)\n")
genus derivado de nombre con cualificador: 5 fila(s)

> # Coherencia: el genus declarado debe ser el primer término del binomio
> incoh <- which(lengths(bin) == 3 & df$genus != "" &
+                df$ge .... [TRUNCATED] 

> df$flag_genus_no_coincide_con_nombre <- FALSE

> if (length(incoh)) {
+   df$flag_genus_no_coincide_con_nombre[incoh] <- TRUE
+   cat("ATENCIÓN — genus no coincide con el binomio:", length(incoh),  .... [TRUNCATED] 
ATENCIÓN — genus no coincide con el binomio: 7 fila(s)
# A tibble: 5 × 2
  scientificName              genus          
  <chr>                       <chr>          
1 Pimelodella lateristriga    Pimelodus      
2 Hoplerythrinus unitaeniatus Erythrinus     
3 Astyanax villwocki          Tetragonopterus
4 Anablepsoides urophthalmus  Rivulus        
5 Curimata vittata            Steindachnerina

> # PARCHE D: la coherencia nombre/genus solo se evaluaba sobre binomios,
> # porque bin captura tres grupos. Cinco filas con nombre de rango generico .... [TRUNCATED] 

> incoh_uni <- which(lengths(uni) == 2 & df$genus != "" &
+                    !grepl("(idae|inae)\\s*$", df$scientificName) &
+                    df .... [TRUNCATED] 

> if (length(incoh_uni)) {
+   df$flag_genus_no_coincide_con_nombre[incoh_uni] <- TRUE
+   cat("ATENCIÓN — genus no coincide con el nombre uninominal: ..." ... [TRUNCATED] 
ATENCIÓN — genus no coincide con el nombre uninominal: 5 fila(s)
# A tibble: 5 × 3
  catalogNumber scientificName genus         
  <chr>         <chr>          <chr>         
1 1801          Anablepsoides  Rivulus       
2 1808          Knodus         Bryconamericus
3 1823          Jupiaba        Astyanax      
4 1843          Astyanax       Hemigrammus   
5 2004          Anablepsoides  Rivulus       

> incoh_ep <- which(lengths(bin) == 3 & df$specificEpithet != "" &
+                   df$specificEpithet != vapply(bin, function(x) if (length(x)==3) .... [TRUNCATED] 

> df$flag_epiteto_no_coincide_con_nombre <- FALSE

> df$flag_epiteto_no_coincide_con_nombre[incoh_ep] <- TRUE

> # ---- 4c. Correcciones ortográficas específicas ----
> idx_cren <- which(df$scientificName == "Crenicichlla sedentaria")

> if (length(idx_cren)) {
+   df$scientificName[idx_cren] <- "Crenicichla sedentaria"
+   df$genus[idx_cren] <- "Crenicichla"
+   for (i in idx_cren)  .... [TRUNCATED] 

> # El mapa grafia_familia solo actúa sobre el campo family; cuando la
> # familia mal escrita está además en scientificName hay que corregirla ahí.
> .... [TRUNCATED] 

> if (length(idx_asp)) {
+   df$scientificName[idx_asp] <- "Aspredinidae"
+   for (i in idx_asp) anotar(i, "scientificName_grafia_familia_corregida")
 .... [TRUNCATED] 

> # Hyphopthalmidae no existe con ninguna grafía. Se vacía para que el
> # bloque 5b derive la familia del género, igual que con la cadena de autoría. .... [TRUNCATED] 

> if (length(idx_hyp)) {
+   df$family[idx_hyp] <- ""
+   for (i in idx_hyp) anotar(i, "family_inexistente_vaciada")
+ }

> # ---- 5. Completar class y order desde el backbone ----
> # Derivación desde una fuente autoritativa a partir del género. No es
> # imputación: el  .... [TRUNCATED] 

> n_cl <- 0

> for (i in falta) {
+   fb <- backbone %>% filter(Genus == df$genus[i]); if (nrow(fb) != 1) next
+   cl <- clase_dwc(fb$Class[1]); if (is.na(cl)) nex .... [TRUNCATED] 

> cat("class completada:", n_cl, "| sin resolver:", length(falta) - n_cl, "\n")
class completada: 6288 | sin resolver: 71 

> # Segundo intento: si el genero no esta en el backbone, la clase se sigue
> # de la familia. Es la misma derivacion, un nivel mas arriba.
> fam_cls  .... [TRUNCATED] 

> falta2 <- which((is.na(df$class) | df$class == "") & df$family != "")

> for (i in falta2) {
+   fb <- fam_cls %>% filter(Family == df$family[i]); if (nrow(fb) != 1) next
+   cl <- clase_dwc(fb$Class[1]); if (is.na(cl)) n .... [TRUNCATED] 

> # ---- 5b. Cerrar huecos de coherencia interna ----
> # Si la clase está resuelta, el reino y el filo se siguen necesariamente.
> idx <- which(df$cl .... [TRUNCATED] 

> if (length(idx)) {
+   df$kingdom[idx] <- "Animalia"; df$phylum[idx] <- "Chordata"
+   for (i in idx) anotar(i, "kingdom_phylum_derivados_de_class") .... [TRUNCATED] 
kingdom/phylum completados: 62 fila(s)

> # La familia estaba disponible en el backbone al derivar la clase.
> # PARCHE A2: cuando el género ya tiene familia en el archivo, se usa ESA y no
> .... [TRUNCATED] 

> idx <- which((is.na(df$family) | df$family == "") & !is.na(df$genus) & df$genus != "")

> n_f <- 0; n_fb <- 0

> for (i in idx) {
+   fa <- fam_en_archivo$family_en_archivo[fam_en_archivo$genus == df$genus[i]]
+   if (length(fa) == 1) {
+     df$family[i] <- fa .... [TRUNCATED] 

> cat("family completada desde el archivo:", n_f, "| desde el backbone:", n_fb, "fila(s)\n")
family completada desde el archivo: 27 | desde el backbone: 0 fila(s)

> # FishBase devuelve clados informales con barra ("Perciformes/Serranoidei",
> # "Eupercaria/misc"). El término anterior a la barra sí es un orden vá .... [TRUNCATED] 

> idx <- which(grepl("/", df$order))

> if (length(idx)) {
+   df$order_fishbase_informal[idx] <- df$order[idx]
+   raiz <- sub("/.*$", "", df$order[idx])
+   df$order[idx] <- ifelse(grepl .... [TRUNCATED] 
órdenes informales normalizados: 2 fila(s)

> # ---- 5c. Un género no puede tener dos órdenes en el mismo archivo ----
> # La corrección de homónimos escribió el orden del backbone solo en las
> .... [TRUNCATED] 

> for (g in gen_multi) {
+   fb <- backbone %>% filter(Genus == g); if (nrow(fb) != 1) next
+   idx <- which(df$genus == g & df$order != fb$Order[1])
 .... [TRUNCATED] 
   Ilisha : unificado a Clupeiformes ( 1 fila(s), antes Perciformes )
   Sicydium : unificado a Gobiiformes ( 7 fila(s), antes Perciformes )

> # ---- 5c-bis (v2). Autoridad única para order ----
> # Mezclar la clasificación del origen (Perciformes para todo) con la de
> # FishBase solo en l .... [TRUNCATED] 

> n_ord <- 0

> for (i in idx) {
+   fb <- backbone %>% filter(Genus == df$genus[i]); if (nrow(fb) != 1) next
+   if (!is.na(df$order[i]) && df$order[i] == fb$Order .... [TRUNCATED] 

> cat("order alineado al backbone:", n_ord, "fila(s)\n")
order alineado al backbone: 869 fila(s)

> # Repetir la normalizacion de clados informales DESPUES de asignar el orden
> # desde el backbone. FishBase devuelve "Eupercaria/misc" o
> # "Percif ..." ... [TRUNCATED] 

> if (length(idx)) {
+   df$order_fishbase_informal[idx] <- df$order[idx]
+   raiz <- sub("/.*$", "", df$order[idx])
+   df$order[idx] <- ifelse(grepl .... [TRUNCATED] 
ordenes informales normalizados: 128 fila(s)

> # ---- 5c-ter. Respaldo familia -> orden para generos fuera del backbone ----
> # Mismo patron que el bloque 5 usa para class, un nivel mas arriba y .... [TRUNCATED] 

> gen_fam_unico <- df %>% filter(genus != "", family != "") %>%
+   distinct(genus, family) %>% count(genus) %>% filter(n == 1) %>% pull(genus)

> idx <- which(df$genus %in% gen_fam_unico & !(df$genus %in% backbone$Genus) & df$family != "")

> n_o <- 0

> for (i in idx) {
+   fb <- fam_ord %>% filter(Family == df$family[i]); if (nrow(fb) != 1) next
+   ord <- sub("/.*$", "", fb$Order[1])
+   if (!grep .... [TRUNCATED] 

> cat("order derivado de la familia (genero fuera del backbone):", n_o, "fila(s)\n")
order derivado de la familia (genero fuera del backbone): 7 fila(s)

> # ---- 5c-quater. Orden para las determinaciones a nivel de familia ----
> # Ultimo hueco de la cadena: 5c-bis exige que el genero resuelva en el ba .... [TRUNCATED] 

> idx <- which(df$family != "" & (is.na(df$order) | df$order == "") &
+              (is.na(df$genus)  | df$genus  == ""))

> n_q <- 0

> for (i in idx) {
+   fa <- fam_ord_archivo$order[fam_ord_archivo$family == df$family[i]]
+   if (length(fa) == 1) {
+     df$order[i] <- fa; n_q <-  .... [TRUNCATED] 

> cat("order derivado para determinaciones a nivel de familia:", n_q, "fila(s)\n")
order derivado para determinaciones a nivel de familia: 3 fila(s)

> # ---- 5d. taxonRank derivado de la forma del nombre ----
> # El orden importa: es_genero también captura los nombres terminados en
> # idae/inae, a .... [TRUNCATED] 

> sn <- trimws(df$scientificName)

> es_familia <- grepl("^[A-Z][a-z]+(idae|inae)$", sn)

> es_binomio <- grepl("^[A-Z][a-z]+ [a-z][a-z-]+$", sn)

> es_genero  <- grepl("^[A-Z][a-z]+( sp\\.?[0-9]*)?$", sn) & !es_familia

> df$taxonRank[vacio & es_binomio] <- "species"

> df$taxonRank[vacio & es_genero]  <- "genus"

> df$taxonRank[vacio & es_familia] <- "family"

> for (i in which(vacio & (es_binomio | es_familia | es_genero)))
+   anotar(i, "taxonRank_derivado_de_scientificName")

> cat("taxonRank derivado:", sum(vacio & (es_binomio | es_familia | es_genero)),
+     "| sin resolver:", sum(is.na(df$taxonRank) | df$taxonRank == "" .... [TRUNCATED] 
taxonRank derivado: 847 | sin resolver: 12 

> # PARCHE B2: 5d solo rellena rangos vacíos. Once filas traían taxonRank
> # "genus" desde el origen sobre un binomio completo (531, 1970, 2474, 2497 .... [TRUNCATED] 

> if (length(incoh_rank)) {
+   cat("taxonRank='genus' sobre un binomio, corregido a 'species':",
+       length(incoh_rank), "fila(s):", paste(df$cat .... [TRUNCATED] 
taxonRank='genus' sobre un binomio, corregido a 'species': 11 fila(s): 531, 1970, 2474, 2497, 2559, 2561, 2572, 2576, 2598, 2609, 2834 

> # PARCHE B6: un nombre terminado en -inae es una subfamilia, no una familia.
> # "subfamily" es término válido del vocabulario de rangos. Afecta a c .... [TRUNCATED] 

> idx <- which(es_subfamilia & df$taxonRank %in% c("family", ""))

> if (length(idx)) {
+   df$taxonRank[idx] <- "subfamily"
+   for (i in idx) anotar(i, "taxonRank_subfamilia")
+   cat("taxonRank=subfamily:", length( .... [TRUNCATED] 
taxonRank=subfamily: 1 fila(s)

> # ---- 6. Regenerar higherClassification ----
> # El campo original tiene profundidad variable y en las filas de Plantae
> # conserva la jerarquía v .... [TRUNCATED] 

> df$higherClassification[df$higherClassification == "Organism"] <- ""

> idx_hc <- which((is.na(df$higherClassification_verbatim) & df$higherClassification != "") |
+                 (!is.na(df$higherClassification_verbat .... [TRUNCATED] 

> if (length(idx_hc)) {
+   for (i in idx_hc) anotar(i, "higherClassification_regenerado")
+ }

> # ---- 7. Marcar registros sin metadatos (no se eliminan) ----
> df$registro_incompleto <- with(df,
+   (is.na(recordedBy)|recordedBy=="") & (is.na( .... [TRUNCATED] 

> cat("registros incompletos marcados:", sum(df$registro_incompleto), "\n")
registros incompletos marcados: 4 

> # ---- 7b. PARCHE B4: filas sin ningún dato taxonómico ----
> # Catálogos 1309, 1343, 1455, 1733, 1743, 3794 y 4322 no traen nombre ni
> # jerarquía .... [TRUNCATED] 

> cat("filas sin ningún dato taxonómico:", sum(df$flag_sin_taxonomia), "\n")
filas sin ningún dato taxonómico: 7 

> # ---- 8. Marcar scientificName que contiene un nombre de familia ----
> df$flag_nombre_es_familia <- grepl("^\\s*\\w+(idae|inae)\\s*$", df$scientif .... [TRUNCATED] 

> cat("scientificName con nombre de familia:", sum(df$flag_nombre_es_familia), "\n")
scientificName con nombre de familia: 24 

> # ---- 8b. Familia minoritaria dentro del género ----
> # Se separan dos situaciones que no son lo mismo:
> #  - familia minoritaria del mismo orden .... [TRUNCATED] 

> # El desempate no puede ser arbitrario: cuando dos familias tienen el mismo
> # número de filas, slice_max elige una al azar y la bandera puede acab .... [TRUNCATED] 

> fam_may <- fam_cuenta %>%
+   group_by(genus) %>%
+   mutate(n_max = max(n_filas), empate = sum(n_filas == n_max) > 1) %>%
+   filter(n_filas == n_m .... [TRUNCATED] 

> n_emp <- fam_cuenta %>% group_by(genus) %>%
+   summarise(empate = sum(n_filas == max(n_filas)) > 1, .groups = "drop") %>%
+   filter(empate) %>% pu .... [TRUNCATED] 

> if (length(n_emp))
+   cat("géneros con empate en la familia mayoritaria (desempatados por backbone):",
+       paste(n_emp, collapse = ", "), "\n")
géneros con empate en la familia mayoritaria (desempatados por backbone): Ilisha, Opisthonema, Urotrygon 

> ord_fam <- sub %>% filter(order != "") %>% count(family, order) %>%
+   group_by(family) %>% slice_max(n, n = 1, with_ties = FALSE) %>% ungroup() %> .... [TRUNCATED] 

> df <- df %>%
+   left_join(fam_may, by = "genus") %>%
+   left_join(ord_fam, by = "family") %>%
+   left_join(ord_fam %>% rename(family_mayoritaria  .... [TRUNCATED] 

> df$flag_family_minoritaria <- with(df,
+   genus != "" & family != "" & !is.na(family_mayoritaria) &
+   family != family_mayoritaria)

> df$flag_family_orden_discrepante <- with(df,
+   flag_family_minoritaria & !is.na(orden_de_la_familia) &
+   !is.na(orden_mayoritario) & orden_de_la .... [TRUNCATED] 

> cat("familia minoritaria en el género:", sum(df$flag_family_minoritaria), "fila(s)\n")
familia minoritaria en el género: 93 fila(s)

> cat("  de ellas, de otro orden (error probable):",
+     sum(df$flag_family_orden_discrepante), "fila(s)\n")
  de ellas, de otro orden (error probable): 6 fila(s)

> if (any(df$flag_family_orden_discrepante))
+   print(df[df$flag_family_orden_discrepante,
+            c("catalogNumber","scientificName","genus","f ..." ... [TRUNCATED] 
# A tibble: 6 × 5
  catalogNumber scientificName                  genus              family         family_mayoritaria
  <chr>         <chr>                           <chr>              <chr>          <chr>             
1 5322          Ilisha                          Ilisha             Cichlidae      Pristigasteridae  
2 777           Sternarchorhynchus curvirostris Sternarchorhynchus Astroblepidae  Apteronotidae     
3 1157          Peckoltia                       Peckoltia          Hypopomidae    Loricariidae      
4 3582          Sternopygus macrurus            Sternopygus        Callichthyidae Sternopygidae     
5 3650          Sternopygus macrurus            Sternopygus        Callichthyidae Sternopygidae     
6 4337          Anisotremus                     Anisotremus        Rivulidae      Haemulidae        

> df <- df %>% select(-orden_de_la_familia, -orden_mayoritario, -family_mayoritaria)

> # ---- 8c. PARCHE B3: familia con más de un orden ----
> # flag_family_minoritaria se calcula DENTRO del género, así que un género que
> # aparece u .... [TRUNCATED] 

> df <- df %>% left_join(ord_may_fam, by = "family")

> df$flag_orden_minoritario_en_familia <- !is.na(df$family) & df$family != "" &
+   !is.na(df$order) & df$order != "" & !is.na(df$orden_mayoritario_fa .... [TRUNCATED] 

> df <- df %>% select(-orden_mayoritario_familia)

> cat("filas con orden minoritario dentro de su familia:",
+     sum(df$flag_orden_minoritario_en_familia), "fila(s)\n")
filas con orden minoritario dentro de su familia: 7 fila(s)

> if (any(df$flag_orden_minoritario_en_familia))
+   print(df[df$flag_orden_minoritario_en_familia,
+            c("catalogNumber","scientificName","g ..." ... [TRUNCATED] 
# A tibble: 7 × 5
  catalogNumber scientificName                  genus              family         order        
  <chr>         <chr>                           <chr>              <chr>          <chr>        
1 5322          Ilisha                          Ilisha             Cichlidae      Clupeiformes 
2 777           Sternarchorhynchus curvirostris Sternarchorhynchus Astroblepidae  Gymnotiformes
3 1157          Peckoltia                       Peckoltia          Hypopomidae    Siluriformes 
4 3582          Sternopygus macrurus            Sternopygus        Callichthyidae Gymnotiformes
5 3650          Sternopygus macrurus            Sternopygus        Callichthyidae Gymnotiformes
6 4185          Paranthias colonus              Paranthias         Serrasalmidae  Perciformes  
7 4186          Serranus psittacinus            Serranus           Serrasalmidae  Perciformes  

> # Renombrado: estas filas no son un error, son identificaciones a nivel
> # de familia. La etiqueta anterior sugería anomalía donde no la hay.
> df$ .... [TRUNCATED] 

> df$flag_nombre_es_familia <- NULL

> # ---- 9. PARCHE B1: géneros sin correspondencia en el backbone ----
> # La rama "class_derivada_de_family" es un respaldo correcto, pero absorbe en .... [TRUNCATED] 

> if (nrow(gen_no_resuelto)) {
+   write_csv(gen_no_resuelto,
+             "reportes_y_revisiones/generos_no_resueltos_backbone.csv", na = "")
+   ca .... [TRUNCATED] 
                                                                                                                   
géneros sin correspondencia en el backbone: 20 
# A tibble: 20 × 3
   genus             family          filas
   <chr>             <chr>           <int>
 1 Lipopterichthys   Loricariidae       16
 2 Cochliodon        Loricariidae       13
 3 Piabucina         Lebiasinidae       11
 4 Peckoltichthys    Loricariidae        6
 5 Paradon           Parodontidae        5
 6 Saxatilia         Cichlidae           5
 7 Carcharthinus     Carcharhinidae      2
 8 Pseudocetopsis    Cetopsidae          2
 9 Sciadeops         Ariidae             2
10 Amphyocharax      Characidae          1
11 Cynoponthicus     Muraenesocidae      1
12 Durlanis          Auchenipteridae     1
13 Jurengranulis     Engraulidae         1
14 Orthropristis     Haemulidae          1
15 Paradon           Lebiasinidae        1
16 Parauchenipterus  Auchenipteridae     1
17 Rhandinoloricaria Loricariidae        1
18 Saxatalia         Cichlidae           1
19 Sorubumichthys    Pimelodidae         1
20 Sternachella      Apteronotidae       1

> # ---- 8d. Segunda opinion sobre family: el backbone, no la mayoria del genero ----
> # NO corrige: L3 sigue vigente, solo se derivan las familias v .... [TRUNCATED] 

> df$flag_family_discrepa_backbone <- !is.na(df$family_backbone) &
+   df$family != "" & df$family != df$family_backbone

> cat("family distinta a la del backbone para el mismo genero:",
+     sum(df$flag_family_discrepa_backbone), "fila(s) |",
+     "de ellas nuevas (sin ..." ... [TRUNCATED] 
family distinta a la del backbone para el mismo genero: 1728 fila(s) | de ellas nuevas (sin flag_family_minoritaria): 1658 

> print(df %>% filter(flag_family_discrepa_backbone & !flag_family_minoritaria) %>%
+         count(genus, family, family_backbone, name = "filas") %> .... [TRUNCATED] 
# A tibble: 49 × 4
   genus           family          family_backbone   filas
   <chr>           <chr>           <chr>             <int>
 1 Moenkhausia     Characidae      Acestrorhamphidae   290
 2 Astyanax        Characidae      Acestrorhamphidae   251
 3 Creagrutus      Characidae      Stevardiidae        206
 4 Bryconamericus  Characidae      Stevardiidae        198
 5 Hemigrammus     Characidae      Acestrorhamphidae   107
 6 Knodus          Characidae      Stevardiidae         95
 7 Hyphessobrycon  Characidae      Acestrorhamphidae    87
 8 Rhoadsia        Characidae      Acestrorhamphidae    84
 9 Chrysobrycon    Characidae      Stevardiidae         54
10 Brachychalcinus Characidae      Acestrorhamphidae    53
11 Pseudochalceus  Characidae      Acestrorhamphidae    33
12 Gymnocorymbus   Characidae      Acestrorhamphidae    27
13 Hemibrycon      Characidae      Stevardiidae         21
14 Ceratobranchia  Characidae      Stevardiidae         20
15 Ctenobrycon     Characidae      Acestrorhamphidae    20
16 Triportheus     Characidae      Triportheidae        17
17 Bario           Characidae      Acestrorhamphidae    12
18 Tyttocharax     Characidae      Stevardiidae         10
19 Chilodus        Chilodontidae   Chilodidae            9
20 Eretmobrycon    Characidae      Stevardiidae          8
21 Jupiaba         Characidae      Acestrorhamphidae     6
22 Caenotropus     Chilodontidae   Chilodidae            5
23 Epinephelus     Serranidae      Epinephelidae         4
24 Cyclopsetta     Paralichthyidae Cyclopsettidae        3
25 Hypopygus       Hypopomidae     Rhamphichthyidae      3
26 Poptella        Characidae      Acestrorhamphidae     3
27 Steatogenys     Hypopomidae     Rhamphichthyidae      3
28 Chalceus        Characidae      Chalceidae            2
29 Colossoma       Characidae      Serrasalmidae         2
30 Crenuchus       Characidae      Crenuchidae           2
31 Iotabrycon      Characidae      Stevardiidae          2
32 Rypticus        Serranidae      Grammistidae          2
33 Syacium         Paralichthyidae Cyclopsettidae        2
34 Urobatis        Urolophidae     Urotrygonidae         2
35 Alphestes       Serranidae      Epinephelidae         1
36 Astyanacinus    Characidae      Acestrorhamphidae     1
37 Boehlkea        Characidae      Stevardiidae          1
38 Caulolatilus    Malacanthidae   Latilidae             1
39 Citharichthys   Paralichthyidae Cyclopsettidae        1
40 Gephyrocharax   Characidae      Stevardiidae          1
41 Grundulus       Characidae      Acestrorhamphidae     1
42 Gymnothorax     Ophichthidae    Muraenidae            1
43 Holacanthus     Pomacentridae   Pomacanthidae         1
44 Membras         Atherinidae     Atherinopsidae        1
45 Othonocheirodus Characidae      Stevardiidae          1
46 Paranthias      Serrasalmidae   Epinephelidae         1
47 Phenacobrycon   Characidae      Stevardiidae          1
48 Serranus        Serrasalmidae   Serranidae            1
49 Thayeria        Characidae      Acestrorhamphidae     1

> df <- df %>% select(-family_backbone)

> # ---- 8. Cierre Darwin Core ----
> # Tres campos que el estandar espera y el portal no entrega. Ninguno es
> # imputacion: los tres se derivan de u .... [TRUNCATED] 

> df$dynamicProperties[idx] <- '{"establishmentMeansVerbatim":"nativeEndemic","endemismo":"endemico"}'

> df$establishmentMeans[idx] <- "native"

> cat("establishmentMeans nativeEndemic reasignados a native:", length(idx), "\n")
establishmentMeans nativeEndemic reasignados a native: 148 

> # 8b. La coleccion es ecuatoriana y los 13 registros transfronterizos son
> # de Peru y Venezuela: los 6.427 estan en Sudamerica. GBIF lo deriva de
 .... [TRUNCATED] 

> # 8c. Todo el archivo son especimenes preservados en coleccion: la
> # presencia es un hecho, no una inferencia. GBIF la infiere desde
> # individua .... [TRUNCATED] 

> write_csv(df, ARCHIVO_SALIDA, na = "")
                                                                                                                   
> cat("\nGuardado en", ARCHIVO_SALIDA, "— el archivo de entrada no se modificó.\n")

Guardado en datos/02_intermedios/ocurrences_salida_taxonomia.csv — el archivo de entrada no se modificó.

> cat("\n=== CORRECCIONES APLICADAS ===\n")

=== CORRECCIONES APLICADAS ===

> print(table(df$metodo_correccion_taxon[df$metodo_correccion_taxon != ""]))

                                                                                                                                                                                                                                                                     class_derivada_de_family|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           51 
                                                                                                                                                            class_derivada_de_family|kingdom_phylum_derivados_de_class|order_derivado_de_family_backbone|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                                                                                                      class_derivada_de_genus|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                         4657 
                                                                                                                                                                                                                                 class_derivada_de_genus|order_desde_backbone_autoridad_unica|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                          708 
                                                                                                                                                                                          class_derivada_de_genus|order_desde_backbone_autoridad_unica|order_informal_reducido_a_orden_valido|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           95 
                                                                                                                                                                                                                            class_derivada_de_genus|order_unificado_por_genero_desde_backbone|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            5 
                                               family_formato_invalido_vaciada|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|kingdom_phylum_derivados_de_class|family_derivada_de_genus_en_archivo|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                                                                              family_grafia_corregida|class_derivada_de_genus|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            3 
                                                                                                                                                                  family_grafia_corregida|class_derivada_de_genus|order_desde_backbone_autoridad_unica|order_informal_reducido_a_orden_valido|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                     family_grafia_corregida|genus_derivado_de_nombre_generico|class_derivada_de_genus|kingdom_phylum_derivados_de_class|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                          family_grafia_corregida|scientificName_grafia_familia_corregida|class_derivada_de_family|kingdom_phylum_derivados_de_class|order_derivado_de_family_en_archivo|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                   family_rango_incorrecto_corregido|class_derivada_de_family|kingdom_phylum_derivados_de_class|order_derivado_de_family_en_archivo|taxonRank_derivado_de_scientificName|taxonRank_subfamilia|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                                                                    family_rango_incorrecto_corregido|class_derivada_de_genus|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            9 
                                                                                                                                                                                                                            genus_derivado_de_nombre_con_cualificador|class_derivada_de_genus|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            5 
                                                                                                                                                                                              genus_derivado_de_nombre_generico|class_derivada_de_family|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            4 
                                                                                                                         genus_derivado_de_nombre_generico|class_derivada_de_genus|kingdom_phylum_derivados_de_class|family_derivada_de_genus_en_archivo|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                             genus_derivado_de_nombre_generico|class_derivada_de_genus|kingdom_phylum_derivados_de_class|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                   genus_derivado_de_nombre_generico|class_derivada_de_genus|order_desde_backbone_autoridad_unica|order_informal_reducido_a_orden_valido|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                     genus_derivado_de_nombre_generico|class_derivada_de_genus|order_unificado_por_genero_desde_backbone|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                               genus_derivado_de_nombre_generico|class_derivada_de_genus|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           15 
                                                               genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_family|kingdom_phylum_derivados_de_class|order_derivado_de_family_genero_fuera_del_backbone|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                 genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_family|order_derivado_de_family_genero_fuera_del_backbone|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            6 
                                                                                                                                                    genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_family|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           30 
                                                                               genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|kingdom_phylum_derivados_de_class|family_derivada_de_genus_en_archivo|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           24 
genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|kingdom_phylum_derivados_de_class|order_informal_reducido_a_orden_valido|order_desde_backbone_autoridad_unica|order_informal_reducido_a_orden_valido|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            2 
                                                                                                                   genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|kingdom_phylum_derivados_de_class|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           26 
                                                                         genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|order_desde_backbone_autoridad_unica|order_informal_reducido_a_orden_valido|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           29 
                                                                                                                genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|order_desde_backbone_autoridad_unica|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           23 
                                                                                                           genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|order_unificado_por_genero_desde_backbone|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            2 
                                                                                                                                                     genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                          622 
                                                                                                                                                                             genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           11 
                                                                                                                                   genus_grafia_corregida|genus_derivado_de_nombre_generico|class_derivada_de_genus|order_desde_backbone_autoridad_unica|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                            genus_grafia_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|kingdom_phylum_derivados_de_class|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                         genus_grafia_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|order_desde_backbone_autoridad_unica|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            6 
                                                                                                                              genus_grafia_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           31 
                             genus_grafia_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|family_inexistente_vaciada|class_derivada_de_genus|kingdom_phylum_derivados_de_class|family_derivada_de_genus_en_archivo|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                                                                                                                              higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           16 
                                                                                                                                                                                                                                                        jerarquia_superior_corregida_homonimo|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           10 
                                                                                                                                                                                                                              scientificName_capitalizacion_corregida|class_derivada_de_genus|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            2 
                                                                        scientificName_capitalizacion_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|order_desde_backbone_autoridad_unica|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            2 
                            scientificName_capitalizacion_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|scientificName_grafia_corregida_manualmente|class_derivada_de_genus|order_desde_backbone_autoridad_unica|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                  specificEpithet_derivado_de_scientificName|class_derivada_de_genus|taxonRank_corregido_por_forma_del_nombre|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           11 
>

verga si cierto, me confundi de archivos aca tienes ambos para que los analices, de una vez ya aplique tus cambios para las coordenadas checale esta en el csv que corri junto con la validacion taxonomica asi que corre la misma auditoria pero para taxonomia, 
por cierto aca
"E. Menores — decisión suya, no las toco

* `min.` (13 celdas) frente a `min` (46). Misma abreviatura, dos formas. No colapsa ningún miembro porque son localidades distintas.
* Espaciado de iniciales dobles (§2, bloque E3).
* `A 99,4 km NW. Playón` usa coma decimal; las otras 18 celdas con decimal en texto libre usan punto.
* `2.5 m. Norte Río Nashiño` (cat. con `Parque Nacional Yasuní`): la unidad `m.` para una distancia de 2,5 es inverosímil, probablemente `km`. No lo infiero."

te dije que el criterio te lo dejo a ti pero no me dijiste que decidiste

---

# claude response

Perdón, tienes razón: te dejé cuatro decisiones colgadas y no las cerré. Van primero, después la verificación de coordenadas y luego la auditoría de taxonomía.

---

# 0. LAS CUATRO DECISIONES DE §E — cerradas

| Caso | Decisión | Por qué |
|---|---|---|
| `min.` (13) vs `min` (46) | **Quitar el punto** → `min` | Es símbolo de unidad, mismo criterio que ya aplicaron las ops 100 y 106 con `mts.` → `m` y `Km.` → `km `. Un símbolo de unidad no lleva punto |
| Iniciales dobles pegadas | **Separar con espacio**: `P. A. Buckup`, `M. E. Sánchez`, `M. G. Sánchez` | El archivo ya escribe la inicial simple con espacio (`M. Ampam`, `K. Swing`) y cinco de los ocho nombres con dos iniciales usan la forma separada. Es formato, no identidad. **Los bloques sueltos `A.E.`, `M.O.`, `T.N.`, `G.M.W.`, `R.A.P.`, `E.P.` NO se tocan**: separarlos insinuaría una estructura nombre-apellido que no está confirmada (son E4) |
| `A 99,4 km NW. Playón` | **Punto decimal** → `99.4` | Dos celdas contra 18 que ya usan punto. No hay ambigüedad posible: `99,4 km` no puede ser separador de millares |
| `2.5 m. Norte Río Nashiño` | **No la toco. Va al oficio** | Aquí sí cambiaría el dato: 2,5 m y 2,5 km difieren por mil. Y la excluyo a propósito de la regla del punto anterior, porque quitarle el punto a esa `m.` haría que la lectura inverosímil parezca deliberada |

**Simulado: 15 celdas en `locality`, 68 en `recordedBy`, 0 en el resto. Cero colaterales** (`A.E.`/`M.O.`/`T.N.`/`G.M.W.`/`R.A.P.`/`E.P.` intactos, `2.5 m.` intacto).

```json
[
  {
    "op": "core/text-transform",
    "engineConfig": { "facets": [], "mode": "row-based" },
    "columnName": "locality",
    "expression": "grel:if(isBlank(value), value, value.replace(/\\bmin\\./, \"min\").replace(\"99,4 km\", \"99.4 km\"))",
    "onError": "keep-original",
    "repeat": false,
    "repeatCount": 0,
    "description": "min. -> min: simbolo de unidad sin punto, mismo criterio de mts.->m (op 100) y Km.->km (op 106). Coma decimal -> punto: 2 celdas frente a 18 que ya usan punto. NO se toca 2.5 m. del cat. 310: esa unidad esta en duda y va al oficio."
  },
  {
    "op": "core/text-transform",
    "engineConfig": { "facets": [], "mode": "row-based" },
    "columnName": "locationRemarks",
    "expression": "grel:if(isBlank(value), value, value.replace(/\\bmin\\./, \"min\").replace(\"99,4 km\", \"99.4 km\"))",
    "onError": "keep-original",
    "repeat": false,
    "repeatCount": 0,
    "description": "locationRemarks: misma regla por simetria de columna (0 celdas hoy)"
  },
  {
    "op": "core/text-transform",
    "engineConfig": { "facets": [], "mode": "row-based" },
    "columnName": "recordedBy",
    "expression": "grel:if(isBlank(value), value, value.replace(/\\b([A-ZÁÉÍÓÚÑ])\\.([A-ZÁÉÍÓÚÑ])\\.(?=\\s+[A-ZÁÉÍÓÚÑ][a-záéíóúñ])/, \"$1. $2.\"))",
    "onError": "keep-original",
    "repeat": false,
    "repeatCount": 0,
    "description": "Iniciales dobles pegadas seguidas de apellido: se separan con espacio, como ya escribe el archivo la inicial simple. El lookahead exige apellido detras, asi que A.E., M.O., T.N., G.M.W., R.A.P. y E.P. (bloque E4, sin apellido) quedan intactos."
  },
  {
    "op": "core/text-transform",
    "engineConfig": { "facets": [], "mode": "row-based" },
    "columnName": "identifiedBy",
    "expression": "grel:if(isBlank(value), value, value.replace(/\\b([A-ZÁÉÍÓÚÑ])\\.([A-ZÁÉÍÓÚÑ])\\.(?=\\s+[A-ZÁÉÍÓÚÑ][a-záéíóúñ])/, \"$1. $2.\"))",
    "onError": "keep-original",
    "repeat": false,
    "repeatCount": 0,
    "description": "identifiedBy: misma regla por simetria de columna (0 celdas hoy)"
  },
  {
    "op": "core/text-transform",
    "engineConfig": { "facets": [], "mode": "row-based" },
    "columnName": "recordEnteredBy",
    "expression": "grel:if(isBlank(value), value, value.replace(/\\b([A-ZÁÉÍÓÚÑ])\\.([A-ZÁÉÍÓÚÑ])\\.(?=\\s+[A-ZÁÉÍÓÚÑ][a-záéíóúñ])/, \"$1. $2.\"))",
    "onError": "keep-original",
    "repeat": false,
    "repeatCount": 0,
    "description": "recordEnteredBy: misma regla por simetria de columna (0 celdas hoy)"
  }
]
```

Añade al oficio, junto a `Punta km 13+501`: **catálogo 310, `Parque Nacional Yasuní. 2.5 m. Norte Río Nashiño` — ¿son 2,5 m o 2,5 km?**

---

# 1. LOS PARCHES DE COORDENADAS: APLICADOS Y VERIFICADOS

| Parche | Esperado | Encontrado |
|---|---|---|
| **12b** precisión por estructura | 28 filas reclasificadas | 28 exactas: `dms_minuto` 37→1, y las 28 filas a **1.900 m bajaron a 30/100 m**. Ninguna fila queda en 1.900 |
| **12c** simetría con el datum | 51 `precision_origen` vaciadas | 51, y ahora **0 filas con precisión y sin coordenada** |
| **15e** la incertidumbre declara su origen | ~6.200 `georeferenceRemarks` | 261 → **6.177**; filas con incertidumbre y sin protocolo ni remarks: **4.360 → 0** |
| **17b** techo de 6 decimales | `lat_final`/`lon_final` a 6 | 6 y 6. Antes 18 |

Y lo que **no** se movió: `decimalLatitude`, `decimalLongitude`, `metodo_correccion`, `coherencia_provincia`, `signo_ambiguo`, `coordenada_compartida`, `provincia_minoritaria`, `discordancia_explicada`, `confianza_coordenada`, `geodeticDatum` y `georeferenceVerificationStatus` — **idénticos en las 6.427 filas**. Los parches tocaron solo lo suyo.

**Un detalle cosmético que sí hay que arreglar:** la consola imprimió `filas reclasificadas por el parche 12b: NA`. Es mi `cat()`, no el parche: comparo contra `precision_verbatim` recalculado y esa función devuelve `NA` en las filas sin verbatim, así que el `sum()` propaga NA. Reemplaza esas tres líneas por:

```r
prev <- df$precision_origen
df$precision_origen <- mapply(reclasificar_precision,
                              df$verbatimCoordinates, prev, USE.NAMES = FALSE)
cat("  filas reclasificadas por el parche 12b:",
    sum(prev != df$precision_origen, na.rm = TRUE), "\n")
```

Debe imprimir **28**.

---

# 2. VEREDICTO GLOBAL — `Fishbase.R`

**CORRECTA.** Y con una propiedad que ningún script anterior había alcanzado:

> **Correcciones silenciosas: 0. Anotaciones vacías: 0.**
>
> 6.420 filas cambiaron algún campo taxonómico. 6.420 filas tienen `metodo_correccion_taxon` poblado. Cambio sin anotación: **0**. Anotación sin cambio: **0**. La trazabilidad que exige Guevara está cerrada al cien por cien, fila a fila.

| Verificación | Resultado |
|---|---|
| Estructura | 6.427 × 131 (112 heredadas + 19 nuevas), alineación 100 % |
| Preservación del origen | los 7 `*_verbatim` == entrada en **6.427/6.427** |
| `higherClassification` vs campos atómicos | **0 desajustes** en 6.427 filas |
| Un género → un orden | **0 géneros con dos órdenes** |
| Un género → una clase / una familia → una clase | **0 y 0** |
| Vocabularios | `kingdom` {Animalia}, `phylum` {Chordata}, `class` {Actinopterygii, Elasmobranchii}, `taxonRank` {species, genus, family, subfamily}. **0 valores fuera de vocabulario** |
| `order` con forma válida | 34 valores, **todos terminan en -iformes** |
| `family` con forma válida | 111 valores, **todos cumplen `[A-Z][a-z]+(idae\|inae)`** |
| `genus` == 1er término del binomio | 7 discrepancias, **las 7 marcadas** |
| `specificEpithet` == 2º término | 12 discrepancias, **las 12 marcadas** |
| `taxonRank=species` sin epíteto / `genus` con epíteto | **0 y 0** |
| Higiene (espacios, NBSP, controles, no-ASCII) en los 10 campos taxonómicos | **0** |
| Nombres que colapsan al normalizar caso/puntuación | **0 grupos** en `scientificName`, `genus`, `family`, `order` |
| El script no salió de su dominio | tocó 13 columnas taxonómicas + `continent`; **ninguna columna espacial** |

Cobertura ganada: `class` 37 → **6.420**, `genus` 5.547 → **6.396**, `specificEpithet` 4.330 → **5.160**, `taxonRank` 5.568 → **6.415**, `family` 6.395 → **6.420**.

---

# 3. FEEDBACK DE `Dudas.md` — bloque F

### 3.1 F12 hay que reescribirlo entero: no son dos familias, son ocho, y ninguna es «se documenta, no se corrige»

Tu texto dice: *«`Haemulidae` (16 filas sin orden, 1 con Perciformes) y `Pomacentridae` (14 sin orden, 1 con Acanthuriformes). No es error de dato: es el criterio de vaciar el orden cuando FishBase devuelve un clado informal».*

Lo verificado sobre el archivo:

**a) No son 30 filas sin orden, son 112**, repartidas en 12 familias: Sciaenidae 37, Gerreidae 18, Haemulidae 16, Pomacentridae 14, Labridae 6, Centropomidae 5, Polynemidae 5, Sphyraenidae 4, Lutjanidae 4, Malacanthidae 1, Priacanthidae 1. Las 112 traían `Perciformes` del origen y lo perdieron.

**b) La fila que «conserva el orden» en cada una de las dos familias no es una excepción del criterio: es un registro defectuoso.**

| Familia | La fila rara | Por qué conserva el orden |
|---|---|---|
| Haemulidae | cat. **5367**, `Orthropristis chalceus` | `Orthropristis` es errata de `Orthopristis` y por eso no resuelve en el backbone. El bloque 5c-bis lo salta y la fila se queda con el `Perciformes` del origen. **La inconsistencia de Haemulidae la causa una errata de género** |
| Pomacentridae | cat. **4201**, `Holacanthus passer` | `Holacanthus` sí resuelve, y su familia en el backbone es **Pomacanthidae**, no Pomacentridae. **La inconsistencia de Pomacentridae la causa una familia mal asignada** |

En los dos casos el patrón es el mismo: la fila que sobresale es la que tiene el defecto. Reescribe F12 como dos preguntas concretas (¿`Orthropristis` es `Orthopristis`? ¿el cat. 4201 es Pomacanthidae?) y no como una nota metodológica.

### 3.2 F4 y F11: el propio script tiene el criterio y no los incluyó

El bloque 4a declara: *«el nombre no existe con esa grafía, difiere en una o dos letras de un género válido, la familia declarada corresponde a ese género, y la grafía correcta ya está presente en el propio dataset»*. Tres géneros cumplen las cuatro condiciones y **no están en el mapa**:

| Como aparece | Filas | Grafía correcta, presente en el archivo | Familia |
|---|---|---|---|
| `Paradon` | **6** | `Parodon` (16 filas) | Parodontidae en ambas |
| `Amphyocharax` | 1 | `Aphyocharax` (1 fila) | Characidae en ambas |
| `Carcharthinus` | 2 | `Carcharhinus` (1 fila) | Carcharhinidae en ambas |

El de `Paradon` es el más grave y no está descrito así en el oficio: **`Paradon pongoensis` (6 filas) y `Parodon pongoensis` (9 filas) son el mismo binomio partido en dos miembros de la dimensión Taxón.**

Y un cuarto caso, que separo porque no es lo mismo: **`Saxatalia` (1) vs `Saxatilia` (5)**, misma familia y mismo orden, ninguno de los dos en el backbone. Aquí la mayoría interna es 5:1 pero no hay autoridad externa que arbitre, así que es inferencia del mismo estatus que `Araujo→Arajuno`: se aplica y se pide confirmada.

### 3.3 Un dato nuevo para F4: una de las seis filas de `Paradon` declara otra familia

El catálogo **6294** (`Paradon pongoensis`) trae `family = Lebiasinidae` mientras las otras cinco traen `Parodontidae`. El script lo marcó con `flag_family_minoritaria`, pero en el oficio no consta. Es una fila con dos defectos a la vez: grafía de género y familia.

### 3.4 F7: los cinco cualificadores están bien tratados, pero cinco filas distintas rompen la convención

Los cinco de F7 (`cf.batesii`, `gr. cochliodon`, `complex microps`) quedaron sin `taxonRank`, que es lo correcto. Lo que aparece al lado es otra cosa: **1.234 filas ponen el cualificador solo en `identificationQualifier`, y 5 lo meten además dentro de `scientificName`**:

| catalogNumber | `scientificName` | `identificationQualifier` |
|---|---|---|
| 5158, 5337 | `Syacium sp.` | `sp.` |
| 6425 | `Astroblepus sp.1` | `sp. 1` |
| 6426 | `Astroblepus sp.2` | `sp. 2` |
| 6427 | `Astroblepus sp.3` | `sp. 3` |

Fíjate en la contradicción **dentro de la misma fila**: el cualificador está escrito `sp.1` en el nombre y `sp. 1` en su propia columna. Y `Astroblepus sp.1` no empareja con ningún backbone: GBIF lo marcará.

### 3.5 F5 y F8 confirmados sin cambios

Los 7 sin taxonomía (`flag_sin_taxonomia`) y los 24 a nivel de familia siguen exactos. Y los 24 **ya tienen orden y clase los 24**: el parche 5c-quater cerró ese hueco de verdad.

---

# 4. RESUMEN DE CAMBIOS POR COLUMNA

**23.250 celdas en 13 columnas**, más `occurrenceStatus` como columna nueva:

| Columna | Celdas | Vacío→dato | Dato→vacío | Juicio |
|---|---|---|---|---|
| `continent` | 6.427 | 6.427 | 0 | correcto **salvo 4 filas** (§5.4) |
| `higherClassification` | 6.420 | 62 | 0 | correcto, regenerado y verificado contra los atómicos |
| `class` | 6.393 | 6.383 | 0 | correcto |
| `order` | 944 | 62 | **112** | **el vaciado de 112 es un defecto** (§5.1) |
| `taxonRank` | 858 | 847 | 0 | correcto |
| `genus` | 849 | 849 | 0 | correcto, descomposición mecánica |
| `specificEpithet` | 830 | 830 | 0 | correcto |
| `establishmentMeans` / `dynamicProperties` | 148 / 148 | 0 / 148 | 0 | correcto (`nativeEndemic` → `native` + endemismo preservado) |
| `kingdom` / `phylum` | 72 / 72 | 62 | 0 | correcto |
| `scientificName` | 46 | 0 | 0 | correcto: 40 de grafía de género, 5 de capitalización, 1 de familia |
| `family` | 43 | 25 | 0 | correcto |

**Daño colateral: ninguno.** Ni una celda modificada sin anotación, ni una anotación sin celda modificada. Y el script no salió de su dominio: no tocó una sola columna espacial.

---

# 5. NUEVAS ANOMALÍAS Y PLAN DE ACCIÓN

## 5.1 El defecto principal: dos pasadas de la misma regla con dos comportamientos distintos

La normalización de clados informales aparece dos veces con **dos regex y dos respaldos diferentes**:

| Pasada | Regex de validación | Qué hace si no valida |
|---|---|---|
| Primera (antes de 5c-bis) | `formes$` | **revierte a `order_verbatim`** |
| Segunda (después de 5c-bis) | `iformes$` | **vacía el campo** |

La segunda es la que alcanza a 128 filas, y por eso **112 registros salen al Darwin Core sin orden cuando el origen declaraba `Perciformes`**. Vaciar convierte «la autoridad se abstiene» en «no hay orden», que es una afirmación más fuerte de la que sostienen los datos: FishBase no dice que `Perciformes` sea falso, dice que su clado (`Eupercaria/misc`, `Carangaria/misc`, `Ovalentaria/misc`) no tiene rango formal. Y `order_fishbase_informal` ya deja constancia de esa discrepancia.

**Y hay una consecuencia peor: el vaciado silenció a su propio detector.** Con Pomacentridae en 14 vacíos + 1 `Acanthuriformes`, el orden mayoritario de la familia pasa a ser Acanthuriformes y `flag_orden_minoritario_en_familia` **no marca al catálogo 4201**, que es justo la fila anómala.

**Simulado el arreglo:** 112 filas recuperan `Perciformes`, `order` vacío baja de **119 a 7** (solo las 7 sin taxonomía), y las familias con el orden en dos estados bajan de 8 a 7 — **y las 7 restantes son exactamente los casos de F1**. La bandera se convierte en un detector limpio del error de familia.

```r
# ---- 5c-bis-fix. PARCHE: unificar el respaldo de las dos pasadas de clados
# informales. La primera pasada revierte a order_verbatim y la segunda vacia el
# campo; ademas una valida con "formes$" y la otra con "iformes$". El resultado
# es que 112 filas que declaraban Perciformes en el origen salen al DwCA sin
# orden. Que FishBase devuelva "Eupercaria/misc" no prueba que Perciformes sea
# falso: prueba que su clado no tiene rango formal, y eso ya queda registrado en
# order_fishbase_informal. Vaciar afirma mas de lo que el dato sostiene, y ademas
# apaga flag_orden_minoritario_en_familia justo donde hay una anomalia (cat. 4201).
# Sustituye el ifelse de la SEGUNDA pasada por este:
idx <- which(grepl("/", df$order))
if (length(idx)) {
  df$order_fishbase_informal[idx] <- df$order[idx]
  raiz <- sub("/.*$", "", df$order[idx])
  valido <- grepl("^[A-Z][a-z]+iformes$", raiz)
  df$order[idx] <- ifelse(valido, raiz, df$order_verbatim[idx])
  for (i in idx) anotar(i, "order_informal_reducido_a_orden_valido")
  cat("ordenes informales normalizados:", length(idx),
      "| revertidos al verbatim:", sum(!valido), "\n")
}
# Aplica el mismo criterio y el mismo regex a la PRIMERA pasada, que hoy usa
# "formes$" (acepta cualquier cosa terminada en -formes, no solo ordenes).
```

## 5.2 El mapa `grafia_genero` está incompleto — nueve filas

Tres géneros cumplen literalmente el criterio declarado del bloque 4a. Van **dentro del mapa existente**, no en un bloque aparte, porque no son un criterio nuevo:

```r
# Anadir estas tres entradas a grafia_genero (bloque 4a). Cumplen las cuatro
# condiciones del criterio ya declarado: el nombre no existe con esa grafia,
# difiere en una letra de un genero valido, la familia declarada coincide, y la
# grafia correcta ya esta en el propio archivo.
  "Paradon"        = "Parodon",        # Parodontidae; 6 filas. "Paradon pongoensis"
                                       # y "Parodon pongoensis" son el mismo binomio
  "Amphyocharax"   = "Aphyocharax",    # Characidae; 1 fila (F4 ya lo documenta)
  "Carcharthinus"  = "Carcharhinus",   # Carcharhinidae; 2 filas (F11 ya lo documenta)
```

Y aparte, porque no es lo mismo — aquí no hay autoridad externa, solo mayoría interna:

```r
# ---- 4a-bis. INFERENCIA POR MAYORIA INTERNA, no correccion verificada.
# Saxatilia (5 filas) y Saxatalia (1) conviven con la misma familia y el mismo
# orden, y ninguno de los dos resuelve en FishBase. Mismo estatus que
# Araujo->Arajuno: se aplica y se pide confirmada a Yanez en el mismo oficio.
idx <- which(df$genus == "Saxatalia" | grepl("^Saxatalia\\b", df$scientificName))
if (length(idx)) {
  df$genus[idx] <- ifelse(df$genus[idx] == "Saxatalia", "Saxatilia", df$genus[idx])
  df$scientificName[idx] <- sub("^Saxatalia\\b", "Saxatilia", df$scientificName[idx])
  for (i in idx) anotar(i, "genus_grafia_unificada_por_mayoria_interna")
  cat("Saxatalia -> Saxatilia (inferencia por mayoria interna):", length(idx), "fila(s)\n")
}
```

## 5.3 Convención del cualificador — seis celdas

Dos arreglos de formato con evidencia interna, ninguno pierde información:

```r
# ---- 4d. PARCHE: el cualificador vive en identificationQualifier, no en el nombre.
# 1.234 filas ponen el cualificador solo en su columna; 5 lo repiten dentro de
# scientificName, y ademas con otro formato en la misma fila ("sp.1" en el nombre
# frente a "sp. 1" en la columna). "Astroblepus sp.1" no empareja con ningun
# backbone y crea tres miembros espurios en la dimension Taxon. La distincion
# entre las tres morfoespecies NO se pierde: sigue integra en
# identificationQualifier, que es donde Darwin Core la espera.
idx <- which(grepl("\\bsp\\.?\\s*[0-9]*\\s*$", df$scientificName) &
             df$identificationQualifier != "")
if (length(idx)) {
  df$scientificName[idx] <- trimws(sub("\\s*\\bsp\\.?\\s*[0-9]*\\s*$", "", df$scientificName[idx]))
  for (i in idx) anotar(i, "cualificador_retirado_del_nombre")
  cat("cualificador retirado de scientificName:", length(idx), "fila(s)\n")
}

# Espacio tras el cualificador abreviado. El propio identificationQualifier del
# cat. 5146 ya escribe "cf. batesii" con espacio; el nombre dice "cf.batesii".
idx <- which(grepl("\\b(cf|aff|gr)\\.\\S", df$scientificName))
if (length(idx)) {
  df$scientificName[idx] <- sub("\\b(cf|aff|gr)\\.(\\S)", "\\1. \\2", df$scientificName[idx])
  for (i in idx) anotar(i, "espacio_tras_cualificador")
  cat("espacio insertado tras el cualificador:", length(idx), "fila(s)\n")
}
```

## 5.4 `continent` es la única imputación de todo el pipeline

`df$continent <- "South America"` escribe en las 6.427 filas, y **cuatro de ellas no declaran país, ni provincia, ni localidad, ni coordenada**: los catálogos 4371–4374, los mismos que el propio script marca con `registro_incompleto`. Afirmar el continente de un registro que no dice dónde está es exactamente lo que el PARCHE 1 del script de coordenadas prohibió para el datum.

```r
# 8b (corregido). El continente se sigue del pais o de la coordenada, que es
# dato del origen. En las 4 filas que no declaran ninguno de los dos (4371-4374,
# las mismas de registro_incompleto) no se sigue de nada: escribirlo seria la
# unica imputacion de todo el pipeline. Mismo criterio que el PARCHE 1 aplico al
# geodeticDatum sin coordenada.
tiene_anclaje <- (df$country != "" & !is.na(df$country)) |
                 (df$decimalLatitude != "" & !is.na(df$decimalLatitude))
df$continent <- ifelse(tiene_anclaje, "South America", "")
cat("continent escrito:", sum(tiene_anclaje),
    "| omitido por falta de anclaje geografico:", sum(!tiene_anclaje), "\n")
```

`occurrenceStatus = "present"` sí lo dejo en las 6.427, incluidas las 7 sin determinar: la presencia del ejemplar es un hecho del acervo y no depende de que esté identificado.

## 5.5 Para INABIO — sumar al oficio

1. **`Orthropristis chalceus` (cat. 5367)**: ¿es `Orthopristis`? Es la fila que rompe la coherencia de Haemulidae.
2. **`Holacanthus passer` (cat. 4201)**: el backbone lo pone en **Pomacanthidae** y el registro dice Pomacentridae. ¿Se corrige la familia?
3. **`Paradon pongoensis` (6 filas)**: confirmar que es `Parodon pongoensis`, el mismo binomio que ya está 9 veces en el archivo.
4. **Catálogo 6294**: única fila de `Paradon` con `family = Lebiasinidae` frente a cinco con `Parodontidae`.
5. **`Saxatalia` → `Saxatilia`** (1 fila): inferencia por mayoría interna, pendiente de visto bueno.
6. **Los 20 géneros de `generos_no_resueltos_backbone.csv`** hay que partirlos en dos listas antes de mandarlos: los que son **errata con la grafía correcta en el propio archivo** (`Paradon`, `Amphyocharax`, `Carcharthinus`) y los que son **géneros válidos ausentes de FishBase** (`Cochliodon`, `Piabucina`, `Lipopterichthys`, `Peckoltichthys`, `Pseudocetopsis`, `Parauchenipterus`, `Sciadeops`, `Durlanis`, `Saxatilia`). Mandarlos juntos hace que Yáñez revise 73 filas cuando 9 se resuelven sin él. **Buena noticia: ninguno de los 20 perdió jerarquía** — el respaldo por familia les dio clase y orden a los 73.

## 5.6 Verificado y descartado

- **`flag_family_discrepa_backbone` = 1.728 filas** no es una anomalía nueva: es el desdoblamiento de Characidae (Acestrorhamphidae 290+251+107…, Stevardiidae 206+198+95…). Marca, no corrige, y así debe quedarse hasta que INABIO fije la clasificación de referencia (F2).
- **`taxonID` sigue con 19 identificadores apuntando a más de un nombre (464 filas)** y 18 nombres con más de un `taxonID` (445 filas). Las correcciones de grafía no lo movieron. K5 sigue vigente sin cambios.
- **Los 4 casos de `slice_max` con empate** (Ilisha, Opisthonema, Urotrygon) están desempatados por backbone de forma determinista. No hay aleatoriedad en la salida.
- **`cap_nombre`** no rompió ningún nombre con cualificador: los de tres términos quedan fuera por construcción, y verifiqué que los 5 cambios son los declarados.
- **`Sciadeops`** parece errata de `Sciades` (que está en el archivo) pero **no lo propongo**: es un género descrito, no una grafía inexistente. Va a la lista de Yáñez, no al mapa.

---

## CIERRE

Aplica **5c-bis-fix**, las tres entradas de `grafia_genero`, **4a-bis**, **4d** y el **8b corregido**, y vuelve a correr. Espera ver: `order` vacío bajando de 119 a **7**, `flag_orden_minoritario_en_familia` subiendo de 7 a **8** (entra el 4201), `scientificName` con cinco cambios más, `Paradon`/`Amphyocharax`/`Carcharthinus`/`Saxatalia` desaparecidos como grafías, y `continent` en **6.423** filas en vez de 6.427. Si sale otra cifra, me la pasas y lo revisamos.

Con eso la fase R queda cerrada y lo siguiente es el `meta.xml` con el desplazamiento de índice, que es el último bloqueo antes del DwCA.

---

# you asked

message time: 2026-08-21 22:22:36

> source("~/Limpieza de datos/Limpieza_Ictiologia/scripts/Coordenadas.R", echo = TRUE)

> # ================================================================
> # LIMPIEZA DE COORDENADAS - Colección Ictiológica MECN-DP INABIO
> # Versión 4  .... [TRUNCATED] 

> library(dplyr)

> library(parzer)

> library(sf)

> sf::sf_use_s2(TRUE)   # necesario para que st_distance devuelva metros en EPSG:4326

> # ---- 0. Configuración ----
> ARCHIVO_ENTRADA <- "datos/02_intermedios/ocurrences_openrefine.csv"

> ARCHIVO_SALIDA  <- "datos/02_intermedios/ocurrences_salida_coordenadas.csv"

> ARCHIVO_REPORTE <- "reportes_y_revisiones/reporte_coordenadas_revision.csv"

> norm_nombre <- function(x) {
+   x <- iconv(x, to = "ASCII//TRANSLIT")
+   x <- tolower(gsub("[^A-Za-z ]", "", x))
+   trimws(gsub("\\s+", " ", x))
 .... [TRUNCATED] 

> # ---- Polígonos administrativos de nivel 1 (GADM 4.1) ----
> # Se descargan una sola vez y quedan cacheados en DIR_REFERENCIA. Requiere
> # los paq .... [TRUNCATED] 

> PAISES_GADM    <- c("ECU", "PER", "VEN")   # Ecuador + los dos transfronterizos

> TOLERANCIA_BORDE_M <- 5000

> dir.create(DIR_REFERENCIA, recursive = TRUE, showWarnings = FALSE)

> cargar_gadm <- function(paises, dir_cache) {
+   if (!requireNamespace("geodata", quietly = TRUE) ||
+       !requireNamespace("terra",   quietly =  .... [TRUNCATED] 

> df <- read_csv(ARCHIVO_ENTRADA, col_types = cols(.default = "c"))
                                                                                                                     
> cat("Filas cargadas:", nrow(df), "\n")
Filas cargadas: 6427 

> # ---- 1. Preservar el origen ANTES de tocar nada (CAMBIO 1) ----
> df$verbatimLatitude  <- df$decimalLatitude

> df$verbatimLongitude <- df$decimalLongitude

> df$decimalLatitude_num  <- suppressWarnings(as.numeric(df$decimalLatitude))

> df$decimalLongitude_num <- suppressWarnings(as.numeric(df$decimalLongitude))

> # ---- 2. Clasificar tipo de verbatimCoordinates ----
> classify_coord <- function(x) {
+   if (is.na(x) || trimws(x) == "") return("vacio")
+   if  .... [TRUNCATED] 

> df$coord_tipo <- sapply(df$verbatimCoordinates, classify_coord)

> es_utm_con_letra <- function(x) !grepl("°", x) & grepl("[0-9](\\.[0-9]+)?\\s*[ENSWensw]", x)

> df$coord_tipo[df$coord_tipo == "dms" & es_utm_con_letra(df$verbatimCoordinates)] <- "utm_o_similar"

> # ---- 2b. CAMBIO C: validación de rango en minutos y segundos ----
> # Un DMS con 075'' o 80' es aritméticamente parseable pero está mal escrito
>  .... [TRUNCATED] 

> df$dms_rango_invalido <- vapply(df$verbatimCoordinates, dms_rango_invalido, logical(1))

> cat("Filas con minutos o segundos >= 60 en el origen:", sum(df$dms_rango_invalido), "\n")
Filas con minutos o segundos >= 60 en el origen: 12 

> # ---- 3. Bounding box: Ecuador continental + Galápagos ----
> in_bbox <- function(lat, lon) {
+   continental <- !is.na(lat) & !is.na(lon) & lat >= .... [TRUNCATED] 

> # ---- 4. Validación de rangos UTM ----
> utm_easting_valido <- function(e) !is.na(e) && e >= 160000 && e <= 840000

> utm_northing_valido <- function(n, epsg) {
+   if (is.na(n)) return(FALSE)
+   if (epsg %in% c(32717, 32718)) return(n >= 9380000 && n <= 10000000)
 .... [TRUNCATED] 

> # ================================================================
> # CAMBIO A (1/2): los polígonos se cargan ANTES del corrector de signo,
> # por .... [TRUNCATED] 

> gadm <- cargar_gadm(PAISES_GADM, DIR_REFERENCIA)

> if (!is.null(gadm)) {
+   # Alias: stateProvince que no son nivel 1 en su pais.
+   # "Maynas" es provincia peruana dentro del departamento de Loret .... [TRUNCATED] 

> prov_norm_df[is.na(prov_norm_df)] <- ""

> # Union por provincia, calculada una sola vez y reutilizada tanto por el
> # desempate de signo como por la evaluación de coherencia del bloque 14.
 .... [TRUNCATED] 

> if (!is.null(gadm)) {
+   for (p in unique(prov_norm_df[prov_norm_df != ""])) {
+     sel <- gadm[gadm$prov_norm == p, ]
+     if (nrow(sel) > 0) po .... [TRUNCATED] 
Poligonos cargados: 75 | provincias con union: 26 

> # Devuelve TRUE/FALSE si hay polígono para la provincia declarada, NA si no
> # se puede evaluar. NA nunca se interpreta como aprobación.
> en_provi .... [TRUNCATED] 

> # ---- 5. Corrector de swap/signo (CAMBIO A 2/2) ----
> # Regla de precedencia:
> #   1. Si la coordenada de origen ya cae en el bbox, se respeta ta .... [TRUNCATED] 

> # ---- 6. Guardián transfronterizo ----
> regiones_transfronterizas <- c("Apure", "Maynas", "Loreto")

> es_transfronterizo <- df$stateProvince %in% regiones_transfronterizas |
+   (!is.na(df$country) & !df$country %in% c("Ecuador", ""))

> cat("Registros transfronterizos identificados:", sum(es_transfronterizo), "\n")
Registros transfronterizos identificados: 13 

> # ---- 7. Filas con decimalLatitude/Longitude ya pobladas ----
> df$lat_final <- NA_real_; df$lon_final <- NA_real_; df$metodo_correccion <- NA_char .... [TRUNCATED] 

> for (i in seq_len(nrow(df))) {
+   la <- df$decimalLatitude_num[i]; lo <- df$decimalLongitude_num[i]
+   if (is.na(la) || is.na(lo)) { df$metodo_cor .... [TRUNCATED] 

> # ---- 8. Parsers para reconstruir desde verbatimCoordinates ----
> normalize_dms <- function(x) {
+   x <- gsub("´´", '"', x); x <- gsub("''", '"', .... [TRUNCATED] 

> # CAMBIO 2: el northing manda sobre la letra.
> # En UTM el falso norte de 10.000.000 m solo existe en el hemisferio sur, así
> # que un northing >= .... [TRUNCATED] 

> convertir_utm2 <- function(raw) {
+   if (is.na(raw)) return(c(lat = NA, lon = NA, zona = NA))
+   hemisferio <- detectar_hemisferio(raw)
+   raw_cl .... [TRUNCATED] 

> resolve_dms <- function(raw, es_transf, prov_norm = "") {
+   raw_norm <- normalize_dms(raw)
+   partes <- regmatches(raw_norm, regexec("^(.*[NnSs]) ..." ... [TRUNCATED] 

> vacio_idx <- which(df$metodo_correccion == "vacio")

> for (i in vacio_idx) {
+   tipo <- df$coord_tipo[i]; raw <- df$verbatimCoordinates[i]
+   if (is.na(raw) || trimws(raw) == "") next
+   if (tipo ==  .... [TRUNCATED] 

> # ---- 8b. Respaldo: coordenadas sin letra de hemisferio (signo inferido) ----
> intentar_sin_hemisferio <- function(raw, prov_norm = "") {
+   x <- .... [TRUNCATED] 

> pendientes_idx <- which(is.na(df$lat_final) & !is.na(df$verbatimCoordinates) &
+                           trimws(df$verbatimCoordinates) != "")

> for (i in pendientes_idx) {
+   r <- intentar_sin_hemisferio(df$verbatimCoordinates[i], prov_norm_df[i])
+   if (!is.na(r["lat"])) {
+     df$lat_fi .... [TRUNCATED] 

> # ---- 8c. Zona UTM 17S mal asignada en Sucumbíos/Orellana ----
> # Verificado con pyproj y reverificado en la auditoría de la v2: para el mismo
> # .... [TRUNCATED] 

> idx_zona <- which(df$metodo_correccion == "utm_zona_32717" &
+                     df$stateProvince %in% c("Sucumbíos", "Orellana"))

> for (i in idx_zona) {
+   r <- convertir_zona18(df$verbatimCoordinates[i])
+   if (!is.na(r["lat"])) {
+     df$lat_final[i] <- as.numeric(r["lat"]) .... [TRUNCATED] 

> # ---- 9. Centroides de referencia por provincia (solo informativo) ----
> dist_km <- function(lat1, lon1, lat2, lon2) {
+   sqrt(((lat1 - lat2) * 1 .... [TRUNCATED] 

> centroides <- df %>%
+   filter(metodo_correccion %in% c("original", "dms_directo"), !is.na(lat_final)) %>%
+   group_by(stateProvince) %>%
+   summ .... [TRUNCATED] 

> coherente_con_centroide <- function(lat, lon, prov, umbral_km = 150) {
+   if (is.na(lat) || is.na(prov) || !(prov %in% centroides$stateProvince)) r .... [TRUNCATED] 

> df$dist_centroide_km <- mapply(function(la, lo, p) {
+   if (is.na(la) || is.na(p) || !(p %in% centroides$stateProvince)) return(NA_real_)
+   cc <- .... [TRUNCATED] 

> # ---- 10. Recuperación de irreparables con doble validación ----
> # CAMBIO 7: clase de caracteres explícita. En TRE (gsub sin perl=TRUE) la
> # se .... [TRUNCATED] 

> recuperar_decimal_corrupto <- function(raw, prov) {
+   m <- regmatches(raw, regexec("^(-?[0-9]+\\.[0-9]+)\\s+(-?[0-9,]+)$", raw))[[1]]
+   if (leng .... [TRUNCATED] 

> df$metodo_correccion[df$metodo_correccion == "vacio" & is.na(df$lat_final)] <- "irreparable"

> irr_idx <- which(df$metodo_correccion == "irreparable" &
+                    !is.na(df$verbatimCoordinates) & trimws(df$verbatimCoordinates) != "")

> n_rec <- 0

> for (i in irr_idx) {
+   r <- recuperar_northing_truncado(df$verbatimCoordinates[i], df$stateProvince[i])
+   if (is.null(r)) r <- recuperar_decimal .... [TRUNCATED] 

> cat("Filas recuperadas del bloque irreparable:", n_rec, "\n")
Filas recuperadas del bloque irreparable: 6 

> # CAMBIO 6: tres causas distintas de ausencia de coordenada.
> sin_verbatim <- is.na(df$verbatimCoordinates) | trimws(df$verbatimCoordinates) == ""

> sin_decimal  <- is.na(df$decimalLatitude_num)

> df$metodo_correccion[df$metodo_correccion == "irreparable" & sin_verbatim & sin_decimal] <-
+   "sin_dato_origen"

> df$metodo_correccion[df$metodo_correccion == "irreparable" & sin_verbatim & !sin_decimal] <-
+   "descartada_fuera_de_rango"

> # CAMBIO A: bandera explícita de elección de signo no resuelta por polígono.
> df$signo_ambiguo <- !is.na(df$metodo_correccion) & grepl("_ambiguo$", .... [TRUNCATED] 

> cat("Filas con signo ambiguo no resuelto por poligono:", sum(df$signo_ambiguo), "\n")
Filas con signo ambiguo no resuelto por poligono: 14 

> # ---- 11. Nivel de confianza por fila ----
> df$confianza_coordenada <- dplyr::case_when(
+   is.na(df$lat_final) ~ "sin_coordenada",
+   df$metodo .... [TRUNCATED] 

> # ---- 12. Precisión leída del ORIGEN (CAMBIO B) ----
> # La v3 cerraba con return("utm_metro") y convertía en UTM cualquier cadena
> # no reconocid .... [TRUNCATED] 

> df$precision_origen <- mapply(precision_verbatim,
+                               df$verbatimCoordinates, df$verbatimLatitude, df$coord_tipo)

> # ---- 12b. PARCHE: la precision de un sexagesimal no depende de que los segundos
> # lleven comilla doble. El clasificador del bloque 12 etiqueta d .... [TRUNCATED] 

> prev <- df$precision_origen

> df$precision_origen <- mapply(reclasificar_precision,
+                               df$verbatimCoordinates, prev, USE.NAMES = FALSE)

> cat("  filas reclasificadas por el parche 12b:",
+     sum(prev != df$precision_origen, na.rm = TRUE), "\n")
  filas reclasificadas por el parche 12b: 32 

> # ---- 12c. Simetria con el PARCHE 1: si se retira el datum de una fila sin
> # coordenada porque "un datum sin coordenada no significa nada", lo mi .... [TRUNCATED] 

> # ---- 13. coordinateUncertaintyInMeters estimada ----
> df$coordinateUncertaintyInMeters <- dplyr::case_when(
+   is.na(df$lat_final) ~ NA_characte .... [TRUNCATED] 

> # ---- 13b. PARCHE 2: piso tecnologico de la incertidumbre ----
> # Seis decimales son 11 cm y el bloque 13 los traducia a 10 m en 4.249
> # filas.  .... [TRUNCATED] 

> piso_m <- ifelse(is.na(anio_evento) | anio_evento < 2000, 100, 30)

> unc_num  <- suppressWarnings(as.numeric(df$coordinateUncertaintyInMeters))

> unc_piso <- pmax(unc_num, piso_m)

> df$piso_incertidumbre_aplicado <- !is.na(unc_num) & unc_piso > unc_num

> df$coordinateUncertaintyInMeters <- ifelse(is.na(unc_piso), NA_character_,
+                                            as.character(as.integer(unc_ .... [TRUNCATED] 

> df$incertidumbre_criterio <- ifelse(
+   is.na(df$coordinateUncertaintyInMeters), NA_character_,
+   paste0("estimada_desde_precision_origen:", df$p .... [TRUNCATED] 

> cat("  incertidumbre elevada al piso tecnologico:",
+     sum(df$piso_incertidumbre_aplicado, na.rm = TRUE), "\n")
  incertidumbre elevada al piso tecnologico: 4538 

> # ================================================================
> # 14. Coherencia con la provincia por contención en polígono
> # (CAMBIO 3 y 5  .... [TRUNCATED] 

> df$criterio_coherencia     <- NA_character_

> df$dist_fuera_provincia_km <- NA_real_

> df$umbral_km               <- NA_real_

> tiene_coord <- !is.na(df$lat_final)

> if (!is.null(gadm)) {
+   df$criterio_coherencia[tiene_coord] <- "poligono_gadm"
+   pts <- sf::st_as_sf(
+     data.frame(idx = which(tiene_coord), .... [TRUNCATED] 
  reclasificadas como fuera_de_tierra_firme: 9 

> # ---- 14b. Reparto de las discordancias: mecanicas vs. sin explicacion.
> # No corrige ninguna coordenada. Solo responde: ¿invertir el signo de la
 .... [TRUNCATED] 

> for (i in which(df$coherencia_provincia == "discordante")) {
+   p  <- prov_norm_df[i]
+   la <- df$lat_final[i]; lo <- df$lon_final[i]
+   df$disco .... [TRUNCATED] 

> cat("\n=== REPARTO DE LAS DISCORDANCIAS ===\n")

=== REPARTO DE LAS DISCORDANCIAS ===

> print(table(df$discordancia_explicada, useNA = "no"))

           signo_latitud sin_explicacion_mecanica 
                      85                      146 

> print(table(df$stateProvince, df$discordancia_explicada))
                                
                                 signo_latitud sin_explicacion_mecanica
  Apure                                      0                        0
  Azuay                                      0                        0
  Bolívar                                    0                        3
  Cañar                                      0                        0
  Carchi                                     0                        1
  Chimborazo                                 0                        0
  Cotopaxi                                   0                        2
  El Oro                                     0                       11
  Esmeraldas                                80                       13
  Galápagos                                  0                        0
  Guayas                                     0                        1
  Imbabura                                   1                        1
  Loja                                       0                        0
  Loreto                                     0                        0
  Los Ríos                                   0                        0
  Manabí                                     0                        5
  Maynas                                     0                        0
  Morona Santiago                            0                        7
  Napo                                       0                        7
  Orellana                                   2                       14
  Pastaza                                    0                       19
  Pichincha                                  2                       12
  Santa Elena                                0                        0
  Santo Domingo de los Tsáchilas             0                        3
  Sucumbíos                                  0                       44
  Tungurahua                                 0                        3
  Zamora Chinchipe                           0                        0

> # ---- 14c. Northing fuera de rango: ¿un solo digito lo explica? Se prueba solo
> # en las discordancias que produjo nuestra propia conversion UTM.  .... [TRUNCATED] 

> idx <- which(df$coherencia_provincia == "discordante" &
+                df$discordancia_explicada == "sin_explicacion_mecanica" &
+                 .... [TRUNCATED] 

> for (i in idx) {
+   nums <- as.numeric(regmatches(df$verbatimCoordinates[i],
+             gregexpr("[0-9]+\\.?[0-9]*", df$verbatimCoordinates[i])) .... [TRUNCATED] 

> cat("Discordancias con hipotesis de un digito en el northing:",
+     sum(!is.na(df$hipotesis_northing)), "de", length(idx), "\n")
Discordancias con hipotesis de un digito en el northing: 13 de 15 

> # ================================================================
> # CAMBIO 4: coordenada compartida vs provincia minoritaria
> # ================ .... [TRUNCATED] 

> df$clave_coord <- clave

> resumen_clave <- df %>%
+   filter(!is.na(clave_coord), !is.na(stateProvince), stateProvince != "") %>%
+   count(clave_coord, stateProvince, name = .... [TRUNCATED] 

> claves_compartidas <- unique(resumen_clave$clave_coord[resumen_clave$n_prov > 1])

> pares_mayoritarios <- resumen_clave %>%
+   filter(n_filas == n_max) %>%
+   transmute(par = paste(clave_coord, stateProvince, sep = "||")) %>%
+    .... [TRUNCATED] 

> df$coordenada_compartida <- !is.na(df$clave_coord) & df$clave_coord %in% claves_compartidas

> df$provincia_minoritaria <- df$coordenada_compartida &
+   !(paste(df$clave_coord, df$stateProvince, sep = "||") %in% pares_mayoritarios)

> # ---- 15. No declarar precisión sobre una coordenada contradictoria ----
> # Con poligono disponible, la contencion geografica es el criterio; la m .... [TRUNCATED] 

> df$coordinateUncertaintyInMeters[sospechosa] <- NA_character_

> df$incertidumbre_criterio[sospechosa] <- "no_estimable_coordenada_marcada_para_revision"

> df$georeferenceVerificationStatus <- dplyr::case_when(
+   is.na(df$lat_final) ~ NA_character_,
+   sospechosa          ~ "requires verification",
+ .... [TRUNCATED] 

> # ---- 15b. PARCHE 4: la bandera minoritaria viaja al Darwin Core ----
> # El bloque 15 la excluye de "sospechosa" a proposito y esta bien: con
> #  .... [TRUNCATED] 

> cat("  georeferenceRemarks poblado por provincia minoritaria:",
+     sum(df$provincia_minoritaria & !is.na(df$lat_final), na.rm = TRUE), "\n")
  georeferenceRemarks poblado por provincia minoritaria: 56 

> # ---- 15c. La evaluacion de coherencia que no se pudo hacer, o que dio fuera
> # de tierra firme, tambien tiene que viajar. Un registro marino en u .... [TRUNCATED] 

> marca[!is.na(df$lat_final) & df$coherencia_provincia == "fuera_de_tierra_firme"] <-
+   "coordenada fuera del poligono terrestre de la provincia dec ..." ... [TRUNCATED] 

> marca[!is.na(df$lat_final) & df$coherencia_provincia == "no_evaluable"] <-
+   "coherencia con la provincia no evaluable: el registro no declara pro ..." ... [TRUNCATED] 

> df$georeferenceRemarks <- ifelse(
+   is.na(marca), df$georeferenceRemarks,
+   ifelse(is.na(df$georeferenceRemarks) | df$georeferenceRemarks == "", .... [TRUNCATED] 

> cat("  georeferenceRemarks poblado por coherencia no concluyente:",
+     sum(!is.na(marca)), "\n")
  georeferenceRemarks poblado por coherencia no concluyente: 13 

> # ---- 15d. El motivo de la marca tambien tiene que viajar. El bloque 15 pone
> # "requires verification" en 238 filas y el bloque 14b ya sabe por q .... [TRUNCATED] 

> motivo[!is.na(df$lat_final) & df$coherencia_provincia == "discordante" &
+          df$discordancia_explicada == "signo_latitud"] <-
+   "punto fuer ..." ... [TRUNCATED] 

> motivo[!is.na(df$lat_final) & df$coherencia_provincia == "discordante" &
+          df$discordancia_explicada == "sin_explicacion_mecanica"] <-
+    .... [TRUNCATED] 

> motivo[!is.na(df$lat_final) & df$signo_ambiguo] <- ifelse(
+   is.na(motivo[!is.na(df$lat_final) & df$signo_ambiguo]),
+   "el origen no declara hem ..." ... [TRUNCATED] 

> motivo[!is.na(df$lat_final) & df$dms_rango_invalido] <- ifelse(
+   is.na(motivo[!is.na(df$lat_final) & df$dms_rango_invalido]),
+   "el sexagesimal ..." ... [TRUNCATED] 

> df$georeferenceRemarks <- ifelse(
+   is.na(motivo), df$georeferenceRemarks,
+   ifelse(is.na(df$georeferenceRemarks) | df$georeferenceRemarks == "" .... [TRUNCATED] 

> cat("  georeferenceRemarks poblado por motivo de revision:", sum(!is.na(motivo)), "\n")
  georeferenceRemarks poblado por motivo de revision: 238 

> # ---- 15e. PARCHE: la incertidumbre tambien tiene que decir de donde sale.
> # 4.360 filas publican coordinateUncertaintyInMeters sin protocolo ni  .... [TRUNCATED] 

> df$georeferenceRemarks <- ifelse(
+   is.na(nota_unc), df$georeferenceRemarks,
+   ifelse(is.na(df$georeferenceRemarks) | df$georeferenceRemarks ==  .... [TRUNCATED] 

> cat("  georeferenceRemarks poblado por incertidumbre estimada:",
+     sum(!is.na(nota_unc)), "\n")
  georeferenceRemarks poblado por incertidumbre estimada: 5939 

> # CAMBIO 8: declarar el protocolo solo donde hubo reconstrucción.
> df$georeferenceProtocol <- ifelse(
+   !is.na(df$lat_final) & !df$metodo_correcc .... [TRUNCATED] 

> # ================================================================
> # CAMBIO 1: volcar el resultado a los campos Darwin Core
> # ================== .... [TRUNCATED] 

> # Seis decimales es el techo que GBIF acepta sin marcar COORDINATE_ROUNDED, y
> # recortar los ceros de cola evita afirmar una resolucion que la fic .... [TRUNCATED] 

> df$decimalLatitude  <- ifelse(is.na(df$lat_final),  "", fmt_coord(round(df$lat_final,  6)))

> df$decimalLongitude <- ifelse(is.na(df$lon_final), "", fmt_coord(round(df$lon_final, 6)))

> # El datum solo se declara donde el script lo determinó: la conversión UTM usa
> # EPSG:327xx/326xx, que son WGS84 por definición. En las filas que  .... [TRUNCATED] 

> n_datum_nuevo   <- sum(justifica_datum &
+                        (is.na(df$geodeticDatum) | df$geodeticDatum == ""))

> df$geodeticDatum <- ifelse(justifica_datum & (is.na(df$geodeticDatum) | df$geodeticDatum == ""),
+                            "WGS84", df$geodeticDa .... [TRUNCATED] 

> cat("  geodeticDatum escrito por conversion UTM:", n_datum_nuevo,
+     "de", sum(justifica_datum), "filas convertidas\n")
  geodeticDatum escrito por conversion UTM: 492 de 1013 filas convertidas

> # PARCHE 1: un datum sin coordenada no significa nada. 51 filas traian
> # WGS84 desde el portal y se quedaron sin punto (49 irreparables, 1
> # des .... [TRUNCATED] 

> df$geodeticDatum[is.na(df$lat_final)] <- NA_character_

> cat("  geodeticDatum retirado por falta de coordenada:", n_datum_huerfano, "\n")
  geodeticDatum retirado por falta de coordenada: 51 

> cat("\nVolcado a Darwin Core:\n")

Volcado a Darwin Core:

> cat("  decimalLatitude poblado :", sum(df$decimalLatitude != ""), "\n")
  decimalLatitude poblado : 6177 

> cat("  filas donde cambió      :", sum(!identico & !is.na(df$lat_final)), "\n")
  filas donde cambió      : 1605 

> cat("  origen preservado en verbatimLatitude/verbatimLongitude\n")
  origen preservado en verbatimLatitude/verbatimLongitude

> # ---- 16. Resumen ----
> cat("\n=== MÉTODO DE CORRECCIÓN ===\n");  print(table(df$metodo_correccion, useNA = "ifany"))

=== MÉTODO DE CORRECCIÓN ===

         decimal_separador_corrupto         decimal_sin_signo_neg_ambos   decimal_sin_signo_neg_lon_ambiguo 
                                  1                                   6                                   2 
          descartada_fuera_de_rango                         dms_directo                       dms_neg_ambos 
                                  1                                 234                                  47 
                        dms_neg_lon                 dms_neg_lon_ambiguo                  dms_swap_neg_ambos 
                                 15                                   2                                   8 
                   dms_swap_neg_lon                         irreparable                           neg_ambos 
                                  8                                  66                                   7 
                            neg_lon                     neg_lon_ambiguo                            original 
                                  1                                   4                                4562 
           original_transfronterizo                     sin_dato_origen            sin_hemisferio_neg_ambos 
                                 10                                 183                                  33 
             sin_hemisferio_neg_lon      sin_hemisferio_neg_lon_ambiguo             sin_hemisferio_original 
                                  1                                   4                                  16 
      sin_hemisferio_swap_neg_ambos sin_hemisferio_swap_neg_lon_ambiguo                                swap 
                                  1                                   2                                 197 
        utm_northing_truncado_32717         utm_northing_truncado_32718                      utm_zona_32617 
                                  3                                   2                                  27 
                     utm_zona_32717         utm_zona_32717_northing_x10                      utm_zona_32718 
                                 42                                   6                                 899 
  utm_zona_32718_corregido_de_32717        utm_zona_32718_northing_x100            verbatim_transfronterizo 
                                 29                                   5                                   3 

> cat("\n=== NIVEL DE CONFIANZA ===\n");    print(table(df$confianza_coordenada))

=== NIVEL DE CONFIANZA ===

    convertida       inferida          leida   reconstruida sin_coordenada 
          1008            354           4809              6            250 

> cat("\n=== COHERENCIA CON LA PROVINCIA ===\n")

=== COHERENCIA CON LA PROVINCIA ===

> print(table(df$coherencia_provincia, df$criterio_coherencia, useNA = "ifany"))
                       
                        poligono_gadm sin_provincia_declarada <NA>
  coherente                      5933                       0    0
  discordante                     231                       0    0
  fuera_de_tierra_firme             9                       0    0
  no_evaluable                      0                       4    0
  <NA>                              0                       0  250

> cat("\n=== BANDERAS ===\n")

=== BANDERAS ===

> cat("  coordenada compartida entre provincias:", sum(df$coordenada_compartida, na.rm = TRUE), "\n")
  coordenada compartida entre provincias: 525 

> cat("  de ellas, en provincia minoritaria    :", sum(df$provincia_minoritaria, na.rm = TRUE), "\n")
  de ellas, en provincia minoritaria    : 56 

> cat("  signo ambiguo no resuelto             :", sum(df$signo_ambiguo, na.rm = TRUE), "\n")
  signo ambiguo no resuelto             : 14 

> cat("  DMS con minuto o segundo >= 60        :", sum(df$dms_rango_invalido & tiene_coord, na.rm = TRUE), "\n")
  DMS con minuto o segundo >= 60        : 12 

> cat("  marcadas para revisión (sospechosas)  :", sum(sospechosa, na.rm = TRUE), "\n")
  marcadas para revisión (sospechosas)  : 238 

> cat("  con coordenada y sin incertidumbre    :",
+     sum(!is.na(df$lat_final) & is.na(df$coordinateUncertaintyInMeters)), "\n")
  con coordenada y sin incertidumbre    : 238 

> cat("\n=== COBERTURA ===\n")

=== COBERTURA ===

> cat("  con coordenada:", sum(!is.na(df$lat_final)),
+     sprintf("(%.1f%%)\n", 100 * mean(!is.na(df$lat_final))))
  con coordenada: 6177 (96.1%)

> cat("  sin coordenada:", sum(is.na(df$lat_final)), "\n")
  sin coordenada: 250 

> # ---- 17. Exportación ----
> # CAMBIO D: umbral_km solo tiene sentido si corrió la rama de respaldo.
> df_export <- df %>% select(-decimalLatitude_ .... [TRUNCATED] 

> if (!is.null(gadm)) df_export <- df_export %>% select(-umbral_km)

> # ---- 17b. lat_final/lon_final son la coordenada sin redondear. El bloque 16 fija
> # 6 decimales como techo publicable; el CSV intermedio no puede .... [TRUNCATED] 

> df_export$lon_final <- ifelse(is.na(df$lon_final), "", fmt_coord(round(df$lon_final, 6)))

> write_csv(df_export, ARCHIVO_SALIDA, na = "")
                                                                                                                   
> cat("\nGuardado en", ARCHIVO_SALIDA, "\n")

Guardado en datos/02_intermedios/ocurrences_salida_coordenadas.csv 

> # CAMBIO A, C y D: el reporte incorpora signo ambiguo, DMS fuera de rango y
> # los registros marinos reclasificados.
> df %>%
+   filter(coherencia .... [TRUNCATED] 
                                                                                                                   
> cat("Reporte de revisión en", ARCHIVO_REPORTE, "\n")
Reporte de revisión en reportes_y_revisiones/reporte_coordenadas_revision.csv 
Avisos:
1: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  80 38 52 
2: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  80 38 52 
3: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  80 38 52 
4: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 00 57 075  80 42 32
5: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 55 71 54 53 
6: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  80 38 52 
7: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 00 20 27  90 51 35
8: In base::.Call(...) : not within -180/360 range, got: 9994 
9: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  90 38 52 
10: In base::.Call(...) :
  invalid format, more than 3 numeric slots, got: 8  80 38 52 
> source("~/Limpieza de datos/Limpieza_Ictiologia/scripts/Fishbase.R", echo = TRUE)

> # ================================================================
> # CORRECCIÓN TAXONÓMICA - Colección Ictiológica MECN-DP INABIO
> #
> # Solo err .... [TRUNCATED] 

> ARCHIVO_ENTRADA <- "datos/02_intermedios/ocurrences_salida_coordenadas.csv"

> ARCHIVO_SALIDA  <- "datos/02_intermedios/ocurrences_salida_taxonomia.csv"

> df <- read_csv(ARCHIVO_ENTRADA, col_types = cols(.default = "c"))
                                                                                                                     
> cat("Filas:", nrow(df), "\n")
Filas: 6427 

> if (!"metodo_correccion_taxon" %in% names(df)) df$metodo_correccion_taxon <- ""

> anotar <- function(i, txt) {
+   df$metodo_correccion_taxon[i] <<- ifelse(df$metodo_correccion_taxon[i] == "", txt,
+                                .... [TRUNCATED] 

> # Preservar el valor de origen ANTES de tocar nada
> for (col in c("kingdom","phylum","class","order","family","scientificName","higherClassificatio ..." ... [TRUNCATED] 

> backbone <- load_taxa() %>% select(Genus, Family, Order, Class) %>%
+   distinct(Genus, .keep_all = TRUE)

> # FishBase usa Teleostei como clase; el backbone de publicación usa
> # Actinopterygii. Escribir Teleostei genera conflicto al publicar.
> clase_dwc .... [TRUNCATED] 

> # ---- 1. kingdom = Plantae: colisión de homónimos ----
> # Sicydium y Loricaria existen como género de pez y como género de planta,
> # descritos p .... [TRUNCATED] 

> for (i in idx_plantae) {
+   fb <- backbone %>% filter(Genus == df$genus[i])
+   if (nrow(fb) != 1) { warning(sprintf("fila %d: género '%s' sin reso ..." ... [TRUNCATED] 

> cat("kingdom=Plantae corregidos:", length(idx_plantae), "\n")
kingdom=Plantae corregidos: 10 

> # ---- 2. Rango equivocado en el campo family ----
> # El campo contiene una subfamilia o un orden en lugar de una familia.
> # No es una reasignaci .... [TRUNCATED] 

> for (mal in names(rango_erroneo)) {
+   idx <- which(df$family == mal)
+   if (!length(idx)) next
+   df$family[idx] <- rango_erroneo[[mal]]
+   for .... [TRUNCATED] 
   Characinae -> Characidae : 7 fila(s)
   Tetragonopterinae -> Characidae : 1 fila(s)
   Loricariinae -> Loricariidae : 1 fila(s)
   Clupeiformes -> Engraulidae : 1 fila(s)

> # ---- 3. Grafía incorrecta de familia ----
> # La familia no existe con esa grafía; difiere en una o dos letras de una
> # familia válida y el géne .... [TRUNCATED] 

> for (mal in names(grafia_familia)) {
+   idx <- which(df$family == mal)
+   if (!length(idx)) next
+   df$family[idx] <- grafia_familia[[mal]]
+   f .... [TRUNCATED] 
   Archiridae -> Achiridae : 1 fila(s)
   Scorpanidae -> Scorpaenidae : 1 fila(s)
   Triporthidae -> Triportheidae : 1 fila(s)
   Characidiidae -> Crenuchidae : 1 fila(s)
   Asprenidae -> Aspredinidae : 1 fila(s)
   Gemplylidae -> Gempylidae : 1 fila(s)

> # ---- 3b. family con valor que no es una denominación de familia ----
> # El campo debe contener un nombre de familia. Una cadena de autoría en
> # .... [TRUNCATED] 

> if (length(idx)) {
+   cat("family con formato inválido (vaciada para derivar del género):\n")
+   print(unique(df$family[idx]))
+   df$family[idx]  .... [TRUNCATED] 
family con formato inválido (vaciada para derivar del género):
[1] "(Fels & de Rham, 1981)"

> # ---- 4. Capitalización binomial ----
> # Convención nomenclatural: género en mayúscula inicial, epíteto en
> # minúscula. Es una regla de formato, .... [TRUNCATED] 

> nuevo <- vapply(df$scientificName, cap_nombre, character(1), USE.NAMES = FALSE)

> idx <- which(!is.na(nuevo) & nuevo != df$scientificName)

> if (length(idx)) {
+   cat("  capitalización binomial corregida:", length(idx), "fila(s)\n")
+   print(unique(data.frame(de = df$scientificName[idx] .... [TRUNCATED] 
  capitalización binomial corregida: 5 fila(s)
                       de                       a
1                  knodus                  Knodus
2 Crenicichlla Sedentaria Crenicichlla sedentaria
3    Bujurquina Huallagae    Bujurquina huallagae
4 pyrrhulina semifasciata Pyrrhulina semifasciata

> # ---- 4a. Grafía incorrecta de género ----
> # Mismo criterio que grafia_familia: el nombre no existe con esa grafía,
> # difiere en una o dos letr .... [TRUNCATED] 

> n_gg <- 0

> for (mal in names(grafia_genero)) {
+   bien <- grafia_genero[[mal]]
+   idx <- which(df$genus == mal |
+                grepl(paste0("^", mal, "\\b ..." ... [TRUNCATED] 
   Symbranchus -> Synbranchus : 11 fila(s)
   Astroblepu -> Astroblepus : 6 fila(s)
   Andinocara -> Andinoacara : 4 fila(s)
   Limatulichtys -> Limatulichthys : 2 fila(s)
   Lesbiasina -> Lebiasina : 2 fila(s)
   Mylosomma -> Mylossoma : 2 fila(s)
   Hipostomus -> Hypostomus : 1 fila(s)
   Hypomostus -> Hypostomus : 1 fila(s)
   Chaestostoma -> Chaetostoma : 1 fila(s)
   Cichlosoma -> Cichlasoma : 1 fila(s)
   Cenicichla -> Crenicichla : 1 fila(s)
   Hypetecara -> Hypselecara : 1 fila(s)
   Hemmigrammus -> Hemigrammus : 1 fila(s)
   Moekhausia -> Moenkhausia : 1 fila(s)
   Creagutus -> Creagrutus : 1 fila(s)
   Brachycalcinus -> Brachychalcinus : 1 fila(s)
   Phyrulina -> Pyrrhulina : 1 fila(s)
   Shyrna -> Sphyrna : 1 fila(s)
   Hyphopthalmus -> Hypophthalmus : 1 fila(s)
   Paradon -> Parodon : 6 fila(s)
   Amphyocharax -> Aphyocharax : 1 fila(s)
   Carcharthinus -> Carcharhinus : 2 fila(s)

> cat("grafía de género corregida:", n_gg, "fila(s)\n")
grafía de género corregida: 49 fila(s)

> # ---- 4a-bis. INFERENCIA POR MAYORIA INTERNA, no correccion verificada.
> # Saxatilia (5 filas) y Saxatalia (1) conviven con la misma familia y el  .... [TRUNCATED] 

> if (length(idx)) {
+   df$genus[idx] <- ifelse(df$genus[idx] == "Saxatalia", "Saxatilia", df$genus[idx])
+   df$scientificName[idx] <- sub("^Saxatal ..." ... [TRUNCATED] 
Saxatalia -> Saxatilia (inferencia por mayoria interna): 1 fila(s)

> # ---- 4b. Derivar genus y specificEpithet desde scientificName ----
> # 829 filas traen un binomio completo en scientificName pero tienen genus
> # .... [TRUNCATED] 

> idx_g <- which((is.na(df$genus) | df$genus == "") & lengths(bin) == 3)

> for (i in idx_g) { df$genus[i] <- bin[[i]][2]; anotar(i, "genus_derivado_de_scientificName") }

> cat("genus derivado del binomio:", length(idx_g), "fila(s)\n")
genus derivado del binomio: 819 fila(s)

> idx_e <- which((is.na(df$specificEpithet) | df$specificEpithet == "") & lengths(bin) == 3)

> for (i in idx_e) { df$specificEpithet[i] <- bin[[i]][3]; anotar(i, "specificEpithet_derivado_de_scientificName") }

> cat("specificEpithet derivado del binomio:", length(idx_e), "fila(s)\n")
specificEpithet derivado del binomio: 830 fila(s)

> # ---- 4b2. Derivar genus cuando el nombre es de rango genérico ----
> # Misma descomposición mecánica que el binomio: si el scientificName es un
>  .... [TRUNCATED] 

> idx <- which((is.na(df$genus) | df$genus == "") & solo_genero)

> for (i in idx) {
+   df$genus[i] <- sub("^\\s*([A-Z][a-z]+).*$", "\\1", df$scientificName[i])
+   anotar(i, "genus_derivado_de_nombre_generico")
+ }

> cat("genus derivado de nombre de rango genérico:", length(idx), "fila(s)\n")
genus derivado de nombre de rango genérico: 25 fila(s)

> # ---- 4b3. Genero en nombres con cualificador de incertidumbre ----
> # Colocar inmediatamente despues del bloque 4b2, antes de la derivacion de cl .... [TRUNCATED] 

> idx <- which(cualificado & (is.na(df$genus) | df$genus == "") &
+              grepl("^[A-Z][a-z]+\\b", df$scientificName))

> for (i in idx) {
+   df$genus[i] <- sub("^\\s*([A-Z][a-z]+).*$", "\\1", df$scientificName[i])
+   anotar(i, "genus_derivado_de_nombre_con_cualificad ..." ... [TRUNCATED] 

> cat("genus derivado de nombre con cualificador:", length(idx), "fila(s)\n")
genus derivado de nombre con cualificador: 5 fila(s)

> # Coherencia: el genus declarado debe ser el primer término del binomio
> incoh <- which(lengths(bin) == 3 & df$genus != "" &
+                df$ge .... [TRUNCATED] 

> df$flag_genus_no_coincide_con_nombre <- FALSE

> if (length(incoh)) {
+   df$flag_genus_no_coincide_con_nombre[incoh] <- TRUE
+   cat("ATENCIÓN — genus no coincide con el binomio:", length(incoh),  .... [TRUNCATED] 
ATENCIÓN — genus no coincide con el binomio: 7 fila(s)
# A tibble: 5 × 2
  scientificName              genus          
  <chr>                       <chr>          
1 Pimelodella lateristriga    Pimelodus      
2 Hoplerythrinus unitaeniatus Erythrinus     
3 Astyanax villwocki          Tetragonopterus
4 Anablepsoides urophthalmus  Rivulus        
5 Curimata vittata            Steindachnerina

> # PARCHE D: la coherencia nombre/genus solo se evaluaba sobre binomios,
> # porque bin captura tres grupos. Cinco filas con nombre de rango generico .... [TRUNCATED] 

> incoh_uni <- which(lengths(uni) == 2 & df$genus != "" &
+                    !grepl("(idae|inae)\\s*$", df$scientificName) &
+                    df .... [TRUNCATED] 

> if (length(incoh_uni)) {
+   df$flag_genus_no_coincide_con_nombre[incoh_uni] <- TRUE
+   cat("ATENCIÓN — genus no coincide con el nombre uninominal: ..." ... [TRUNCATED] 
ATENCIÓN — genus no coincide con el nombre uninominal: 5 fila(s)
# A tibble: 5 × 3
  catalogNumber scientificName genus         
  <chr>         <chr>          <chr>         
1 1801          Anablepsoides  Rivulus       
2 1808          Knodus         Bryconamericus
3 1823          Jupiaba        Astyanax      
4 1843          Astyanax       Hemigrammus   
5 2004          Anablepsoides  Rivulus       

> incoh_ep <- which(lengths(bin) == 3 & df$specificEpithet != "" &
+                   df$specificEpithet != vapply(bin, function(x) if (length(x)==3) .... [TRUNCATED] 

> df$flag_epiteto_no_coincide_con_nombre <- FALSE

> df$flag_epiteto_no_coincide_con_nombre[incoh_ep] <- TRUE

> # ---- 4d. PARCHE: el cualificador vive en identificationQualifier, no en el nombre.
> # 1.234 filas ponen el cualificador solo en su columna; 5 lo  .... [TRUNCATED] 

> if (length(idx)) {
+   df$scientificName[idx] <- trimws(sub("\\s*\\bsp\\.?\\s*[0-9]*\\s*$", "", df$scientificName[idx]))
+   for (i in idx) anotar(i .... [TRUNCATED] 
cualificador retirado de scientificName: 5 fila(s)

> # Espacio tras el cualificador abreviado. El propio identificationQualifier del
> # cat. 5146 ya escribe "cf. batesii" con espacio; el nombre dice " ..." ... [TRUNCATED] 

> if (length(idx)) {
+   df$scientificName[idx] <- sub("\\b(cf|aff|gr)\\.(\\S)", "\\1. \\2", df$scientificName[idx])
+   for (i in idx) anotar(i, "esp ..." ... [TRUNCATED] 
espacio insertado tras el cualificador: 1 fila(s)

> # ---- 4c. Correcciones ortográficas específicas ----
> idx_cren <- which(df$scientificName == "Crenicichlla sedentaria")

> if (length(idx_cren)) {
+   df$scientificName[idx_cren] <- "Crenicichla sedentaria"
+   df$genus[idx_cren] <- "Crenicichla"
+   for (i in idx_cren)  .... [TRUNCATED] 

> # El mapa grafia_familia solo actúa sobre el campo family; cuando la
> # familia mal escrita está además en scientificName hay que corregirla ahí.
> .... [TRUNCATED] 

> if (length(idx_asp)) {
+   df$scientificName[idx_asp] <- "Aspredinidae"
+   for (i in idx_asp) anotar(i, "scientificName_grafia_familia_corregida")
 .... [TRUNCATED] 

> # Hyphopthalmidae no existe con ninguna grafía. Se vacía para que el
> # bloque 5b derive la familia del género, igual que con la cadena de autoría. .... [TRUNCATED] 

> if (length(idx_hyp)) {
+   df$family[idx_hyp] <- ""
+   for (i in idx_hyp) anotar(i, "family_inexistente_vaciada")
+ }

> # ---- 5. Completar class y order desde el backbone ----
> # Derivación desde una fuente autoritativa a partir del género. No es
> # imputación: el  .... [TRUNCATED] 

> n_cl <- 0

> for (i in falta) {
+   fb <- backbone %>% filter(Genus == df$genus[i]); if (nrow(fb) != 1) next
+   cl <- clase_dwc(fb$Class[1]); if (is.na(cl)) nex .... [TRUNCATED] 

> cat("class completada:", n_cl, "| sin resolver:", length(falta) - n_cl, "\n")
class completada: 6295 | sin resolver: 64 

> # Segundo intento: si el genero no esta en el backbone, la clase se sigue
> # de la familia. Es la misma derivacion, un nivel mas arriba.
> fam_cls  .... [TRUNCATED] 

> falta2 <- which((is.na(df$class) | df$class == "") & df$family != "")

> for (i in falta2) {
+   fb <- fam_cls %>% filter(Family == df$family[i]); if (nrow(fb) != 1) next
+   cl <- clase_dwc(fb$Class[1]); if (is.na(cl)) n .... [TRUNCATED] 

> # ---- 5b. Cerrar huecos de coherencia interna ----
> # Si la clase está resuelta, el reino y el filo se siguen necesariamente.
> idx <- which(df$cl .... [TRUNCATED] 

> if (length(idx)) {
+   df$kingdom[idx] <- "Animalia"; df$phylum[idx] <- "Chordata"
+   for (i in idx) anotar(i, "kingdom_phylum_derivados_de_class") .... [TRUNCATED] 
kingdom/phylum completados: 62 fila(s)

> # La familia estaba disponible en el backbone al derivar la clase.
> # PARCHE A2: cuando el género ya tiene familia en el archivo, se usa ESA y no
> .... [TRUNCATED] 

> idx <- which((is.na(df$family) | df$family == "") & !is.na(df$genus) & df$genus != "")

> n_f <- 0; n_fb <- 0

> for (i in idx) {
+   fa <- fam_en_archivo$family_en_archivo[fam_en_archivo$genus == df$genus[i]]
+   if (length(fa) == 1) {
+     df$family[i] <- fa .... [TRUNCATED] 

> cat("family completada desde el archivo:", n_f, "| desde el backbone:", n_fb, "fila(s)\n")
family completada desde el archivo: 27 | desde el backbone: 0 fila(s)

> # FishBase devuelve clados informales con barra ("Perciformes/Serranoidei",
> # "Eupercaria/misc"). El término anterior a la barra sí es un orden vá .... [TRUNCATED] 

> idx <- which(grepl("/", df$order))

> if (length(idx)) {
+   df$order_fishbase_informal[idx] <- df$order[idx]
+   raiz <- sub("/.*$", "", df$order[idx])
+   valido <- grepl("^[A-Z][a-z]+ ..." ... [TRUNCATED] 
ordenes informales normalizados: 2 | revertidos al verbatim: 0 

> # ---- 5c. Un género no puede tener dos órdenes en el mismo archivo ----
> # La corrección de homónimos escribió el orden del backbone solo en las
> .... [TRUNCATED] 

> for (g in gen_multi) {
+   fb <- backbone %>% filter(Genus == g); if (nrow(fb) != 1) next
+   idx <- which(df$genus == g & df$order != fb$Order[1])
 .... [TRUNCATED] 
   Ilisha : unificado a Clupeiformes ( 1 fila(s), antes Perciformes )
   Sicydium : unificado a Gobiiformes ( 7 fila(s), antes Perciformes )

> # ---- 5c-bis (v2). Autoridad única para order ----
> # Mezclar la clasificación del origen (Perciformes para todo) con la de
> # FishBase solo en l .... [TRUNCATED] 

> n_ord <- 0

> for (i in idx) {
+   fb <- backbone %>% filter(Genus == df$genus[i]); if (nrow(fb) != 1) next
+   if (!is.na(df$order[i]) && df$order[i] == fb$Order .... [TRUNCATED] 

> cat("order alineado al backbone:", n_ord, "fila(s)\n")
order alineado al backbone: 869 fila(s)

> # Repetir la normalizacion de clados informales DESPUES de asignar el orden
> # desde el backbone. FishBase devuelve "Eupercaria/misc" o
> # "Percif ..." ... [TRUNCATED] 

> if (length(idx)) {
+   df$order_fishbase_informal[idx] <- df$order[idx]
+   raiz <- sub("/.*$", "", df$order[idx])
+   valido <- grepl("^[A-Z][a-z]+ ..." ... [TRUNCATED] 
ordenes informales normalizados: 128 | revertidos al verbatim: 112 

> # ---- 5c-ter. Respaldo familia -> orden para generos fuera del backbone ----
> # Mismo patron que el bloque 5 usa para class, un nivel mas arriba y .... [TRUNCATED] 

> gen_fam_unico <- df %>% filter(genus != "", family != "") %>%
+   distinct(genus, family) %>% count(genus) %>% filter(n == 1) %>% pull(genus)

> idx <- which(df$genus %in% gen_fam_unico & !(df$genus %in% backbone$Genus) & df$family != "")

> n_o <- 0

> for (i in idx) {
+   fb <- fam_ord %>% filter(Family == df$family[i]); if (nrow(fb) != 1) next
+   ord <- sub("/.*$", "", fb$Order[1])
+   if (!grep .... [TRUNCATED] 

> cat("order derivado de la familia (genero fuera del backbone):", n_o, "fila(s)\n")
order derivado de la familia (genero fuera del backbone): 7 fila(s)

> # ---- 5c-quater. Orden para las determinaciones a nivel de familia ----
> # Ultimo hueco de la cadena: 5c-bis exige que el genero resuelva en el ba .... [TRUNCATED] 

> idx <- which(df$family != "" & (is.na(df$order) | df$order == "") &
+              (is.na(df$genus)  | df$genus  == ""))

> n_q <- 0

> for (i in idx) {
+   fa <- fam_ord_archivo$order[fam_ord_archivo$family == df$family[i]]
+   if (length(fa) == 1) {
+     df$order[i] <- fa; n_q <-  .... [TRUNCATED] 

> cat("order derivado para determinaciones a nivel de familia:", n_q, "fila(s)\n")
order derivado para determinaciones a nivel de familia: 3 fila(s)

> # ---- 5d. taxonRank derivado de la forma del nombre ----
> # El orden importa: es_genero también captura los nombres terminados en
> # idae/inae, a .... [TRUNCATED] 

> sn <- trimws(df$scientificName)

> es_familia <- grepl("^[A-Z][a-z]+(idae|inae)$", sn)

> es_binomio <- grepl("^[A-Z][a-z]+ [a-z][a-z-]+$", sn)

> es_genero  <- grepl("^[A-Z][a-z]+( sp\\.?[0-9]*)?$", sn) & !es_familia

> df$taxonRank[vacio & es_binomio] <- "species"

> df$taxonRank[vacio & es_genero]  <- "genus"

> df$taxonRank[vacio & es_familia] <- "family"

> for (i in which(vacio & (es_binomio | es_familia | es_genero)))
+   anotar(i, "taxonRank_derivado_de_scientificName")

> cat("taxonRank derivado:", sum(vacio & (es_binomio | es_familia | es_genero)),
+     "| sin resolver:", sum(is.na(df$taxonRank) | df$taxonRank == "" .... [TRUNCATED] 
taxonRank derivado: 847 | sin resolver: 12 

> # PARCHE B2: 5d solo rellena rangos vacíos. Once filas traían taxonRank
> # "genus" desde el origen sobre un binomio completo (531, 1970, 2474, 2497 .... [TRUNCATED] 

> if (length(incoh_rank)) {
+   cat("taxonRank='genus' sobre un binomio, corregido a 'species':",
+       length(incoh_rank), "fila(s):", paste(df$cat .... [TRUNCATED] 
taxonRank='genus' sobre un binomio, corregido a 'species': 11 fila(s): 531, 1970, 2474, 2497, 2559, 2561, 2572, 2576, 2598, 2609, 2834 

> # PARCHE B6: un nombre terminado en -inae es una subfamilia, no una familia.
> # "subfamily" es término válido del vocabulario de rangos. Afecta a c .... [TRUNCATED] 

> idx <- which(es_subfamilia & df$taxonRank %in% c("family", ""))

> if (length(idx)) {
+   df$taxonRank[idx] <- "subfamily"
+   for (i in idx) anotar(i, "taxonRank_subfamilia")
+   cat("taxonRank=subfamily:", length( .... [TRUNCATED] 
taxonRank=subfamily: 1 fila(s)

> # ---- 6. Regenerar higherClassification ----
> # El campo original tiene profundidad variable y en las filas de Plantae
> # conserva la jerarquía v .... [TRUNCATED] 

> df$higherClassification[df$higherClassification == "Organism"] <- ""

> idx_hc <- which((is.na(df$higherClassification_verbatim) & df$higherClassification != "") |
+                 (!is.na(df$higherClassification_verbat .... [TRUNCATED] 

> if (length(idx_hc)) {
+   for (i in idx_hc) anotar(i, "higherClassification_regenerado")
+ }

> # ---- 7. Marcar registros sin metadatos (no se eliminan) ----
> df$registro_incompleto <- with(df,
+   (is.na(recordedBy)|recordedBy=="") & (is.na( .... [TRUNCATED] 

> cat("registros incompletos marcados:", sum(df$registro_incompleto), "\n")
registros incompletos marcados: 4 

> # ---- 7b. PARCHE B4: filas sin ningún dato taxonómico ----
> # Catálogos 1309, 1343, 1455, 1733, 1743, 3794 y 4322 no traen nombre ni
> # jerarquía .... [TRUNCATED] 

> cat("filas sin ningún dato taxonómico:", sum(df$flag_sin_taxonomia), "\n")
filas sin ningún dato taxonómico: 7 

> # ---- 8. Marcar scientificName que contiene un nombre de familia ----
> df$flag_nombre_es_familia <- grepl("^\\s*\\w+(idae|inae)\\s*$", df$scientif .... [TRUNCATED] 

> cat("scientificName con nombre de familia:", sum(df$flag_nombre_es_familia), "\n")
scientificName con nombre de familia: 24 

> # ---- 8b. Familia minoritaria dentro del género ----
> # Se separan dos situaciones que no son lo mismo:
> #  - familia minoritaria del mismo orden .... [TRUNCATED] 

> # El desempate no puede ser arbitrario: cuando dos familias tienen el mismo
> # número de filas, slice_max elige una al azar y la bandera puede acab .... [TRUNCATED] 

> fam_may <- fam_cuenta %>%
+   group_by(genus) %>%
+   mutate(n_max = max(n_filas), empate = sum(n_filas == n_max) > 1) %>%
+   filter(n_filas == n_m .... [TRUNCATED] 

> n_emp <- fam_cuenta %>% group_by(genus) %>%
+   summarise(empate = sum(n_filas == max(n_filas)) > 1, .groups = "drop") %>%
+   filter(empate) %>% pu .... [TRUNCATED] 

> if (length(n_emp))
+   cat("géneros con empate en la familia mayoritaria (desempatados por backbone):",
+       paste(n_emp, collapse = ", "), "\n")
géneros con empate en la familia mayoritaria (desempatados por backbone): Ilisha, Opisthonema, Urotrygon 

> ord_fam <- sub %>% filter(order != "") %>% count(family, order) %>%
+   group_by(family) %>% slice_max(n, n = 1, with_ties = FALSE) %>% ungroup() %> .... [TRUNCATED] 

> df <- df %>%
+   left_join(fam_may, by = "genus") %>%
+   left_join(ord_fam, by = "family") %>%
+   left_join(ord_fam %>% rename(family_mayoritaria  .... [TRUNCATED] 

> df$flag_family_minoritaria <- with(df,
+   genus != "" & family != "" & !is.na(family_mayoritaria) &
+   family != family_mayoritaria)

> df$flag_family_orden_discrepante <- with(df,
+   flag_family_minoritaria & !is.na(orden_de_la_familia) &
+   !is.na(orden_mayoritario) & orden_de_la .... [TRUNCATED] 

> cat("familia minoritaria en el género:", sum(df$flag_family_minoritaria), "fila(s)\n")
familia minoritaria en el género: 93 fila(s)

> cat("  de ellas, de otro orden (error probable):",
+     sum(df$flag_family_orden_discrepante), "fila(s)\n")
  de ellas, de otro orden (error probable): 6 fila(s)

> if (any(df$flag_family_orden_discrepante))
+   print(df[df$flag_family_orden_discrepante,
+            c("catalogNumber","scientificName","genus","f ..." ... [TRUNCATED] 
# A tibble: 6 × 5
  catalogNumber scientificName                  genus              family         family_mayoritaria
  <chr>         <chr>                           <chr>              <chr>          <chr>             
1 5322          Ilisha                          Ilisha             Cichlidae      Pristigasteridae  
2 777           Sternarchorhynchus curvirostris Sternarchorhynchus Astroblepidae  Apteronotidae     
3 1157          Peckoltia                       Peckoltia          Hypopomidae    Loricariidae      
4 3582          Sternopygus macrurus            Sternopygus        Callichthyidae Sternopygidae     
5 3650          Sternopygus macrurus            Sternopygus        Callichthyidae Sternopygidae     
6 4337          Anisotremus                     Anisotremus        Rivulidae      Haemulidae        

> df <- df %>% select(-orden_de_la_familia, -orden_mayoritario, -family_mayoritaria)

> # ---- 8c. PARCHE B3: familia con más de un orden ----
> # flag_family_minoritaria se calcula DENTRO del género, así que un género que
> # aparece u .... [TRUNCATED] 

> df <- df %>% left_join(ord_may_fam, by = "family")

> df$flag_orden_minoritario_en_familia <- !is.na(df$family) & df$family != "" &
+   !is.na(df$order) & df$order != "" & !is.na(df$orden_mayoritario_fa .... [TRUNCATED] 

> df <- df %>% select(-orden_mayoritario_familia)

> cat("filas con orden minoritario dentro de su familia:",
+     sum(df$flag_orden_minoritario_en_familia), "fila(s)\n")
filas con orden minoritario dentro de su familia: 9 fila(s)

> if (any(df$flag_orden_minoritario_en_familia))
+   print(df[df$flag_orden_minoritario_en_familia,
+            c("catalogNumber","scientificName","g ..." ... [TRUNCATED] 
# A tibble: 9 × 5
  catalogNumber scientificName                  genus              family         order          
  <chr>         <chr>                           <chr>              <chr>          <chr>          
1 5322          Ilisha                          Ilisha             Cichlidae      Clupeiformes   
2 777           Sternarchorhynchus curvirostris Sternarchorhynchus Astroblepidae  Gymnotiformes  
3 1157          Peckoltia                       Peckoltia          Hypopomidae    Siluriformes   
4 3582          Sternopygus macrurus            Sternopygus        Callichthyidae Gymnotiformes  
5 3650          Sternopygus macrurus            Sternopygus        Callichthyidae Gymnotiformes  
6 4185          Paranthias colonus              Paranthias         Serrasalmidae  Perciformes    
7 4186          Serranus psittacinus            Serranus           Serrasalmidae  Perciformes    
8 4201          Holacanthus passer              Holacanthus        Pomacentridae  Acanthuriformes
9 4337          Anisotremus                     Anisotremus        Rivulidae      Perciformes    

> # Renombrado: estas filas no son un error, son identificaciones a nivel
> # de familia. La etiqueta anterior sugería anomalía donde no la hay.
> df$ .... [TRUNCATED] 

> df$flag_nombre_es_familia <- NULL

> # ---- 9. PARCHE B1: géneros sin correspondencia en el backbone ----
> # La rama "class_derivada_de_family" es un respaldo correcto, pero absorbe en .... [TRUNCATED] 

> if (nrow(gen_no_resuelto)) {
+   write_csv(gen_no_resuelto,
+             "reportes_y_revisiones/generos_no_resueltos_backbone.csv", na = "")
+   ca .... [TRUNCATED] 
                                                                                                                   
géneros sin correspondencia en el backbone: 15 
# A tibble: 15 × 3
   genus             family          filas
   <chr>             <chr>           <int>
 1 Lipopterichthys   Loricariidae       16
 2 Cochliodon        Loricariidae       13
 3 Piabucina         Lebiasinidae       11
 4 Peckoltichthys    Loricariidae        6
 5 Saxatilia         Cichlidae           6
 6 Pseudocetopsis    Cetopsidae          2
 7 Sciadeops         Ariidae             2
 8 Cynoponthicus     Muraenesocidae      1
 9 Durlanis          Auchenipteridae     1
10 Jurengranulis     Engraulidae         1
11 Orthropristis     Haemulidae          1
12 Parauchenipterus  Auchenipteridae     1
13 Rhandinoloricaria Loricariidae        1
14 Sorubumichthys    Pimelodidae         1
15 Sternachella      Apteronotidae       1

> # ---- 8d. Segunda opinion sobre family: el backbone, no la mayoria del genero ----
> # NO corrige: L3 sigue vigente, solo se derivan las familias v .... [TRUNCATED] 

> df$flag_family_discrepa_backbone <- !is.na(df$family_backbone) &
+   df$family != "" & df$family != df$family_backbone

> cat("family distinta a la del backbone para el mismo genero:",
+     sum(df$flag_family_discrepa_backbone), "fila(s) |",
+     "de ellas nuevas (sin ..." ... [TRUNCATED] 
family distinta a la del backbone para el mismo genero: 1729 fila(s) | de ellas nuevas (sin flag_family_minoritaria): 1658 

> print(df %>% filter(flag_family_discrepa_backbone & !flag_family_minoritaria) %>%
+         count(genus, family, family_backbone, name = "filas") %> .... [TRUNCATED] 
# A tibble: 49 × 4
   genus           family          family_backbone   filas
   <chr>           <chr>           <chr>             <int>
 1 Moenkhausia     Characidae      Acestrorhamphidae   290
 2 Astyanax        Characidae      Acestrorhamphidae   251
 3 Creagrutus      Characidae      Stevardiidae        206
 4 Bryconamericus  Characidae      Stevardiidae        198
 5 Hemigrammus     Characidae      Acestrorhamphidae   107
 6 Knodus          Characidae      Stevardiidae         95
 7 Hyphessobrycon  Characidae      Acestrorhamphidae    87
 8 Rhoadsia        Characidae      Acestrorhamphidae    84
 9 Chrysobrycon    Characidae      Stevardiidae         54
10 Brachychalcinus Characidae      Acestrorhamphidae    53
11 Pseudochalceus  Characidae      Acestrorhamphidae    33
12 Gymnocorymbus   Characidae      Acestrorhamphidae    27
13 Hemibrycon      Characidae      Stevardiidae         21
14 Ceratobranchia  Characidae      Stevardiidae         20
15 Ctenobrycon     Characidae      Acestrorhamphidae    20
16 Triportheus     Characidae      Triportheidae        17
17 Bario           Characidae      Acestrorhamphidae    12
18 Tyttocharax     Characidae      Stevardiidae         10
19 Chilodus        Chilodontidae   Chilodidae            9
20 Eretmobrycon    Characidae      Stevardiidae          8
21 Jupiaba         Characidae      Acestrorhamphidae     6
22 Caenotropus     Chilodontidae   Chilodidae            5
23 Epinephelus     Serranidae      Epinephelidae         4
24 Cyclopsetta     Paralichthyidae Cyclopsettidae        3
25 Hypopygus       Hypopomidae     Rhamphichthyidae      3
26 Poptella        Characidae      Acestrorhamphidae     3
27 Steatogenys     Hypopomidae     Rhamphichthyidae      3
28 Chalceus        Characidae      Chalceidae            2
29 Colossoma       Characidae      Serrasalmidae         2
30 Crenuchus       Characidae      Crenuchidae           2
31 Iotabrycon      Characidae      Stevardiidae          2
32 Rypticus        Serranidae      Grammistidae          2
33 Syacium         Paralichthyidae Cyclopsettidae        2
34 Urobatis        Urolophidae     Urotrygonidae         2
35 Alphestes       Serranidae      Epinephelidae         1
36 Astyanacinus    Characidae      Acestrorhamphidae     1
37 Boehlkea        Characidae      Stevardiidae          1
38 Caulolatilus    Malacanthidae   Latilidae             1
39 Citharichthys   Paralichthyidae Cyclopsettidae        1
40 Gephyrocharax   Characidae      Stevardiidae          1
41 Grundulus       Characidae      Acestrorhamphidae     1
42 Gymnothorax     Ophichthidae    Muraenidae            1
43 Holacanthus     Pomacentridae   Pomacanthidae         1
44 Membras         Atherinidae     Atherinopsidae        1
45 Othonocheirodus Characidae      Stevardiidae          1
46 Paranthias      Serrasalmidae   Epinephelidae         1
47 Phenacobrycon   Characidae      Stevardiidae          1
48 Serranus        Serrasalmidae   Serranidae            1
49 Thayeria        Characidae      Acestrorhamphidae     1

> df <- df %>% select(-family_backbone)

> # ---- 8. Cierre Darwin Core ----
> # Tres campos que el estandar espera y el portal no entrega. Ninguno es
> # imputacion: los tres se derivan de u .... [TRUNCATED] 

> df$dynamicProperties[idx] <- '{"establishmentMeansVerbatim":"nativeEndemic","endemismo":"endemico"}'

> df$establishmentMeans[idx] <- "native"

> cat("establishmentMeans nativeEndemic reasignados a native:", length(idx), "\n")
establishmentMeans nativeEndemic reasignados a native: 148 

> # 8b (corregido). El continente se sigue del pais o de la coordenada, que es
> # dato del origen. En las 4 filas que no declaran ninguno de los dos  .... [TRUNCATED] 

> df$continent <- ifelse(tiene_anclaje, "South America", "")

> cat("continent escrito:", sum(tiene_anclaje),
+     "| omitido por falta de anclaje geografico:", sum(!tiene_anclaje), "\n")
continent escrito: 6423 | omitido por falta de anclaje geografico: 4 

> # 8c. Todo el archivo son especimenes preservados en coleccion: la
> # presencia es un hecho, no una inferencia. GBIF la infiere desde
> # individua .... [TRUNCATED] 

> write_csv(df, ARCHIVO_SALIDA, na = "")
                                                                                                                   
> cat("\nGuardado en", ARCHIVO_SALIDA, "— el archivo de entrada no se modificó.\n")

Guardado en datos/02_intermedios/ocurrences_salida_taxonomia.csv — el archivo de entrada no se modificó.

> cat("\n=== CORRECCIONES APLICADAS ===\n")

=== CORRECCIONES APLICADAS ===

> print(table(df$metodo_correccion_taxon[df$metodo_correccion_taxon != ""]))

                                                                                                                                                                                                                                                                     class_derivada_de_family|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           51 
                                                                                                                                                            class_derivada_de_family|kingdom_phylum_derivados_de_class|order_derivado_de_family_backbone|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                                                                                                      class_derivada_de_genus|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                         4657 
                                                                                                                                                                                                                                 class_derivada_de_genus|order_desde_backbone_autoridad_unica|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                          708 
                                                                                                                                                                                          class_derivada_de_genus|order_desde_backbone_autoridad_unica|order_informal_reducido_a_orden_valido|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           95 
                                                                                                                                                                                                                            class_derivada_de_genus|order_unificado_por_genero_desde_backbone|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            5 
                                               family_formato_invalido_vaciada|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|kingdom_phylum_derivados_de_class|family_derivada_de_genus_en_archivo|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                                                                              family_grafia_corregida|class_derivada_de_genus|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            3 
                                                                                                                                                                  family_grafia_corregida|class_derivada_de_genus|order_desde_backbone_autoridad_unica|order_informal_reducido_a_orden_valido|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                     family_grafia_corregida|genus_derivado_de_nombre_generico|class_derivada_de_genus|kingdom_phylum_derivados_de_class|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                          family_grafia_corregida|scientificName_grafia_familia_corregida|class_derivada_de_family|kingdom_phylum_derivados_de_class|order_derivado_de_family_en_archivo|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                   family_rango_incorrecto_corregido|class_derivada_de_family|kingdom_phylum_derivados_de_class|order_derivado_de_family_en_archivo|taxonRank_derivado_de_scientificName|taxonRank_subfamilia|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                                                                    family_rango_incorrecto_corregido|class_derivada_de_genus|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            9 
                                                                                                                                                                                                                            genus_derivado_de_nombre_con_cualificador|class_derivada_de_genus|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            4 
                                                                                                                                                                                                  genus_derivado_de_nombre_con_cualificador|espacio_tras_cualificador|class_derivada_de_genus|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                              genus_derivado_de_nombre_generico|class_derivada_de_family|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            3 
                                                                                                                         genus_derivado_de_nombre_generico|class_derivada_de_genus|kingdom_phylum_derivados_de_class|family_derivada_de_genus_en_archivo|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                             genus_derivado_de_nombre_generico|class_derivada_de_genus|kingdom_phylum_derivados_de_class|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                   genus_derivado_de_nombre_generico|class_derivada_de_genus|order_desde_backbone_autoridad_unica|order_informal_reducido_a_orden_valido|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                     genus_derivado_de_nombre_generico|class_derivada_de_genus|order_unificado_por_genero_desde_backbone|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                               genus_derivado_de_nombre_generico|class_derivada_de_genus|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           10 
                                                                                                                                                              genus_derivado_de_nombre_generico|cualificador_retirado_del_nombre|class_derivada_de_genus|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            5 
                                                               genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_family|kingdom_phylum_derivados_de_class|order_derivado_de_family_genero_fuera_del_backbone|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                 genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_family|order_derivado_de_family_genero_fuera_del_backbone|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            5 
                                                                                                                                                    genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_family|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           24 
                                                                               genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|kingdom_phylum_derivados_de_class|family_derivada_de_genus_en_archivo|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           24 
genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|kingdom_phylum_derivados_de_class|order_informal_reducido_a_orden_valido|order_desde_backbone_autoridad_unica|order_informal_reducido_a_orden_valido|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            2 
                                                                                                                   genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|kingdom_phylum_derivados_de_class|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           26 
                                                                         genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|order_desde_backbone_autoridad_unica|order_informal_reducido_a_orden_valido|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           29 
                                                                                                                genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|order_desde_backbone_autoridad_unica|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           23 
                                                                                                           genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|order_unificado_por_genero_desde_backbone|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            2 
                                                                                                                                                     genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                          622 
                                                                                                                                                                             genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            9 
                                                                                                                                   genus_grafia_corregida|genus_derivado_de_nombre_generico|class_derivada_de_genus|order_desde_backbone_autoridad_unica|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                        genus_grafia_corregida|genus_derivado_de_nombre_generico|class_derivada_de_genus|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                            genus_grafia_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|kingdom_phylum_derivados_de_class|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                         genus_grafia_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|order_desde_backbone_autoridad_unica|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            6 
                                                                                                                              genus_grafia_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           37 
                             genus_grafia_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|family_inexistente_vaciada|class_derivada_de_genus|kingdom_phylum_derivados_de_class|family_derivada_de_genus_en_archivo|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                      genus_grafia_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            2 
                                                      genus_grafia_unificada_por_mayoria_interna|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_family|order_derivado_de_family_genero_fuera_del_backbone|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                                                                                                                              higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           16 
                                                                                                                                                                                                                                                        jerarquia_superior_corregida_homonimo|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           10 
                                                                                                                                                                                                                              scientificName_capitalizacion_corregida|class_derivada_de_genus|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            2 
                                                                        scientificName_capitalizacion_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|class_derivada_de_genus|order_desde_backbone_autoridad_unica|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            2 
                            scientificName_capitalizacion_corregida|genus_derivado_de_scientificName|specificEpithet_derivado_de_scientificName|scientificName_grafia_corregida_manualmente|class_derivada_de_genus|order_desde_backbone_autoridad_unica|taxonRank_derivado_de_scientificName|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                            1 
                                                                                                                                                                                  specificEpithet_derivado_de_scientificName|class_derivada_de_genus|taxonRank_corregido_por_forma_del_nombre|higherClassification_regenerado 
                                                                                                                                                                                                                                                                                                                           11 
>

he aplicado tus cambios openrefine, coordenadas y taxonomicos, que opinas todos estan en ocurrences_con_identifications.csv quiero que leas el codigo que hace esa union y la validez con el identifications original la idea es solo tener una tabla y para terminar que opinas de mi reporte de plausibilidad

---

# claude response

Los tres parches quedaron aplicados y verificados. Una nota antes de entrar: el `ocurrences_salida_taxonomia.csv` que subiste es el de las 02:35, o sea el **anterior** a los parches taxonómicos. El `ocurrences_con_identifications.csv` sí viene del bueno (0 `Paradon`, 0 `Saxatalia`, `order` vacío en 7, `continent` vacío en 4). No es problema: me sirvió como control para medir exactamente qué añadió la unión.

# 1. Los parches, contra el CSV

| | Esperado | Real |
|---|---|---|
| 12b | 28 filas reclasificadas | **32** (28 + 4 que también cambiaron de etiqueta sin cambiar de valor). Filas a 1.900 m: **0** |
| 5c-bis-fix | 112 recuperan orden, `order` vacío 119→7 | **112 revertidos al verbatim**, `order` vacío = **7** |
| `flag_orden_minoritario_en_familia` | 7 → 8 | **9**. Me quedé corto: además del 4201 (Holacanthus) entró el 4337, que antes tenía el orden vacío y por eso tampoco se veía |
| Familias con orden en dos estados | 7, todas casos F1 | 7, y son exactamente los F1 |
| `grafia_genero` | +9 filas | **49** total (40+9). `Paradon`, `Amphyocharax`, `Carcharthinus` fuera |
| Géneros sin resolver | 20 → 15 | **15**. Los 5 que salieron son los cuatro corregidos + `Saxatalia` fusionado en `Saxatilia` |
| 8b corregido | 6.423 / 4 | **6.423 / 4** |
| 4d | 5 + 1 | **5 + 1** |

Y el `cat()` del 12b ya imprime un número.

---

# 2. AUDITORÍA DE `UnirIdentificationsOcurrences.R`

## 2.1 Veredicto

**CORRECTA EN LA ESTRUCTURA, CON UN ERROR DE CRITERIO Y UN BUG CONOCIDO SIN CORREGIR.**

Lo que está impecable:

| Verificación | Resultado |
|---|---|
| Alineación por clave (`match(df$id, id$coreid)`) | 6.427/6.427, `stopifnot` correcto. **No usa posición**, que es lo que salva el intercambio 3766/3767 |
| Partición cerrada | 93 nombres distintos = 23 previas + 70 al oficio. `sin_destino` = 0 |
| Anotación | `metodo_correccion_taxon` cambia en **848 filas = 803 + 21 + 23 + 1**. Cero celdas modificadas sin anotar |
| Salida | 6.427 × 132. Una sola tabla, una sola columna nueva (`previousIdentifications`) |
| Autorías importadas (803) | 0 con NBSP, 0 con `and`, 0 con paréntesis desbalanceados, 0 con `&` pegado a letra. 219 llevan `&`. La normalización `and → &` funcionó sobre las 213 que lo traían |
| `identifiedBy` | 0 importados. Los 7 candidatos son la fecha `2023-04-25` (cat. 1335) y `unknown` en 4276, 4358, 4371–4374. Descarte correcto y documentado |
| Las 23 `previousIdentifications` | todas 2019–2021 contra un core de julio 2023, todas con nombre distinto, ninguna truncada. Legítimas |

## 2.2 El bug que sigue ahí: `nrm()` sin `perl=TRUE`

`identifications.csv` trae **463 espacios duros U+00A0** (30 en `scientificName`, 433 en `scientificNameAuthorship`). La línea 23 es `gsub("\\s+", " ", ...)` sin `perl=TRUE`, y en el motor TRE de R `\s` **no captura el U+00A0**. `trimws` tampoco.

Reproduje el discriminador entero con las dos versiones:

| | Código actual | Con `perl=TRUE` |
|---|---|---|
| Nombres distintos | **93** | **63** |
| `previousIdentifications` | 23 | 23 |
| «misma fecha: mismo acto con dos nombres» | **38** | **9** |
| Sin fecha comparable | 31 | 30 |
| Truncamiento / posterior / `undefined` | 1 / 0 / 18 | 1 / 0 / 18 |
| **Al oficio de INABIO** | **88** | **58** |

**Treinta de los 93 «nombres distintos» son el mismo nombre con un carácter invisible en medio**, y 29 caen justo en el cubo que Yáñez tiene que revisar a mano.

Y hay un detalle que conviene que veas: el comentario de las líneas 107-108 dice *«contra el verbatim sale 24/9/30 y recibe 57»*. Ese 9 es el número **corregido**. El comentario describe el comportamiento que el código no implementa. Si Guevara compara la bitácora con la salida, ahí hay una inconsistencia que te va a preguntar.

```r
# nrm() tiene que ver el espacio duro. identifications.csv trae 463 U+00A0
# (30 en scientificName, 433 en scientificNameAuthorship) y \s en TRE no los
# captura. Sin esto, 30 nombres identicos cuentan como distintos y 29 de ellos
# van al oficio como "mismo acto con dos nombres" siendo el mismo nombre.
nrm <- function(x) {
  x <- gsub("\u00a0", " ", nz(x), fixed = TRUE)
  trimws(gsub("\\s+", " ", x, perl = TRUE))
}
```

## 2.3 El error de criterio: `identificationQualifier` se importa de otra determinación

Este es el hallazgo de fondo y no lo cubre ningún comentario del script.

El bloque de la línea 66 importa el cualificador «donde el core no tiene nada». Pero `identificationQualifier` **no es un atributo del registro: es un atributo del acto de determinación**, y el acto que describe `identifications` no es el del core. **18 de las 21 filas importadas traen un nombre distinto en `identifications`.** El resultado:

| catalogNumber | Nombre en el core | Nombre en identifications | Cualificador importado |
|---|---|---|---|
| 4057, 4061 | `Anablepsoides rubrolineatus` | `Rivulus` | `sp.` |
| 4013, 4026 | `Pimelodella lateristriga` | `Pimelodella` | `sp.` |
| 4271 | `Creagrutus kunturus` | `Chrysobrycon` | `sp.` |
| 3765 | `Xyliphius melanopterus` | `Microglanis` | `sp.` |
| 4388 | `Knodus gamma` | `Hemigrammus schmardae` | `cf.` |

El `sp.` califica a `Rivulus`, no a `Anablepsoides rubrolineatus`. Escribirlo en el core produce una contradicción explícita: **binomio completo + `taxonRank = species` + `identificationQualifier = sp.`**, que significa «especie indeterminada del género».

Medido: filas con `sp.` sobre `taxonRank = species` **29 antes de la unión → 45 después. La unión creó 16 contradicciones nuevas.**

De las 21, solo una sobrevive a un criterio correcto (mismo nombre **y** cualificador compatible con el rango): el catálogo 4559, `Apistogramma cf. cruzi`. Una celda ganada contra veinte contradicciones creadas.

**Mi decisión: retirar el bloque entero.** Y las 21 filas van al oficio, porque son la mejor prueba de que `identifications` describe otra determinación:

```r
# El cualificador es atributo del ACTO de determinacion, no del registro.
# identifications describe otra determinacion (18 de 21 traen otro nombre), asi
# que su cualificador no aplica al nombre del core: importarlo produce binomio
# completo + taxonRank=species + identificationQualifier="sp.", que se contradice.
# Medido: 29 -> 45 filas con esa contradiccion. El unico aporte legitimo era el
# catalogo 4559 (Apistogramma cf. cruzi). No compensa.
i_qua <- which(vac(df$identificationQualifier) & copiable(id$identificationQualifier))
cat("identificationQualifier NO importados (pertenecen a otra determinacion):",
    length(i_qua), "\n")
motivo[i_qua] <- ifelse(is.na(motivo[i_qua]),
  "identifications trae cualificador de su propia determinacion, incompatible con el nombre del core",
  motivo[i_qua])
# y quitar la linea df$identificationQualifier[i_qua] <- ... y su marcar()
```

Aparte, las **29 preexistentes** (`sp.` sobre binomio que ya venían del origen) son una pregunta nueva para el oficio: ninguna fase las ha tocado.

## 2.4 Tres cosas que la unión dejó fuera sin decirlo

**a) 181 `dateIdentified`.** `identifications` tiene fecha donde el core no. Son **176 `sin datos` + 5 `s.d.`**, o sea placeholders que OpenRefine ya vació. El descarte es correcto pero el script solo justifica `identifiedBy`. Una línea de bitácora, no un cambio.

**b) `tidInterpreted` — y aquí hay evidencia dura para J1.** El script lo ignora en silencio. Difiere de `taxonID` en **49 filas** y el core está vacío en 12. Y mira los catálogos 3766 y 3767:

| catalogNumber | `taxonID` (core) | `tidInterpreted` (identifications) | Nombre core | Nombre identifications |
|---|---|---|---|---|
| 3766 | 35266 | **36078** | Brachyhypopomus | Trichomycterus |
| 3767 | 36078 | **35266** | Trichomycterus | Brachyhypopomus |

**El identificador está intercambiado exactamente igual que el nombre.** Eso prueba que el 3766/3767 es un desalineamiento de filas y no dos redeterminaciones: si fueran redeterminaciones, los `taxonID` no se cruzarían. Tu pregunta 2 de J1 pasa de hipótesis a hecho demostrado, y con una prueba independiente de la comparación de nombres.

**c) `recordID` de `identifications` no coincide con el del core en ninguna fila** (0/6.427). Es el UUID de la determinación, no de la ocurrencia. Correcto descartarlo, pero conviene decir por qué.

## 2.5 El hallazgo que más te sirve: `identifications.modified` resuelve el problema del CDC

En la auditoría de OpenRefine te dije que `dcterms:modified` no sirve como marca de agua incremental porque 1.506 registros tienen `dateIdentified` posterior al `modified` del core, y 4.288 filas conservan el sello de 2020 declarando determinaciones de 2023.

`identifications.csv` trae su propio `modified`, con rango **2023-10-20 → 2025-11-03**, y es **posterior al del core en 4.567 filas**. Cero filas tienen `dateIdentified` posterior a él.

O sea: **el portal sí registra la modificación, pero en el timestamp de la extensión, no en el del core.** Para la carga incremental del data warehouse la marca de agua utilizable es

```
watermark = max(core.modified, identifications.modified)
```

Eso convierte un «no se puede hacer carga incremental» en «se puede, con esta fórmula», y es material directo para el capítulo de desarrollo. Guárdate ese `modified` antes de descartar la tabla: es lo único de `identifications.csv` que no puedes reconstruir después.

---

# 3. EL REPORTE DE PLAUSIBILIDAD

## 3.1 Lo que está bien, y no es poco

La arquitectura es la correcta: 43 reglas en 7 bloques, cada hallazgo con `bloque · regla · campos · valores · severidad · destino`, y un `resumen_regla` aparte. Que hayas separado **severidad** (gravedad) de **destino** (quién decide) es la decisión de diseño que hace usable el reporte: `propio` 1.679, `INABIO` 4.012, `ya_marcado` 143. Y que el script imprima *«casos distintos a resolver»* además de filas demuestra que ya viste el problema del volumen.

Los parches que le metiste están bien pensados: el PARCHE E que evita duplicar `flag_family_minoritaria`, la excepción de cantón homónimo que evitaba marcar 583 filas correctas, la nota de que el bloque 7 «propone y el curador decide».

## 3.2 El problema principal: el reporte confunde filas con trabajo

- **5.834 filas · 4.235 registros distintos (66 % de la colección) · pero solo 1.053 casos distintos.**
- **Cinco reglas de 43 concentran el 54 % de las filas.**
- Y las tres mayores se resuelven con **una respuesta cada una**, ya planteadas en el oficio:

| Regla | Filas | Casos | Ya está en |
|---|---|---|---|
| institución o proyecto en el campo de colector | 1.056 | 69 | **E2** |
| mismo punto, fecha y especie en varios catálogos | 722 | 237 | **G1** |
| `locality` y `locationRemarks` idénticos | 491 | — | nota de modelado |

Son **2.269 filas, el 39 % del reporte, para tres decisiones**.

Y el cruce severidad × destino remata el punto:

|  | INABIO | propio | ya_marcado |
|---|---|---|---|
| alta | **439** | 0 | 0 |
| media | 2.466 | 383 | 143 |
| informativa | 1.107 | 1.296 | 0 |

**Le estás mandando a Yáñez 4.012 filas.** Eso no es un oficio, es un segundo inventario. Pero `alta + INABIO` son **439 filas, 411 registros, 149 casos** — y esa sí es una lista que un curador revisa.

**Mi recomendación:** el CSV de detalle es anexo y nadie lo lee entero. Lo que se envía es `resumen_regla` ordenado por **casos**, no por filas, y la primera vuelta con INABIO es solo `severidad = alta`. Añade al resumen una columna `n_casos` junto a `n_filas`: la diferencia entre 1.056 y 69 es la diferencia entre asustar y pedir una decisión.

## 3.3 Tres ajustes concretos

**a) Saca las verificaciones superadas a otro archivo.** `cantón homónimo de su provincia (verificado, no es error)` 387 filas y `continent sobre coordenada marina (aviso esperado)` 9. Son 396 filas (7 %) que dicen «esto está bien». Están correctamente marcadas `informativa/propio`, pero mezcladas con los hallazgos bajan la señal del anexo. Van a `reporte_plausibilidad_verificadas.csv` — y ahí sí valen oro, porque son evidencia de que el chequeo corrió y pasó, que es justo lo que necesitas en el Capítulo IV.

**b) Colapsa los solapes anidados.** `taxonID apunta a más de un nombre` (464) + `un mismo nombre con más de un taxonID` (445), con 67 en común, son **842 filas para una sola pregunta**: ¿el `taxonID` de Symbiota es estable o se reasigna? Igual con `familia minoritaria` (93) ⊃ `familia minoritaria y además de otro orden` (6) y ⊃ `orden minoritario en la familia` (6 comunes). Una regla con un campo `subtipo` en vez de tres reglas paralelas.

**c) Baja `año de colecta atípico para el colector` a `propio`.** 253 filas, 69 casos, regla autorreferencial declarada en L9. Preguntarle a INABIO por 253 registros porque un colector colectó un año fuera de su mediana no va a producir respuesta.

## 3.4 El bloque 7: te sale 1 de 5, y está bien que así sea

Es lo único genuinamente nuevo del reporte, 39 filas y 5 casos:

| Caso | Veredicto |
|---|---|
| `Mira (7) ~ Mera (38)` | dos cantones reales |
| `Synodontidae (7) ~ Cynodontidae (19)` | dos familias reales |
| `Anodus (3) ~ Knodus (95)` | dos géneros reales |
| `Conodon (2) ~ Cynodon (4)` | dos géneros reales |
| **`Tarapoa (20) ~ Taracoa (111)`** | **el verdadero**, y es el que ya sabíamos: 66 filas de Taracoa/Cuyabeno son Tarapoa |

Cuatro falsos positivos legítimos y un acierto que ya estaba documentado. **No lo escondas: decláralo así en el Capítulo IV.** Es una regla de recall alto y precisión baja por diseño, y por eso su destino es «propone, el curador decide». Una regla ortográfica que no produzca falsos positivos sobre nombres taxonómicos y topónimos es una regla que no encuentra nada. Ese 1/5 con cuatro descartes razonados es un resultado presentable, no un fallo.

## 3.5 Cinco reglas que faltan, y las cinco son de una línea

Todas cubren cosas que ya sabemos que existen y que hoy ninguna regla ve:

```r
# 1. Determinacion posterior al sello de modificacion del registro. La regla
#    "registro modificado antes de la colecta" solo mira eventDate (2 filas).
#    Con dateIdentified son 1.506, y es lo que invalida modified como marca de
#    agua para la carga incremental del DW.
reg(which(nz(df$dateIdentified) != "" &
          substr(df$dateIdentified, 1, 4) > substr(df$modified, 1, 4)),
    "registro", "determinado despues del sello dcterms:modified",
    "dateIdentified|modified", paste(df$dateIdentified, ">", substr(df$modified,1,10)),
    "media", "propio")

# 2. Tipo nomenclatural sin datos de colecta. registro_incompleto no lo alcanza
#    porque el cat. 4358 declara country. Es el holotipo hueco.
reg(which(nz(df$typeStatus) != "" &
          (vac(df$recordedBy) | vac(df$eventDate) | vac(df$locality))),
    "registro", "tipo nomenclatural sin datos de colecta",
    "typeStatus|recordedBy|eventDate|locality", df$typeStatus, "alta", "INABIO")

# 3. Coordenada compartida con otra provincia estando en la minoria. La bandera
#    existe desde el script de coordenadas y no entra al tablero.
reg(which(df$provincia_minoritaria == "TRUE"),
    "coordenadas", "coordenada compartida y provincia minoritaria",
    "stateProvince|decimalLatitude|decimalLongitude",
    paste(df$stateProvince, df$decimalLatitude, df$decimalLongitude), "alta", "INABIO")

# 4. La descripcion del sitio existe pero esta en el campo secundario: 289 filas
#    quedarian sin miembro en la dimension Localidad.
reg(which(vac(df$locality) & !vac(df$locationRemarks)),
    "geografia", "locality vacia con locationRemarks poblada",
    "locality|locationRemarks", df$locationRemarks, "media", "propio")

# 5. Cualificador incompatible con el rango: "sp." significa especie
#    indeterminada y no puede acompanar a un binomio completo.
reg(which(df$identificationQualifier == "sp." & df$taxonRank == "species"),
    "taxonomia", "cualificador sp. sobre un binomio completo",
    "scientificName|identificationQualifier|taxonRank",
    paste(df$scientificName, "+", df$identificationQualifier), "media", "INABIO")
```

---

## CIERRE

**Unión:** aplica el `nrm()` con el espacio duro y retira el bloque de `identificationQualifier`, y vuelve a correr. Espera ver el oficio bajando de **88 a 58** casos, «misma fecha» de **38 a 9**, `identificationQualifier` importados de 21 a 0, y las 21 apareciendo en el CSV pendiente. Las 803 autorías, las 23 previas y el catálogo 4322 no deben moverse.

Guarda `identifications.modified` en una columna del core antes de dar la tabla por cerrada. Es el dato que arregla la carga incremental y es lo único que no vas a poder reconstruir después.

**Plausibilidad:** el motor está bien, lo que falla es la presentación. Ordena por casos, manda `alta` en primera vuelta, saca las verificaciones superadas a su propio archivo y añade las cinco reglas de arriba.

Con eso quedan cuatro etapas cerradas y una sola tabla. Lo que bloquea el DwCA sigue siendo el desplazamiento de índice del `meta.xml`, más tres términos que hay que declarar en el esquema y hoy no están: `occurrenceStatus`, `continent` y `previousIdentifications`.

---

# you asked

message time: 2026-08-21 23:27:10

![image](data:image/webp;base64,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)

> source("~/Limpieza de datos/Limpieza_Ictiologia/scripts/UnirIdentificationsOcurrences.R", echo = TRUE)

> # ================================================================
> # EXTRACCION DE identifications.csv AL CORE
> # Coleccion Ictiologica MECN-DP - .... [TRUNCATED] 

> CORE   <- "datos/02_intermedios/ocurrences_salida_taxonomia.csv"

> IDENT  <- "datos/01_crudos/identifications.csv"

> SALIDA <- "datos/02_intermedios/ocurrences_con_identifications.csv"

> PENDIENTE <- "reportes_y_revisiones/identifications_para_inabio.csv"

> df <- read_csv(CORE,  col_types = cols(.default = "c"))
                                                                                                                     
> id <- read_csv(IDENT, col_types = cols(.default = "c"))
                                                                                                                     
> nz  <- function(x) ifelse(is.na(x), "", x)

> # nrm() tiene que ver el espacio duro. identifications.csv trae 463 U+00A0
> # (30 en scientificName, 433 en scientificNameAuthorship) y \s en TRE n .... [TRUNCATED] 

> vac <- function(x) nrm(x) == ""

> # Alineacion por clave, no por posicion. identifications trae 3762-3767
> # con un intercambio reciproco entre 3766 y 3767, asi que el orden de fila .... [TRUNCATED] 

> stopifnot(identical(nrm(id$coreid), nrm(df$id)))

> motivo <- rep(NA_character_, nrow(df))

> # ---- 1. Los tres aportes: solo donde el core no tiene nada ----
> # "undefined" es texto literal en 18 filas. "unpublised" aparece en 6, y cinco
> .... [TRUNCATED] 

> copiable <- function(v) !vac(v) & !(tolower(nrm(v)) %in% NO_COPIABLE) &
+   !grepl("^\\d{4}-\\d{2}-\\d{2}$", nrm(v))

> # Las autorias que entran no han pasado por ninguna regla del core. 208 de las
> # 799 traen " and " donde la operacion 89 del JSON de OpenRefine es .... [TRUNCATED] 

> aut_norm <- gsub("\\band\\b", "&", nrm(id$scientificNameAuthorship[i_aut]))

> aut_norm <- trimws(gsub("\\s+", " ", aut_norm))

> cat("  autorias normalizadas con la regla del core (and -> &):",
+     sum(aut_norm != nrm(id$scientificNameAuthorship[i_aut])), "\n")
  autorias normalizadas con la regla del core (and -> &): 213 

> df$scientificNameAuthorship[i_aut] <- aut_norm

> # identifiedBy NO se importa. Los 7 valores que identifications aporta donde el
> # core no tiene nada son: la cadena "2023-04-25" (catalogo 1335),  .... [TRUNCATED] 

> cat("identifiedBy de identifications descartados por placeholder:",
+     length(i_ide_descartado), "\n")
identifiedBy de identifications descartados por placeholder: 7 

> cat("  valores:", paste(unique(nrm(id$identifiedBy[i_ide_descartado])), collapse = " | "), "\n")
  valores: 2023-04-25 | unknown 

> # dateIdentified no se copia: los 181 valores en identifications son 176 vacios
> # y 5 s.d., que ya se retiraron del core.
> cat("dateIdentified NO ..." ... [TRUNCATED] 
dateIdentified NO importados (176 sin datos, 5 s.d.): 181

> # recordID es el UUID de la determinacion, no de la ocurrencia, y tidInterpreted 
> # muestra cruce de IDs en 3766/3767 (evidencia de desalineamient .... [TRUNCATED] 
recordID y tidInterpreted de identifications descartados: no aplican al core

> # El cualificador es atributo del ACTO de determinacion, no del registro.
> # identifications describe otra determinacion (18 de 21 traen otro nombr .... [TRUNCATED] 

> cat("identificationQualifier NO importados (pertenecen a otra determinacion):",
+     length(i_qua), "\n")
identificationQualifier NO importados (pertenecen a otra determinacion): 21 

> motivo[i_qua] <- ifelse(is.na(motivo[i_qua]),
+   "identifications trae cualificador de su propia determinacion, incompatible con el nombre del core ..." ... [TRUNCATED] 

> cat("scientificNameAuthorship tomados de identifications:", length(i_aut), "\n")
scientificNameAuthorship tomados de identifications: 803 

> # ---- 1b. Catalogo 4322: el unico aporte taxonomico neto de toda la tabla ----
> # El core no tiene ningun nombre (flag_sin_taxonomia) y identifica .... [TRUNCATED] 

> if (length(i_432)) {
+   df$scientificName[i_432] <- nrm(id$scientificName[i_432])
+   df$family[i_432]         <- nrm(id$scientificName[i_432])
+   .... [TRUNCATED] 
determinacion a nivel de familia tomada de identifications: 1 -> catalogos 4322 

> # ---- 2. previousIdentifications ----
> # Discriminador: una redeterminacion es un evento nuevo. Solo se escribe si
> # el nombre difiere Y la fech .... [TRUNCATED] 

> d_id  <- nrm(id$dateIdentified)

> d_cor <- nrm(df$dateIdentified)

> g_id  <- gran(d_id); g_cor <- gran(d_cor)

> L     <- ifelse(pmin(g_id, g_cor) == 1L, 4L, ifelse(pmin(g_id, g_cor) == 2L, 7L, 10L))

> # El verbatim es el core tal como llego del portal. Comparar contra el es
> # comparar dos fuentes; comparar contra el core limpio es comparar ident .... [TRUNCATED] 

> nombre_difiere <- copiable(id$scientificName) & !vac(nombre_core_origen) &
+   nrm(id$scientificName) != nombre_core_origen &
+   tolower(nrm(id$sci .... [TRUNCATED] 

> fecha_anterior <- g_id > 0 & g_cor > 0 &
+   substr(d_id, 1, L) < substr(d_cor, 1, L)

> # identifications pierde el epiteto especifico en 1.111 filas respecto al core.
> # Cuando el nombre de identifications es prefijo del nombre del co .... [TRUNCATED] 

> i_prev <- which(nombre_difiere & fecha_anterior & !truncamiento)

> cat("  descartadas por truncamiento pese a tener fecha anterior:",
+     sum(nombre_difiere & fecha_anterior & truncamiento), "\n")
  descartadas por truncamiento pese a tener fecha anterior: 1 

> if (!"previousIdentifications" %in% names(df)) df$previousIdentifications <- NA_character_

> df$previousIdentifications[i_prev] <- nrm(id$scientificName[i_prev])

> cat("previousIdentifications escritas (fecha anterior probada):", length(i_prev), "\n")
previousIdentifications escritas (fecha anterior probada): 23 

> # ---- 3. Lo que NO se escribe: al oficio ----
> # Tres grupos que el discriminador no puede resolver, mas el texto literal
> # "undefined" que iden .... [TRUNCATED] 

> motivo[which(nombre_difiere & (g_id == 0 | g_cor == 0))] <- "sin fecha comparable en identifications"

> motivo[which(!vac(id$scientificName) &
+                tolower(nrm(id$scientificName)) == "undefined")] <- "identifications trae el texto literal u ..." ... [TRUNCATED] 

> # El bloque anterior cubre tres destinos. Faltan dos casos que hoy salen en cero
> # pero que el script no probaba: el nombre distinto con fecha POS .... [TRUNCATED] 

> motivo[which(nombre_difiere & fecha_posterior)] <-
+   "identifications trae una determinacion POSTERIOR: el core seria el desactualizado"

> motivo[which(nombre_difiere & truncamiento)] <-
+   "identifications trae el nombre truncado, no una determinacion anterior"

> sin_destino <- setdiff(which(nombre_difiere & is.na(motivo)), i_prev)

> if (length(sin_destino)) {
+   cat("ATENCION - diferencias sin destino asignado:", length(sin_destino), "\n")
+   print(df$catalogNumber[sin_destino .... [TRUNCATED] 

> stopifnot(length(sin_destino) == 0)

> cat("particion cerrada:", sum(nombre_difiere), "nombres distintos =",
+     length(i_prev), "previas +", sum(nombre_difiere & !is.na(motivo)), "al o ..." ... [TRUNCATED] 
particion cerrada: 63 nombres distintos = 23 previas + 45 al oficio

> i_pend <- which(!is.na(motivo))

> tibble(catalogNumber = df$catalogNumber[i_pend],
+        core_id       = df$id[i_pend],
+        nombre_identifications = nrm(id$scientificName[i_p .... [TRUNCATED] 
                                                                                                                   
> cat("casos enviados al oficio de INABIO:", length(i_pend), "\n")
casos enviados al oficio de INABIO: 66 

> # Ninguna celda del core cambia sin quedar anotada. Es la misma invariante que
> # sostienen las tres etapas anteriores.
> marcar <- function(v, idx .... [TRUNCATED] 

> df$metodo_correccion_taxon <- marcar(df$metodo_correccion_taxon, i_aut,
+   "scientificNameAuthorship_tomado_de_identifications")

> df$metodo_correccion_taxon <- marcar(df$metodo_correccion_taxon, i_prev,
+   "previousIdentifications_desde_identifications")

> if (exists("i_432")) df$metodo_correccion_taxon <- marcar(df$metodo_correccion_taxon, i_432,
+   "determinacion_familia_tomada_de_identifications")

> # El dcterms:modified del core falla como marca de agua incremental porque 4.288
> # filas conservan el sello de 2020 pese a declarar determinacione .... [TRUNCATED] 

> write_csv(df, SALIDA, na = "")
                                                                                                                   
> cat("\nGuardado en", SALIDA, "\n")

Guardado en datos/02_intermedios/ocurrences_con_identifications.csv 
> source("~/Limpieza de datos/Limpieza_Ictiologia/scripts/ValidacionPlausibilidad.R", echo = TRUE)

> # ================================================================
> # VALIDACIÓN DE PLAUSIBILIDAD Y CONSISTENCIA INTERNA
> # Colección Ictiológica  .... [TRUNCATED] 

> ARCHIVO  <- "datos/02_intermedios/ocurrences_salida_taxonomia.csv"

> SALIDA   <- "reportes_y_revisiones/reporte_plausibilidad.csv"

> RESUMEN  <- "reportes_y_revisiones/reporte_plausibilidad_resumen.csv"

> HOY      <- Sys.Date()

> ANIO_MIN <- 1900   # fundación de la colección

> df <- read_csv(ARCHIVO, col_types = cols(.default = "c"))
                                                                                                                     
> num <- function(x) suppressWarnings(as.numeric(x))

> vac <- function(x) is.na(x) | trimws(x) == ""

> nz  <- function(x) ifelse(is.na(x), "", x)

> H <- list()

> reg <- function(idx, bloque, regla, campos, valores, severidad, destino) {
+   if (!length(idx)) return(invisible())
+   H[[length(H) + 1]] <<- tibb .... [TRUNCATED] 

> # ---------------------------------------------------------------
> # BLOQUE 1 - TEMPORAL
> # ------------------------------------------------------ .... [TRUNCATED] 

BLOQUE 1 - Temporal

> # Granularidad comun: una fecha con solo ano no puede compararse por dia.
> # c(4,7,10)[g] elimina los elementos donde g=0 y desalinea el vector ent .... [TRUNCATED] 

> ge <- gran(nz(df$eventDate)); gd <- gran(nz(df$dateIdentified))

> ok <- ge > 0 & gd > 0

> gc <- pmin(ge, gd)

> L  <- ifelse(gc == 1L, 4L, ifelse(gc == 2L, 7L, 10L))

> idx <- which(ok & substr(nz(df$dateIdentified), 1, L) < substr(nz(df$eventDate), 1, L))

> reg(idx, "temporal", "determinado antes de ser colectado",
+     "eventDate | dateIdentified",
+     paste(df$eventDate[idx], "|", df$dateIdentified .... [TRUNCATED] 
  [alta       ] determinado antes de ser colectado                73

> idx <- which(ge > 0 & substr(nz(df$eventDate), 1, 4) > format(HOY, "%Y"))

> reg(idx, "temporal", "fecha de colecta en el futuro", "eventDate",
+     df$eventDate[idx], "alta", "INABIO")
  [alta       ] fecha de colecta en el futuro                      2

> idx <- which(gd > 0 & substr(nz(df$dateIdentified), 1, 4) > format(HOY, "%Y"))

> reg(idx, "temporal", "fecha de determinacion en el futuro", "dateIdentified",
+     df$dateIdentified[idx], "alta", "INABIO")

> idx <- which(ge > 0 & num(substr(nz(df$eventDate), 1, 4)) < ANIO_MIN)

> reg(idx, "temporal", "colecta anterior a la fundacion de la coleccion",
+     "eventDate", df$eventDate[idx], "alta", "INABIO")
  [alta       ] colecta anterior a la fundacion de la coleccion     1

> # El registro no puede modificarse antes de que el ejemplar se colecte.
> idx <- which(ge > 0 & !vac(df$modified) &
+                substr(nz(df$mo .... [TRUNCATED] 

> reg(idx, "temporal", "registro modificado antes de la colecta",
+     "eventDate | modified",
+     paste(df$eventDate[idx], "|", df$modified[idx]), .... [TRUNCATED] 
  [alta       ] registro modificado antes de la colecta            2

> # 1. Determinacion posterior al sello de modificacion del registro. La regla
> #    "registro modificado antes de la colecta" solo mira eventDate (2 .... [TRUNCATED] 

> reg(idx, "registro", "determinado despues del sello dcterms:modified",
+     "dateIdentified|modified", paste(df$dateIdentified[idx], ">", substr(df .... [TRUNCATED] 
  [media      ] determinado despues del sello dcterms:modified  1506

> # eventDate y su propio verbatim declaran años distintos.
> av <- ifelse(grepl("^\\d{4}", nz(df$verbatimEventDate)),
+              substr(nz(df$ver .... [TRUNCATED] 

> idx <- which(ge > 0 & !is.na(av) & av != substr(nz(df$eventDate), 1, 4))

> reg(idx, "temporal", "eventDate y verbatimEventDate con anos distintos",
+     "eventDate | verbatimEventDate",
+     paste(df$eventDate[idx], "|",  .... [TRUNCATED] 
  [alta       ] eventDate y verbatimEventDate con anos distintos    20

> # El portal completo el dia con 01 sobre un verbatim que solo traia ano-mes.
> idx <- which(grepl("^\\d{4}-\\d{1,2}$", nz(df$verbatimEventDate)) &
+ .... [TRUNCATED] 

> reg(idx, "temporal", "dia fabricado por el portal (01 sobre verbatim ano-mes)",
+     "eventDate | verbatimEventDate | day",
+     paste(df$eventDat .... [TRUNCATED] 
  [media      ] dia fabricado por el portal (01 sobre verbatim ano-mes)   169

> idx <- which(ge > 0 & vac(df$startDayOfYear))

> reg(idx, "temporal", "eventDate parcial sin startDayOfYear (grano no diario)",
+     "eventDate | startDayOfYear", df$eventDate[idx], "informativa", .... [TRUNCATED] 
  [informativa] eventDate parcial sin startDayOfYear (grano no diario)   234

> # Ano atipico para el colector: 1.5 x rango intercuartil, minimo 15 registros.
> tmp <- df %>% mutate(.i = row_number(), anio = num(substr(nz(eventD .... [TRUNCATED] 

> reg(tmp$.i, "temporal", "ano de colecta atipico para el colector",
+     "eventDate | recordedBy",
+     paste(tmp$eventDate, "|", tmp$recordedBy),  .... [TRUNCATED] 
  [informativa] ano de colecta atipico para el colector          253

> # ---------------------------------------------------------------
> # BLOQUE 2 - JERARQUIA GEOGRAFICA
> # ------------------------------------------ .... [TRUNCATED] 

BLOQUE 2 - Jerarquia geografica

> # PARCHE: marcar la fila minoritaria, no el canton entero. min_fila esta
> # definida mas abajo en el bloque 4; se sube aqui para que ambos bloques
 .... [TRUNCATED] 

> # PARCHE F: un canton puede pertenecer legitimamente a dos provincias en
> # fechas distintas. La Concordia fue de Esmeraldas hasta su traspaso a
>  .... [TRUNCATED] 

> anio_col <- num(substr(nz(df$eventDate), 1, 4))

> vigente  <- rep(FALSE, nrow(df))

> for (k in seq_len(nrow(VIGENCIA))) {
+   sel <- df$county == VIGENCIA$county[k] & df$stateProvince == VIGENCIA$stateProvince[k] &
+          !is.na( .... [TRUNCATED] 

> idx <- setdiff(min_fila("county", "stateProvince"), which(vigente))

> reg(idx, "geografia", "canton asociado a dos provincias distintas",
+     "county | stateProvince",
+     paste(df$county[idx], "|", df$stateProvinc .... [TRUNCATED] 
  [alta       ] canton asociado a dos provincias distintas        82

> idx <- which(!vac(df$municipality) & vac(df$county))

> reg(idx, "geografia", "parroquia declarada sin canton", "municipality | county",
+     df$municipality[idx], "media", "INABIO")
  [media      ] parroquia declarada sin canton                    12

> # PARCHE P1: en Ecuador varios cantones se llaman igual que su provincia y son
> # legitimos: canton Pastaza en Pastaza, canton Esmeraldas en Esmera .... [TRUNCATED] 

> idx <- which(!vac(df$county) & df$county == df$stateProvince &
+              !(df$county %in% CANTON_HOMONIMO_LEGITIMO))

> reg(idx, "geografia", "nombre de provincia usado como canton",
+     "county | stateProvince", df$county[idx], "media", "INABIO")
  [media      ] nombre de provincia usado como canton            196

> idx <- which(!vac(df$county) & df$county == df$stateProvince &
+              df$county %in% CANTON_HOMONIMO_LEGITIMO)

> reg(idx, "geografia", "canton homonimo de su provincia (verificado, no es error)",
+     "county | stateProvince", df$county[idx], "informativa", "p ..." ... [TRUNCATED] 
  [informativa] canton homonimo de su provincia (verificado, no es error)   387

> idx <- which(!vac(df$county) & df$county == df$municipality)

> reg(idx, "geografia", "mismo valor en canton y parroquia",
+     "county | municipality", df$county[idx], "informativa", "INABIO")
  [informativa] mismo valor en canton y parroquia                125

> idx <- which(!vac(df$municipality) & df$municipality == df$locality)

> reg(idx, "geografia", "parroquia repetida como localidad",
+     "municipality | locality", df$municipality[idx], "informativa", "propio")
  [informativa] parroquia repetida como localidad                175

> idx <- which(!vac(df$locality) & df$locality == df$locationRemarks)

> reg(idx, "geografia", "locality y locationRemarks identicos",
+     "locality | locationRemarks", df$locality[idx], "informativa", "propio")
  [informativa] locality y locationRemarks identicos             491

> # 4. La descripcion del sitio existe pero esta en el campo secundario: 289 filas
> #    quedarian sin miembro en la dimension Localidad.
> idx <- wh .... [TRUNCATED] 

> reg(idx, "geografia", "locality vacia con locationRemarks poblada",
+     "locality|locationRemarks", df$locationRemarks[idx], "media", "propio")
  [media      ] locality vacia con locationRemarks poblada       289

> # PARCHE G: \d{5,} capturaba distancias en metros ("a 10000 m") y no solo
> # coordenadas. Se exige el patron UTM (zona + par easting/northing) o la .... [TRUNCATED] 

> reg(idx, "geografia", "coordenada o altitud embebida en el texto de localidad",
+     "locality", df$locality[idx], "media", "propio")
  [media      ] coordenada o altitud embebida en el texto de localidad    23

> # ---------------------------------------------------------------
> # BLOQUE 3 - ECOLOGIA Y BIOGEOGRAFIA
> # El nucleo de la validacion de plausibil .... [TRUNCATED] 

BLOQUE 3 - Ecologia y biogeografia

> # Editable por el curador. Familias sin representantes dulceacuicolas en la
> # cuenca amazonica ecuatoriana. Achiridae NO va aqui: Hypoclinemus y
> .... [TRUNCATED] 

> AMAZONIA <- c("Orellana","Sucumbios","Sucumbíos","Napo","Pastaza",
+               "Morona Santiago","Zamora Chinchipe")

> PACIFICO <- c("Esmeraldas","Manabi","Manabí","Guayas","El Oro","Santa Elena",
+               "Los Rios","Los Ríos","Santo Domingo de los Tsachilas" .... [TRUNCATED] 

> idx <- which(df$family %in% FAM_MARINAS & df$stateProvince %in% AMAZONIA)

> reg(idx, "ecologia", "familia estrictamente marina en provincia amazonica",
+     "family | stateProvince | scientificName",
+     paste(df$scientif .... [TRUNCATED] 
  [alta       ] familia estrictamente marina en provincia amazonica     2

> # Especie a ambos lados de los Andes con un solo registro en una vertiente:
> # el registro solitario es candidato a error de determinacion o de geo .... [TRUNCATED] 

> reg(tmp$.i, "ecologia", "unico registro de la especie en esa vertiente",
+     "scientificName | stateProvince",
+     paste(tmp$scientificName, "|" .... [TRUNCATED] 
  [media      ] unico registro de la especie en esa vertiente     19

> # Altitud fuera del rango conocido de la especie dentro de la propia coleccion.
> # MAD con piso de 50 m para no marcar especies de altitud muy homo .... [TRUNCATED] 

> reg(tmp$.i, "ecologia", "altitud fuera del rango de la especie en la coleccion",
+     "scientificName | minimumElevationInMeters",
+     paste(tmp$ .... [TRUNCATED] 
  [media      ] altitud fuera del rango de la especie en la coleccion    80

> # ---------------------------------------------------------------
> # BLOQUE 4 - INTEGRIDAD DE LA JERARQUIA TAXONOMICA
> # ------------------------- .... [TRUNCATED] 

BLOQUE 4 - Integridad taxonomica

> # PARCHE E: estas dos reglas duplicaban flag_family_minoritaria (87 de 93
> # filas compartidas) y flag_orden_minoritario_en_familia (13 de 13,
> #  .... [TRUNCATED] 

> nm <- df %>% filter(!vac(taxonID), !vac(scientificName)) %>%
+   distinct(taxonID, scientificName) %>% count(scientificName) %>% filter(n > 1) %>%
+ .... [TRUNCATED] 

> idx_tm <- which(df$taxonID %in% tm)

> idx_nm <- which(df$scientificName %in% nm)

> idx_tax <- union(idx_tm, idx_nm)

> if (length(idx_tax)) {
+   sub_tax <- rep("", length(idx_tax))
+   sub_tax[idx_tax %in% idx_tm & idx_tax %in% idx_nm] <- "ambos (cruce multiple)"
+  .... [TRUNCATED] 
  [media      ] inconsistencia (cruce) entre taxonID y scientificName   842

> # 5. Cualificador incompatible con el rango: "sp." significa especie
> #    indeterminada y no puede acompanar a un binomio completo.
> idx <- which .... [TRUNCATED] 

> reg(idx, "taxonomia", "cualificador sp. sobre un binomio completo",
+     "scientificName|identificationQualifier|taxonRank",
+     paste(df$scienti .... [TRUNCATED] 
  [media      ] cualificador sp. sobre un binomio completo        29

> # Consolidacion de las banderas que el pipeline ya produce.
> # Colapsar solapes anidados de jerarquia (3.3b)
> if (all(c("flag_family_minoritaria", .... [TRUNCATED] 
  [media      ] jerarquia superior minoritaria o discrepante      96

> banderas <- c(flag_genus_no_coincide_con_nombre    = "genus no coincide con el binomio",
+               flag_epiteto_no_coincide_con_nombre  = "epi ..." ... [TRUNCATED] 

> for (b in names(banderas)) {
+   if (!b %in% names(df)) next
+   idx <- which(toupper(nz(df[[b]])) == "TRUE")
+   reg(idx, "taxonomia", banderas[[b] .... [TRUNCATED] 
  [media      ] genus no coincide con el binomio                  12
  [media      ] epiteto no coincide con el binomio                12
  [media      ] registro sin ningun dato taxonomico                7
  [media      ] registro sin metadatos de colecta                  4

> # ---------------------------------------------------------------
> # BLOQUE 5 - REGISTRO Y COLECTA
> # -------------------------------------------- .... [TRUNCATED] 

BLOQUE 5 - Registro y colecta

> idx <- which(vac(df$individualCount))

> reg(idx, "registro", "sin numero de individuos", "individualCount", "", "media", "INABIO")
  [media      ] sin numero de individuos                           5

> # 2. Tipo nomenclatural sin datos de colecta. registro_incompleto no lo alcanza
> #    porque el cat. 4358 declara country. Es el holotipo hueco.
>  .... [TRUNCATED] 

> reg(idx, "registro", "tipo nomenclatural sin datos de colecta",
+     "typeStatus|recordedBy|eventDate|locality", df$typeStatus[idx], "alta", "INABI ..." ... [TRUNCATED] 
  [alta       ] tipo nomenclatural sin datos de colecta            1

> idx <- which(!vac(df$individualCount) & num(df$individualCount) == 0)

> reg(idx, "registro", "numero de individuos igual a cero", "individualCount",
+     df$individualCount[idx], "alta", "INABIO")

> ic <- num(df$individualCount)

> lim <- quantile(ic, .75, na.rm = TRUE) + 3 * IQR(ic, na.rm = TRUE)

> idx <- which(!is.na(ic) & ic > max(lim, 200))

> reg(idx, "registro", "lote con numero de individuos atipicamente alto",
+     "individualCount", df$individualCount[idx], "informativa", "INABIO")
  [informativa] lote con numero de individuos atipicamente alto     7

> idx <- which(!vac(df$maximumElevationInMeters) & vac(df$minimumElevationInMeters))

> reg(idx, "registro", "altitud maxima declarada sin altitud minima",
+     "minimumElevationInMeters | maximumElevationInMeters",
+     df$maximumEle .... [TRUNCATED] 
  [media      ] altitud maxima declarada sin altitud minima      191

> idx <- which(!vac(df$minimumElevationInMeters) & !vac(df$maximumElevationInMeters) &
+                num(df$minimumElevationInMeters) > num(df$maxi .... [TRUNCATED] 

> reg(idx, "registro", "altitud minima mayor que la maxima",
+     "minimumElevationInMeters | maximumElevationInMeters",
+     paste(df$minimumElevat .... [TRUNCATED] 

> # Instituciones y proyectos escritos en el campo de personas.
> NO_PERSONAS <- c("QCAZ","GLOWS","Gueppi","Simbioe","Indigenas","Indígenas","JVDC")

> patron <- paste0("(^|\\| )(", paste(NO_PERSONAS, collapse = "|"), ")( \\||$)")

> idx <- which(grepl(patron, nz(df$recordedBy)))

> reg(idx, "registro", "institucion o proyecto en el campo de colector",
+     "recordedBy", df$recordedBy[idx], "media", "INABIO")
  [media      ] institucion o proyecto en el campo de colector  1056

> # Nombre reducido a iniciales: no identifica a la persona.
> idx <- which(grepl("(^|\\| )[A-Z]\\.([A-Z]\\.)+( \\||$)", nz(df$recordedBy)))

> reg(idx, "registro", "colector reducido a iniciales sin nombre desarrollado",
+     "recordedBy", df$recordedBy[idx], "media", "INABIO")
  [media      ] colector reducido a iniciales sin nombre desarrollado    83

> # Mismo punto, misma fecha y misma especie en catalogos distintos: puede ser
> # un lote legitimo separado en ejemplares o una duplicacion de carga. .... [TRUNCATED] 

> reg(tmp$.i, "registro", "mismo punto, fecha y especie en varios catalogos",
+     "decimalLatitude | eventDate | scientificName",
+     paste(tmp$sc .... [TRUNCATED] 
  [informativa] mismo punto, fecha y especie en varios catalogos   722

> # ---------------------------------------------------------------
> # BLOQUE 5b - VOCABULARIOS CONTROLADOS DE DARWIN CORE
> # Un valor fuera del voc .... [TRUNCATED] 

BLOQUE 5b - Vocabularios controlados

> VOC <- list(
+   establishmentMeans = c("native","nativeReintroduced","introduced",
+                          "introducedAssistedColonisation","vag ..." ... [TRUNCATED] 

> for (campo in names(VOC)) {
+   if (!campo %in% names(df)) next
+   v <- nz(df[[campo]])
+   # Los campos multivalor se evaluan termino a termino.
+ .... [TRUNCATED] 

> # ---------------------------------------------------------------
> # BLOQUE 6 - COORDENADAS (consolidacion, no recalculo)
> # --------------------- .... [TRUNCATED] 

BLOQUE 6 - Coordenadas

> if ("coherencia_provincia" %in% names(df)) {
+   idx <- which(df$coherencia_provincia == "discordante")
+   reg(idx, "coordenadas", "coordenada fuer ..." ... [TRUNCATED] 
  [alta       ] coordenada fuera de la provincia declarada       231
  [alta       ] signo de la coordenada no resuelto                14
  [alta       ] coordenada derivada de un DMS fuera de rango      12
  [media      ] coordenada irrecuperable                          67
  [alta       ] coordenada compartida y provincia minoritaria     56

> # PARCHE P4: declarar continent en las 6.427 genera CONTINENT_COORDINATE_MISMATCH
> # en los puntos que caen en el mar, porque el poligono de contin .... [TRUNCATED] 

> reg(idx, "coordenadas", "continent declarado sobre coordenada marina (aviso GBIF esperado)",
+     "continent | coherencia_provincia", df$continent[ .... [TRUNCATED] 
  [informativa] continent declarado sobre coordenada marina (aviso GBIF esperado)     9

> # ---------------------------------------------------------------
> # OPCIONAL - Altitud declarada contra el modelo digital de elevacion.
> # Requie .... [TRUNCATED] 

> if (USAR_DEM) {
+   library(elevatr); library(sf)
+   sub <- df %>% mutate(.i = row_number()) %>%
+     filter(!vac(decimalLatitude), !vac(minimumEl .... [TRUNCATED] 

> # ---------------------------------------------------------------
> # BLOQUE 7 - SIMILITUD ORTOGRAFICA DENTRO DE LA MISMA COLUMNA
> # Un valor a una .... [TRUNCATED] 

BLOQUE 7 - Similitud ortografica

> norm_txt <- function(x) tolower(iconv(x, to = "ASCII//TRANSLIT"))

> lev1 <- function(a, b) abs(nchar(a) - nchar(b)) <= 1 &&
+                        adist(a, b, ignore.case = TRUE)[1, 1] <= 1

> for (col in c("genus", "family", "county", "municipality", "stateProvince")) {
+   v <- table(df[[col]][!vac(df[[col]])])
+   u <- names(v)
+   if ( .... [TRUNCATED] 
  [media      ] valor a una letra de otro valor de genus           2
  [media      ] valor a una letra de otro valor de genus           3
  [media      ] valor a una letra de otro valor de family          7
  [media      ] valor a una letra de otro valor de county          7
  [media      ] valor a una letra de otro valor de municipality    20

> # ---------------------------------------------------------------
> # SALIDA
> # ---------------------------------------------------------------
> r .... [TRUNCATED] 

> # 3.3a Sacar verificaciones superadas a otro archivo
> reglas_verificadas <- c("canton homonimo de su provincia (verificado, no es error)",
+        .... [TRUNCATED] 

> rep_verificadas <- rep %>% filter(regla %in% reglas_verificadas)

> rep <- rep %>% filter(!(regla %in% reglas_verificadas))

> write_csv(rep_verificadas, "reportes_y_revisiones/reporte_plausibilidad_verificadas.csv", na = "")
                                                                                                                   
> write_csv(rep, SALIDA, na = "")
                                                                                                                   
> # PARCHE P3 y 3.2: el CSV completo es anexo; lo que se lee es esto. Una regla que
> # dispara en 1.056 filas no son 1.056 problemas: son seis pregun .... [TRUNCATED] 

> write_csv(resumen_regla, "reportes_y_revisiones/reporte_plausibilidad_resumen.csv", na = "")
                                                                                                                   
> cat("\n=== RESUMEN POR REGLA ===\n"); print(as.data.frame(resumen_regla))

=== RESUMEN POR REGLA ===
        bloque                                                   regla   severidad    destino filas registros casos
1     registro        mismo punto, fecha y especie en varios catalogos informativa     INABIO   722       722   237
2    geografia                       mismo valor en canton y parroquia informativa     INABIO   125       125    22
3     registro         lote con numero de individuos atipicamente alto informativa     INABIO     7         7     6
4     ecologia   altitud fuera del rango de la especie en la coleccion       media     INABIO    80        80    76
5     registro          institucion o proyecto en el campo de colector       media     INABIO  1056      1056    69
6    taxonomia   inconsistencia (cruce) entre taxonID y scientificName       media     INABIO   842       842    62
7  coordenadas                                coordenada irrecuperable       media     INABIO    67        67    32
8    taxonomia              cualificador sp. sobre un binomio completo       media     INABIO    29        29    21
9     ecologia           unico registro de la especie en esa vertiente       media     INABIO    19        19    19
10   geografia                          parroquia declarada sin canton       media     INABIO    12        12     8
11    registro   colector reducido a iniciales sin nombre desarrollado       media     INABIO    83        83     4
12  ortografia                valor a una letra de otro valor de genus       media     INABIO     5         5     2
13   geografia                   nombre de provincia usado como canton       media     INABIO   196       196     1
14  ortografia               valor a una letra de otro valor de county       media     INABIO     7         7     1
15  ortografia               valor a una letra de otro valor de family       media     INABIO     7         7     1
16  ortografia         valor a una letra de otro valor de municipality       media     INABIO    20        20     1
17    registro                                sin numero de individuos       media     INABIO     5         5     1
18 coordenadas              coordenada fuera de la provincia declarada        alta     INABIO   231       231    91
19 coordenadas           coordenada compartida y provincia minoritaria        alta     INABIO    56        56    43
20    temporal        eventDate y verbatimEventDate con anos distintos        alta     INABIO    20        20    18
21    temporal                      determinado antes de ser colectado        alta     INABIO    73        73    13
22 coordenadas                      signo de la coordenada no resuelto        alta     INABIO    14        14    10
23 coordenadas            coordenada derivada de un DMS fuera de rango        alta     INABIO    12        12     6
24   geografia              canton asociado a dos provincias distintas        alta     INABIO    82        82     4
25    ecologia     familia estrictamente marina en provincia amazonica        alta     INABIO     2         2     2
26    temporal                           fecha de colecta en el futuro        alta     INABIO     2         2     2
27    temporal                 registro modificado antes de la colecta        alta     INABIO     2         2     2
28    registro                 tipo nomenclatural sin datos de colecta        alta     INABIO     1         1     1
29    temporal         colecta anterior a la fundacion de la coleccion        alta     INABIO     1         1     1
30   geografia                    locality y locationRemarks identicos informativa     propio   491       491    99
31    temporal                 ano de colecta atipico para el colector informativa     propio   253       253    69
32   geografia                       parroquia repetida como localidad informativa     propio   175       175    16
33    temporal  eventDate parcial sin startDayOfYear (grano no diario) informativa     propio   234       234    11
34   geografia              locality vacia con locationRemarks poblada       media     propio   289       289    89
35    registro          determinado despues del sello dcterms:modified       media     propio  1506      1506    74
36    registro             altitud maxima declarada sin altitud minima       media     propio   191       191    39
37   geografia  coordenada o altitud embebida en el texto de localidad       media     propio    23        23     8
38    temporal dia fabricado por el portal (01 sobre verbatim ano-mes)       media     propio   169       169     6
39   taxonomia            jerarquia superior minoritaria o discrepante       media ya_marcado    96        96    56
40   taxonomia                      epiteto no coincide con el binomio       media ya_marcado    12        12    10
41   taxonomia                        genus no coincide con el binomio       media ya_marcado    12        12     9
42   taxonomia                       registro sin metadatos de colecta       media ya_marcado     4         4     2
43   taxonomia                     registro sin ningun dato taxonomico       media ya_marcado     7         7     1

> cat("\nRegistros con al menos un hallazgo:", n_distinct(rep$catalogNumber),
+     sprintf("(%.1f%% de la coleccion)\n", 100 * n_distinct(rep$catalog .... [TRUNCATED] 

Registros con al menos un hallazgo: 4690 (73.0% de la coleccion)

> cat("Reglas distintas:", n_distinct(rep$regla),
+     "| casos distintos a resolver:", n_distinct(paste(rep$regla, rep$valores)), "\n")
Reglas distintas: 43 | casos distintos a resolver: 1245 

> cat("\nGuardado en", SALIDA, "\n")

Guardado en reportes_y_revisiones/reporte_plausibilidad.csv 
>

{"key":"2f5f3e3b-9baa-42b0-bc20-d51f0c0ee55c","created":"2026-08-22T04:11:30.843+00:00","modified":"2026-08-22T04:12:40.731+00:00","username":"1said2","file":"dataset_dwca.zip","fileSize":578686,"fileFormat":"DWCA","status":"FINISHED","metrics":{"indexeable":true,"stepTypes":[{"stepType":"VALIDATOR_VALIDATE_ARCHIVE","status":"FINISHED","executionOrder":2},{"stepType":"VALIDATOR_DWCA_TO_VERBATIM","status":"FINISHED","executionOrder":3},{"stepType":"VALIDATOR_VERBATIM_TO_IDENTIFIER","status":"FINISHED","executionOrder":4},{"stepType":"VALIDATOR_VERBATIM_TO_INTERPRETED","status":"FINISHED","executionOrder":5},{"stepType":"VALIDATOR_COLLECT_METRICS","status":"FINISHED","executionOrder":6},{"stepType":"VALIDATOR_UPLOAD_ARCHIVE","status":"FINISHED","executionOrder":1}],"files":[{"fileName":"eml.xml","fileType":"METADATA","terms":[],"issues":[{"issue":"RESOURCE_CONTACTS_MISSING_OR_INCOMPLETE","issueCategory":"METADATA_CONTENT","samples":[]}]},{"fileName":"occurrences.csv","fileType":"CORE","count":6427,"indexedCount":6427,"rowType":"http://rs.tdwg.org/dwc/terms/Occurrence","terms":[{"term":"http://rs.tdwg.org/dwc/terms/recordedBy","rawIndexed":6274,"uniqueRawValues":221,"interpretedIndexed":6427,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"Paúl Tufiño":279,"Martha Buenaño Carriel":497,"Fernando Sánchez":197,"Lida Guarderas":309,"Fernando Anaguano Yancha,N. Narankas,M. Ampam,L. Chuim":166,"Jonathan Santiago Valdiviezo Rivera":813,"GLOWS":171,"QCAZ":534,"Windsor Aguirre":193,"Juan Francisco Rivadeneira":242}},{"term":"http://rs.tdwg.org/dwc/terms/scientificNameAuthorship","rawIndexed":5876},{"term":"http://rs.tdwg.org/dwc/terms/informationWithheld","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/preparations","rawIndexed":6423,"uniqueRawValues":5,"interpretedIndexed":6427,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"":4,"Cabeza":4,"Esqueleto":7,"Ejemplar completo en alcohol,Tejido":1,"Ejemplar seco":1,"Ejemplar completo en alcohol":6410}},{"term":"http://rs.tdwg.org/dwc/terms/associatedOccurrences","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/month","rawIndexed":5900,"uniqueRawValues":12,"interpretedIndexed":5898,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"11":410,"12":442,"2":438,"3":371,"5":723,"6":406,"7":448,"8":549,"9":684,"10":882}},{"term":"http://purl.org/dc/terms/accessRights","rawIndexed":6427},{"term":"http://rs.tdwg.org/dwc/terms/previousIdentifications","rawIndexed":23},{"term":"http://rs.tdwg.org/dwc/terms/specificEpithet","rawIndexed":5160},{"term":"http://rs.tdwg.org/dwc/terms/basisOfRecord","rawIndexed":6427,"uniqueRawValues":1,"interpretedIndexed":6427,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"PRESERVED_SPECIMEN":6427}},{"term":"http://rs.tdwg.org/dwc/terms/taxonID","rawIndexed":5568,"uniqueRawValues":641,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/individualCount","rawIndexed":6422,"uniqueRawValues":109,"interpretedIndexed":6422,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"1":3268,"2":1025,"3":519,"4":323,"5":207,"6":163,"7":114,"8":80,"9":94,"10":68}},{"term":"https://symbiota.org/terms/recordID","rawIndexed":6427},{"term":"http://rs.tdwg.org/dwc/terms/disposition","rawIndexed":6423},{"term":"http://rs.tdwg.org/dwc/terms/infraspecificEpithet","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/georeferenceSources","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/verbatimCoordinates","rawIndexed":5240},{"term":"http://rs.tdwg.org/dwc/terms/decimalLatitude","rawIndexed":6177,"uniqueRawValues":1172,"interpretedIndexed":6178,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"-3.000283":152,"-2.230592":69,"0.831411":62,"-0.87127":65,"-3.015":68,"-1.922734":90,"-1.610411":78,"-0.599774":58,"-2.096164":67,"-1.628154":56}},{"term":"http://rs.tdwg.org/dwc/terms/verbatimEventDate","rawIndexed":5580},{"term":"http://rs.tdwg.org/dwc/terms/identificationQualifier","rawIndexed":1468},{"term":"http://rs.tdwg.org/dwc/terms/islandGroup","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/decimalLongitude","rawIndexed":6177,"uniqueRawValues":1161,"interpretedIndexed":6178,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"-76.625395":89,"-79.85844":68,"-75.988881":78,"-76.19705":56,"-75.901753":80,"-77.924998":68,"-79.952856":62,"-78.271864":58,"-77.846156":152,"-76.247968":63}},{"term":"http://rs.tdwg.org/dwc/terms/day","rawIndexed":5669,"uniqueRawValues":31,"interpretedIndexed":5667,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"1":571,"24":221,"14":206,"25":195,"17":201,"18":231,"7":191,"8":250,"20":232,"10":204}},{"term":"http://rs.tdwg.org/dwc/terms/endDayOfYear","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":5667,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"220":67,"144":72,"298":64,"244":162,"145":73,"213":73,"260":112,"294":71,"31":82,"32":100}},{"term":"http://rs.tdwg.org/dwc/terms/coordinateUncertaintyInMeters","rawIndexed":5939,"uniqueRawValues":3,"interpretedIndexed":5939,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://purl.org/dc/elements/1.1/rights","rawIndexed":6427},{"term":"http://rs.tdwg.org/dwc/terms/reproductiveCondition","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/taxonRank","rawIndexed":6416},{"term":"http://rs.tdwg.org/dwc/terms/dataGeneralizations","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/establishmentMeans","rawIndexed":6380,"uniqueRawValues":3,"interpretedIndexed":6380,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"[introduced,WrappedArray(introduced)]":47,"[native,WrappedArray(native)]":2762,"[uncertain,WrappedArray(uncertain)]":3571}},{"term":"http://rs.tdwg.org/dwc/terms/genus","rawIndexed":6396,"uniqueRawValues":403,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/dynamicProperties","rawIndexed":148},{"term":"http://rs.tdwg.org/dwc/terms/maximumElevationInMeters","rawIndexed":193,"uniqueRawValues":40,"interpretedIndexed":193,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"182.0":12,"228.0":9,"183.0":8,"184.0":8,"240.0":18,"297.0":10,"230.0":8,"174.0":9,"224.0":16,"168.0":14}},{"term":"http://rs.tdwg.org/dwc/terms/otherCatalogNumbers","rawIndexed":636},{"term":"http://rs.tdwg.org/dwc/terms/georeferenceProtocol","rawIndexed":1605},{"term":"https://symbiota.org/terms/recordEnteredBy","rawIndexed":6423},{"term":"http://purl.org/dc/terms/rightsHolder","rawIndexed":6427},{"term":"http://rs.tdwg.org/dwc/terms/occurrenceID","rawIndexed":6427,"uniqueRawValues":6427,"interpretedIndexed":6427,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"9a4174ff-8a82-4c65-84d3-ff498aa48b8a":1,"01898229-e97f-46e0-b33f-8d3d7027e76a":1,"9ec3f92c-bbfd-4106-8cf1-f2e0db4b7d90":1,"635b74b5-69eb-427e-a2e0-0b16c1f78524":1,"34bdce0e-93ee-41fa-b282-25fdcf5f2189":1,"f8ec72a4-107a-44b3-815d-8fec87a59425":1,"70ce25b4-51d7-4753-9f41-ce752b84f36c":1,"fe313b27-54f4-48fa-a6c6-6d68330a2331":1,"b9e2167a-8ff4-42bf-bdf5-1890d49ff60f":1,"67dbb0fa-0f03-4462-b254-2821fa0def89":1}},{"term":"http://rs.tdwg.org/dwc/terms/habitat","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/locality","rawIndexed":5914,"uniqueRawValues":859,"interpretedIndexed":5914,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"Tonchigüe":77,"Parque Nacional Yasuní":84,"Bocana Yaupi":152,"Tiputini-Tambococha":76,"Río Shiripuno":88,"Zancudococha":73,"Cuyabeno":70,"Chiruisla":124,"Kawoa":88,"Bobonaza":144}},{"term":"http://rs.tdwg.org/dwc/terms/higherClassification","rawIndexed":6420},{"term":"http://rs.tdwg.org/dwc/terms/verbatimTaxonRank","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/georeferenceVerificationStatus","rawIndexed":6177},{"term":"http://rs.tdwg.org/dwc/terms/scientificName","rawIndexed":6421},{"term":"http://rs.tdwg.org/dwc/terms/island","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/verbatimDepth","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/institutionCode","rawIndexed":6427,"uniqueRawValues":1,"interpretedIndexed":6427,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"INABIOEC":6427}},{"term":"http://rs.tdwg.org/dwc/terms/subgenus","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/waterBody","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/kingdom","rawIndexed":6420,"uniqueRawValues":1,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/phylum","rawIndexed":6420,"uniqueRawValues":1,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/dateIdentified","rawIndexed":6243,"uniqueRawValues":201,"interpretedIndexed":6243,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"2007":228,"2017":314,"2017-06":275,"2016":367,"2005":217,"2014":198,"2012":152,"2011":288,"2022":200,"2021":186}},{"term":"http://rs.tdwg.org/dwc/terms/identificationRemarks","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/locationRemarks","rawIndexed":4952},{"term":"http://purl.org/dc/terms/modified","rawIndexed":6427,"uniqueRawValues":22,"interpretedIndexed":6427,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"2025-11-03T15:20:41":181,"2025-11-03T15:20:40":184,"2025-11-03T15:20:42":205,"2025-11-03T15:20:34":185,"2022-01-03T10:44:08":179,"2025-11-03T15:20:36":185,"2025-11-03T15:20:38":186,"2020-01-08T16:10:25":4124,"2025-11-03T15:20:37":173,"2025-11-03T15:20:39":183}},{"term":"http://rs.tdwg.org/dwc/terms/associatedTaxa","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/georeferenceRemarks","rawIndexed":6177},{"term":"http://rs.tdwg.org/dwc/terms/taxonRemarks","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/geodeticDatum","rawIndexed":5707},{"term":"http://rs.tdwg.org/dwc/terms/occurrenceStatus","rawIndexed":6427,"uniqueRawValues":1,"interpretedIndexed":6427,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"PRESENT":6427}},{"term":"http://rs.tdwg.org/dwc/terms/recordNumber","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/continent","rawIndexed":6423,"uniqueRawValues":1,"interpretedIndexed":6410,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"SOUTH_AMERICA":6410}},{"term":"http://rs.tdwg.org/dwc/terms/minimumDepthInMeters","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/municipality","rawIndexed":4052},{"term":"http://rs.tdwg.org/dwc/terms/minimumElevationInMeters","rawIndexed":4521,"uniqueRawValues":506,"interpretedIndexed":4521,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"237.0":61,"300.0":59,"290.0":59,"1585.0":65,"200.0":104,"210.0":63,"260.0":98,"240.0":106,"230.0":64,"235.0":149}},{"term":"http://rs.tdwg.org/dwc/terms/identifiedBy","rawIndexed":6418,"uniqueRawValues":41,"interpretedIndexed":6427,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"Jonathan Santiago Valdiviezo Rivera,Pablo Arguello,Daysi Carina Gualavisi Cajas,Juan Luis Valdiviezo Rivera,Evelyn Calvache,Paul Regalado":144,"Jonathan Santiago Valdiviezo Rivera,Daysi Carina Gualavisi Cajas,Juan Luis Valdiviezo Rivera":1607,"Jonathan Santiago Valdiviezo Rivera,Daysi Carina Gualavisi Cajas":435,"Jonathan Santiago Valdiviezo Rivera":1604,"Francisco Provenzano Rizzi":257,"Carolina Michelle Carrillo Moreno":154,"Jonathan Santiago Valdiviezo Rivera,Fernando Anaguano Yancha":219,"Jonathan Santiago Valdiviezo Rivera,Catalina Suquillo,Daysi Carina Gualavisi Cajas":728,"Windsor Aguirre":286,"Juan Francisco Rivadeneira":543}},{"term":"http://rs.tdwg.org/dwc/terms/eventDate","rawIndexed":5903,"uniqueRawValues":916,"interpretedIndexed":5901,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"2011-10-21T00:00":49,"2005-09-01T00:00":77,"2007-09-17T00:00":110,"2016-02-01T00:00":92,"2022-03-01T00:00":58,"2021-09-01T00:00":71,"2022-05-01T00:00":80,"2011-09-01T00:00":78,"2011-12-14T00:00":52,"2016-01-31T00:00":71}},{"term":"http://rs.tdwg.org/dwc/terms/collectionCode","rawIndexed":6427},{"term":"http://rs.tdwg.org/dwc/terms/year","rawIndexed":5903,"uniqueRawValues":51,"interpretedIndexed":5901,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"2009":317,"2008":347,"2007":662,"2005":344,"2016":308,"2013":246,"2023":242,"2011":542,"2022":362,"2010":338}},{"term":"http://rs.tdwg.org/dwc/terms/georeferencedBy","rawIndexed":3501},{"term":"http://rs.tdwg.org/dwc/terms/family","rawIndexed":6421,"uniqueRawValues":110,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/county","rawIndexed":4629},{"term":"http://rs.tdwg.org/dwc/terms/occurrenceRemarks","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/eventID","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/associatedSequences","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/collectionID","rawIndexed":6427},{"term":"http://rs.tdwg.org/dwc/terms/catalogNumber","rawIndexed":6427},{"term":"http://rs.tdwg.org/dwc/terms/sex","rawIndexed":6232,"uniqueRawValues":3,"interpretedIndexed":6232,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"[Indeterminate,WrappedArray(Indeterminate)]":6229,"[Female,WrappedArray(Female)]":2,"[Mixed,WrappedArray(Mixed)]":1}},{"term":"http://rs.tdwg.org/dwc/terms/country","rawIndexed":6423,"uniqueRawValues":3,"interpretedIndexed":6423,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"Ecuador":6410,"Peru":11,"Venezuela (Bolivarian Republic of)":2}},{"term":"http://purl.org/dc/terms/language","rawIndexed":6423},{"term":"http://rs.tdwg.org/dwc/terms/class","rawIndexed":6420,"uniqueRawValues":2,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/order","rawIndexed":6420,"uniqueRawValues":33,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/stateProvince","rawIndexed":6417,"uniqueRawValues":27,"interpretedIndexed":6417,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"Carchi":108,"Sucumbíos":1647,"Orellana":981,"Pichincha":382,"El Oro":331,"Morona Santiago":751,"Pastaza":1000,"Napo":131,"Imbabura":104,"Esmeraldas":511}},{"term":"http://purl.org/dc/terms/references","rawIndexed":6427,"uniqueRawValues":6427,"interpretedIndexed":6427,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"https://localhost/bndb/collections/individual/index.php?occid=680995":1,"https://localhost/bndb/collections/individual/index.php?occid=678622":1,"https://localhost/bndb/collections/individual/index.php?occid=677642":1,"https://localhost/bndb/collections/individual/index.php?occid=1840818":1,"https://localhost/bndb/collections/individual/index.php?occid=679982":1,"https://localhost/bndb/collections/individual/index.php?occid=677332":1,"https://localhost/bndb/collections/individual/index.php?occid=1839713":1,"https://localhost/bndb/collections/individual/index.php?occid=680888":1,"https://localhost/bndb/collections/individual/index.php?occid=678739":1,"https://localhost/bndb/collections/individual/index.php?occid=677804":1}},{"term":"http://rs.tdwg.org/dwc/terms/startDayOfYear","rawIndexed":5669,"uniqueRawValues":337,"interpretedIndexed":5667,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"220":67,"144":72,"298":64,"244":162,"145":73,"213":73,"260":112,"294":71,"31":82,"32":100}},{"term":"http://rs.tdwg.org/dwc/terms/fieldNumber","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/locationID","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/identificationReferences","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/maximumDepthInMeters","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/ownerInstitutionCode","rawIndexed":6427},{"term":"http://rs.tdwg.org/dwc/terms/lifeStage","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/verbatimElevation","rawIndexed":0},{"term":"http://rs.tdwg.org/dwc/terms/typeStatus","rawIndexed":2,"uniqueRawValues":1,"interpretedIndexed":2,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/minimumDistanceAboveSurfaceInMeters","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/maximumDistanceAboveSurfaceInMeters","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/coordinatePrecision","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/organismQuantity","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/organismQuantityType","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/sampleSizeUnit","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/sampleSizeValue","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/organismID","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/samplingProtocol","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":6427,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"":6427}},{"term":"http://rs.tdwg.org/dwc/terms/parentEventID","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":0,"uniqueInterpretedValues":0,"sampleInterpretedValuesMap":{}},{"term":"http://rs.tdwg.org/dwc/terms/countryCode","rawIndexed":0,"uniqueRawValues":0,"interpretedIndexed":6423,"uniqueInterpretedValues":1,"sampleInterpretedValuesMap":{"PE":11,"EC":6410,"VE":2}}],"issues":[{"issue":"COLLECTION_MATCH_NONE","issueCategory":"OCC_INTERPRETATION_BASED","count":6427,"samples":[{"recordId":"1839641","relatedData":{"dwc:collectionID":"b636a8df-9e83-45fe-a0ae-dacfbb36c300","dwc:collectionCode":"MECN-DP"}},{"recordId":"1839642","relatedData":{"dwc:collectionID":"b636a8df-9e83-45fe-a0ae-dacfbb36c300","dwc:collectionCode":"MECN-DP"}},{"recordId":"1839643","relatedData":{"dwc:collectionID":"b636a8df-9e83-45fe-a0ae-dacfbb36c300","dwc:collectionCode":"MECN-DP"}},{"recordId":"1839644","relatedData":{"dwc:collectionID":"b636a8df-9e83-45fe-a0ae-dacfbb36c300","dwc:collectionCode":"MECN-DP"}},{"recordId":"1839645","relatedData":{"dwc:collectionID":"b636a8df-9e83-45fe-a0ae-dacfbb36c300","dwc:collectionCode":"MECN-DP"}}]},{"issue":"CONTINENT_COORDINATE_MISMATCH","issueCategory":"OCC_INTERPRETATION_BASED","count":13,"samples":[{"recordId":"680869","relatedData":{}},{"recordId":"680873","relatedData":{}},{"recordId":"680875","relatedData":{}},{"recordId":"680882","relatedData":{}},{"recordId":"680890","relatedData":{}}]},{"issue":"COORDINATE_INVALID","issueCategory":"OCC_INTERPRETATION_BASED","count":11,"samples":[{"recordId":"1840365","relatedData":{"dwc:verbatimCoordinates":"-0.072489 -78,213,042"}},{"recordId":"680913","relatedData":{"dwc:verbatimCoordinates":"78.28°W / 01.27°N / 00.01°S"}},{"recordId":"680914","relatedData":{"dwc:verbatimCoordinates":"78.28°W / 01.27°N / 00.01°S"}},{"recordId":"680915","relatedData":{"dwc:verbatimCoordinates":"78.28°W / 01.27°N / 00.01°S"}},{"recordId":"680916","relatedData":{"dwc:verbatimCoordinates":"78.28°W / 01.27°N / 00.01°S"}}]},{"issue":"COORDINATE_OUT_OF_RANGE","issueCategory":"OCC_INTERPRETATION_BASED","count":54,"samples":[{"recordId":"1839775","relatedData":{"dwc:verbatimCoordinates":"24581/99445991"}},{"recordId":"1840020","relatedData":{"dwc:verbatimCoordinates":"0018521/0733457"}},{"recordId":"1840023","relatedData":{"dwc:verbatimCoordinates":"0002484/784064"}},{"recordId":"1840024","relatedData":{"dwc:verbatimCoordinates":"2856.80/763529.02"}},{"recordId":"1840025","relatedData":{"dwc:verbatimCoordinates":"14807.33/759887.35"}}]},{"issue":"COUNTRY_COORDINATE_MISMATCH","issueCategory":"OCC_INTERPRETATION_BASED","count":6,"samples":[{"recordId":"1840780","relatedData":{"dwc:decimalLatitude":"-5.063108","dwc:decimalLongitude":"-76.777627","dwc:verbatimCoordinates":"302930/9440090","dwc:geodeticDatum":"WGS84","dwc:country":"Ecuador"}},{"recordId":"680691","relatedData":{"dwc:decimalLatitude":"-5.063108","dwc:decimalLongitude":"-76.777627","dwc:verbatimCoordinates":"302930 / 9440090","dwc:geodeticDatum":"WGS84","dwc:country":"Ecuador"}},{"recordId":"680692","relatedData":{"dwc:decimalLatitude":"-5.063108","dwc:decimalLongitude":"-76.777627","dwc:verbatimCoordinates":"302930 / 9440090","dwc:geodeticDatum":"WGS84","dwc:country":"Ecuador"}},{"recordId":"680693","relatedData":{"dwc:decimalLatitude":"-5.063108","dwc:decimalLongitude":"-76.777627","dwc:verbatimCoordinates":"302930 / 9440090","dwc:geodeticDatum":"WGS84","dwc:country":"Ecuador"}},{"recordId":"680694","relatedData":{"dwc:decimalLatitude":"-5.063108","dwc:decimalLongitude":"-76.777627","dwc:verbatimCoordinates":"302930 / 9440090","dwc:geodeticDatum":"WGS84","dwc:country":"Ecuador"}}]},{"issue":"GEODETIC_DATUM_ASSUMED_WGS84","issueCategory":"OCC_INTERPRETATION_BASED","count":471,"samples":[{"recordId":"1839990","relatedData":{}},{"recordId":"1839991","relatedData":{}},{"recordId":"1839992","relatedData":{}},{"recordId":"1839993","relatedData":{}},{"recordId":"1839994","relatedData":{}}]},{"issue":"INSTITUTION_MATCH_FUZZY","issueCategory":"OCC_INTERPRETATION_BASED","count":6427,"samples":[{"recordId":"1839641","relatedData":{"dwc:institutionCode":"INABIOEC","dwc:ownerInstitutionCode":"INABIO"}},{"recordId":"1839642","relatedData":{"dwc:institutionCode":"INABIOEC","dwc:ownerInstitutionCode":"INABIO"}},{"recordId":"1839643","relatedData":{"dwc:institutionCode":"INABIOEC","dwc:ownerInstitutionCode":"INABIO"}},{"recordId":"1839644","relatedData":{"dwc:institutionCode":"INABIOEC","dwc:ownerInstitutionCode":"INABIO"}},{"recordId":"1839645","relatedData":{"dwc:institutionCode":"INABIOEC","dwc:ownerInstitutionCode":"INABIO"}}]},{"issue":"PRESUMED_NEGATED_LATITUDE","issueCategory":"OCC_INTERPRETATION_BASED","count":6,"samples":[{"recordId":"1840167","relatedData":{"dwc:decimalLatitude":"0.43938","dwc:decimalLongitude":"-76.629934"}},{"recordId":"1840219","relatedData":{"dwc:decimalLatitude":"0.67541","dwc:decimalLongitude":"-76.42361"}},{"recordId":"1840744","relatedData":{"dwc:decimalLatitude":"0.91139","dwc:decimalLongitude":"-77.92565"}},{"recordId":"1840770","relatedData":{"dwc:decimalLatitude":"0.91139","dwc:decimalLongitude":"-77.92565"}},{"recordId":"1840774","relatedData":{"dwc:decimalLatitude":"0.62119","dwc:decimalLongitude":"-75.82578"}}]},{"issue":"RECORDED_DATE_UNLIKELY","issueCategory":"OCC_INTERPRETATION_BASED","count":2,"samples":[{"recordId":"1840780","relatedData":{"dwc:startDayOfYear":"291","dwc:eventDate":"2027-10-18","dwc:year":"2027","dwc:month":"10","dwc:day":"18"}},{"recordId":"1840783","relatedData":{"dwc:startDayOfYear":"289","dwc:eventDate":"2027-10-16","dwc:year":"2027","dwc:month":"10","dwc:day":"16"}}]},{"issue":"TAXON_ID_NOT_FOUND","issueCategory":"OCC_INTERPRETATION_BASED","count":5568,"samples":[{"recordId":"1839641","relatedData":{"dwc:taxonID":"35408"}},{"recordId":"1839642","relatedData":{"dwc:taxonID":"35976"}},{"recordId":"1839643","relatedData":{"dwc:taxonID":"35957"}},{"recordId":"1839644","relatedData":{"dwc:taxonID":"35408"}},{"recordId":"1839645","relatedData":{"dwc:taxonID":"35269"}}]},{"issue":"TAXON_MATCH_FUZZY","issueCategory":"OCC_INTERPRETATION_BASED","count":61,"samples":[{"recordId":"1839796","relatedData":{"dwc:class":"Actinopterygii","dwc:genus":"Trichomycterus","dwc:phylum":"Chordata","dwc:family":"Trichomycteridae","dwc:kingdom":"Animalia","dwc:scientificName":"Trichomycterus taczonowskii","dwc:specificEpithet":"taczonowskii","dwc:order":"Siluriformes"}},{"recordId":"1839912","relatedData":{"dwc:class":"Actinopterygii","dwc:genus":"Sorubumichthys","dwc:phylum":"Chordata","dwc:scientificNameAuthorship":"Spix & Agassiz, 1829","dwc:family":"Pimelodidae","dwc:kingdom":"Animalia","dwc:scientificName":"Sorubumichthys planiceps","dwc:specificEpithet":"planiceps","dwc:order":"Siluriformes"}},{"recordId":"1839988","relatedData":{"dwc:class":"Actinopterygii","dwc:genus":"Imparfinis","dwc:phylum":"Chordata","dwc:scientificNameAuthorship":"(Boulenger, 1887)","dwc:family":"Heptapteridae","dwc:kingdom":"Animalia","dwc:scientificName":"Imparfinis longicauda","dwc:specificEpithet":"longicauda","dwc:order":"Siluriformes"}},{"recordId":"1840158","relatedData":{"dwc:class":"Actinopterygii","dwc:genus":"Farlowella","dwc:phylum":"Chordata","dwc:scientificNameAuthorship":"(Kner, 1853)","dwc:family":"Loricariidae","dwc:kingdom":"Animalia","dwc:scientificName":"Farlowella oxyrhyncha","dwc:specificEpithet":"oxyrhyncha","dwc:order":"Siluriformes"}},{"recordId":"1840250","relatedData":{"dwc:class":"Actinopterygii","dwc:genus":"Cynoponthicus","dwc:phylum":"Chordata","dwc:scientificNameAuthorship":"(Jordan & Gilbert, 1882)","dwc:family":"Muraenesocidae","dwc:kingdom":"Animalia","dwc:scientificName":"Cynoponthicus coniceps","dwc:specificEpithet":"coniceps","dwc:order":"Anguilliformes"}}]},{"issue":"TAXON_MATCH_HIGHERRANK","issueCategory":"OCC_INTERPRETATION_BASED","count":24,"samples":[{"recordId":"1839654","relatedData":{"dwc:class":"Actinopterygii","dwc:genus":"Eretmobrycon","dwc:phylum":"Chordata","dwc:scientificNameAuthorship":"(Román-Valencia, 2000)","dwc:family":"Characidae","dwc:kingdom":"Animalia","dwc:scientificName":"Eretmobrycon dahli","dwc:specificEpithet":"dahli","dwc:order":"Characiformes"}},{"recordId":"1839659","relatedData":{"dwc:class":"Actinopterygii","dwc:genus":"Eretmobrycon","dwc:phylum":"Chordata","dwc:scientificNameAuthorship":"(Román-Valencia, 2000)","dwc:family":"Characidae","dwc:kingdom":"Animalia","dwc:scientificName":"Eretmobrycon dahli","dwc:specificEpithet":"dahli","dwc:order":"Characiformes"}},{"recordId":"1839673","relatedData":{"dwc:class":"Actinopterygii","dwc:genus":"Eretmobrycon","dwc:phylum":"Chordata","dwc:scientificNameAuthorship":"(Román-Valencia, 2000)","dwc:family":"Characidae","dwc:kingdom":"Animalia","dwc:scientificName":"Eretmobrycon dahli","dwc:specificEpithet":"dahli","dwc:order":"Characiformes"}},{"recordId":"1839685","relatedData":{"dwc:class":"Actinopterygii","dwc:genus":"Eretmobrycon","dwc:phylum":"Chordata","dwc:scientificNameAuthorship":"(Román-Valencia, 2000)","dwc:family":"Characidae","dwc:kingdom":"Animalia","dwc:scientificName":"Eretmobrycon dahli","dwc:specificEpithet":"dahli","dwc:order":"Characiformes"}},{"recordId":"1839782","relatedData":{"dwc:class":"Actinopterygii","dwc:genus":"Eretmobrycon","dwc:phylum":"Chordata","dwc:family":"Characidae","dwc:kingdom":"Animalia","dwc:scientificName":"Eretmobrycon dahli","dwc:specificEpithet":"dahli","dwc:order":"Characiformes"}}]},{"issue":"TAXON_MATCH_NONE","issueCategory":"OCC_INTERPRETATION_BASED","count":6,"samples":[{"recordId":"677607","relatedData":{}},{"recordId":"677645","relatedData":{}},{"recordId":"677769","relatedData":{}},{"recordId":"678101","relatedData":{}},{"recordId":"678112","relatedData":{}}]}]}]}}

revisaste que los parches taxonomicos pero no se si revisaste ese bloque json que me mandaste hace rato o ese "Un detalle cosmético que sí hay que arreglar: la consola imprimió `filas reclasificadas por el parche 12b: NA`. Es mi `cat()`, no el parche: comparo contra `precision_verbatim` recalculado y esa función devuelve `NA` en las filas sin verbatim, así que el `sum()` propaga NA. Reemplaza esas tres líneas por:"
osea aplique tus correcciones de validacion de plausibilidad y uniridentifications con respecto a este ultimo osea mi criterio es correcto al unirlos no tiene sentido  tenerlos separados si hay argumentos para ello?
por cierto quiero hacer el dasboard del que hablo el ing
"En la reunión del 28 de julio, Ing. Guevara no le da nombre formal propio — lo describe como el "símil" de lo que hace Open Refine, pero construido en Power BI. Es decir, no es uno de los 5-6 dashboards finales de KPIs para INABIO; es un dashboard de control de calidad de datos, interno, que ustedes usan durante la limpieza (OE2), antes de llegar al modelo dimensional.
Qué es
Un tablero operativo/táctico que muestra el estado de curación del dataset en tiempo real, funcionando como el equivalente visual de las "facetas" de Open Refine (que cuentan cuántos valores caen en cada categoría/error), pero hecho con Power Query + DAX sobre el propio dataset ictiológico.
Para qué sirve (tal como lo explica en la reunión)

* Nadie tiene 100% de calidad — este tablero cuantifica cuánto falta.
* Permite decidir dónde priorizar limpieza (taxonómico, geográfico, multimedia).
* Es la base para la bandera (flagging) de registros: "por revisar", "sin validar país", "sin georreferencia", etc.

Qué debería mostrar (según lo que pide en la sesión)

* Total de registros (tarjeta) vs. registros con errores por categoría.
* Desagregación en cascada: válido taxonómicamente → de esos, válido geográficamente → de esos, con multimedia.
* Indicador de completitud/consistencia por campo Darwin Core.
* Conteo de duplicados, valores en blanco, inconsistencias de formato (fecha, codificación de caracteres)."

aca tienes una conversacion con gemini de como se hizo pero no se creo que mas bien en lugar de enfocarse a los reportes deberia ser a las preguntas del dudas.md osea mostrar visualmente como va la limpieza y tambien tener objetos orientados a las preguntas como soporte ah por cierto supongo que con esto podemos dar por cerrada la limpieza cierto compara los hallazgos con el dudas.md y mandame las preguntas que toque editar/agregar/quitar para que lo haga el antigravity por cierto la idea es que el dashboard puede le pueda seguir haciendo modificaciones a las fuentes osea seguir limpiando volver a cargar las consultas y ver el cambio si puedes redactarlo como prompt para gemini para hacerle mañana fuera el exito

---

# claude response

Verifiqué todo lo aplicado y además leí el reporte del validador de GBIF, que es la noticia grande de esta ronda. Voy por partes.

---

# 1. Lo que preguntas: sí, revisé ambos

| Parche | Estado |
|---|---|
| **JSON OpenRefine (§E)** | ✅ `min.` = **0** (59 `min` limpios) · `99,4` = **0**, `99.4 km` = **2** · `P.A. Buckup` → `P. A. Buckup` (61) · `M.E./M.G. Sánchez` → separadas (7) · `2.5 m.` **intacto** (6) · `A.E.`, `M.O.`, `T.N.`, `G.M.W.` **sin tocar** (69/69/69/11) |
| **12b `cat()`** | ✅ imprime **32**, no `NA`. Son las 28 que cambian de valor más 4 que cambian de etiqueta sin cambiar de piso |
| **Unión** | ✅ `identificationQualifier` = 1.468 (no importó los 21) · `sp.` sobre binomio **29, no 45** · `previousIdentifications` = 23 · autorías = 5.876 · partición cerrada 63 = 23 + 45 · **`modified_identifications` guardada** |
| **Plausibilidad** | ✅ las 5 reglas nuevas dentro, verificadas fuera, resumen con `casos`, `taxonID` colapsado a una regla (842), jerarquía colapsada (96) |

Una nota sobre el conteo del oficio: la unión dice «casos enviados: 66» y la partición «45 al oficio». No es contradicción — 45 son diferencias de nombre y 21 son los cualificadores que ahora se derivan en lugar de importarse. Está bien, pero conviene que el CSV pendiente lleve una columna `tipo` (`nombre` / `cualificador`), porque son dos preguntas distintas para Yáñez.

---

# 2. EL VALIDADOR DE GBIF: el `meta.xml` está resuelto

`status: FINISHED · indexeable: true · count 6427 · indexedCount 6427`. Y lo más importante: **los términos ahora mapean bien**. `recordedBy` devuelve nombres de personas, `preparations` devuelve preparaciones, `institutionCode` devuelve INABIOEC. El desplazamiento de índice que invalidaba el reporte anterior **ya no está**. Ese era el último bloqueo del DwCA.

Y los tres términos que faltaban viajan: `previousIdentifications` 23, `occurrenceStatus` 6.427 PRESENT, `continent` 6.423.

## 2.1 Triangulación: cada aviso de GBIF tiene contraparte propia

Esto es material directo para el Capítulo IV. No hay una sola sorpresa:

| Aviso de GBIF | n | Bandera propia | n |
|---|---|---|---|
| `TAXON_ID_NOT_FOUND` | 5.568 | `taxonID` poblado | **5.568** ✔ |
| `INSTITUTION_MATCH_FUZZY` | 6.427 | K6 | 6.427 ✔ |
| `COLLECTION_MATCH_NONE` | 6.427 | K2 | 6.427 ✔ |
| `GEODETIC_DATUM_ASSUMED_WGS84` | 471 | con coordenada y sin datum | 470 (+1) ✔ |
| `COORDINATE_INVALID` + `COORDINATE_OUT_OF_RANGE` | 11 + 54 = **65** | `irreparable` con verbatim | **66** ✔ |
| `COUNTRY_COORDINATE_MISMATCH` | 6 | lote −5.063108 (H2/B2) | 5 (+1) ✔ |
| `PRESUMED_NEGATED_LATITUDE` | 6 | `discordante` (3 además `signo_ambiguo`) | **6/6** ✔ |
| `CONTINENT_COORDINATE_MISMATCH` | 13 | L6, previsto y documentado | 13 ✔ |
| `RECORDED_DATE_UNLIKELY` | 2 | `eventDate` 2027 (B2) | 2 ✔ |

**Cero avisos sin contraparte.** Puedes escribirlo así en la discusión: la batería propia no solo reprodujo el juicio del validador externo, lo anticipó con el detalle del motivo, que GBIF no da.

Y hay una asimetría a tu favor: de las 66 coordenadas que declaramos irrecuperables, **GBIF recuperó exactamente una** (`interpretedIndexed` 6.178 frente a nuestras 6.177) y descartó 65. O sea, nuestro criterio conservador coincide con el suyo en el 98,5 % y solo perdimos un punto por ser más estrictos.

## 2.2 Lo que mejoró y se puede medir

| | Reporte anterior | Ahora |
|---|---|---|
| `TAXON_MATCH_FUZZY` | 74 | **61** |
| `TAXON_MATCH_HIGHERRANK` | 29 | **24** |
| `TAXON_MATCH_NONE` | 7 | **6** |

Esa caída es el efecto medible de las correcciones de grafía de género. Es tu indicador de antes/después para OE2, y viene de una herramienta externa: vale más que cualquier métrica interna.

## 2.3 Tres cosas nuevas que salen del validador

1. **`eml.xml`: `RESOURCE_CONTACTS_MISSING_OR_INCOMPLETE`.** Único hallazgo de metadatos. No es dato, es el EML: falta contacto del recurso con nombre, rol y correo. Se arregla en el IPT/metadatos en cinco minutos y es lo único que separa el archivo de estar impecable en esa categoría.
2. **`countryCode` lo deriva GBIF solo** (6.423: EC 6.410, PE 11, VE 2) y `country` «Perú» lo resolvió a «Peru». Retira esa recomendación mía de la lista: no hace falta añadir la columna, aunque declararla explícitamente sigue siendo mejor práctica.
3. **`endDayOfYear` lo deriva GBIF en 5.667 filas.** B6 queda cerrado sin acción, tal como preveías.
4. **`dcterms:modified` con 22 valores únicos y 4.124 filas en `2020-01-08T16:10:25`.** El validador acaba de publicar la prueba del sello congelado. Úsalo como evidencia del hallazgo de CDC.

---

# 3. ¿Unir o mantener separado `identifications`?

**Tu criterio es correcto**, y hay tres argumentos duros a favor:

1. **Es una relación 1:1, no una jerarquía.** 6.427 filas, 6.427 `coreid` distintos, cero redeterminaciones múltiples. En Kimball una tabla 1:1 con la tabla base no es una dimensión: es un conjunto de atributos degenerados que se colapsan. Modelarla aparte te obliga a una clave sustituta que no discrimina nada.
2. **Su cobertura es peor en todo**: 4.299 géneros frente a 6.396, 3.229 epítetos frente a 5.160, `taxonRank` y `infraspecificEpithet` vacíos al 100 %. Publicarla como extensión DwC duplicaría la taxonomía del core con datos inferiores y añadiría 463 NBSP y 271 placeholders al archivo publicado.
3. **El aporte real cabe en cuatro columnas**: 803 autorías, 23 `previousIdentifications`, una determinación (4322) y el `modified`. Es 1,3 % del contenido de la tabla.

Pero hay **tres argumentos en contra que te van a plantear en la defensa**, y conviene que los tengas respondidos antes:

- **«¿Y si mañana el portal exporta el historial completo?»** El modelo unido no lo soporta: `previousIdentifications` es texto concatenado, no una tabla. **Respuesta: declara una dimensión Determinación en el modelo dimensional aunque hoy tenga cardinalidad 1:1.** Deja el hueco previsto. Es mucho más barato que rehacer el DW cuando aparezca el historial.
- **«Darwin Core tiene una extensión de identificaciones; descartarla es una decisión de publicación.»** Cierto, y hay que justificarla en la memoria del DwCA con las cifras del punto 2, no solo en la tesis.
- **«Al unir, `scientificNameAuthorship` mezcla dos procedencias.»** Hoy se distinguen por `metodo_correccion_taxon`, que es columna interna y **no viaja al DwCA**. Si alguien pregunta de dónde salieron 803 autorías, la respuesta vive solo en tu CSV intermedio. Considera anotarlo también en `identificationRemarks`, que está vacío al 100 % y es el término que existe justo para eso.

---

# 4. ¿Está cerrada la limpieza?

**La parte automatizable, sí.** Cuatro etapas con la misma invariante sostenida: cero correcciones silenciosas, cero imputación, verbatim preservado, y el juicio de un validador externo reproducido íntegro.

Lo que queda no es limpieza, son tres cosas de otra naturaleza:

| | Qué es | Cuánto |
|---|---|---|
| **Autoridad curatorial** | El oficio a Yáñez | 411 registros con hallazgo `alta`, 149 casos |
| **Configuración del portal** | localhost, GRSciColl, INABIOEC/INABIO, contactos del EML | bloque K, 4 preguntas |
| **Autoridad externa que no tienes** | DPA del INEC para validar los 116 `county` y 167 `municipality` | 1 archivo |

Ese último sigue siendo el único frente detectable por máquina que no puedes cerrar solo. Pídelo en el mismo oficio.

---

# 5. EDICIONES A `Dudas.md` PARA ANTIGRAVITY

## 5.1 QUITAR — resuelto, ya no es duda

| Bloque | Motivo |
|---|---|
| **F11** (`Carcharthinus`) | corregido en el script; queda como línea de bitácora, no como pregunta |
| **F4**, los casos `Paradon`→`Parodon` y `Amphyocharax`→`Aphyocharax` | corregidos por el criterio del bloque 4a |
| **B6** (`endDayOfYear`) | GBIF lo deriva de `eventDate` en 5.667 filas. Cerrado sin acción |
| **L7** (`occurrenceStatus` no viaja) | ya viaja: 6.427 PRESENT en el validador |
| Nota del `meta.xml` desplazado | resuelto; el validador mapea los términos correctamente |

## 5.2 CORREGIR — la cifra o el planteamiento están mal

| Bloque | Cambio |
|---|---|
| **H1** | «33 registros de Sucumbíos» → **40 filas dentro de un metro del mismo punto**: 36 Sucumbíos, 2 Orellana, 1 Bolívar, 1 Esmeraldas. Rango de catálogo **5185–5658**, no es lote contiguo. 38 de las 40 sin `locality` ni `county` |
| **D1** | El punto `−0,871270 / −79,858440` lo comparten **65 filas de cuatro provincias** (Esmeraldas 62, Orellana 1, Pichincha 1, Bolívar 1), no 62 de Esmeraldas. Reencuadrar: no es un signo invertido, es **un punto por defecto** |
| **H3** | De pregunta a confirmación: el 4195 comparte verbatim exacto con 4180, 4181, 4182, 4190 y 4200 salvo el grado de longitud (**90 en vez de 80**). Los cinco declaran Manabí y caen en Manabí. **La provincia está bien; la coordenada no** |
| **D6bis, punto 3** | El 4187 comparte la latitud hasta el centésimo de segundo con el 4201 (`01°40'45.551'' / 91°59'53.448''`, isla Darwin). **71° es 91°**, misma sustitución de dígito que el 4195 |
| **D4** | Reescribir: **tres de los cinco grupos los resuelve el archivo**. `4184` = `0.75''` (los hermanos 4196–4198 traen la longitud idéntica) · `4151` = `07.3''` (hermanos 4149 y 4150 en el mismo minuto 34') · **Bobonaza, 7 filas**: `01°92'` es `01°52'`, la serie va de 43' a 52' y 5904–5906 están en `01°52'57.2''`. Siguen abiertos solo `4212/4213` y `3765` |
| **F12** | Reescribir entero. **No es «se documenta, no se corrige»**: son dos registros defectuosos. Haemulidae: la fila rara es el **5367, `Orthropristis` es errata de `Orthopristis`**. Pomacentridae: la fila rara es el **4201, `Holacanthus` es Pomacanthidae en el backbone**. Dos preguntas concretas |
| **J1** | Actualizar cifras con el espacio duro corregido: **63 nombres distintos** (no 88), **23 previas + 45 al oficio**. «Misma fecha» baja de 38 a **9**. Y el **3766/3767 deja de ser duda**: el `tidInterpreted` está intercambiado exactamente igual que el nombre (3766: core 35266 / ident 36078; 3767 al revés). Es desalineamiento probado, no redeterminación |
| **D9** | 470 → **471** según el validador |
| **E3 / E5** | `M. E. Sánchez`, `M. G. Sánchez` y `P. A. Buckup` ahora llevan espacio entre iniciales. Actualizar las grafías del oficio para que coincidan con el archivo |

## 5.3 AÑADIR — bloques nuevos

**Nuevo bloque encabezando el capítulo geográfico — reemplaza gran parte de D2:**

> **El ingreso QCAZ concentra el 72 % de las discordancias.** Los registros cuyo `recordedBy` contiene `QCAZ` (598 con coordenada) fallan la contención provincial en el **27,9 %** de los casos; el resto de la colección, en el **1,1 %**. Veinticinco veces más. 167 de las 231 discordancias están en los catálogos ≈5100–5799; en el tramo 5600–5699, 42 de cada 100 filas son discordantes y 76 de cada 100 no tienen localidad.
> **Pregunta única:** ¿cómo se cargaron esos registros? ¿Migración desde otro sistema, carga masiva sin georreferenciación propia, o punto asignado por lote?

**Añadir al bloque F o G:**
- **Catálogo 4358: holotipo sin datos de colecta.** `typeStatus = Holotype`, `stateProvince = Galápagos`, familia Haemulidae, y **sin colector, sin fecha, sin localidad, sin número de ejemplares, sin identificador**. Es uno de los dos únicos tipos de la colección. ¿Es un tipo real o un `typeStatus` mal asignado?
- **Catálogo 3944: el otro holotipo tiene la latitud en el hemisferio equivocado.** Mismos seis números en el verbatim que 3762–3764, que traen `N` explícita y salen a **+0,091267**. El portal guardó **−0,091267**. Son 20 km, y Quebrada Sune está en Pacto, Pichincha.
- **Catálogo 3765 está corrupto en dos ejes a la vez.** Ya está en J1 por contaminación taxonómica; además declara Orellana cuando sus cuatro hermanas sitúan Quebrada Sune en Pichincha/Pacto, y su sexagesimal trae 76 segundos. Unificar las dos menciones en una sola entrada.
- **Catálogo 6294**: única fila de `Parodon` con `family = Lebiasinidae` frente a cinco con `Parodontidae`.
- **29 filas con `identificationQualifier = "sp."` sobre un binomio completo.** Vienen del origen, ninguna fase las ha tocado. `sp.` significa especie indeterminada y contradice al nombre.

**Añadir al bloque C:**
- `Río Colimbo` (3142–3143) vs `Río Columbo` (1653–1655): misma provincia, mismo cantón, misma parroquia. 3 contra 2, sin mayoría que decida.
- `pozo primare` (6, cat. 290–295) vs `Pozo Pimare` (5, cat. 326–329, 394, 407): mismo pozo, Bloque 31, PN Yasuní.
- `Punta km 13+501` (cat. 5641) vs `Punta km 13+500` (13 filas), todas en Chiruisla.
- Cinco topónimos irresolubles desde el archivo: `Río Mashpi Grande y Chicho` (3394, 3397) · `Masphien` (2403) · `laguna redondo cocha` (2950–2952) · `Río átun playa cocha` (3730–3732) · `Salinas.006` (583).
- `Pod` (cat. 59) y `ECY` (5600, 5650): localidades de tres letras sin resolver.
- **Catálogo 1555**: `Río Aguarico … Pisorie` declarado en **Carchi / Tulcán / Tobar Donoso**, a más de 300 km del resto del lote Pisorie.
- **Catálogo 310**: `2.5 m. Norte Río Nashiño`. ¿Son 2,5 m o 2,5 km?

**Añadir al bloque K:**
- **`dcterms:modified` no se actualiza al redeterminar.** 4.124 filas conservan el sello `2020-01-08T16:10:25` declarando determinaciones de 2023. El portal sí registra la modificación, pero en el timestamp de la extensión `identifications` (rango 2023-10-20 → 2025-11-03, posterior al del core en 4.567 filas). **Pregunta:** ¿es comportamiento esperado del portal? Determina la marca de agua de la carga incremental del DW.
- **`eml.xml` sin contacto completo**: el validador devuelve `RESOURCE_CONTACTS_MISSING_OR_INCOMPLETE`. ¿Quién figura como contacto del recurso, con qué rol y qué correo?

**Añadir al bloque D o G:**
- **Galápagos: 24 filas con `island`, `islandGroup` y `waterBody` vacíos al 100 %**, incluidas las 9 capturas marinas. Con la coordenada ya reconstruida se pueden poblar. ¿Autorizan derivar `island` desde el polígono y declarar `waterBody`?
- **7 filas con `locality = "Varios Sitios"`** llevan un punto único con 100 m de incertidumbre; el propio texto contradice esa precisión.

## 5.4 AÑADIR UN ANEXO NUEVO — «Verificado y descartado»

Antigravity debería crear una sección al final con lo que se comprobó y **no** es error. Sirve para que nadie lo reabra y es evidencia para el Capítulo IV:

`Pacayaku` (Pastaza) vs `Pacayacu` (Sucumbíos): dos parroquias reales · `Piñacocha` (Pastaza, Río Rutuno) vs `Pañacocha` (Sucumbíos): lugares distintos · `Río Mindo` vs `Río Pindo` · `Mira` vs `Mera`: dos cantones · `Synodontidae` vs `Cynodontidae`, `Anodus` vs `Knodus`, `Conodon` vs `Cynodon`: pares reales · cantones homónimos de su provincia (387 filas, legítimos) · las 33 celdas de `scientificNameAuthorship` con `.,`: formato ICZN correcto · las 144 celdas de `recordedBy` de 200 caracteres exactos: expansión, no truncamiento.

---

# 6. EL TABLERO DE CALIDAD — prompt para Gemini

Antes del prompt, tres correcciones a lo que ya tienes montado, visibles en la captura:

1. **El gráfico «% completitud por campo y fase» está midiendo las columnas equivocadas.** Todas las barras están al 100 % porque estás despivotando las 133 columnas del archivo final, y `flag_*`, `coord_tipo`, `confianza_coordenada`, `metodo_correccion` **siempre** están pobladas. La completitud solo tiene sentido sobre los **92 términos Darwin Core**, que son los que existen en las dos fases.
2. **«% registros limpios 34,0 %» es un titular que te va a costar caro en la defensa.** Mide «sin ningún hallazgo, de cualquier severidad», y ahí entra `locality y locationRemarks idénticos`. El KPI de portada debe ser **«% de registros sin hallazgo de severidad alta» = 93,6 %** (411 de 6.427), con el 34 % como segunda medida etiquetada «sin hallazgo de ningún tipo».
3. **Falta el eje que pide Guevara y falta el que pides tú.** Él pidió cascada y flagging; tú quieres las preguntas de `Dudas.md`. Se resuelven con una sola tabla más: una dimensión `Preguntas` que enlace cada regla con el bloque del oficio.

```
=========================================================
PROMPT PARA GEMINI - TABLERO DE CONTROL DE CALIDAD (OE2)
Coleccion Ictiologica MECN-DP, INABIO
Power BI Desktop | Power Query (M) + DAX
=========================================================

CONTEXTO
Tesis de Ingenieria en Software, UTN Ibarra. Objetivo especifico
OE2: limpieza y transformacion. Esto NO es un dashboard analitico
para INABIO: es un tablero OPERATIVO INTERNO que evidencia el
control de calidad durante la curacion, el simil en Power BI de
las facetas de OpenRefine. Debe poder actualizarse: yo sigo
limpiando, regenero los CSV, pulso Actualizar y el tablero
refleja el avance sin tocar el modelo.

Ya tengo montado un primer intento con cinco consultas y modelo
en estrella. Quiero que lo revises, corrijas lo que esta mal y lo
completes. No repitas lo que ya funciona: dame el codigo M y el
DAX de lo que cambia o se anade, con la ruta de menu de Power BI
Desktop en espanol para cada paso.

FUENTES (CSV, UTF-8, separador coma)
  ocurrences_con_identifications.csv   6.427 x 133  [estado final]
  occurrences.csv                      6.427 x 92   [crudo del portal]
  reporte_plausibilidad.csv            ~4.239 filas [hechos]
  reporte_plausibilidad_resumen.csv    43 filas     [dimension Reglas]
  reporte_plausibilidad_verificadas.csv             [comprobado, no es error]
  reporte_coordenadas_revision.csv     328 filas
  identifications_para_inabio.csv      66 filas
  Dudas_bloques.csv                    [lo creo yo, ver abajo]

LO QUE HAY QUE CORREGIR DE MI VERSION ACTUAL

1. La consulta de completitud despivota las 133 columnas del
   archivo final. Debe despivotar SOLO los 92 terminos Darwin
   Core, que son los unicos presentes en las dos fases. Las
   columnas internas (flag_*, coord_tipo, confianza_coordenada,
   metodo_correccion, precision_origen, lat_final, lon_final,
   coherencia_provincia, dist_*, signo_ambiguo, dms_rango_invalido,
   *_verbatim, metodo_correccion_taxon, incertidumbre_criterio,
   piso_incertidumbre_aplicado, coordenada_compartida,
   provincia_minoritaria, hipotesis_northing, order_fishbase_informal,
   registro_incompleto, identificado_a_nivel_familia,
   modified_identifications) siempre estan pobladas y falsean el
   grafico al 100%. Dame el codigo M que filtre la lista de campos
   contra la cabecera de occurrences.csv en vez de escribir las 92
   a mano, para que siga funcionando si el esquema cambia.

2. El KPI de portada debe ser
   % registros sin hallazgo alto = 1 - (registros con severidad alta / total)
   Hoy muestro "% registros limpios 34%", que mide sin hallazgo de
   ningun tipo e incluye avisos informativos. Deja las dos medidas,
   pero la de portada es la primera y la segunda va etiquetada.

3. Anade una dimension nueva: Preguntas.
   La creo yo como Dudas_bloques.csv con estas columnas:
     bloque_dudas (A3, B1, C7, D2, F12, J1, K6...)
     titulo, destinatario (INABIO / Guevara / propio),
     estado (abierto / respondido / cerrado / verificado_no_es_error),
     n_registros_declarado
   y una tabla puente Reglas_x_Preguntas (regla, bloque_dudas),
   porque una regla puede alimentar dos bloques y un bloque puede
   alimentarse de varias reglas. Dame el modelo con esa puente
   resuelta sin generar ambiguedad de filtro.

QUE TIENE QUE MOSTRAR, EN TRES PAGINAS

Pagina 1 - ESTADO DE LA CURACION
  Tarjetas: total registros | % sin hallazgo alto | registros que
  esperan a INABIO | hallazgos alta | reglas que disparan.
  Embudo en cascada (lo pidio el director): total -> con taxon ->
  determinado a especie -> con coordenada -> coordenada coherente
  con la provincia -> con fecha completa. Cada escalon con su
  porcentaje sobre el total y sobre el escalon anterior.
  Barras apiladas de hallazgos por bloque y severidad.
  Segmentadores: bloque, severidad, destino, provincia.

Pagina 2 - COMPLETITUD ANTES / DESPUES
  Grafico de barras agrupadas por termino Darwin Core con las dos
  fases (origen / limpio), ordenado por la ganancia. Solo 92
  terminos. Medida "campos ganados" = poblados_limpio - poblados_origen.
  Tarjeta con el total de celdas ganadas y con las vaciadas
  (placeholders retirados), que son dos cosas distintas y las dos
  son resultado.

Pagina 3 - SEGUIMIENTO DEL OFICIO A INABIO
  Es la pagina que mas me importa y la que no tengo.
  Tabla matriz: bloque_dudas x estado, con el numero de registros
  afectados y las reglas que lo sustentan.
  Al seleccionar un bloque, un detalle con los catalogos concretos
  y el valor que dispara la regla, para poder mandarselo al curador.
  Tarjeta: preguntas abiertas / respondidas / cerradas.
  Tabla aparte con reporte_plausibilidad_verificadas.csv bajo el
  titulo "comprobado y descartado", porque demuestra que la
  verificacion corrio y paso.

REQUISITOS TECNICOS
- Modelo en estrella, direccion de filtro unica de dimension a
  hecho, tabla _Medidas vacia para todas las medidas.
- Parametro de ruta de carpeta en Power Query, para que las siete
  consultas apunten a una variable y no a rutas absolutas.
- Todas las medidas con DIVIDE, nunca con /.
- Formato condicional por severidad: alta rojo, media ambar,
  informativa gris.
- Nada de Copilot ni de visuales de terceros: solo visuales
  nativos, porque esto se defiende ante un tribunal.

FORMATO DE TU RESPUESTA
1) Codigo M completo de cada consulta que cambia o se anade,
   listo para pegar en el Editor avanzado.
2) Codigo DAX de cada medida, agrupado por pagina.
3) Pasos de menu en espanol para el modelo y las relaciones.
4) Al final, una lista de lo que NO se puede resolver con estas
   fuentes y que archivo haria falta.
No expliques que es Power BI ni que es un esquema en estrella:
doy los dos por sabidos.
=========================================================
```

Una cosa más para el tablero, que sale del validador y te da un indicador externo: guarda el JSON de GBIF de cada corrida en `reportes_y_revisiones/` con la fecha. Con dos corridas ya puedes graficar `TAXON_MATCH_FUZZY 74 → 61` y `HIGHERRANK 29 → 24`. Un KPI de calidad medido por un tercero, con serie temporal, es lo que convierte OE2 de «limpié datos» en «demuestro que la limpieza mejoró el dataset».