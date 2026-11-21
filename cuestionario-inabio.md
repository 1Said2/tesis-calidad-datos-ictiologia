# CUESTIONARIO PARA INABIO

### Colección ictiológica MECN-DP · pendientes del conjunto final regenerado

### Estado del cuestionario

**Nota de alcance.**
Las preguntas marcadas ALTA son las que condicionan la publicación del conjunto de datos y el cierre del capítulo de resultados. Las demás pueden resolverse en rondas posteriores: cada respuesta se traduce en una regla nueva del script de curación, no en una versión nueva del conjunto.

| Bloque | Preguntas | Pendientes | Alta | Media | Baja |
|---|---|---|---|---|---|
| A | 3 | 3 | 1 | 2 | 0 |
| B | 6 | 6 | 3 | 2 | 1 |
| C | 38 | 38 | 4 | 14 | 20 |
| D | 17 | 17 | 4 | 6 | 7 |
| E | 5 | 5 | 0 | 3 | 2 |
| F | 19 | 19 | 7 | 12 | 0 |
| G | 1 | 1 | 0 | 1 | 0 |
| H | 2 | 2 | 0 | 2 | 0 |
| I | 3 | 3 | 0 | 0 | 3 |
| J | 4 | 4 | 1 | 3 | 0 |
| K | 2 | 2 | 1 | 1 | 0 |
| **Total** | **100** | **100** | **21** | **46** | **33** |

## Cómo usar este documento

Cada duda trae un filtro reproducible sobre dos archivos, `ocurrences_curado.csv` y `reporte_plausibilidad_post.csv`. Esto permite aislar inmediatamente los registros afectados y revisar los datos en su contexto.

Las cifras corresponden a la versión final regenerada por `Curacion.R`: 6.427 especímenes y 174 columnas. Se conservan las 168 columnas de entrada y se añaden seis; conservar las columnas no significa que sus valores estén intactos, pues las seis reglas modifican sus campos objetivo. La curación intervino 1.612 identificadores: R1 en 191, R2 en 289, R3 en 23, R4 en 500, R5 en 169 y R6 en 460; hay solapamientos entre reglas.

Las columnas que empiezan por `flag_` son banderas booleanas producidas por el pipeline. Según los URI de `meta.xml` y los cinco términos añadidos (`verbatimLatitude`, `verbatimLongitude`, `occurrenceStatus`, `previousIdentifications`, `verbatimLocality`), las 174 columnas se reparten en 88 del espacio de nombres Darwin Core, seis Dublin Core, dos de Symbiota (`recordEnteredBy`, `recordID`), el identificador estructural `id` y 77 auxiliares de procesamiento y auditoría. Los términos añadidos se contrastaron con la [referencia de Darwin Core](https://dwc.tdwg.org/terms/). Las seis columnas incorporadas por la curación son `verbatimLocality`, `locationRemarks_verbatim`, `eventDate_portal`, `metodo_correccion_curacion`, `regla_curacion` y `ronda_curacion`.

PRE contiene 5.007 hallazgos sobre 3.398 especímenes; POST, 4.024 sobre 2.842: 491 alertas altas, 2.550 medias y 983 informativas. Las 491 alertas altas siguen pendientes: estos conteos no significan que hayan sido resueltas. El inventario registra 64 reglas, 43 con hallazgos, 19 sin hallazgos y dos verificadas/descartadas.

La severidad "alta" señala una contradicción que requiere revisión prioritaria. La severidad "media" identifica inconsistencias que deben verificarse. La categoría "informativa" señala patrones y no constituye una aprobación curatorial; las dos reglas verificadas/descartadas se registran en su anexo separado.

**Anexos que acompañan a este cuestionario.**

| Archivo | Filas × columnas | Qué contiene | Dudas que sustenta |
|---|---|---|---|
| `ocurrences_curado.csv` | 6.427 × 174 | Conjunto final con términos estándar, metadatos del portal y auxiliares, según el desglose anterior | Todas |
| `reporte_plausibilidad_pre.csv` | 5.007 × 8 | Validación antes de la curación; 3.398 especímenes con al menos un hallazgo | Comparaciones PRE/POST |
| `reporte_plausibilidad_post.csv` | 4.024 × 8 | Un hallazgo por fila, con regla, severidad y destino; 2.842 especímenes | Todas las que citan una `regla` |
| `reporte_correcciones.csv` | 3.370 × 6 | Asignaciones sobre campos objetivo, con `id`, `campo`, valor anterior y nuevo; 1.612 identificadores intervenidos. Los respaldos y las anotaciones se conservan en el core, aunque no todos generen filas adicionales en este reporte | B5, C36, C37, C38, D10, D11 |
| `reglas_ejecutadas_post.csv` | 64 × 2 | Una fila por regla, con su estado (`con_hallazgos`, `sin_hallazgos`, `verificada_descartada`) | Vista general |
| `reporte_plausibilidad_resumen_post.csv` | 43 × 7 | Una fila por regla con hallazgos: filas, registros y casos únicos, agrupados por severidad y destino | Vista general |
| `reporte_plausibilidad_verificadas_post.csv` | 1.309 × 8 | Casos evaluados y descartados con justificación: 583 cantones homónimos de su provincia y 726 ejemplares del mismo lote de colecta | Registro de reglas verificadas |
| `identifications_para_inabio.csv` | 71 × 11 | Discrepancias con el core, motivo y autoría rechazada | J1, J2, G1 |
| `gbif_contraste_completo.csv` | 938 × 9 | Contraste por nombre; 19 resultados con `matchType = HIGHERRANK` y uno `NONE` | F8, F12, F13 |
| `gbif_nombres_difusos.csv` | 30 × 8 | Treinta nombres variantes, presentes en 46 ocurrencias; las sugerencias no son correcciones aprobadas | F12, F14 |
| `multimedia_caption_vs_core_post.csv` | 162 × 6 | Discrepancias de nombre por espécimen; mismo contenido que PRE | J3 |
| `multimedia.csv` | 430 × 19 | Extensión original: imágenes de 346 especímenes, URL y derechos | J3 |
| _(sin archivo separado)_ | — | Dieciséis géneros, presentes en 64 filas, con `genero_fuera_de_backbone_fishbase = TRUE` | F8 |
---

## BLOQUE A — Identificadores y alcance

### A1. [ALTA] Uso del campo `otherCatalogNumbers`

**El problema.** Solo 636 registros (9,9 %) lo tienen poblado: 573 con prefijo `QCAZ` y 64 con prefijo `PEC`. El catálogo 5387 lleva los dos prefijos, por eso 573 + 64 no da 636.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `otherCatalogNumbers != ""` → 636 registros.

**Pregunta.** ¿Son ejemplares transferidos desde la PUCE y otra colección, duplicados de lote, o referencias cruzadas de otra naturaleza?

---

### A2. [MEDIA] Números de catálogo externos repetidos y con formato irregular

**El problema.** Además de lo ya consultado en A1, un barrido del campo completo encontró tres defectos distintos.

- **Treinta y cuatro números aparecen en más de un registro MECN-DP.** Los catálogos 5383 y 5389 comparten siete (`QCAZ-1383`, `1396`, `1397`, `1654`, `1659`, `1661`, `1662`), lo que parece copia del bloque entero y no una coincidencia.
- **`QCAZ-Z211`** lleva una letra que ningún otro token del campo tiene.
- **`PEC-46`** aparece dentro de la serie 457–464 del catálogo 5587.
- **`PEC-001`, `PEC-002`, `PEC-004` y `PEC-009`** llevan cero a la izquierda mientras `PEC-13`, `PEC-24` y `PEC-28` no.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: separando `otherCatalogNumbers` por `|`, 34 números distintos aparecen en más de un registro, y esos registros son 56. (Como referencia, 188 registros declaran más de un número externo.)

**Preguntas.**
1. ¿Un mismo ejemplar `QCAZ` puede estar referenciado desde dos registros MECN-DP, o el bloque de 5383/5389 es una duplicación de carga?
2. Confirmo que `PEC-46` (en el cat. 5587) es un error por `PEC-461` (la serie es 457-458-459-460-462-463-464 y falta justo el 461), favor confirmar.
3. ¿`QCAZ-Z211` es un formato válido de esa colección?
4. ¿El cero a la izquierda es significativo o normalizo a `PEC-1`, `PEC-2`?

---

### A3. [MEDIA] individualCount: vacíos y lotes atípicos

**El problema.** individualCount sí existe en el archivo, pero presenta dos anomalías: hay 5 registros sin número de individuos (vacíos) y 7 lotes con un número atípicamente alto.

**Filas afectadas.** 12 registros en total.

**Por qué importa.** individualCount es la medida principal de la tabla de hechos del almacén. Los datos vacíos rompen sumatorias, y los atípicos pueden sesgar los análisis poblacionales.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `individualCount` vacío (5 registros), o `individualCount` > 200 (7 registros: catálogos 654, 1018, 1366, 1499, 2671, 5218, 5226, con valores entre 205 y 679).

**Preguntas.**
1. ¿Los 5 registros sin dato se cuentan como 1 ejemplar o quedan nulos?
2. ¿Los 7 lotes con números altos son correctos o hay un error de digitación?
3. Tres de los siete son caracinos (Characidae) de lagunas amazónicas: 5218 en Zancudococha (679), 5226 en Laguna Canangueno (330) y 1366 en Cuyabeno (553). Los otros cuatro son un Characidae de Taura (1499), un Poeciliidae (654) y dos Loricariidae (1018 y 2671). ¿Corresponden a capturas masivas reales de un mismo lance, o el número se refiere al lote completo y no al frasco catalogado?


---

## BLOQUE B — Fechas

### B1. [MEDIA] Veinte registros donde `eventDate` y `verbatimEventDate` declaran años distintos

**El problema.** `verbatimEventDate` guarda la fecha tal como estaba escrita en la ficha original; `eventDate` es la fecha normalizada que usa el sistema. Deberían ser la misma fecha en dos formatos. En estas 20 filas **son fechas diferentes, con años distintos**, a veces con décadas de separación. Una de las dos está mal, y no puedo saber cuál sin ver la etiqueta del frasco: si mando la fecha equivocada al modelo, toda la serie temporal de la colección queda sesgada.

**Filas afectadas.**

| catalogNumber | `eventDate` | `verbatimEventDate` | Colector | Localidad |
|---|---|---|---|---|
| 4915 | 2018-11-16 | 2022-08-01 | Fermando Romero | Cueva de los Tayos |
| 4961 | 2017-06-28 | 2022-06-01 | Patricio Quizhpe | Río Palenque |
| 5017 | 2001-06-03 | 2009-01-11 | Juan Francisco Rivadeneira | Río Rumiyacu |
| 5018 | 2001-06-29 | 2009-01-10 | Juan Francisco Rivadeneira | Sur de Capitán Augusto Rivadeneyra |
| 5019 | 2007-09-18 | 2008-12-22 | GLOWS | Río Chiguaza |
| **5020** | **1985-03-01** | **2008-12-19** | J. M. Touzet | Sábalo |
| 5028 | 2001-06-03 | 2010-04-23 | Juan Francisco Rivadeneira | Río Rumiyacu |
| 5029 | 2001-06-03 | 2010-06-08 | Juan Francisco Rivadeneira | Río Rumiyacu |
| 5030 | 2001-06-03 | 2010-06-19 | Juan Francisco Rivadeneira | Río Rumiyacu |
| 5031 | 2001-11-07 | 2010-06-11 | Juan Francisco Rivadeneira | Río Rumiyacu |
| 5032 | 2001-11-07 | 2011-01-20 | Juan Francisco Rivadeneira | Río Rumiyacu |
| 5033 | 2001-11-07 | 2011-01-20 | Juan Francisco Rivadeneira | Río Rumiyacu |
| 5034 | 2005-08-20 | 2011-09-12 | Juan Francisco Rivadeneira | Río a 10 m punto OBE occidental boya 3 |
| **5069** | 2005-10-13 | **2025-10-13** | QCAZ | Chiruisla |
| 5200 | 1992-09-05 | 1993-11-10 | QCAZ | Laguna Mateococha |
| **5468** | 2023-06-13 | **2005** | Kevin Chugá \| Santiago Núñez | Reserva Puranquí |
| **5492** | **1905-06-27** | **2005** | Lida Guarderas | Lorocachi |
| **5551** | 2023-06-16 | **2005-09-01** | Kevin Chugá \| Santiago Núñez | Reserva Puranquí |
| 2463 | 2011-06-18 | 18/06/2012 | J. Valdiviezo \| C. Carrillo | Laguna Limoncocha |
| 2464 | 2011-06-18 | 18/06/2012 | J. Valdiviezo \| C. Carrillo | Laguna Limoncocha |

**Tres patrones distintos, y cada uno necesita respuesta propia:**
- **El bloque de Rivadeneira (5017–5034, nueve filas).** El `eventDate` es sistemáticamente anterior al `verbatim` por seis a diez años. Que sean nueve filas del mismo colector, casi todas en la misma localidad (siete de nueve en el Río Rumiyacu) y con un desfase del mismo signo apunta a un error de digitación por lote, no a nueve errores independientes.
- **Los dos de la Reserva Puranquí (5468 y 5551).** `eventDate` dice 2023 y `verbatim` dice 2005, pero el colector es Kevin Chugá, cuyos demás registros son todos de 2023. Aquí el verbatim parece el equivocado.
- **Los tres imposibles.** El 5492 dice 1905 cuando el verbatim dice 2005 — un dígito. El 5069 tiene un verbatim en 2025 posterior a su propio `eventDate`. El 5020 declara 1985 frente a 2008, veintitrés años.

**Cómo aislar los registros.** En `reporte_plausibilidad_post.csv`: `regla = "eventDate y verbatimEventDate con anos distintos"` → 20 registros.

**Preguntas.**
1. Como criterio general: ¿manda `eventDate` o `verbatimEventDate` cuando discrepan?
2. Para las nueve filas de Rivadeneira (5017, 5018, 5028–5034): ¿pueden revisar la etiqueta física de una sola de ellas? Si el desfase es sistemático, con una se resuelven las nueve.
3. Para 5468 y 5551: ¿el trabajo de campo en Reserva Puranquí fue en 2023 o en 2005?
4. Para 5492: ¿1905 es un error por 2005?

---

### B2. [BAJA] Cinco fechas verbatim malformadas, y dos contradicen el bloque B5

**El problema.** Cinco registros tienen `verbatimEventDate` con un formato que no corresponde a ninguna fecha válida.

| catalogNumber | `eventDate` | `verbatimEventDate` | Lectura probable |
|---|---|---|---|
| 4048, 4050 | 2017-12-01 | `2017-12-019` | El día sería 19, no el 01 |
| 5796 | 2005-06 | `2005-06 10` | El día 10 existe y `eventDate` lo perdió |
| 6264 | 2024 | `2024-2024-11` | ¿2024-11? |
| 4292 | (vacío) | `201-08-19` | Año truncado |

Los catálogos 4048 y 4050 importan más allá de sí mismos: en B5 sostengo que el `01` del día lo fabricó el portal porque el verbatim solo traía año y mes. En estos dos el verbatim **sí trae día**, y es distinto del que el sistema escribió. Eso significa que el criterio de B5 no cubre todos los casos y que puede haber más días perdidos, no solo inventados.

**Preguntas.**
1. ¿Los catálogos 4048 y 4050 se colectaron el 19 de diciembre de 2017?
2. ¿El catálogo 4292 es de 2010, 2011 u otro año?
3. ¿Existen más registros donde el portal haya sobrescrito un día real?

---

### B3. [ALTA] Cuatro fechas de colecta imposibles o inverosímiles

**El problema.** Fechas que no pueden ser correctas tal como están.

| catalogNumber | `eventDate` | Situación |
|---|---|---|
| 5684 | 2027-10-18 | **En el futuro.** La localidad se recuperó de `locationRemarks` (C36), pero la coordenada está vacía como `irreparable`; su georreferencia sigue pendiente |
| 5687 | 2027-10-16 | En el futuro, mismo colector y mismo lote que la anterior |
| 5757 | 1897-06-05 | Anterior a la fundación de la colección; localidad vacía |
| 5492 | 1905-06-27 | Su propio verbatim dice 2005 (ver B1) |

Los catálogos 5684 y 5687 comparten fecha futura, colector y fecha de determinación, y ambos venían sin localidad en el archivo del portal; el 5684 tiene además su georreferencia pendiente. No son errores sueltos: parece un lote mal digitado.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `catalogNumber` IN (5684, 5687, 5757, 5492) → 4 registros.

**Preguntas.**
1. ¿Los catálogos 5684 y 5687 corresponden a 2017, 2021 o alguna otra fecha? ¿Se digitaron juntos con otros registros que también deba revisar?
2. ¿El catálogo 5757 es realmente de 1897, o es un error por 1997?

---

### B4. [ALTA] Setenta y tres registros identificados *antes* de ser colectados

**El problema.** `dateIdentified` es anterior a `eventDate`: el sistema afirma que alguien determinó taxonómicamente un ejemplar antes de que se recogiera. Es imposible por definición.

**Filas afectadas.**

| `eventDate` | `dateIdentified` | n | catalogNumber |
|---|---|---|---|
| 2006-02-10 a 2006-02-18 | 2005 | 45 | 408–451, 466 |
| 2013-02-25 | 2011 | 9 | 2298–2306 |
| 2013-02-25 | 2012 | 3 | 2307, 2405, 2406 |
| 2022-09 | 2022-01 | 6 | 4997–5002 |
| 2017-07-20 | 2017-06 | 3 | 3931, 3939, 3943 |
| **2025-11-19** | 2025-03-24 | 2 | 6231, 6237 |
| **2025-10-03 / 08-03** | 2025-04-08 | 3 | 6422, 6423, 6424 |
| 2027-10-16/18 | 2023-08-25 | 2 | 5684, 5687 |

Los bloques son de catálogos consecutivos, lo que indica errores de carga por lote y no casos aislados. El bloque grande (408–451) son 45 registros seguidos. Los cinco de 2025 (6231, 6237, 6422–6424) son todos del mismo colector, Fernando Sánchez, determinados por Jonathan Valdiviezo.

**Cómo aislar los registros.** En `reporte_plausibilidad_post.csv`: `regla = "determinado antes de ser colectado"` → 73 registros.

**Preguntas.**
1. Para el bloque 408–451: ¿la colecta fue en 2006 y la determinación en 2005 está mal, o al revés?
2. ¿Existe registro de cuándo se cargaron estos lotes al sistema? Serviría para saber qué campo se desplazó.
3. Para los cinco registros de 2025 de Fernando Sánchez: ¿las fechas de colecta o determinación están invertidas o corresponden a años anteriores?

---

### B5. [MEDIA] Ciento sesenta y nueve fechas con el día inventado en origen

**El problema.** El `verbatimEventDate` solo trae año y mes (por ejemplo `2003-8`), pero el `eventDate` del sistema completó el día con `01`. Ese `01` no viene de la ficha. Los 169 pertenecen a la carga masiva del 2020-01-08 (misma marca en `modified`), mientras que los 231 registros de la carga del 2025-11-03 con la misma situación conservaron año y mes sin día. La digitadora principal es la misma en ambas cargas, así que el `01` lo introdujo el proceso de carga de 2020, no la persona que digitó la ficha. El verbatim de esa carga además escribe el mes sin cero (`2003-8`), otra huella del mismo proceso. Ese día poblaba `day` antes de R5; en el conjunto final se retiró y no debe tratarse como una fecha diaria observada.

Dos registros de este bloque tienen además una discrepancia entre los meses declarados:

| catalogNumber | `eventDate` antes de R5 | `verbatimEventDate` | `eventDate` después de R5 |
|---|---|---|---|
| 3819 | 2011-09-01 | `2011-11` | 2011-09 |
| 3820 | 2011-09-01 | `2011-11` | 2011-09 |

R5 retiró únicamente el día `01`: conservó septiembre, vació `day` y `startDayOfYear` y no intentó resolver la contradicción con noviembre. Esto prueba que los dos campos discrepan, no que noviembre sea necesariamente el mes correcto.

**Cambio aplicado.** Se truncó `eventDate` al grano año-mes indicado por el verbatim (AAAA-MM) y se vaciaron `day` y `startDayOfYear`. El valor que fabricó el portal quedó en `eventDate_portal`. Como R5 conserva el año y el mes de `eventDate`, la discrepancia de los catálogos 3819 y 3820 queda pendiente de resolución curatorial.

**Filas afectadas.** 169 registros.

**Por qué importa.** Choca de frente con la regla de no imputación que rige toda la limpieza. Si un análisis pregunta "¿qué día del mes se colecta más?", esas 169 filas dirán "el primero" sin que nadie lo haya observado.

**Cómo aislar los registros.** En `ocurrences_curado.csv`:  `eventDate_portal` no vacío

**Si no corresponde.** Restaurar `eventDate_portal` sobre `eventDate` y recalcular `day` y `startDayOfYear` en esos 169 registros.

**Preguntas.**
1. ¿Se confirma el truncamiento, o prefieren conservar el día 01 documentado como convención del portal? En ese caso se revierte.
2. ¿Existe libro de campo que permita recuperar el día real de estas 169 colectas?
3. Para los catálogos 3819 y 3820: ¿el mes de colecta correcto es septiembre, como indica `eventDate`, noviembre, como indica `verbatimEventDate`, u otro? Debe verificarse contra la fuente curatorial.

---

### B6. [ALTA] Quinientos veinticuatro registros sin fecha y cuatrocientos tres con fecha incompleta

**El problema.** Además de los casos anteriores, el grano temporal no es uniforme:
- **524 registros sin `eventDate`** — no hay fecha de colecta.
- **400 registros con solo año y mes** (`2011-09`). De ellos, 169 tenían el día `01` fabricado por el portal y se truncaron en la curación (ver B5); los 231 restantes ya venían sin día.
- **3 registros con solo el año**: catálogos 5163, 5531 y 6264.

**Por qué importa.** Determina el grano mínimo de la dimensión Tiempo. Si el 14 % de la colección no tiene día, un dashboard con eje diario deja fuera esos registros silenciosamente.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `eventDate = ""` (524); `largo(eventDate) < 10` y `<> ""` (403).

**Preguntas.**
1. ¿Los 524 sin fecha se excluyen de los análisis temporales o se agrupan en una categoría "fecha desconocida"?
2. ¿Existen libros de campo o etiquetas físicas que permitan recuperar alguna de estas fechas?

---

## BLOQUE C — Geografía administrativa

### C1. [MEDIA] Cinco cantones aparecen bajo dos provincias distintas

**El problema.** Un cantón pertenece a una sola provincia. En el dataset, cinco valores de `county` aparecen asociados a dos `stateProvince` diferentes, lo que rompe la jerarquía y hará que la dimensión Geografía tenga dos padres para el mismo hijo.

| Cantón (`county`) | Provincias declaradas | Filas |
|---|---|---|
| Aguarico | Orellana / Sucumbíos | 537 |
| Shushufindi | Orellana / Sucumbíos | 206 |
| El Edén | Esmeraldas / Orellana | 130 (1 en Esmeraldas) |
| Puyango | El Oro / Loja | 14 |
| La Concordia | Esmeraldas / Santo Domingo de los Tsáchilas | 7 |

Para La Concordia existe explicación histórica (cambió de provincia en 2007). Puyango pertenece a Loja. Sin embargo, para Aguarico y Shushufindi la explicación histórica es falsa: Aguarico fue cantón de Napo y pasó a Orellana en 1998; Shushufindi se cantonizó en Napo en 1984 y pasó a Sucumbíos en 1989. Ninguno estuvo en la provincia que se les atribuye. Para El Edén, 129 filas son de Orellana (Chiruisla) y solo 1 es de Esmeraldas (Alto Tambo, que es San Lorenzo).

**Cómo aislar los registros.** En `reporte_plausibilidad_post.csv`: `regla = "canton asociado a dos provincias distintas"` → 82 registros.

**Preguntas.**
1. ¿La provincia debe reflejar la división administrativa **vigente hoy** o **la vigente en la fecha de colecta**? Es la decisión que más afecta al modelo: 880 registros dependen de ella.
2. Para El Edén (1 fila en Esmeraldas): ¿Confirman la corrección a San Lorenzo?

---

### C2. [ALTA] Cuatrocientos cuarenta registros con parroquia que no cuadra con el clasificador DPA-INEC

**El problema.** Es el mismo defecto de C1 un nivel más abajo, en el campo `municipality`.

| Parroquia | Cantones declarados |
|---|---|
| Pacto | Distrito Metropolitano de Quito · Quito · San Miguel de Los Bancos |
| Tumbaco | Distrito Metropolitano de Quito · Quito |
| Shushufindi | Cuyabeno · Shushufindi |
| Dayuma | Francisco de Orellana · Orellana |
| Yasuní | (Orellana y Sucumbíos como provincia) |
| San Roque (Cab. en San Vicente) | (Orellana y Sucumbíos como provincia) |

`Puerto Bolívar` (Machala y Putumayo) y `Salinas` (Ibarra y Salinas) son homónimos legítimos de lugares distintos y no necesitan corrección, solo una clave calificada por nivel en el modelo.

**Cómo aislar los registros.** En `reporte_plausibilidad_post.csv`: `regla = "parroquia no existe en ese canton segun DPA-INEC"` → 440 registros. Ambas reglas se ejecutan con severidad media: una discordancia con el clasificador administrativo es una duda de nomenclatura, no un dato imposible.

**Preguntas.**
1. ¿Pacto pertenece a Quito o a San Miguel de los Bancos? El registro que la asigna a San Miguel de los Bancos, ¿es un error o una zona limítrofe?
2. ¿Confirman que Puerto Bolívar y Salinas son homónimos y no errores?

---

### C3. [ALTA] El campo `county` mezcla cantones, parroquias y localidades

**El problema.** Darwin Core reserva `county` para el cantón y `municipality` para la parroquia. En el dataset conviven los tres niveles dentro de `county`. La cifra se actualizó a 328 registros y 38 casos distintos. El cantón `Orellana` figura en el DPA como `Francisco de Orellana` y no es un error.

| Valor en `county` | Qué es en realidad | Filas |
|---|---|---|
| `Distrito Metropolitano de Quito` / `Quito` | El mismo cantón con dos etiquetas | 212 / 14 |
| `Francisco de Orellana` / `Coca` | El mismo cantón con dos etiquetas | 12 / 1 |
| `El Edén`, `Tonchigüe`, `Súa`, `Tonsupa`, `Pañacocha`, `Inés Arango`, `Teniente Hugo Ortiz`, `Guayllabamba` | Parroquias, no cantones | 130, 18, 17, 6, 2, 1, 1, 5 |
| `Yasuní`, `Intag`, `Añangu`, `Río Macarena`, `Timpoka`, `Playa Ancha`, `Indiyalla`, `Simbocal`, `Durango` | Localidades o áreas, no cantones | 1 a 8 cada uno |
| `Parroquia Pacto` | Lleva el nivel escrito dentro del valor | 1 |
| `Bahía de Caráquez` | Cabecera cantonal (de Sucre), no parroquia/cantón | 3 |
| `Marchena`, `Fernandina` | Islas, no parroquias. Deberían ir en `island` (declaradas en `municipality`) | 2, 2 |
| `ACUS Los Monos` | Área de conservación, no parroquia (declarada en `municipality`) | 2 |
| `San Jacinto de Buena Fé` | Repite la tilde de Buena Fé | 1 |
| `Orellana` | Nombre de provincia repetido en el nivel de cantón | 196 |

**Cómo aislar los registros.** En `reporte_plausibilidad_post.csv`: `regla = "canton no existe en esa provincia segun DPA-INEC"` → 328 registros.

**Preguntas.**
1. ¿Reasigno los valores a su nivel correcto (parroquias a `municipality`, localidades a `locality`) o INABIO prefiere una revisión propia?
2. ¿Unifico `Quito`/`Distrito Metropolitano de Quito` y `Coca`/`Francisco de Orellana`? ¿Con cuál nombre?
3. ¿Bahía de Caráquez se reasigna a Sucre?
4. Para Marchena y Fernandina: ¿Se mueven a `island` con `islandGroup = Galápagos`?

---

### C4. [BAJA] Nueve valores más de `county` que no son cantones

**El problema.** Ampliación de la tabla de C3 con los valores que faltaban.

| Valor | Qué es realmente |
|---|---|
| Tandapi, Lumbaqui, Mompiche, Salango, Crucita, Yahuarcocha | parroquias |
| Macas, Puyo | ciudades, cabeceras de Morona y Pastaza |
| Urbina Jado | nombre histórico del cantón Salitre |

Además, `Distrito Torres Causana` (en `municipality`) lleva el nivel escrito dentro del valor, igual que `Parroquia Pacto`, y `Buena Fé` se escribe con tilde cuando la denominación oficial es `Buena Fe`. `Maynas` y `Apure`, que figuraban en una versión anterior de esta tabla, no se incluyen: en los registros de Perú y Venezuela el segundo nivel administrativo es legítimamente una provincia o un estado (`Maynas` en `county` para Loreto; `Apure` en `stateProvince`, con `country = Venezuela`). El caso de Maynas como provincia se trata en C7.

**Preguntas.**
1. ¿Reemplazo cada uno por su cantón, o los muevo al campo que corresponde a su nivel real?
2. ¿`Urbina Jado` debe modernizarse a `Salitre` o conservarse como estaba al momento de la colecta?
3. ¿Autorizan quitar la tilde de `Buena Fé`?

---

### C5. [BAJA] Doce registros con parroquia pero sin cantón

**El problema.** Tienen `municipality` poblado y `county` vacío: se declara la parroquia sin el cantón que la contiene. La jerarquía queda con un hueco intermedio.

**Filas afectadas.** Catálogos 460, 2950, 2951, 2952, 3766, 3767, 4914, 5075, 5550, 5591, 6168, 6169.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `catalogNumber` IN (460, 2950, 2951, 2952, 3766, 3767, 4914, 5075, 5550, 5591, 6168, 6169) → 12 registros.

**Pregunta.** ¿Pueden completar el cantón de estas doce, o las dejo como jerarquía incompleta documentada?

---

### C6. [MEDIA] Dos correcciones de topónimo que necesitan visto bueno

**El problema.** Apliqué o dejé pendientes dos cambios que no son ortográficos sino léxicos, y quiero confirmarlos antes de darlos por cerrados.
- **`Araujo` → `Arajuno` (22 filas).** No existe ningún cantón «Araujo» en Ecuador; Arajuno sí, en Pastaza. La corrección ya está aplicada.
- **`PescadeRío` (catálogos 683 y 684).** No la corregí porque no puedo determinar el original. Podría ser `Pescadero` o `Pesca de Río`. El contexto es `PescadeRío. luego de desfogue del agua de las piscinas`. La R mayúscula a mitad de palabra es la huella de un reemplazo automático de «rio» por «Río», el mismo que produjo formas como «exploratoRío» en la normalización inicial. Como ese reemplazo no inserta espacios, el original era una sola palabra terminada en «-rio», lo que hace menos probable la lectura «Pesca de Río». La forma ya viene así en el archivo descargado del portal.

**Preguntas.**
1. ¿Confirman que `Araujo` era `Arajuno`?
2. ¿Qué decía la ficha original en los catálogos 683 y 684?

---

### C7. [BAJA] Dos grafías del mismo distrito peruano, en dos niveles distintos

**El problema.** Los catálogos 2950–2952 declaran `stateProvince = Maynas` y `municipality = Torres Causoma`. Los catálogos 2532–2538 declaran `stateProvince = Loreto`, `county = Maynas` y `municipality = Distrito Torres Causana`. Es la misma zona del Perú modelada en dos niveles distintos, y `Causoma` parece errata de `Causana`.

**Preguntas.**
1. ¿`Torres Causoma` es errata de `Torres Causana`?
2. ¿Adopto Loreto como provincia y Maynas como cantón para los diez, o al revés?

---

### C8. [ALTA] ¿Quién georreferenció la colección?

**El problema.** En el conjunto final, `georeferencedBy` tiene un único valor no vacío —`Mateo Andrés Vega Yánez`— en 3.501 registros y está vacío en 2.926. De estos últimos, **2.629 tienen coordenadas** y 297 no las tienen. El pipeline no atribuye la autoría de una conversión a la persona que proporcionó o verificó la georreferencia original (ver D15).

**Por qué importa.** Si el nombre corresponde a la persona que efectivamente georreferenció esos 3.501 registros, es un dato de procedencia valioso para la dimensión Persona. Si es un valor asignado en bloque durante una migración del portal, no significa nada y no debe modelarse como una autoría.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `georeferencedBy = ""` → 2.926; añadir `decimalLatitude <> ""` → 2.629 registros.

**Preguntas.**
1. ¿Las 3.501 georreferenciaciones son efectivamente de esta persona, o es un valor por defecto del portal?
2. Los 2.629 registros que en el archivo curado tienen coordenada y sin georreferenciador, ¿fueron georreferenciados por otra persona, o la coordenada venía ya en la ficha de campo?

---

### C9. [MEDIA] Códigos de estación dentro de `locality`

**El problema.** Hay registros con códigos como `ICT-1`…`ICT-9`, `ICT-001`, `ICT-004`, `IC-01`, `WAM-306`…`WAM-359`, `CAMP 1` (ya normalizado a `Campamento 1` en la Fase 1), `P.B.` (catálogos 530 y 531, escritos además con espaciado incoherente entre sí: `P.B. 1.2` y `P.B.2.2`), `ICT-06-GLI-OR`, `PC23` (y `PC24`, que está en `locationRemarks`), y `18 M` (que es la localidad completa de 37 registros y no un fragmento) dentro de la localidad, mientras que `fieldNumber`, `eventID` y `recordNumber` están vacíos en las 6.427 filas.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `locality` contiene `"ICT-"` o `"WAM-"` o `"Bloque"` o `"P.B."` o `"18 M"`. Y `fieldNumber`, `eventID` y `recordNumber` están vacíos en las 6.427 filas.

**Preguntas.**
1. ¿`ICT-1`, `ICT-01` e `ICT-001` son la misma estación?
2. ¿Estos códigos deben ir a `fieldNumber` o a `eventID`?

---

### C10. [MEDIA] Valores administrativos que no corresponden al lugar

**El problema.**
- `San Roque (Cab. en San Vicente)` en 8 filas del cantón Shushufindi: el paréntesis es el desambiguador INEC de la parroquia homónima de Antonio Ante, Imbabura.
- 14 filas con `municipality = Shushufindi` y `locality = Zábalo`, a 108 km de la parroquia Shushufindi.

**Cómo aislar los registros.** En `reporte_plausibilidad_post.csv`: `regla = "mismo valor en canton y parroquia"` → 125 registros.

**Pregunta.** ¿Se corrigen estas inconsistencias reasignando a sus ubicaciones reales?

---

### C11. [BAJA] Conflictos de denominación o ubicación en topónimos específicos

**El problema.** Se detectaron varios casos irresolubles automáticamente donde nombres o ubicaciones se contradicen:

- **Río Colimbo (3142–3143) vs Río Columbo (1653–1655):** Misma provincia, cantón y parroquia. Son 3 contra 2, sin mayoría clara.
- **pozo primare (6, cat. 290–295) vs Pozo Pimare (5, cat. 326–329, 394, 407):** Mismo pozo, Bloque 31, PN Yasuní.
- **Punta km 13+501 (cat. 5641) vs Punta km 13+500 (13 filas):** Todas en Chiruisla.
- **Cinco topónimos irresolubles desde el archivo:** Río Mashpi Grande y Chicho (3394, 3397), Masphien (2403), laguna redondo cocha (2950–2952), Río átun playa cocha (3730–3732), Salinas.006 (583). La capitalización ya la resuelve el propio archivo: existen cuatro filas con Laguna Redondo Cocha correctamente escrita y tres con Sector Redondococha. La consulta se reduce a decidir si el topónimo va junto, separado o con guion.
- **Siglas como localidad:** `Pod` (cat. 59) y `ECY` (5600, 5650), localidades de tres letras sin resolver.
- **Catálogo 1555:** Declara `Río Aguarico … Pisorie` en Carchi / Tulcán / Tobar Donoso, pero eso está a más de 300 km del resto del lote Pisorie.
- **Catálogo 310:** Localidad dice `2.5 m. Norte Río Nashiño`. ¿Son 2,5 m o 2,5 km?

**Pregunta.** ¿Pueden revisar y confirmar la grafía/ubicación correcta para cada uno de estos casos concretos?

---

### C12. [ALTA] Nombre corto frente a nombre oficial en los campos `county` y `municipality`

**El problema.** El dataset escribe en `county` `Orellana` (196 filas) y `Coca` (1) donde el clasificador del INEC dice `Francisco de Orellana`, y escribe en `municipality` `Sarayaku` (146) donde el INEC dice `Sarayacu`. `Quinindé` no entra en esta duda: es el nombre oficial del cantón, la regla de contraste con DPA-INEC no lo marca, y la parroquia cabecera ya figura en `municipality` como `Rosa Zárate (Quinindé)`.

**Pregunta.** Para la dimensión Geografía del almacén, ¿se conserva el nombre de uso común del portal o se adopta la denominación oficial del INEC? La decisión afecta a 343 registros y determina si la jerarquía se une por texto o por código DPA.

---

### C13. [BAJA] `Q/N1 Buenaventura` y `Q/N2 Buenaventura`

**El problema.** 3 celdas. El campo escribe `Quebrada S/N 1` y `Estero S/N 2` con espacio en 40 valores. Se corrigió el espacio por ser tipográfico.

**Pregunta.** ¿`Q/N` significa «quebrada sin nombre»? Si es así, ¿debe desarrollarse como los demás `S/N`?

---

### C14. [BAJA] Magnitud sin unidad

**El problema.** `OBE Oriental a 390 al Oeste del punto unión` (1 valor). Las otras 53 expresiones de distancia del campo llevan `m` o `km`.

**Pregunta.** ¿390 metros o 390 kilómetros?

---

### C15. [BAJA] Dos denominaciones para un mismo sitio

**El problema.** `Curaray - Motor Cocha` (10 filas) y `Río Curaray Motor Cocha`.

**Pregunta.** ¿Son el mismo sitio? ¿Con qué denominación se unifica?

---

### C16. [BAJA] Cuatro denominaciones alrededor de Canandé

**El problema.** `Estación Científica Canandé - Jocotoco`, `Estación Canandé de la Fundación Jocotoco`, `Reserva Ecológica Canandé`, `Reserva Río Canandé Fundación Jocotoco`.

**Pregunta.** ¿Son la estación, la reserva y la fundación tres entidades distintas, o una con cuatro nombres?

---

### C17. [BAJA] Siglas sin resolver dentro de `locality`

**El problema.** `DHR` (10 filas, en `Junto vía a DHR` y `Vía Sansahuari/DHR`).

**Pregunta.** ¿Qué significa `DHR`?

---

### C18. [BAJA] Sitio con dos redacciones de la misma distancia temporal

**El problema.** `Río Yasuní a 2 h en canoa de la Comunidad Kawimeno` (6 filas) y `Río Yasuní a 2 horas de la Comunidad Kawimeno` (2 filas), en total 8 filas.

**Pregunta.** ¿Un miembro o dos?

---

### C19. [BAJA] Tres grafías de la misma laguna en Pastaza

**El problema.** `Chobacocha` (1 fila), `Chubacocha` (1) y `Chabacocha` (1), del mismo colector y del mismo lote.

**Pregunta.** ¿Cuál es la grafía correcta?

---

### C20. [BAJA] Chuyayaku frente a Chayayaku

**El problema.** `Chuyayaku` (2 filas) y `Chayayaku` (1), del mismo colector que Chobacocha.

**Pregunta.** ¿Cuál es la grafía correcta?

---

### C21. [BAJA] Anacocha frente a Pañacocha

**El problema.** `Anacocha` (1 fila) frente a `Pañacocha` (62). La mayoría es aplastante pero no se puede descartar que sea otro sitio.

**Pregunta.** ¿Anacocha es errata de Pañacocha o un sitio distinto?

---

### C22. [BAJA] Piñacocha frente a Pañacocha

**El problema.** `Piñacocha` (1 fila) frente a `Pañacocha` (62). Mismo caso que C21.

**Pregunta.** ¿Piñacocha es errata de Pañacocha o un sitio distinto?

---

### C23. [MEDIA] Tres denominaciones del mismo río en Sucumbíos

**El problema.** `Sábalo` (5 filas, Touzet 1985), `Zábalo` (14, registros de 2024) y `Río Sabalos` (11). El cambio de grafía coincide con un cambio de época.

**Pregunta.** ¿Se unifica a una sola denominación? ¿Cuál?

---

### C24. [MEDIA] Río Pishira frente a Río Pichira

**El problema.** `Río Pishira` (14 filas) y `Río Pichira` (8), ambos en la parroquia Limoncocha.

**Pregunta.** ¿Cuál es la grafía correcta?

---

### C25. [MEDIA] Tres grafías de un topónimo en tres campos

**El problema.** `Indiyana` (6 filas, de 1993, declara Napo), `Indillana` (10) e `Indiyalla` (4). La variante Indiyana es coherente con la provincia de Napo antes de la creación de Orellana.

**Pregunta.** ¿Son el mismo lugar? ¿Con qué denominación se unifica?

---

### C26. [MEDIA] Río Tarapuy frente a Río Tanipuy

**El problema.** `Tarapuy` (75 filas) y `Río Tanipuy` (1). Misma coordenada, misma fecha, mismo colector: es el mismo sitio.

**Pregunta.** ¿Se corrige Tanipuy a Tarapuy?

---

### C27. [MEDIA] Munchimkim frente a Muchinkin Chico

**El problema.** `Munchimkim` (24 filas) y `Muchinkin Chico` (24). Empate exacto.

**Pregunta.** ¿Son el mismo sitio? ¿Con qué denominación se unifica?

---

### C28. [MEDIA] Dos denominaciones para el campamento de Pisorie

**El problema.** `Campamento T. Pisorie Setsacco` (2 filas) y `Campamento 1` (21). Fechas consecutivas, misma coordenada. La `T.` no es un número.

**Pregunta.** ¿Son el mismo campamento? ¿Con qué nombre se registra?

---

### C29. [BAJA] Huiririma Cucha frente a Huiririma Sacha

**El problema.** `Huiririma Cucha` (7 filas) y `Huiririma Sacha` (2). Misma coordenada. En kichwa, `cucha` es laguna y `sacha` es selva: la diferencia es semántica, no ortográfica.

**Pregunta.** ¿Son dos sitios distintos o una errata?

---

### C30. [BAJA] Variación de preposición en Saguangal

**El problema.** `a Saguangal` (8 filas) y `al Saguangal` (1). Misma carretera.

**Pregunta.** ¿Se unifica a una sola forma?

---

### C31. [BAJA] Seis pares de topónimos con variación de género gramatical

**El problema.** Bermeja/Bermejo, Kenkim/Kenkin, Monsoya/Mansoya, Chague/Changue, Chumunde/Chumende, Malimpia/Malimpio.

**Pregunta.** ¿Cuál es la forma correcta en cada par?

---

### C32. [MEDIA] Sufijo kichwa yacu, yacua y yawa en tres topónimos

**El problema.** Morete Yacua (30 filas) / Yacu (27), Carlos Yacua (22) / Yawa (22), Chulla chaqui Yacua (18) / Chullachaquiyawa (18). La primera forma de cada par está en `locality` y la segunda en `locationRemarks`, como `Río Morete Yacu`, `Río Carlos Yawa` y `Río Chullachaquiyawa`. Es una convención lingüística, no tres erratas.

**Pregunta.** ¿Se adopta una sola forma del sufijo o se conservan las variantes?

---

### C33. [MEDIA] Cuatro grafías de Lagarto-cocha

**El problema.** `Lagarto-cocha` (26 filas), `Lagarto-Cocha` (10), `Lagarto Cocha` (10) y `Lagartococha` (6).

**Pregunta.** ¿Junto, separado, con guion? ¿Con qué capitalización?

---

### C34. [BAJA] Chorera

**El problema.** `Chorera` (1 fila). ¿Es `Chorrera`?

**Pregunta.** ¿Chorera es errata de Chorrera?

---

### C35. [BAJA] Nivel administrativo escrito dentro de locality

**El problema.** `Distrito: Torres Causana` aparece en 7 celdas de `locality`. Es el mismo patrón que `Parroquia Pacto`, ya documentado en C3.

**Pregunta.** ¿Se extrae el nivel administrativo al campo que le corresponde?


---

### C36. [MEDIA] Doscientos ochenta y nueve topónimos promovidos de `locationRemarks` a `locality`

**El problema.** En 289 registros `locality` estaba vacía y el nombre del sitio figuraba solo en `locationRemarks` (89 valores distintos, como `Laguna Canangueno`, `Laguna Mateococha` o `Cuyabeno Lodge`).

**Cambio aplicado.** El valor se pasó a `locality` y se vació `locationRemarks`. Ejemplo: `locality = ∅`, `locationRemarks = "Río Napo"` → `locality = "Río Napo"`, `locationRemarks = ∅`. El original quedó en `locationRemarks_verbatim`.

**Por qué importa.** `locality` es el descriptor principal del sitio para GBIF y para el modelo; un registro sin ella queda fuera de cualquier análisis por lugar. El propio archivo muestra que `locationRemarks` se usó como copia de `locality`: 500 registros los tenían idénticos (ver C38).

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `metodo_correccion_curacion` contiene `locality_promovida_desde_locationRemarks` → 289 registros.

**Si no corresponde.** Restaurar `locationRemarks_verbatim` sobre `locationRemarks` y vaciar `locality` en esos 289.

**Pregunta.** ¿El texto de `locationRemarks` en estos registros es la localidad de colecta, o describe otra cosa, como una referencia o un punto de acceso?

---

### C37. [BAJA] Veintitrés localidades con la coordenada y la altitud escritas dentro del texto

**El problema.** En 23 registros de la Reserva Biológica Limoncocha, `locality` terminaba con la coordenada UTM y la altitud, por ejemplo `Reserva Biológica Limoncocha. Laguna Limoncocha 18N 320868/9956786 234 msnm`. Eso partía cuatro sitios reales en siete valores distintos de `locality`.

**Cambio aplicado.** Se recortó el sufijo: el ejemplo queda como `Reserva Biológica Limoncocha. Laguna Limoncocha`. El texto completo quedó en `verbatimLocality`, por lo que no se perdió la UTM ni la altitud originales. Sin embargo, en nueve registros la UTM embebida no representa el mismo punto que `decimalLatitude`/`decimalLongitude` y `verbatimCoordinates`.

Aunque el texto dice `18N`, la interpretación técnicamente justificable para reproducir el contraste es WGS 84 / UTM zona 18 Sur (EPSG:32718): los registros declaran `geodeticDatum = WGS84`, Limoncocha está al sur del ecuador y los northings cercanos a 9.950.000 corresponden al falso norte del hemisferio sur. Interpretarlos como EPSG:32618 produciría latitudes cercanas a 88° N, fuera de la zona de uso y geográficamente incompatibles. La transformación con `sf`/PROJ y la distancia geodésica respecto al core dan:

| Catálogos | UTM en `verbatimLocality` | UTM transformada a WGS84 | Coordenada decimal del core | Distancia | `coordinateUncertaintyInMeters` |
|---|---|---|---|---:|---:|
| 2478–2483 | 318808 / 9959494 | -0.36632149, -76.62813920 | -0.365800, -76.629164 | 127,9 m | 30 m |
| 2464–2465 | 321429 / 9953040 | -0.42469405, -76.60460510 | -0.388558, -76.604683 | 4,018 km | 30 m |
| 2484 | 319811 / 9959906 | -0.36259714, -76.61912828 | -0.407828, -76.619142 | 5,029 km | 30 m |

Las tres separaciones superan la incertidumbre publicada, pero eso no demuestra cuál representación es correcta. En los nueve casos `verbatimCoordinates` repite la coordenada decimal del core. Los registros relacionados ayudan a confirmar la contradicción: 2462–2463 tienen la misma coordenada decimal que 2464–2465, pero su UTM `321429/9957040` queda a 10,4 m; y 2473–2477 tienen una UTM casi idéntica a la de 2478–2483 (`318807/9959492`), aunque corresponden a Río Playayacu. Estos patrones justifican revisar las fuentes, pero no autorizan a corregir ninguna coordenada sin confirmación curatorial.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `metodo_correccion_curacion` contiene `locality_recortada_coordenada_embebida` → 23 registros.

**Si no corresponde.** Restaurar `verbatimLocality` sobre `locality` en esos 23.

**Preguntas.**
1. ¿Se confirma que los cuatro sitios resultantes (Laguna Limoncocha, Río Pishira cerca de la carretera, Río Playayacu y Entrada al muelle) son los que corresponden?
2. Para los catálogos 2464–2465, 2478–2483 y 2484: ¿pueden contrastar la etiqueta o el cuaderno de campo y confirmar si corresponde la UTM escrita en `locality`, la coordenada decimal de `verbatimCoordinates` y del core, u otra coordenada?

---

### C38. [MEDIA] Quinientos `locationRemarks` que repetían literalmente `locality`

**El problema.** En 500 registros `locationRemarks` tenía exactamente el mismo texto que `locality` (por ejemplo `Río Santa Rosa`, `Río Simanwe`, `Río Curaray`). No era información adicional del sitio: era una copia.

**Cambio aplicado.** Se vació `locationRemarks` en esos 500. El texto sigue íntegro en `locality` y, además, quedó respaldado en `locationRemarks_verbatim`.

**Por qué importa.** Un campo duplicado infla la aparente riqueza del registro y obliga a cualquier análisis a decidir cuál de los dos usar. Vaciar la copia no pierde ni un carácter.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `metodo_correccion_curacion` contiene `locationRemarks_espejo_vaciado` → 500 registros.

**Si no corresponde.** Restaurar `locationRemarks_verbatim` sobre `locationRemarks` en esos 500.

**Pregunta.** ¿La repetición era un uso intencional del portal (por ejemplo, una plantilla de carga) o se puede dar por redundante?

---

## BLOQUE D — Coordenadas

### D1. [ALTA] Ochenta y cinco coordenadas que se arreglan invirtiendo la latitud (y un punto por defecto)

**El problema.** El punto cae en el hemisferio equivocado. Al invertir el signo de la latitud, la coordenada entra dentro de la provincia declarada. Estas coordenadas venían así en el dataset.

**Excepción masiva:** El punto `-0.871270 / -79.858440` (con latitud negativa) lo comparten 65 filas de cuatro provincias distintas (Esmeraldas 62, Orellana 1, Pichincha 1, Bolívar 1). Esto indica que no es un signo invertido al azar, sino un **punto por defecto** o de referencia mal propagado.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `coherencia_provincia = "discordante"` y `discordancia_explicada = "signo_latitud"` → 85 registros.

**Preguntas.**
1. ¿Autorizan invertir el signo de la latitud en las 20 filas restantes donde el módulo sí coincide con la localidad descrita?
2. Para las 65 filas en `-0.871270 / -79.858440`: ¿corresponden a una coordenada de referencia del sistema que sobreescribió a la real?

---

### D2. [ALTA] El ingreso QCAZ concentra el 83 % de las discordancias

**El problema.** Los registros cuyo `recordedBy` contiene `QCAZ` (593 con coordenada) fallan la contención provincial en 162 casos, el 27,3 %. Entre los otros 5.537 registros con coordenada hay 34 discordancias, el 0,6 %: la proporción de QCAZ es unas 44 veces mayor.

De las 196 discordancias actuales, 161 están en los catálogos 5100–5799. En el tramo 5600–5699, 37 de cada 100 filas son discordantes y 76 no tenían localidad en el archivo del portal (34 tras recuperar topónimos desde `locationRemarks`, ver C36).

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `recordedBy` contiene `QCAZ` y `decimalLatitude <> ""` → 593 registros; añadir `coherencia_provincia = "discordante"` → 162, el 82,7 % de las 196 discordancias. El reporte POST de contención provincial contiene los mismos 196 identificadores.

**Pregunta.** ¿Cómo se cargaron esos registros? ¿Fueron una migración desde otro sistema, una carga masiva sin georreferenciación propia, o se asignaron puntos por defecto al lote completo?

---

### D3. [BAJA] Trece banderas de hemisferio ambiguo

**El problema.** En trece registros falta evidencia para confirmar los signos. Doce están sin coordenadas publicables; el catálogo 3944 conserva la coordenada decimal original, marcada para revisión. La provincia declarada no basta para resolver una interpretación única.

**Filas afectadas.** 13: catálogos 3765, 3926, 3927, 3944, 4183, 4195, 4289, 4948, 4949, 5246, 5648, 5674 y 5678.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `signo_ambiguo = TRUE` → 13 registros.

**Corrección propuesta (no aplicada).** Catálogo 4195 (*Pareques viola*, especie marina): su verbatim es `00°54'5.8'' / 90°38'52''`, sin letra de hemisferio. Leído con 90° cae en el mar a 1.090 km de Manabí, la provincia declarada. Con un solo dígito cambiado, 80° en lugar de 90°, y hemisferio sur, queda en `-0.901611 / -80.647778`, frente a la costa de Manabí y a unos 9 km de los catálogos 4196–4198, que son del mismo equipo de colectores, de las mismas fechas (febrero y marzo de 2017) y están en `00°57'0.75''S / 80°42'32.73''W`. Se propone esa lectura; no se propone copiar la coordenada de los vecinos, porque los minutos del 4195 son distintos y apuntan a un sitio cercano, no al mismo. Se verifica con `catalogNumber = 4195`.

**Pregunta.** ¿Puede el curador determinar el hemisferio de estos trece registros desde la localidad descrita?

---

### D4. [MEDIA] Doce coordenadas con minutos o segundos mayores que 59

**El problema.** En notación sexagesimal, minutos y segundos van de 0 a 59. Estas doce declaran valores imposibles.

Los patrones sugieren hipótesis para tres de los cinco grupos, pendientes de confirmación documental:
- Catálogo 4184: `0.75''` (los hermanos 4196–4198 traen la longitud idéntica).
- Catálogo 4151: `07.3''` (sus hermanos 4149 y 4150 caen en el mismo minuto 34').
- Bobonaza (7 filas): se plantea `01°52'` como hipótesis para `01°92'` (la serie de colecta va de 43' a 52', y los 5904–5906 están en 01°52'57.2'').

Los doce casos requieren comprobar la fuente. En particular, 4212/4213 declaran `3°55'64''S` y 3765 declara 76,40 segundos (ver F10); no hay una representación independiente corroborada que resuelva esos valores.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `dms_rango_invalido = TRUE` → 12 registros.

**Pregunta.** ¿Pueden verificar las doce coordenadas en etiquetas o libretas, especialmente 4212, 4213 y 3765, y confirmar o rechazar las hipótesis?

---

### D5. [BAJA] Siete registros en el mar, alrededor de Galápagos

**El problema.** Siete registros tienen `coherencia_provincia = fuera_de_tierra_firme`, con distancias de 11,26 a 12 km al polígono terrestre. En una colección ictiológica pueden ser capturas marinas legítimas; la categoría por sí sola no demuestra un error ni confirma la procedencia.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `coherencia_provincia = "fuera_de_tierra_firme"` → 7 registros.

**Pregunta.** ¿Confirman que son capturas marinas legítimas? Solo necesito el visto bueno para dejar constancia de que se revisaron.

---

### D6. [ALTA] Doscientos noventa y siete registros sin coordenadas, por seis causas

**El problema.** Los 297 registros sin coordenadas finales requieren acciones diferentes según la evidencia conservada:

| Causa | n | Situación |
|---|---|---|
| `sin_dato_origen` | 183 | Nunca hubo coordenada, ni decimal ni verbatim |
| `irreparable` | 84 | Hay información de origen, pero no permite reconstruir un punto único con las reglas aprobadas |
| `dms_invalido_pendiente` | 12 | Minutos o segundos fuera de rango; confirmar la fuente |
| `signo_ambiguo` | 11 | Falta evidencia suficiente de hemisferio |
| `utm_ambiguo` | 5 | No hay una interpretación UTM única respaldada |
| `descartada_fuera_de_rango` | 2 | Catálogos 5170 y 5612; las posiciones decimales se descartaron y no hay verbatim suficiente para reconstruirlas |

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `decimalLatitude = ""` y `decimalLongitude = ""` → 297. Agrupar por `metodo_correccion` reproduce los seis grupos; no basta con filtrar solo las tres categorías originales.

**Preguntas.**
1. Para los 84 irreparables y los casos pendientes por DMS, signo o UTM: ¿existe la coordenada en el libro de campo?
2. Para el catálogo 5170: ¿es un ejemplar peruano mal asignado a Pastaza, o la coordenada pertenece a otro registro?

---

### D7. [MEDIA] Ochenta y cuatro coordenadas irreparables con patrones que requieren revisar la fuente

**El problema.** D6 incluye 84 registros con `metodo_correccion = irreparable`. Los patrones siguientes ofrecen hipótesis de lectura, pero no autorizan una reconstrucción automática ni agotan los 84 casos.

| Familia | Filas | Situación |
|---|---|---|
| Prefijo de zona UTM pegado al easting | 4033, 4035 | `17828629 / 9809829` es zona 17, E 828629, N 9809829, y cae en Pastaza. `18193103 / 9823038` es zona 18 y también cae en Pastaza |
| Easting y northing invertidos | 5013 | `09993222/0746084` es N 9993222 / E 746084, par válido en zona 17S |
| Punto decimal perdido | 4947–5013, 13 filas | El catálogo 5011 trae `0016647/7887937`, dígito por dígito el mismo valor que el 4948 `00.16647/78.87937`, cuya lectura también está pendiente por ambigüedad de signo |
| Easting corto de un dígito | El Oro 3897–3917 (20) y Pastaza 3518–3526 (9) | `65536 / 9612584`: el northing es válido, al easting le falta un dígito. Admite dos lecturas y ambas caen en la provincia |
| Rango en lugar de punto | 4222–4227, 6 filas | `78.28°W / 01.27°N / 00.01°S` son tres valores: una longitud y **dos latitudes** |

El catálogo 4187 declara `01°40'45.55 / 71°54'53''`. La latitud coincide con la del 4201 (`01°40'45.551''`) hasta el centésimo de segundo, pero la longitud no comparte ni los minutos (54 frente a 59) ni los segundos (53 frente a 53.448). La hipótesis de sustitución de dígito se sostiene únicamente para el grado (71 frente a 91). El registro quedó clasificado como irrecuperable.

Otros casos pendientes son 4037, 4176–4178, 4246, 4353–4357, 4702, 5292 y 6425–6427. En 4353–4357 puede faltar el punto decimal; 4037 podría llevar la zona UTM pegada al easting; y en 4246 la latitud podría haber perdido el punto. El catálogo 5292 también permanece sin coordenada recuperada. Son hipótesis para contrastar con la fuente, no correcciones aplicadas.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `metodo_correccion = "irreparable"` → 84 registros.

**Preguntas.**
1. Para 4033 y 4035: ¿confirman que el `17` y el `18` iniciales son la zona UTM? Si sí, esas dos se recuperan sin supuestos.
2. Para el bloque 4222–4227: ¿fue un transecto entre 01°27'N y 00°01'S, o una de las dos latitudes está de más?
3. Para el catálogo 4187: ¿es 91°54'53"W?
4. Para los bloques de El Oro y Pastaza: ¿existe libreta de campo? Con un solo punto verificado se resuelven.

---

### D8. [MEDIA] Cincuenta y seis alertas de provincia minoritaria en coordenadas compartidas

**El problema.** Hay 487 registros con `coordenada_compartida = TRUE`, usando la clave del país y la coordenada redondeada a cinco decimales. De ellos, 56 tienen `provincia_minoritaria = TRUE`. Puede tratarse de un límite provincial o de un punto de referencia compartido; el patrón no demuestra por sí solo una copia errónea.

**Filas afectadas.** 56, marcadas en el anexo con `provincia_minoritaria = TRUE`.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `provincia_minoritaria = TRUE` → 56 registros.

En los empates de frecuencia, la bandera utiliza la discordancia de contención provincial sin escoger una provincia mayoritaria arbitrariamente. El reporte POST contiene las mismas 56 alertas.

**Pregunta.** ¿Estos 56 comparten evento de colecta con los demás de su coordenada, o se les asignó una coordenada de referencia por lote?

---

### D9. [BAJA] Cuatro registros con coordenada y sin provincia declarada

**El problema.** Tienen coordenada válida pero `stateProvince` vacío, así que no hay contra qué contrastarla. Quedaron como `no_evaluable`.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `coherencia_provincia = "no_evaluable"` → 4 registros.

**Pregunta.** ¿Pueden completar la provincia, o la derivo de la coordenada y lo documento como derivación?

---

### D10. [ALTA] Cuatrocientas sesenta imputaciones de datum y 952 banderas acumuladas

**El problema.** La entrada de la última curación contiene 460 registros con coordenada y `geodeticDatum` vacío. Los valores declarados son WGS84 (4.758) o EPSG:4326 (998), pero eso no demuestra el datum histórico de los registros sin declaración. La salida final acumula 952 `datum_asumido = TRUE`: 492 heredadas de la Fase 2 y 460 añadidas por R6.

**Cambio aplicado.** R6 escribió WGS84 en sus 460 registros, conservó la marca `datum_asumido = TRUE` y anotó el supuesto en `georeferenceRemarks`. Las 492 marcas anteriores permanecen identificadas como evidencia de otra etapa.

**Por qué importa.** Si la colección usó PSAD56 en los registros antiguos —datum común en cartografía ecuatoriana anterior al GPS— el desplazamiento respecto a WGS84 puede superar los 200 m, lo que invalidaría el radio de incertidumbre declarado.

**Cómo aislar los registros.** En `ocurrences_curado.csv`, `metodo_correccion_curacion` contiene `datum_declarado_por_supuesto` → 460 imputaciones de R6. `datum_asumido = TRUE` → 952 marcas acumuladas; los filtros no son equivalentes.

**Si no corresponde.** Para revertir R6, usar sus 460 identificadores y los valores anteriores de `geodeticDatum`, `georeferenceRemarks` y `datum_asumido` en `reporte_correcciones.csv`. No vaciar indiscriminadamente los 952 registros, pues se alterarían también las decisiones de la Fase 2.

**Preguntas.**
1. ¿Toda la colección se georreferenció en WGS84, o los registros anteriores a determinada fecha usaron PSAD56 u otro datum?
2. ¿Se confirma el supuesto o se revierten las 460 imputaciones de R6 a campo vacío?

---

### D11. [MEDIA] Ciento noventa y una altitudes en el campo equivocado

**El problema.** 191 registros declaraban altitud máxima sin altitud mínima. En la colección no existe ningún rango real de altitud: antes de la curación, 4.519 registros declaraban solo el mínimo, 191 solo el máximo, y los 2 únicos con ambos campos los tienen iguales.

**Cambio aplicado.** El valor se movió a minimumElevationInMeters; el original quedó en verbatimElevation.

**Por qué importa.** Al entrar esas 191 altitudes al campo que evalúan las reglas de plausibilidad, 17 resultaron anómalas: 14 contra el modelo digital de elevación y 3 contra el rango altitudinal de su especie (ver D16, I3). Antes estaban ocultas.

**Cómo aislar los registros.** `verbatimElevation` no vacío

**Si no corresponde.** Filtrar `verbatimElevation` no vacío y devolver el valor a `maximumElevationInMeters`, vaciando `minimumElevationInMeters`.

**Preguntas.**
1. ¿Se confirma que son altitudes puntuales y no el techo de un rango?
2. Para las 17 que quedaron marcadas como anómalas, ¿se revisa la etiqueta física?

---

### D12. [BAJA] Falta de atributos de masas de agua en capturas marinas

**El problema.** Galápagos: 24 filas tienen `island`, `islandGroup` y `waterBody` vacíos al 100 %, incluidas las siete capturas clasificadas como marinas. Con la coordenada ya reconstruida se pueden poblar esos campos derivados.

**Pregunta.** ¿Autorizan derivar `island` desde el polígono y declarar `waterBody`?

---

### D13. [BAJA] Localidad "Varios Sitios" con falsa precisión

**El problema.** Los siete registros con `locality = "Varios Sitios"` tienen `coordinateUncertaintyInMeters` vacío en el conjunto final. La columna auxiliar `incertidumbre_estimada_m` contiene 100 m como estimación, no como incertidumbre confirmada o publicada. Los siete tienen resolución numérica de seis decimales (`decimal_6d`); esto no demuestra exactitud de diez metros ni el radio de toda la localidad. Cuatro caen fuera del polígono terrestre de Galápagos.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `catalogNumber` IN (61, 64, 65, 66, 67, 69, 71) → 7 registros.

**Pregunta.** ¿Qué representa la coordenada digitada y qué sitios abarca cada lote? ¿Existe documentación que permita determinar el radio de incertidumbre de toda la localidad?

---

### D14. [MEDIA] Treinta y dos alertas de coordenada minoritaria dentro de su localidad

**El problema.** La comprobación de coherencia mide contención en el polígono de la provincia, de modo que no ve el caso en que varias filas declaran la misma localidad y una cae a decenas de kilómetros de las demás dentro de la misma provincia. Comparando cada registro contra la coordenada mayoritaria de su propia localidad —en grupos de cinco filas o más y donde al menos el 80 % comparte un mismo punto— resultan 32 filas repartidas en 17 casos del reporte POST.

| Cat. | Provincia | Localidad | Filas del grupo | Distancia a la mayoría |
|---|---|---|---|---|
| 6247, 6290 | Pastaza | Kawoa | 88 | 57,1 km |
| 6242 | Pastaza | Yandanaentsa | 67 | 46,2 km |
| 251 | Sucumbíos | Comunidad Alto Rodríguez Río Gueppi | 8 | 47,3 km |
| 5198 | Sucumbíos | Estero S/N T2 Sansahuari | 13 | 42,9 km |
| 2529 | Pastaza | Sector Villano A-B | 9 | 39,2 km |
| 3833 | Pastaza | Pavacachi Yacu | 13 | 35,2 km |
| 99 | Orellana | Indillana | 6 | 29,5 km |
| 1269 | Sucumbíos | Aguas Negras | 14 | 27,7 km |
| 3891 | El Oro | Río Chaguana | 8 | 18,5 km |
| 2408 | Pichincha | Camino a Palmira | 6 | 14,2 km |

En los catálogos 6242, 6247 y 6290 el método de coordenadas registra `swap`: se corrigió una transposición de ejes. Por tanto, no corresponde atribuir todos los puntos exclusivamente al origen. La discrepancia entre localidad y coordenada sigue pendiente y no autoriza a copiar la posición mayoritaria.

Dos filas más aparecen en la lista por el motivo contrario: en `Atacames` (catálogo 5180) y en `Súa` (catálogo 18) la mayoría del grupo es la que está mal —son las latitudes invertidas de D1— y el minoritario es el correcto. El catálogo 5180 declara `0.87127 / -79.85844` y sus 22 hermanos declaran `-0.87127` con la misma longitud.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `flag_coord_minoritaria_en_localidad = TRUE` (32), columna `dist_a_mayoria_localidad_km`.

**Pregunta.** En los 30 registros restantes, además de los dos casos inversos descritos, ¿la coordenada pertenece a otro sitio del mismo lote o la localidad está mal escrita en esas filas?

---

### D15. [MEDIA] Autoría de la georreferencia

**El problema.** El conjunto final no atribuye georreferencias al proceso de limpieza. Conserva 3.501 registros con `Mateo Andrés Vega Yánez` y 2.926 sin `georeferencedBy`; 2.629 de estos últimos tienen coordenadas. Transformar una representación de coordenadas no identifica a quien proporcionó ni verificó la georreferencia.

**Preguntas.** ¿Quién proporcionó y quién verificó las georreferencias de los 2.629 registros con coordenada y sin autoría? ¿Existe evidencia para confirmar a Mateo Andrés Vega Yánez o a otro responsable, sin extender una autoría por defecto?

---

### D16. [BAJA] Contraste altitudinal contra modelo digital de elevación

**El problema.** 70 registros declaran una altitud que discrepa del DEM en más de 300 m. La cifra subió de 56 en PRE a 70 en POST tras la curación: catorce de las altitudes que pasaron del campo máximo al mínimo (ver D11) resultaron discordantes al evaluarse por primera vez. La referencia se conserva en `datos/00_referencia/dem_elevatr.rds`: AWS mediante elevatr, z = 10, EPSG:4326 y metros. La caché cubre las 953 coordenadas únicas de POST (924 necesarias en PRE), sin nuevas descargas. Es el único control altitudinal del pipeline que no usa la propia colección como referencia.

**Pregunta.** ¿Se corrige la altitud declarada, se conserva la de la etiqueta física, o se declaran ambas?

---

### D17. [BAJA] Ciento noventa y siete filas contiguas con los ejes transpuestos

**El problema.** Los catálogos 6228 a 6424, 197 filas de Fernando Sánchez en Pastaza (2024-2025), tienen los ejes transpuestos en el 100 % del lote.

**Pregunta.** ¿Es un defecto de la plantilla de carga del portal? ¿Se corrige la transposición?

---

## BLOQUE E — Personas

### E1. [MEDIA] Un mismo colector con tres grafías del apellido

**El problema.** Conviven `M. Ampam` (240 registros), `M. Ampak` (23) y `Miguel Ampa` (21). `Ampam` y `Ampak` son terminaciones válidas en shuar, así que no puedo decidir cuál es la correcta sin conocer a la persona. Si no se unifica, la dimensión Persona tendrá tres miembros para un solo colector y sus 284 registros aparecerán repartidos.

**Pregunta.** ¿Cuál es la grafía correcta del nombre de esta persona?

---

### E2. [MEDIA] Instituciones y proyectos escritos en el campo de colector

**El problema.** El campo `recordedBy` de Darwin Core es para personas. Estos valores no lo son:

| Valor | Apariciones | Qué es |
|---|---|---|
| `QCAZ` | 728 | Museo de Zoología de la PUCE |
| `GLOWS` | 171 | Proyecto de investigación |
| `Gueppi` | 128 | Proyecto o área protegida peruana |
| `Simbioe` | 27 | Organización |
| `Indígenas` | 1 | Descripción genérica, no una persona |
| `JVDC` | 1 | Sigla sin desarrollar |

En muchos registros aparecen concatenados con personas reales, por ejemplo `QCAZ | Franklin Pasquel`.

**Cómo aislar los registros.** En `reporte_plausibilidad_post.csv`: `regla = "institucion o proyecto en el campo de colector"` → 1056 registros.

**Preguntas.**
1. ¿Estas entidades deben moverse a `institutionCode` / `associatedReferences` y salir de `recordedBy`?
2. ¿`Indígenas` corresponde a colectores comunitarios de los que exista registro nominal?
3. ¿Qué significa `JVDC`?

---

### E3. [MEDIA] La misma persona registrada como abreviatura y como nombre completo

**El problema.** Dieciocho pares que muy probablemente son la misma persona, y diez abreviaturas que no se pueden completar desde el propio archivo. No puedo unificar sin confirmación: una abreviatura puede corresponder a dos personas con el mismo apellido.

Los conteos suman las apariciones en `recordedBy`, `identifiedBy` y `recordEnteredBy`: por ejemplo, `María Belén Carrillo` figura solo como digitadora.

Los conteos suman las apariciones en `recordedBy`, `identifiedBy` y `recordEnteredBy`.

**Pares con nombre completo en el archivo** (registros con la abreviatura / con el nombre completo):

| Abreviatura | Nombre completo | Registros |
|---|---|---|
| `K. Swing` | `Kelly Swing` | 58 / 59 |
| `Belén Carrillo` | `María Belén Carrillo` | 12 / 54 |
| `C. Puertas` | `Cecilia Puertas Donoso` | 91 / 47 |
| `L. Chuim` | `Liseth Chuim` | 220 / 21 |
| `I. Narankas` | `Israel Narankas` | 55 / 21 |
| `G. Narankas` | `Germán Narankas` | 32 / 21 |
| `L. Guarderas` | `Lida Guarderas` | 1 / 309 |
| `E. Calvache` | `Evelyn Calvache` | 1 / 180 |
| `Omar Domínguez` | `Omar Domínguez Domínguez` | 1 / 33 |
| `S. Vega` | `Santiago Vega` | 6 / 6 |
| `L. Coloma` | `Luis Coloma` | 3 / 4 |
| `R. Ramírez` | `Raúl Ramírez` | 3 / 3 |
| `P. Paredes` | `Patricia Paredes` | 1 / 4 |
| `F. Ulloa` | `Fausto Ulloa` | 1 / 3 |
| `S. Abril` | `Sara Abril` | 1 / 3 |
| `R. Boada` | `Ruth Boada` | 2 / 2 |
| `A. Galarza` | `M. A. Galarza` | 2 / 1 |
| `M. Gaybor` | `Margarita Gaybor` | 1 / 1 |

**Abreviaturas sin un nombre completo inequívoco en el archivo:**

| Abreviatura | Registros | Situación |
|---|---|---|
| `N. Narankas` | 264 | El Narankas más frecuente, y ningún Narankas con N aparece con nombre completo |
| `P. Chuim` | 22 | Solo existe `Liseth Chuim` completo, con otra inicial |
| `J. Vásquez` / `C. Vásquez` | 9 / 3 | Ningún Vásquez con nombre completo |
| `P. Casco` / `H. Casco` | 7 / 5 | Ningún Casco con nombre completo |
| `S. Paredes` | 3 | Solo existe `Patricia Paredes`, con otra inicial |
| `M. Sánchez` | 2 | Podría ser `M. E. Sánchez` (6) o `M. G. Sánchez` (1) |
| `D. Sánchez` | 2 | Ningún D. Sánchez con nombre completo |
| `J. Córdova` | 1 | Podría ser `Jorge Córdova` (2) o `José Córdova` (2) |
| `J. Ulloa` | 1 | Solo existe `Fausto Ulloa`, con otra inicial |
| `E. Grijalva` | 1 | Solo existe `Mario Grijalba`, con otra inicial y otra grafía |

**Preguntas.**
1. ¿Puedo unificar cada par al nombre completo?
2. `C. Vásquez` y `J. Vásquez`, ¿son dos personas distintas?

---

### E4. [BAJA] Nombres incompletos que no permiten identificar a la persona

**El problema.** Registros donde solo hay apellido, solo nombre de pila o solo iniciales.

| Valor | Registros | Falta |
|---|---|---|
| `A.E.`, `M.O.`, `T.N.` | 69 cada uno | Nombre completo detrás de las iniciales |
| `Geovanni` | 19 | Apellido |
| `G.M.W.` | 11 | Nombre completo |
| `R.A.P.` | 4 (en 2 filas) | Nombre completo |
| `Rodríguez` | 3 | Nombre de pila |
| `E.P.` | 2 | Nombre completo |
| `C.P.` | 1 | Nombre completo |
| `Ma. Serena` | — | Abreviatura sin apellido |

Las tres primeras suman 207 registros, no es un caso marginal.

**Cómo aislar los registros.** En `reporte_plausibilidad_post.csv`: `regla = "colector reducido a iniciales sin nombre desarrollado"` → 83 registros.

**Pregunta.** ¿A quién corresponden estas iniciales? Aparecen juntas en los mismos registros, así que probablemente sean un equipo de campo identificable.

---

### E5. [BAJA] Nombres con grafía dudosa

**El problema.** Nombres que parecen erratas, o que parecen la misma persona que otra forma presente en el archivo. Cuando la tabla dice «¿La misma persona que…?», la pregunta es si las dos formas deben unificarse. No toco ninguno, porque un nombre propio puede escribirse de forma inesperada y corregirlo por mi cuenta sería inventar una identidad.

| Como aparece | Posible forma correcta | Registros |
|---|---|---|
| `Fermando Romero` | ¿Fernando? | 1 |
| `Agusta Córdova` | Convive con `Agusto Córdova` (5689) y `A. Córdova` (5735) en el mismo lote QCAZ | 1 |
| `Edwin Carrilo` | ¿Carrillo? | 1 |
| `A. Guiterez` | ¿La misma persona que `Sara Gutiérrez` (2), pese a la otra inicial? | 1 |
| `M. Grijalva` | ¿La misma persona que `Mario Grijalba` (1)? | 1 |
| `M. Peñaherera` | ¿Errata de Peñaherrera, como `S. Peñaherrera` (1)? | 1 |
| `Francis Boily` | ¿Es `Francis Boyle` (1) o familiar de `Dylan Boily` (1)? | 1 |
| `Paola Nallely Plamerín Serrano` | ¿Palmerín? | 2 |
| `Paúl Ramírez` | ¿Errata de `Raúl Ramírez` (3)? | 1 |
| `Paul Regalado` | ¿Paúl? | 288 |
| `Pablo Arguello` | ¿Argüello? | 299 |
| `Martin Cuji` | ¿Martín? | 144 |
| `Guillermo Orti` | ¿Ortí? | 2 |
| `Yarlnyn Jaramillo` | ¿Yarlyn? ¿Marilyn? | 1 |
| `Rossana Manosalva` / `Rosa Manosalva` | ¿La misma persona? | 2 / 1 |
| `J. Críollo` | ¿Criollo, sin tilde? | 7 |
| `Santiago Villamarín Cortéz` | ¿Cortés o Cortez? | 131 |

**Cómo aislar los registros.** En `reporte_plausibilidad_post.csv`: `regla = "valor a una letra de otro valor de recordedBy"` y `campos = "recordedBy"` → 9 alertas en 9 registros. Las reglas equivalentes de `locality` producen 19 alertas en 16 registros y las de `scientificName`, cinco en cinco. Los empates se expresan neutralmente, sin convertir la forma más frecuente en autoridad.

**Pregunta.** ¿Pueden confirmar la grafía correcta de cada uno? El de Villamarín afecta a 131 registros.

---

## BLOQUE F — Taxonomía

### F1. [ALTA] Nueve registros repartidos en dos banderas cuya familia pertenece a un orden distinto al del género

**El problema.** La familia declarada no solo es minoritaria dentro del género: pertenece a un orden completamente distinto. No son casos discutibles taxonómicamente.

| Catálogo | Nombre | Familia declarada | flag_family_orden_discrepante | flag_orden_minoritario_en_familia |
|---|---|---|---|---|
| 5322 | `Ilisha` | Cichlidae | Sí | Sí |
| 777 | `Sternarchorhynchus curvirostris` | Astroblepidae | Sí | Sí |
| 1157 | `Peckoltia` | Hypopomidae | Sí | Sí |
| 3582 | `Sternopygus macrurus` | Callichthyidae | Sí | Sí |
| 3650 | `Sternopygus macrurus` | Callichthyidae | Sí | Sí |
| 4337 | `Anisotremus` | Rivulidae | Sí | Sí |
| 4185 | `Paranthias colonus` | Serrasalmidae | No | Sí |
| 4186 | `Serranus psittacinus` | Serrasalmidae | No | Sí |
| 4201 | `Holacanthus passer` | Pomacentridae | No | Sí |

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `flag_family_orden_discrepante = TRUE` (6) o `flag_orden_minoritario_en_familia = TRUE` (9).

**Pregunta.** ¿Corrijo la familia desde el backbone de FishBase, igual que hice con las familias vacías, o prefieren revisarlas?

---

### F2. [MEDIA] Noventa y tres registros con familia minoritaria dentro de su género

**El problema.** Un género tiene registros repartidos en dos familias distintas. A diferencia de F1, aquí ambas familias son del mismo orden, lo que apunta a eventos de reclasificación taxonómica reales y no a errores. Los bloques mayores:

| Familia declarada | Familia mayoritaria del género | Filas |
|---|---|---|
| Characidae | Iguanodectidae | 17 |
| Triportheidae | Characidae | 16 |
| Characidae | Bryconidae | 12 |
| Curimatidae | Prochilodontidae | 3 |
| Characidae | Curimatidae | 5 |
| Pimelodidae | Heptapteridae | 5 |
| Characidae | Acestrorhynchidae | 2 |

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `flag_family_minoritaria = TRUE` → 93 registros.

**Preguntas.**
1. ¿Se unifica cada género a una sola familia según la clasificación vigente, o se conserva la familia con la que se determinó cada ejemplar?
2. Si se unifica, ¿qué clasificación se toma como referencia: FishBase, Eschmeyer's Catalog of Fishes, u otra?

---

### F3. [MEDIA] Dieciséis registros donde el nombre completo contradice a los campos atomizados, y en nueve hay tres indicios internos

**El problema.** En dieciséis registros, `scientificName` describe una especie y `genus` más `specificEpithet` describen otra. Los campos atomizados, el nombre mayoritario asociado con `taxonID` y la autoría comparada dentro de la colección aportan tres indicios de inconsistencia interna. En nueve registros los tres coinciden contra `scientificName`, pero proceden del mismo conjunto y no constituyen fuentes taxonómicas independientes ni determinan qué nombre es correcto.

| Cat. | `scientificName` publicado | `genus` + `specificEpithet` | El `taxonID` de la fila lo usan | La autoría de la fila corresponde a | Indicios |
|---|---|---|---|---|---|
| 1244 | Creagrutus flavescens | Creagrutus beni | 10 filas de *Creagrutus beni* | Eigenmann, 1911 (*beni*) | 3 |
| 1804 | Astyanax villwocki | Astyanax abramis | 59 filas de *Astyanax abramis* | (Jenyns, 1842) (*abramis*) | 3 |
| 1980 | Hoplerythrinus unitaeniatus | Erythrinus erythrinus | 22 filas de *Erythrinus erythrinus* | (Bloch & Schneider, 1801) | 3 |
| 2008 | Astyanax villwocki | Tetragonopterus argenteus | 37 filas de *T. argenteus* | Cuvier, 1816 (*argenteus*) | 3 |
| 2075 | Pimelodella lateristriga | Pimelodella grisea | 17 filas de *P. grisea* | (Regan, 1903) (*grisea*) | 3 |
| 2308 | Crenicichla saxatilis | Crenicichla cincta | 7 filas de *C. cincta* | Regan, 1905 (*cincta*) | 3 |
| 2331 | Astyanax villwocki | Astyanax fasciatus | 2 filas de *A. fasciatus* | (Cuvier, 1819) (*fasciatus*) | 3 |
| 2348 | Hemiodus unimaculatus | Hemiodus microlepis | 5 filas de *H. microlepis* | Kner, 1858 (*microlepis*) | 3 |
| 2358 | Curimata vittata | Steindachnerina bimaculata | 12 filas de *S. bimaculata* | (Steindachner, 1876) | 3 |
| 1851 | Pimelodus blochii | Pimelodus albofasciatus | taxonID exclusivo de la fila | Mees, 1974 (*albofasciatus*) | 2 |
| 2084 | Charax tectifer | Charax gibbosus | taxonID exclusivo de la fila | (Linnaeus, 1758) (*gibbosus*) | 2 |
| 2804 | Moenkhausia dichroura | Moenkhausia lepidura | 30 filas de *M. lepidura* | mayoritaria para su nombre | 2 |
| 531 | Pimelodella lateristriga | *Pimelodus* lateristriga | 3 filas de *Pimelodus* | sin autoría en el portal; hoy `(Lichtenstein, 1823)`, importada de `identifications.csv` | 1 |
| 2208, 2234, 2339 | Anablepsoides urophthalmus | *Rivulus* urophthalmus | *A. urophthalmus* | mayoritaria para su nombre | 2 |

Los tres registros de `Rivulus` no son un error: `Rivulus` es el género anterior de `Anablepsoides`, el epíteto coincide y el `taxonID` apunta al nombre nuevo. Es un campo atomizado que no se actualizó tras un cambio de combinación.

Hay un efecto medible en la jerarquía: los catálogos 531 y 2075 publican el mismo `scientificName` (`Pimelodella lateristriga`) y terminan en familias distintas, Pimelodidae y Heptapteridae, porque cada uno heredó la familia de su propio género divergente.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `flag_nombre_contradice_atomicos = TRUE` (16) y `testigos_contra_scientificName = 3` (9).

**Preguntas.**
1. En los nueve registros con tres indicios internos, ¿cuál es la identificación respaldada por el ejemplar y su historial de determinaciones?
2. Si `scientificName` corresponde a la redeterminación correcta y los otros cuatro campos quedaron viejos, ¿se actualizan `genus`, `specificEpithet`, `taxonID` y `scientificNameAuthorship` a partir de `scientificName`?
3. ¿Cuál de los dos, 531 o 2075, es *Pimelodella lateristriga*?

**Doce donde discrepa el epíteto** (marcadas con `flag_epiteto_no_coincide_con_nombre`):

| catalogNumber | `scientificName` | `specificEpithet` declarado |
|---|---|---|
| 1244 | Creagrutus flavescens | beni |
| 1804 | Astyanax villwocki | abramis |
| 1851 | Pimelodus blochii | albofasciatus |
| 1980 | Hoplerythrinus unitaeniatus | erythrinus |
| 2008 | Astyanax villwocki | argenteus |
| 2075 | Pimelodella lateristriga | grisea |
| 2084 | Charax tectifer | gibbosus |
| 2308 | Crenicichla saxatilis | cincta |
| 2331 | Astyanax villwocki | fasciatus |
| 2348 | Hemiodus unimaculatus | microlepis |
| 2358 | Curimata vittata | bimaculata |
| 2804 | Moenkhausia dichroura | lepidura |

Varios pares son sinónimos conocidos (`Rivulus`/`Anablepsoides`), lo que sugiere que el campo atomizado quedó con el nombre anterior.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `flag_genus_no_coincide_con_nombre = TRUE` (12) o `flag_epiteto_no_coincide_con_nombre = TRUE` (12).

**Pregunta.** ¿Manda `scientificName` o el par `genus` + `specificEpithet`?

---

### F4. [ALTA] Seis registros con ejemplar y sin identificación taxonómica

**El problema.** Tienen colector, fecha, localidad, coordenada, preparación y número de ejemplares — todo menos el taxón. Uno de ellos declara 134 ejemplares.

| catalogNumber | Colector | Fecha | Localidad | Ejemplares |
|---|---|---|---|---|
| 1309 | Martha Buenaño Carriel | 2008-12-22 | Noreste de Tarapoa | 2 |
| 1343 | Martha Buenaño Carriel | 2009-01-11 | Cuyabeno | **134** |
| 1455 | Martha Buenaño Carriel | 2009-01-10 | Río Cuyabeno | 1 |
| 1733 | Jonathan Valdiviezo | 2010-03-22 | Lago Agrio, Estero Chananguecillo | 4 |
| 1743 | Jonathan Valdiviezo | 2010-04-19 | Comunidad Santa Elena, Estero Cuencano | 8 |
| 3794 | Lida Guarderas | 2005-09 | Morete Yacua | 4 |

Nota: el catálogo 4322 (Paúl Tufiño, 2019-10-23, Quebrada S/N) fue rescatado parcialmente con `Characidae` desde `identifications.csv`, por lo que su `flag_sin_taxonomia = FALSE` y se trata en la sección G1.

**Por qué importa.** En el modelo dimensional son hechos sin dimensión Taxón. O se les asigna un miembro "sin determinar" o quedan fuera de todo análisis taxonómico.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `flag_sin_taxonomia = TRUE` → 6 registros.

**Preguntas.**
1. ¿Estos ejemplares están sin determinar en el depósito o se perdió la determinación al digitalizar?
2. ¿Los incluyo como "sin determinar" o los excluyo?

---

### F5. [MEDIA] Cuatro registros que solo tienen un nombre de familia

**El problema.** Cuatro registros (catálogos 4371 a 4374) están determinados únicamente hasta familia, sin género ni especie. En el catálogo 4371 la grafía `Asprenidae` ya se corrigió a `Aspredinidae`; los cuatro siguen siendo válidos como determinación a nivel de familia.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `catalogNumber` IN (4371, 4372, 4373, 4374) → 4 registros.

**Pregunta.** ¿Son registros reales pendientes de catalogar, o filas de prueba que quedaron en el sistema?

---

### F6. [MEDIA] Veinticinco registros determinados solo hasta familia

**El problema.** No es un error —es una determinación legítima a nivel de familia— pero conviene confirmarlo. Los nombres involucrados: `Aspredinidae`, `Aulopidae`, `Characidae`, `Heptapteridae`, `Lebiasinidae`, `Loricariidae`, `Loricariinae`, `Sternopygidae`.

Nota: `Loricariinae` (catálogo 4306) es una **subfamilia**, no una familia, y su `taxonRank` ya lo declara como `subfamily`; aparece aquí porque la bandera `identificado_a_nivel_familia` la incluye.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `identificado_a_nivel_familia = TRUE` → 25 registros.

**Pregunta.** ¿Confirman que son determinaciones a nivel de familia y no identificaciones incompletas pendientes?

---

### F7. [ALTA] Diecinueve identificadores de taxón apuntan a más de un nombre

**El problema.** `taxonID` debería identificar un concepto taxonómico de forma única. Diecinueve valores apuntan a dos o tres nombres distintos (y afectan a 464 filas):

| `taxonID` | Nombres asociados |
|---|---|
| 35235 | Astyanax · Astyanax villwocki · **Jupiaba** |
| 35854 | Pimelodella lateristriga · Pimelodus · Pimelodus blochii |
| 35377 | Characidium · Characidium purpuratum · Characidium steindachneri |
| 35293 | Bryconamericus · **Knodus** |
| 35581 | Astyanax · **Hemigrammus** |
| 35962 | Anablepsoides · Rivulus |
| 36029 | Curimata vittata · Steindachnerina bimaculata |
| 36061 | Astyanax villwocki · Tetragonopterus argenteus |
| *(y once más)* | |

Algunos son sinonimias razonables (`Rivulus`/`Anablepsoides`); otros cruzan géneros distintos. El nombre mayoritario asociado con `taxonID` es un indicio interno de la colección, no una autoridad independiente para sustituir `scientificName`.

**Por qué importa.** Impide usar `taxonID` como clave natural de la dimensión Taxón: habría que generar una clave sustituta.

**Cómo aislar los registros.** En `reporte_plausibilidad_post.csv`: `regla = "inconsistencia (cruce) entre taxonID y scientificName"` → 42 hallazgos. Los 464 registros del grupo completo de 19 `taxonID` ambiguos no equivalen al subconjunto señalado por el reporte. Se incluyen además ambos catálogos 6105 y 3624 de `Paratrygon aiereba`, con `taxonID` 35821 y 35822 y frecuencia uno cada uno, descritos como empate sin mayoría única; ninguno se corrige automáticamente.

**Pregunta.** ¿El `taxonID` es un identificador estable del portal o se reasigna al redeterminar? Determina si sirve como clave o solo como referencia.

---

### F8. [ALTA] Géneros sin correspondencia en FishBase y casos no concluyentes en GBIF

**El problema.** Dieciséis géneros sin correspondencia en FishBase afectan a 64 registros del conjunto final. El contraste congelado de sus nombres científicos completos con GBIF se distribuye así; la tabla cuenta filas, no consultas nuevas de géneros aislados:

| Resultado GBIF del nombre publicado | Filas | Lectura |
|---|---|---|
| `EXACT` | 36 | Coincidencia de nombre documentada, sin verificar la identificación del ejemplar |
| `VARIANT` | 12 | Sugerencias ortográficas o nomenclaturales que requieren revisión |
| `HIGHERRANK` | 15 | Correspondencia solo a un rango superior |
| `NONE` | 1 | Catálogo 6045, `Saxatalia lucius`, sin correspondencia |

Las sugerencias de grafía incluyen `Cynoponthicus` → *Cynoponticus*, `Jurengranulis` → *Jurengraulis*, `Orthropristis` → *Orthopristis*, `Rhandinoloricaria` → *Rhadinoloricaria*, `Sorubumichthys` → *Sorubimichthys* y `Sternachella` → *Sternarchella*. Se mantienen como propuestas de F12, no como identificaciones confirmadas.

El archivo ofrece también una hipótesis para `Durlanis perugiae` (catálogo 6046): once registros usan `Duringlanis perugiae` con la misma autoría. El contraste GBIF actual solo resuelve el primero a un rango superior; la frecuencia interna no basta para corregirlo.

**Siguen pendientes las grafías `Saxatilia` y `Saxatalia`.** Cinco registros publican `Saxatilia` (5891, 5925, 5967, 6270 y 6271), cuyos binomios solo resuelven a un rango superior; el 6045 conserva `Saxatalia lucius` y tiene `NONE`. Debe confirmarse la validez y referencia de esos nombres, sin asumir una segregación reciente solo por ausencia en los backbones.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: filtrar `genero_fuera_de_backbone_fishbase = TRUE`.

**Corrección propuesta (no aplicada).** Catálogo 6046: `Durlanis perugiae` → `Duringlanis perugiae`. Once registros usan la grafía correcta con la misma autoría `(Steindachner, 1882)` frente a uno con la errata. Se verifica con `catalogNumber = 6046`.

**Pregunta.** ¿`Saxatilia` es un género válido de descripción reciente todavía ausente de FishBase y de GBIF, o es una grafía que hay que sustituir? Si es válido, ¿cuál es la referencia de su descripción para citarla en el conjunto de datos? Para el catálogo 6045, ¿la grafía original `Saxatalia lucius` corresponde a `Saxatilia lucius`?

---

### F9. [MEDIA] Nueve registros repartidos en siete familias con `order` en dos estados

**El problema.** Dentro de una misma familia, un registro tiene un orden declarado distinto al resto del grupo. No obedece al criterio de vaciado: son registros defectuosos. Las siete familias afectadas son Astroblepidae, Callichthyidae, Cichlidae, Hypopomidae, Pomacentridae, Rivulidae y Serrasalmidae, con un total de 9 filas en la minoría. La discrepancia del catálogo 4201 (familia Pomacentridae frente al género *Holacanthus*, que pertenece a Pomacanthidae) no se ha corregido.

**Corrección propuesta (no aplicada).** Catálogo 4201: `family = Pomacentridae` → `Pomacanthidae`. *Holacanthus passer* es un pez ángel (Pomacanthidae), no un pez damisela (Pomacentridae); la bandera `flag_family_discrepa_backbone` está en `TRUE`. Se verifica con `catalogNumber = 4201`.

**Pregunta.** Para los ocho registros restantes con orden discordante dentro de su familia, ¿se corrige el orden a la mayoría del grupo o corresponde a reclasificaciones legítimas que deben conservarse?

---

### F10. [ALTA] Registros con inconsistencias cruzadas (Holotipos, taxones y coordenadas)

**El problema.** Hay registros que presentan múltiples fallos de concepto o procedencia en simultáneo, afectando incluso a holotipos:

- **Catálogo 4358 (Holotipo sin datos):** Declara `typeStatus = Holotype`, `stateProvince = Galápagos`, familia `Haemulidae`. Sin embargo, no tiene colector, fecha, localidad, número de ejemplares, ni identificador. Es uno de los dos únicos tipos de la colección. ¿Es un holotipo real o un typeStatus mal asignado?
- **Catálogo 3944 (Holotipo con hemisferio pendiente de confirmación):** Es el otro holotipo y conserva una latitud cuya interpretación es ambigua. Sus seis números en el verbatim son idénticos a los 3762–3764 (que traen `N` explícita y salen a `+0,091267`). El portal guardó `-0,091267` (una diferencia de 20 km), y Quebrada Sune está en Pacto, Pichincha, en el hemisferio Norte.
- **Catálogo 3765 (Contaminación doble):** `identifications` dice `Microglanis` y el core arrastra `Xyliphius melanopterus` de sus vecinos. Además, declara Orellana cuando sus cuatro hermanas sitúan Quebrada Sune en Pichincha/Pacto, y su coordenada sexagesimal trae 76 segundos. Está corrupto en los ejes taxonómico y geográfico.
- **Catálogo 6294:** Única fila de `Parodon` con `family = Lebiasinidae` frente a cinco con `Parodontidae`.
- **Veintinueve filas con `identificationQualifier = "sp."` sobre un binomio completo:** Vienen así del origen. "sp." significa especie indeterminada y contradice directamente la existencia del binomio completo.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `catalogNumber` en (4358, 3944, 3765, 6294) para los casos singulares; para el grupo de cualificadores, `identificationQualifier = "sp."` y `taxonRank = "species"` → 29 registros. `genero_fuera_de_backbone_fishbase` no identifica todos estos casos.

**Preguntas.**
1. ¿Los catálogos 4358 y 3944 son verdaderamente holotipos? Si es así, se requiere completar la ficha del 4358 y confirmar la corrección de hemisferio del 3944.
2. ¿Qué se hace con el catálogo 3765, que parece una suma de errores de digitación en todos los ejes?
3. ¿Se corrige la familia de `Parodon` a `Parodontidae` en el 6294?
4. En los 29 binomios completos con "sp.", ¿se elimina el cualificador o se recorta el binomio a género?

---

### F11. [MEDIA] Sesenta y dos nombres científicos con más de una autoría

**El problema.** En el conjunto final regenerado, 62 nombres científicos tienen más de una autoría. En 37 nombres hay una autoría de frecuencia máxima única y 66 filas con autorías menos frecuentes. Los otros 25 nombres tienen empate en el máximo y reúnen 75 filas con autoría: no se elige una referencia ni se marca una minoría en esos grupos. La frecuencia dentro de la colección no demuestra cuál autoría es taxonómicamente correcta.

Las 66 minorías corresponden a 43 combinaciones distintas de nombre y autoría. La clasificación final es:

| Tipo | Minorías en el conjunto final | Ejemplo pendiente |
|---|---|---|
| Autoría distinta | 31 | Autores distintos para un mismo nombre |
| Solo el paréntesis | 29 | `Brycon dentex`: `Günther, 1860` frente a `(Günther, 1860)` |
| Solo tildes, guion o espaciado | 6 | `Barriga Salazar` frente a `Barriga-Salazar` |
| Solo el año | 0 | `Brachyhypopomus regani`: cinco años distintos, de 2017 a 2021, en grupos empatados |
| Errata del apellido | 0 | `Carcharhinus porosus`: `Ranzanl, 1840` frente a `Ranzani, 1840`, en grupo empatado |

Los ceros no resuelven las discrepancias de año o apellido: esos casos están en grupos empatados y siguen pendientes. En `Gymnotus coatesi` empatan Hoedeman, 1962 y La Monte, 1935 (cinco filas cada una), y también existen otras autorías menos frecuentes. `Mugil curema` y `Chaetostoma bifurcum` tienen dos autorías con dos filas cada una. Todos requieren validación, sin escoger por orden de aparición.

El paréntesis tiene valor nomenclatural: declara un cambio de combinación desde la descripción original. La referencia nomenclatural y la combinación publicada deben comprobarse; la frecuencia del dataset no decide la forma correcta.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `flag_autoria_minoritaria_en_el_nombre = TRUE` → 66 registros; `tipo_discrepancia_autoria = "empate_frecuencia_maxima_sin_referencia_unica"` → 75 filas de 25 nombres. Los 66 identificadores de minorías coinciden con los del reporte POST.

**Corrección propuesta (no aplicada).** Revisar las diferencias de tildes, guion, espaciado y apellido, tanto entre las seis minorías de formato como en los grupos empatados; una ausencia de bandera de minoría no resuelve esas dudas. Ejemplos: `Ranzanl, 1840` / `Ranzani, 1840` (*Carcharhinus porosus*); `Provenzano & Barriga Salazar, 2018` / `Provenzano & Barriga-Salazar, 2018` (*Ancistrus shuar*). En *Arius seemanni* la forma más frecuente es `Guinther, 1864`, frente a Günther, y el mismo autor aparece con guion en *Ancistrus shuar* y sin guion en *Chaetostoma bifurcum*. La dirección de cada corrección debe validarla el curador contra las referencias nomenclaturales, sin tomar la frecuencia como autoridad.

**Preguntas.**
1. Los cinco años consecutivos de `Brachyhypopomus regani` en cinco catálogos consecutivos, ¿son un arrastre de la plantilla de carga?
2. Para las diferencias de paréntesis, ¿qué forma corresponde a la combinación publicada y qué referencia nomenclatural debe respaldarla?

---

### F12. [MEDIA] Treinta nombres que el backbone de GBIF identifica como variantes

**El problema.** Treinta nombres científicos del conjunto final tienen correspondencia variante en GBIF, en 46 ocurrencias. Son 24 nombres (35 filas) clasificados como posibles erratas de taxones aceptados, cinco nombres (10 filas) emparejados con sinónimos (F14) y un nombre de rango subfamiliar en una fila (`Loricariinae` → `Loricariidae`). Todas las sugerencias siguen pendientes de confirmación curatorial.

La bandera `flag_grafia_variante_gbif` identifica toda correspondencia `FUZZY` o `VARIANT`, independientemente de su motivo de revisión. `grafia_sugerida_gbif` conserva la sugerencia; `revisar_gbif` distingue posibles erratas, sinónimos, variantes nomenclaturales o de rango y casos no concluyentes. La bandera no significa que la corrección esté aprobada ni aplicada.

El catálogo 5367 (`Orthropristis chalceus` → *Orthopristis chalceus*) tiene una sugerencia consistente con el resto del archivo. Para 3931 (`Chaetostoma marginatus` → *Chaetostoma marginatum*), el archivo tiene una fila de cada forma: GBIF aporta una referencia externa para consultar al curador, sin resolver automáticamente el empate.

Seis más resuelven géneros de F8: `Cynoponthicus coniceps` (5177), `Jurengranulis` (5320), `Rhandinoloricaria stewarti` (4247), `Sorubumichthys planiceps` (4839), `Sternachella orthos` (6104) y el ya citado 5367.

En dos casos la grafía de GBIF coincide con la mayoría del propio archivo: `Pimelodella modesta` (2 filas) frente a *modestus* (32) y `Poecilia reticulatus` (1) frente a *reticulata* (5).

**Cómo aislar los registros.** Ver `gbif_nombres_difusos.csv`.

**Corrección propuesta (no aplicada).** Validar con el curador las sugerencias de los 24 nombres clasificados como posibles erratas (35 ocurrencias). Ejemplo: *Chaetostoma dermorhynchus* → *Chaetostoma dermorhynchum* (4 registros). En el reporte congelado actual, los 24 tienen confianza 100; ese valor no sustituye la validación curatorial. Se consultan en `gbif_nombres_difusos.csv`, con `revisar` que empieza por `posible_errata_ortografica`. Incluyen `Farlowella oxyrhyncha` del catálogo 5085; los 209, 1591 y 3069 ya conservan `Farlowella oxyrryncha` con coincidencia exacta.

**Pregunta.** ¿Confirman `Farlowella oxyrryncha` para los catálogos 209, 1591 y 3069 y para las otras ocurrencias con grafía divergente? FishBase, el Catálogo de Peces de Eschmeyer y GBIF respaldan `oxyrryncha`.

---

### F13. [MEDIA] Un nombre que GBIF solo resuelve al rango de género y parece errata

**El problema.** Diecinueve nombres del archivo solo resuelven hasta el género o la familia contra el backbone de GBIF. La mayoría son especies descritas recientemente que el backbone no incorpora todavía, pero uno tiene forma de errata de digitación:

| Cat. | Como aparece | Observación |
|---|---|---|
| 5544 | `Parapsettus steindcher` | El epíteto está truncado. ¿`steindachneri`? |

El catálogo 5633 (`Alphestes inmaculatus`), que figuraba en una versión anterior de esta tabla, no pertenece a este grupo: GBIF sí lo resuelve como variante de *immaculatus* (confianza 100 en el contraste congelado actual) y se trata en F12.

**Cómo aislar los registros.** En `gbif_contraste_completo.csv`: `matchType = HIGHERRANK`.

**Pregunta.** ¿Cuál es la grafía correcta del epíteto del catálogo 5544?

---

### F14. [MEDIA] Cinco nombres donde GBIF propone un sinónimo

**El problema.** El backbone de GBIF resuelve cinco nombres del archivo como sinónimos de otro nombre aceptado. El pipeline ya guarda el nombre aceptado en la columna `gbif_nombre_aceptado`, sin aplicarlo.

| Nombre en el archivo | Sinónimo en GBIF | Nombre aceptado |
|---|---|---|
| *Cochliodon oculus* | *Cochliodon oculeus* | *Hypostomus oculeus* (Fowler, 1943) |
| *Selene oerstedii* | *Selene oerstedi* | *Selene orstedii* Lütken, 1880 |
| *Sciadeops troschelii* | *Sciadeops troschellii* | *Notarius troschelii* (Gill, 1863) |
| *Curimatella renhi* | *Curimatella rehni* | *Cyphocharax gillii* (Eigenmann & Kennedy, 1903) |
| *Chaetostoma platycephalus* | *Chaetostomus platycephalus* | *Andeancistrus platycephalus* (Boulenger, 1898) |

**Cómo aislar los registros.** En `gbif_nombres_difusos.csv`: `estado_gbif = SYNONYM`.

**Pregunta.** ¿Acepta el curador estas cinco combinaciones propuestas por el backbone de GBIF?

---

### F15. [ALTA] `establishmentMeans = nativeEndemic` en 148 registros

**El problema.** El valor es el término controlado normativo de Darwin Core (`dwcem:e007`, «native: endemic», incorporado por decisión del Comité Ejecutivo de TDWG 2025-06-12_47, versión vigente del vocabulario 2026-05-26). **El validador de GBIF descarta los 148 valores sin levantar ninguna incidencia**: su vocabulario todavía no implementa el término.

**Pregunta.** ¿Se conserva `nativeEndemic` por conformidad con el estándar vigente, o se colapsa a `native` por compatibilidad con el agregador? La recomendación técnica es conservarlo y documentar la discrepancia.

---

### F16. [ALTA] Cuarenta y ocho nombres con más de una familia

**El problema.** 575 filas de 48 nombres científicos aparecen repartidos en dos familias, con 74 filas en la minoría. Los peores desequilibrios: *Moenkhausia oligolepis* 69/1, *Hoplias malabaricus* 59/1, *Distocyclus conirostris* 20/1 y *Pimelodella lateristriga* con tres familias distintas.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `flag_family_minoritaria_en_el_nombre = TRUE` → 74 registros, los de la familia minoritaria. Para ver los 575 del grupo completo, agrupar por `scientificName` y quedarse con los nombres que tienen más de un valor de `family`.

**Pregunta.** ¿Se unifica cada nombre a la familia mayoritaria, o hay reclasificaciones legítimas que deben conservarse?

---

### F17. [MEDIA] Familia publicada cuando FishBase y el backbone de GBIF discrepan

**El problema.** En 1.729 registros (el 27 % de la colección), la familia publicada no coincide con FishBase para el género. Esto no equivale a un error confirmado: GBIF respalda la familia del registro en 1.632 casos, ambas referencias discrepan de ella en 94 y en tres la correspondencia GBIF no es concluyente. Los posibles cambios históricos de clasificación requieren evaluación, no se presuponen.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `flag_family_discrepa_backbone = TRUE` → 1.729 registros, de los cuales 1.655 son del grupo de Characidae. `clasificacion_discrepancia_family` permite separar los motivos de revisión.

**Pregunta.** ¿La dimensión Taxón usa la familia del origen o la del backbone?

---

### F18. [MEDIA] Cinco registros de Scorpaeniformes

**El problema.** Catálogos 31, 2452, 4188, 5702, 5703: el origen declara el orden Scorpaeniformes, que es más específico que el clado informal al que FishBase y GBIF los asignan.

**Pregunta.** ¿Se conserva Scorpaeniformes o se adopta la jerarquía del backbone?


---

### F19. [MEDIA] Cinco nombres con el cualificador duplicado dentro de `scientificName`

**El problema.** Cinco registros traen el cualificador de la determinación (`cf.`, `gr.`, `complex`) en dos sitios a la vez: dentro de `scientificName` y en `identificationQualifier`, donde ya venía declarado desde el portal. Además tienen `taxonRank` vacío: son los únicos registros con determinación entre los once que quedan sin rango en el archivo; los otros seis no tienen nombre científico. El pipeline solo normalizó el espacio de `cf.batesii`.

**Corrección propuesta (no aplicada).** Retirar el cualificador de `scientificName` y declarar `taxonRank`, dejando el cualificador solo en `identificationQualifier`:
- 5146: `Lycengraulis cf. batesii` → `scientificName = Lycengraulis batesii`, `identificationQualifier = "cf. batesii"`, `taxonRank = species`
- 6395 y 6396: `Hypostomus gr. cochliodon` → `scientificName = Hypostomus`, `identificationQualifier = "gr. cochliodon"`, `taxonRank = genus`
- 4323 y 4325: `Chaetostoma complex microps` → `scientificName = Chaetostoma`, `identificationQualifier = "complex microps"`, `taxonRank = genus`

**Por qué importa.** Darwin Core separa el nombre de la duda sobre el nombre. Con el cualificador dentro de `scientificName`, estos cinco no emparejan con su especie o género en el backbone y quedan fuera de los conteos por taxón.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `catalogNumber` IN (5146, 6395, 6396, 4323, 4325) → 5 registros.

**Pregunta.** ¿Autorizan esta separación? Y para *Hypostomus* gr. *cochliodon* y *Chaetostoma* complex *microps*, ¿el rango correcto es género, o prefieren declararlo a nivel de especie con el cualificador?

---

## BLOQUE G — Estructura y alcance del dataset

### G1. [MEDIA] `identifications.csv` no es un historial, pero contiene información que el core no tiene

**El problema.** La extensión proporcionada tiene 6.427 filas y 6.427 `coreid` distintos: una fila por ocurrencia, sin `identificationID` ni múltiples actos por ejemplar. No constituye un historial completo de determinaciones; esto no demuestra que el portal carezca de otro historial. Sus cifras de cobertura frente al core final regenerado, son: 4.299 géneros frente a 6.396, 3.229 epítetos frente a 5.160, y `taxonRank`, `infraspecificEpithet`, `identificationReferences` e `identificationRemarks` vacías al 100%. Sus 6.424 `dateIdentified` incluyen 271 con los placeholders `sin datos` y `s.d.` que en el core ya limpié.

Al comparar con los nombres originales del core y descartar falsos positivos por espacios duros, la ejecución corregida de la Fase 4 verifica:
- **782 autorías** (`scientificNameAuthorship`) que el core no trae. Otras 21 se descartaron por pertenecer a un nombre distinto al del core (ver J2).
- **0 `identifiedBy`** útiles (los 7 que tiene son una fecha y seis `unknown`).
- **23 posibles identificaciones anteriores**, reconstruidas a partir de nombres diferentes y fechas comparables anteriores; se conservan en `previousIdentifications`, sin considerarlas actos curatoriales confirmados.
- **63 diferencias de nombre**, que incluyen esas 23 posibles identificaciones anteriores y los casos pendientes de revisión (ver J1); no son un grupo adicional que deba sumarse.

**Mi propuesta.** No incorporar esta extensión como un historial completo al modelo. Integrar las 782 autorías compatibles con el nombre del core y conservar las 23 posibles identificaciones anteriores como reconstrucciones pendientes de validación. Incorporarla obligaría a limpiar 52 formas distintas de `identifiedBy` para reconstruir una dimensión que en el core ya está conformada.

**Cómo aislar los registros.** Ver `identifications_para_inabio.csv` de la Fase 4 corregida → 71 registros; las 23 reconstrucciones se identifican por `previousIdentifications` no vacío en `ocurrences_curado.csv`.

**Preguntas.**
1. ¿Confirman que el portal no guarda historial completo de redeterminaciones, o existe en otro lado y esta exportación no lo trae?
2. ¿Autorizan conservar las 782 autorías y las 23 posibles identificaciones anteriores reconstruidas integradas al core, con esa distinción de evidencia?

---

## BLOQUE H — Lotes con anomalías acumuladas

### H1. [MEDIA] Cuarenta registros en una sola coordenada de la provincia del Guayas

**El problema.** Cuarenta filas caen dentro de un metro del mismo punto (`-2.091522 / -79.392815`, provincia del Guayas): 35 con la coordenada exacta y 5 con uno o dos decimales menos (5185, 5192, 5200, 5259 y 5260). 36 de las 40 declaran Sucumbíos. De las 35 exactas, 33 no tenían `locality` en el archivo del portal (quedan 2 tras recuperar topónimos desde `locationRemarks` en la curación) y 33 no tienen `county`. El rango de catálogo abarca del 5185 al 5658, por lo que no es un lote contiguo. La coordenada viene del origen: no la produjo ninguna conversión nuestra.

Esto indica que no es un error de digitación individual, sino una coordenada inyectada masivamente. Las 40 están clasificadas como discordantes y con `georeferenceVerificationStatus = requires verification`.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `decimalLatitude = "-2.091522"` y `decimalLongitude = "-79.392815"` → 35 registros exactos; con una tolerancia de un metro, 40.

**Pregunta.** ¿De dónde salió esa coordenada? ¿Es un punto por defecto del sistema o una referencia institucional mal asignada?

---

### H2. [MEDIA] Trece coordenadas anómalas por posible error de digitación en el *northing*

**El problema.** Trece registros conservan representaciones UTM con posibles errores de dígito en el northing. Actualmente no tienen coordenada decimal publicada: ocho son `irreparable` y cinco `utm_ambiguo`. La ausencia de una zona única respaldada impide reconstruirlos automáticamente; las lecturas siguientes son hipótesis para comprobar en las fuentes.

La pregunta pasa a ser un posible error en el *northing*, con hipótesis concretas:
- `9440090` → ¿`9940090`? (Caería en Orellana, afecta a 5 filas: cat. 5684, 4022, 4023, 4024, 4025)
- `9956191` → ¿`9656191`? (Caería en El Oro, afecta a 5 filas)
- `9890000` → ¿`9800000`? (Caería en Pastaza, afecta a 3 filas)

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `verbatimCoordinates` contiene `9440090`, `9956191` o `9890000` → 13 registros. `hipotesis_northing` está vacío en la versión final y no sirve como filtro de estos casos.

**Pregunta.** ¿Pueden confirmar con el libro de campo si estos *northing* tienen un dígito mal digitado según estas hipótesis?

---

## BLOQUE I — Contradicciones biogeográficas

### I1. [BAJA] Dos especies marinas del Pacífico registradas en la Amazonía

**El problema.** Cada campo es válido por separado; la combinación describe algo que no ocurre.

| catalogNumber | Especie | Familia | Provincia declarada |
|---|---|---|---|
| 5313 | *Epinephelus analogus* (mero del Pacífico) | Epinephelidae | Napo |
| 5453 | *Trachinotus rhodopus* (pámpano del Pacífico) | Carangidae | Sucumbíos |

Ninguna de las dos familias tiene representantes dulceacuícolas en la cuenca amazónica ecuatoriana.

**Cómo aislar los registros.** En `ocurrences_curado.csv`: `catalogNumber` IN (5313, 5453) → 2 registros.

**Preguntas.**
1. ¿El error está en la determinación o en la procedencia?
2. ¿Los ejemplares siguen disponibles para revisión física?

---

### I2. [BAJA] Diecinueve registros solitarios en la vertiente contraria

**El problema.** Diecinueve especies presentes a ambos lados de los Andes tienen un único registro en una de las dos vertientes. Un registro solitario en la vertiente minoritaria es candidato a error de determinación o de procedencia, aunque también puede ser un hallazgo real de distribución.

**Cómo aislar los registros.** En `reporte_plausibilidad_post.csv`: `regla = "unico registro de la especie en esa vertiente"` → 19 registros.

**Pregunta.** ¿Cuáles de estos diecinueve son ampliaciones de distribución conocidas y cuáles conviene revisar?

---

### I3. [BAJA] Ochenta y cinco registros a una altitud fuera del rango de su propia especie

**El problema.** Comparando cada registro contra la mediana de altitud de su misma especie **dentro de esta colección**, 85 se desvían más de seis desviaciones absolutas medianas. Afecta a 34 especies. La cifra subió de 81 a 85 tras la curación: tres son altitudes que estaban en el campo máximo y pasaron al mínimo (ver D11), entrando por primera vez al universo que evalúa esta regla; la cuarta aparece porque esas altitudes nuevas desplazan la mediana de su especie. Ejemplos:

| catalogNumber | Especie | Altitud declarada | Mediana de la especie |
|---|---|---|---|
| 1573 | *Anablepsoides rubrolineatus* | 1.140 m | 260 m |
| 1021, 1037, 1071 | *Charax tectifer* | 894–910 m | 271 m |
| 1023, 1077 | *Bujurquina mariae / moriorum* | 910 m | 270 m |
| 1002, 1193, 1197 | *Ceratobranchia elatior* | 269–483 m | 905 m |
| 1724 | *Creagrutus muelleri* | 940 m | 1.585 m |

No afirmo que la altitud sea incorrecta: puede ser una población de altura real, o la altitud puede pertenecer a otro registro del lote. Las especies con más casos son *Creagrutus muelleri* (8), *Charax tectifer* (4), *Bujurquina mariae* (4) y *Ancistrus malacops* (4).

**Cómo aislar los registros.** En `reporte_plausibilidad_post.csv`: `regla = "altitud fuera del rango de la especie en la coleccion"` → 85 registros.

**Preguntas.**
1. ¿Estas especies tienen rangos altitudinales tan amplios, o la altitud está mal asignada?
2. ¿La altitud se tomó en campo o se derivó de la coordenada a posteriori?

---

## BLOQUE J — Determinaciones previas

### J1. [ALTA] Sesenta y tres casos donde `identifications.csv` y el core discrepan

**El problema.** En la ejecución corregida de la Fase 4, comparar `identifications.csv` con `scientificName_verbatim` produce 83 diferencias brutas: 63 filas con nombres diferentes para clasificar, 18 con el literal `undefined`, una diferencia de sola mayúscula y un aporte neto (el catálogo 4322). Las 63 diferencias se reparten así; los truncamientos están incluidos en cada total, no son casos adicionales:

| Relación entre las fechas comparables | Total | Sin truncamiento | Con truncamiento |
|---|---|---|---|
| Fecha de la extensión anterior | 24 | 23 | 1 |
| Sin fechas comparables | 30 | 24 | 6 |
| Fecha comparable coincidente | 9 | 6 | 3 |

Las 23 diferencias sin truncamiento y con fecha anterior se conservan como posibles identificaciones anteriores, no como redeterminaciones verificadas. De ellas, 13 no están en el oficio y 10 sí: cinco por cualificadores y cinco por autorías rechazadas. Las otras 40 diferencias van al oficio: 30 sin fechas comparables, nueve coincidentes y el truncamiento con fecha anterior.

El anexo `identifications_para_inabio.csv` contiene 71 identificadores distintos: esas 50 diferencias de nombre pendientes (40 más 10), 18 filas adicionales con `undefined` y tres filas adicionales pendientes únicamente por cualificadores (catálogos 1799, 4317 y 4559). Las 21 autorías rechazadas de J2 ya están incluidas en esos grupos, por lo que no se suman otra vez.

Quedan varios casos dudosos o problemáticos:

- **Treinta sin fechas comparables**, seis de ellas con truncamiento del nombre. Los vacíos y placeholders como `sin datos` impiden establecer una secuencia, aunque el core tenga una fecha.
- **Nueve con fecha comparable coincidente**, tres de ellas con truncamiento. En seis coinciden solo los años; en tres coincide la fecha completa. Ninguna de esas coincidencias demuestra un mismo acto de determinación ni establece una secuencia.
- **Catálogos 3766 y 3767 (intercambio sin corregir):** el `tidInterpreted` está intercambiado exactamente igual que el nombre. No se ha aplicado ningún cambio: los datos no permiten decidir cuál de las dos fuentes corresponde a cada ejemplar. Ver la corrección propuesta al final de esta pregunta.
- **Catálogo 4336:** `identifications` dice `Gymnotus` (2019) y el core `Gymnotus coatesi` (2023). Con fecha anterior parecería una redeterminación de género a especie, pero la tabla pierde el epíteto de forma sistemática en 1.918 filas.
- **Catálogo 4322:** `identifications` trae `Characidae` donde el core no tiene ningún nombre. Es el único aporte taxonómico neto de toda la tabla. Se reutiliza la coincidencia exacta de ese nombre ya congelada en GBIF; esto no confirma la identificación del ejemplar, que sigue pendiente del INABIO.
- **Dieciocho filas con el texto `undefined`**.

*(Nota: el catálogo 3765, que también presentaba discrepancias, se trata integralmente en F10.)*

**Corrección propuesta (no aplicada).** Catálogos 3766 y 3767: el core dice 3766 = *Brachyhypopomus*, 3767 = *Trichomycterus*, y `identifications.csv` al revés, con el mismo determinador (Jonathan Valdiviezo) y el mismo año (2017). La extensión es coherente internamente: cada nombre llega con su autoría correcta (Valenciennes, 1832 para *Trichomycterus*; Mago-Leccia, 1994 para *Brachyhypopomus*). Los datos no permiten decidir cuál fuente corresponde a cada ejemplar: se propone la asignación que confirme la etiqueta física de cada frasco, corrigiendo `scientificName` y `family`. Se verifica en `identifications_para_inabio.csv`, `catalogNumber` en (3766, 3767).

**Preguntas.**
1. Para los 30 sin fechas comparables: ¿el lote de julio 2023 fue una redeterminación masiva?
2. Para 4336: ¿Fue una determinación real a nivel de género en 2019 o es la misma pérdida de dato (truncamiento)?
3. Para 4322: ¿Se acepta `Characidae` como determinación?
4. ¿`undefined` significa "no determinado" o es un fallo de exportación?

---

### J2. [MEDIA] Veintiuna autorías que `identifications.csv` trae de un nombre distinto

**El problema.** La extensión aporta 803 valores de `scientificNameAuthorship` que el core no tiene. En 21 de ellos el nombre que declara `identifications.csv` no es el del core, de modo que la autoría pertenece a otra especie. No se importaron.

Los cinco primeros son el caso más claro: son filas donde el propio proceso escribe ese mismo nombre en `previousIdentifications` declarando que es la determinación anterior, y a la vez traía su autoría al nombre actual.

| Cat. | Nombre en el core | Nombre en `identifications` | Autoría rechazada |
|---|---|---|---|
| 4267 | Creagrutus | Chrysobrycon | Weitzman & Menezes, 1998 |
| 4284 | Bryconops | Odontostilbe roloffi | Géry, 1972 |
| 4327 | Anablepsoides | Piabucina elongata | Boulenger, 1887 |
| 4331 | Chrysobrycon | Brachychalcinus nummus | Böhlke, 1958 |
| 4334 | Knodus | Brachychalcinus nummus | Böhlke, 1958 |
| 3766 | Brachyhypopomus | Trichomycterus | Valenciennes, 1832 |
| 3767 | Trichomycterus | Brachyhypopomus | Mago-Leccia, 1994 |

Los catálogos 3766 y 3767 confirman el intercambio recíproco, todavía sin corregir (ver J1): la autoría estaba cruzada igual que el nombre, el `taxonID` y el `tidInterpreted`.

**Cómo aislar los registros.** Ver `identifications_para_inabio.csv`, columnas `autoria_rechazada` y `nombre_de_esa_autoria`.

**Pregunta.** ¿La autoría de esos registros corresponde al nombre actual del core o al nombre anterior que declara la extensión?

---

### J3. [MEDIA] El pie de foto discrepa del nombre del core en 162 ejemplares

**El problema.** `multimedia.csv` contiene 430 imágenes correspondientes a 346 ejemplares. El campo `caption` aporta evidencia documental del nombre asociado a la imagen en la exportación; no demuestra cuál era la identificación cuando se tomó la fotografía ni que hubiera una redeterminación posterior. En la validación POST, comparando con el nombre original conservado en el core final, 184 ejemplares tienen el pie de foto idéntico y 162 discrepan; la clasificación es idéntica a PRE:

| Relación entre el pie de foto y el nombre del core | Ejemplares |
|---|---|
| Pie de foto menos preciso, por ejemplo Knodus sp. frente a Knodus megalops | 98 |
| Género discordante | 28 |
| Epíteto distinto dentro del mismo género | 20 |
| Pie de foto con reserva, cf. o aff., que el core no declara | 16 |

Los 28 de género discordante y los 20 de epíteto distinto requieren cotejar la imagen, la etiqueta y los registros de identificación, como los casos de J1 y J2. La diferencia documental no establece por sí sola una secuencia histórica ni cuál nombre es correcto. Algunos casos:

| Catálogo | Pie de foto | Nombre en el core |
|---|---|---|
| 776 | Eigenmannia virescens | Sternopygus macrurus |
| 791 | Moenkhausia sp. | Astyanax henseli |
| 808 | Acestrocephalus anomalus | Charax tectifer |
| 822 | Prochilodus sp. | Steindachnerina dobula |
| 2946 | Ancistrus malacops | Bujurquina moriorum |

Se verificó que las discrepancias no siguen un patrón de desplazamiento entre números de catálogo contiguos, de modo que no se trata de un corrimiento sistemático en la asociación entre imagen y ejemplar.

Las 430 imágenes tienen direcciones con `localhost` en los cinco campos principales de URL: `identifier`, `accessURI`, `thumbnailAccessURI`, `goodQualityAccessURI` y `associatedSpecimenReference`. Esas direcciones no identifican un acceso público desde otro equipo; el dominio y las rutas correctas debe proporcionarlos el INABIO.

También hay una diferencia de licencia en las 430 filas: `rights` apunta a CC BY-NC 4.0, mientras que `UsageTerms` declara CC BY-NC-SA. La obligación de compartir bajo la misma licencia no coincide entre ambos campos; no se puede decidir cuál corresponde sin confirmación institucional.

**Cómo aislar los registros.** Filtrar `multimedia_caption_vs_core_post.csv` por `clase`. Su contenido coincide con `multimedia_caption_vs_core_pre.csv`; ambos reportes se conservan por separado. Las URL y licencias se consultan en la extensión original `multimedia.csv`.

**Pregunta.** ¿De dónde proceden los nombres de los pies de foto y qué evidencia permite distinguir una identificación anterior, un texto obsoleto o un cruce entre ejemplares; cuáles son las URL públicas correctas y qué licencia debe aplicarse, CC BY-NC 4.0 o CC BY-NC-SA? El pipeline no cambia nombres, URL ni licencias por estas discrepancias.

---

### J4. [MEDIA] Catálogos 2336 y 3775

**El problema.** Misma fecha, dos nombres, discordancia real. Con el 3765 (tratado en F10) son tres casos que necesitan al curador, no dos.

**Pregunta.** ¿Cuál de los dos nombres es el correcto para cada ejemplar?

---

## BLOQUE K — Configuración del portal

### K1. [ALTA] El campo `dcterms:modified` no se actualiza

**El problema.** El campo `dcterms:modified` de las 6.427 filas agrupa casi por completo cuatro episodios de carga masiva (2020-01-08, 2021-01-05, 2022-01-03 y 2025-11-03). Por ejemplo, 4.287 filas conservan el sello del 2020-01-08, y 1.487 de ellas declaran una determinación de 2023. Notamos que el portal sí registra la actividad reciente, pero lo hace en el timestamp de la extensión `identifications`, no en el `core`.

**Pregunta.** ¿El portal actualiza el `dcterms:modified` del `core` cuando un curador edita un registro individualmente, o el sello solo se escribe en las importaciones masivas? La respuesta determina si nuestra carga incremental del Data Warehouse debe basarse en el `core` o si debe leer también los sellos de las extensiones para no perderse las correcciones menores.

---

### K2. [MEDIA] El identificador de la colección no resuelve en GRSciColl

**El problema.** El validador de GBIF devuelve `COLLECTION_MATCH_NONE` en las 6.427 filas: el valor de `collectionID`, `b636a8df-9e83-45fe-a0ae-dacfbb36c300`, no corresponde a ninguna colección registrada en GRSciColl. Es un aviso distinto del `INSTITUTION_MATCH_FUZZY` que ya está documentado, y afecta a un registro institucional que solo el INABIO puede dar de alta o corregir.

**Pregunta.** ¿La colección MECN-DP está registrada en GRSciColl? Si lo está, ¿cuál es su identificador; y si no, se tramita el registro antes de publicar?
