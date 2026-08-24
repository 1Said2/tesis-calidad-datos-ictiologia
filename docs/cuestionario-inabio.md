# CUESTIONARIO PARA INABIO
### Colección ictiológica MECN-DP · pendientes de las tres fases de limpieza

---

## BLOQUE A — Identificadores y alcance

### A3. Uso del campo `otherCatalogNumbers`

**El problema.** Solo 636 registros (9,9 %) lo tienen poblado: 573 con prefijo `QCAZ` y 64 con prefijo `PEC`.

**Preguntas.**
1. ¿Son ejemplares transferidos desde la PUCE y otra colección, duplicados de lote, o referencias cruzadas de otra naturaleza?
2. ¿Esto debe modelarse como un atributo del ejemplar o como una relación entre colecciones?

---

### A3 bis. Números de catálogo externos repetidos y con formato irregular

**El problema.** Además de lo ya consultado en A3, un barrido del campo completo encontró tres defectos distintos.

- **Treinta y cuatro números aparecen en más de un registro MECN-DP.** Los catálogos 5383 y 5389 comparten siete (`QCAZ-1383`, `1396`, `1397`, `1654`, `1659`, `1661`, `1662`), lo que parece copia del bloque entero y no una coincidencia.
- **`QCAZ-Z211`** lleva una letra que ningún otro token del campo tiene.
- **`PEC-46`** aparece dentro de la serie 457–464 del catálogo 5587.
- **`PEC-001`, `PEC-002`, `PEC-004` y `PEC-009`** llevan cero a la izquierda mientras `PEC-13`, `PEC-24` y `PEC-28` no.

Precisión sobre la cifra de A3: son 636 registros con el campo poblado, de los cuales 573 contienen `QCAZ` y 64 contienen `PEC`. El catálogo 5387 lleva los dos prefijos, por eso 573 + 64 no da 636.

**Preguntas.**
1. ¿Un mismo ejemplar `QCAZ` puede estar referenciado desde dos registros MECN-DP, o el bloque de 5383/5389 es una duplicación de carga?
2. Confirmo que `PEC-46` (en el cat. 5587) es un error por `PEC-461` (la serie es 457-458-459-460-462-463-464 y falta justo el 461), favor confirmar.
3. ¿`QCAZ-Z211` es un formato válido de esa colección?
4. ¿El cero a la izquierda es significativo o normalizo a `PEC-1`, `PEC-2`?

---

## BLOQUE B — Fechas

### B1. Veinte registros donde `eventDate` y `verbatimEventDate` declaran años distintos

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
| 5200 | 1992-09-05 | 1993-11-10 | QCAZ | *(sin localidad)* |
| **5468** | 2023-06-13 | **2005** | Kevin Chugá \| Santiago Núñez | Reserva Puranquí |
| **5492** | **1905-06-27** | **2005** | Lida Guarderas | Lorocachi |
| **5551** | 2023-06-16 | **2005-09-01** | Kevin Chugá \| Santiago Núñez | Reserva Puranquí |
| 2463 | 2011-06-18 | 18/06/2012 | J. Valdiviezo \| C. Carrillo | Laguna Limoncocha |
| 2464 | 2011-06-18 | 18/06/2012 | J. Valdiviezo \| C. Carrillo | Laguna Limoncocha |

**Tres patrones distintos, y cada uno necesita respuesta propia:**
- **El bloque de Rivadeneira (5017–5034, nueve filas).** El `eventDate` es sistemáticamente anterior al `verbatim` por unos ocho años. Que sean nueve filas del mismo colector, en la misma localidad y con el mismo desfase apunta a un error de digitación por lote, no a nueve errores independientes.
- **Los dos de la Reserva Puranquí (5468 y 5551).** `eventDate` dice 2023 y `verbatim` dice 2005, pero el colector es Kevin Chugá, cuyos demás registros son todos de 2023. Aquí el verbatim parece el equivocado.
- **Los tres imposibles.** El 5492 dice 1905 cuando el verbatim dice 2005 — un dígito. El 5069 tiene un verbatim en 2025 posterior a su propio `eventDate`. El 5020 declara 1985 frente a 2008, veintitrés años.

**Preguntas.**
1. Como criterio general: ¿manda `eventDate` o `verbatimEventDate` cuando discrepan?
2. Para las nueve filas de Rivadeneira (5017, 5018, 5028–5034): ¿pueden revisar la etiqueta física de una sola de ellas? Si el desfase es sistemático, con una se resuelven las nueve.
3. Para 5468 y 5551: ¿el trabajo de campo en Reserva Puranquí fue en 2023 o en 2005?
4. Para 5492: ¿1905 es un error por 2005?

---

### B1 bis. Cinco fechas verbatim malformadas, y dos contradicen el bloque B4

**El problema.** Cinco registros tienen `verbatimEventDate` con un formato que no corresponde a ninguna fecha válida.

| catalogNumber | `eventDate` | `verbatimEventDate` | Lectura probable |
|---|---|---|---|
| 4048, 4050 | 2017-12-01 | `2017-12-019` | El día sería 19, no el 01 |
| 5796 | 2005-06 | `2005-06 10` | El día 10 existe y `eventDate` lo perdió |
| 6264 | 2024 | `2024-2024-11` | ¿2024-11? |
| 4292 | (vacío) | `201-08-19` | Año truncado |

Los catálogos 4048 y 4050 importan más allá de sí mismos: en el bloque B4 sostengo que el `01` del día lo fabricó el portal porque el verbatim solo traía año y mes. En estos dos el verbatim **sí trae día**, y es distinto del que el sistema escribió. Eso significa que el criterio de B4 no cubre todos los casos y que puede haber más días perdidos, no solo inventados.

**Preguntas.**
1. ¿Los catálogos 4048 y 4050 se colectaron el 19 de diciembre de 2017?
2. ¿El catálogo 4292 es de 2010, 2011 u otro año?
3. ¿Existen más registros donde el portal haya sobrescrito un día real?

---

### B2. Cuatro fechas de colecta imposibles o inverosímiles

**El problema.** Fechas que no pueden ser correctas tal como están.

| catalogNumber | `eventDate` | Situación |
|---|---|---|
| 5684 | 2027-10-18 | **En el futuro.** Además la localidad está vacía y la coordenada cae 412 km fuera de Orellana, en territorio peruano |
| 5687 | 2027-10-16 | En el futuro, mismo colector y mismo lote que la anterior |
| 5757 | 1897-06-05 | Anterior a la fundación de la colección; localidad vacía |
| 5492 | 1905-06-27 | Su propio verbatim dice 2005 (ver B1) |

Los catálogos 5684 y 5687 acumulan tres anomalías simultáneas — fecha futura, sin localidad, coordenada en Perú — con el mismo colector y la misma fecha de determinación. No son cuatro errores sueltos: parece un lote mal digitado.

**Preguntas.**
1. ¿Los catálogos 5684 y 5687 corresponden a 2017, 2021 o alguna otra fecha? ¿Se digitaron juntos con otros registros que también deba revisar?
2. ¿El catálogo 5757 es realmente de 1897, o es un error por 1997?

---

### B3. Setenta y tres registros identificados *antes* de ser colectados

**El problema.** `dateIdentified` es anterior a `eventDate`: el sistema afirma que alguien determinó taxonómicamente un ejemplar antes de que se recogiera. Es imposible por definición.

**Filas afectadas.**

| `eventDate` | `dateIdentified` | n | catalogNumber |
|---|---|---|---|
| 2006-02-17/18 | 2005 | 45 | 408–451, 466 |
| 2013-02-25 | 2011 | 9 | 2298–2306 |
| 2013-02-25 | 2012 | 3 | 2307, 2405, 2406 |
| 2022-09 | 2022-01 | 6 | 4997–5002 |
| 2017-07-20 | 2017-06 | 3 | — |
| **2025-11-19** | 2025-03-24 | 2 | 6231, 6237 |
| **2025-10-03 / 08-03** | 2025-04-08 | 3 | 6422, 6423, 6424 |
| 2027-10-16/18 | 2023-08-25 | 2 | 5684, 5687 |

Los bloques son de catálogos consecutivos, lo que indica errores de carga por lote y no casos aislados. El bloque grande (408–451) son 45 registros seguidos. Los cinco de 2025 (6231, 6237, 6422–6424) son todos del mismo colector, Fernando Sánchez, determinados por Jonathan Valdiviezo.

**Preguntas.**
1. Para el bloque 408–451: ¿la colecta fue en 2006 y la determinación en 2005 está mal, o al revés?
2. ¿Existe registro de cuándo se cargaron estos lotes al sistema? Serviría para saber qué campo se desplazó.
3. Para los cinco registros de 2025 de Fernando Sánchez: ¿las fechas de colecta o determinación están invertidas o corresponden a años anteriores?

---

### B4. Ciento sesenta y nueve fechas con el día inventado en origen

**El problema.** El `verbatimEventDate` solo trae año y mes (por ejemplo `2003-8`), pero el `eventDate` del sistema completó el día con `01`. Ese `01` no viene de la ficha: lo puso el portal. Hoy ese día fabricado está poblando la columna `day` y se propagaría a la dimensión Tiempo como si fuera un dato real.

**Filas afectadas.** 169 registros.

**Por qué importa.** Choca de frente con la regla de no imputación que rige toda la limpieza. Si un análisis pregunta "¿qué día del mes se colecta más?", esas 169 filas dirán "el primero" sin que nadie lo haya observado.

**Preguntas.**
1. ¿Vacío el campo `day` en esas 169 filas y declaro el grano como mensual, o INABIO prefiere conservar el `01` documentándolo como convención del portal?
2. ¿Hay forma de recuperar el día real desde los libros de campo?

---

### B5. Quinientos veinticuatro registros sin fecha y doscientos treinta y cuatro con fecha incompleta

**El problema.** Además de los casos anteriores, el grano temporal no es uniforme:
- **524 registros sin `eventDate`** — no hay fecha de colecta.
- **231 registros con solo año y mes** (`2011-09`).
- **3 registros con solo el año**: catálogos 5163, 5531 y 6264.

**Por qué importa.** Determina el grano mínimo de la dimensión Tiempo. Si el 12% de la colección no tiene día, un dashboard con eje diario deja fuera esos registros silenciosamente.

**Preguntas.**
1. ¿Los 524 sin fecha se excluyen de los análisis temporales o se agrupan en una categoría "fecha desconocida"?
2. ¿Existen libros de campo o etiquetas físicas que permitan recuperar alguna de estas fechas?

---

## BLOQUE C — Geografía administrativa

### C1. Cinco cantones aparecen bajo dos provincias distintas

**El problema.** Un cantón pertenece a una sola provincia. En el dataset, cinco valores de `county` aparecen asociados a dos `stateProvince` diferentes, lo que rompe la jerarquía y hará que la dimensión Geografía tenga dos padres para el mismo hijo.

| Cantón (`county`) | Provincias declaradas | Filas |
|---|---|---|
| Aguarico | Orellana / Sucumbíos | 537 |
| Shushufindi | Orellana / Sucumbíos | 206 |
| El Edén | Esmeraldas / Orellana | 1 |
| Puyango | El Oro / Loja | 14 |
| La Concordia | Esmeraldas / Santo Domingo de los Tsáchilas | 7 |

Para La Concordia existe explicación histórica (cambió de provincia en 2007). Puyango pertenece a Loja. Sin embargo, para Aguarico y Shushufindi la explicación histórica es falsa: Aguarico fue cantón de Napo y pasó a Orellana en 1998; Shushufindi se cantonizó en Napo en 1984 y pasó a Sucumbíos en 1989. Ninguno estuvo en la provincia que se les atribuye (es etiquetado incorrecto, no historia). Para El Edén, 129 filas son de Orellana (Chiruisla) y solo 1 es de Esmeraldas (Alto Tambo, que es San Lorenzo).

**Preguntas.**
1. ¿La provincia debe reflejar la división administrativa **vigente hoy** o **la vigente en la fecha de colecta**? Es la decisión que más afecta al modelo: 880 registros dependen de ella.
2. Para El Edén (1 fila en Esmeraldas): ¿Confirman la corrección a San Lorenzo?

---

### C1 bis. Siete parroquias aparecen bajo más de un cantón

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

**Preguntas.**
1. ¿Pacto pertenece a Quito o a San Miguel de los Bancos? El registro que la asigna a San Miguel de los Bancos, ¿es un error o una zona limítrofe?
2. ¿Confirman que Puerto Bolívar y Salinas son homónimos y no errores?

---

### C2. El campo `county` mezcla cantones, parroquias y localidades

**El problema.** Darwin Core reserva `county` para el cantón y `municipality` para la parroquia. En el dataset conviven los tres niveles dentro de `county`. Casos claros:

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

**Preguntas.**
1. ¿Reasigno los valores a su nivel correcto (parroquias a `municipality`, localidades a `locality`) o INABIO prefiere una revisión propia?
2. ¿Unifico `Quito`/`Distrito Metropolitano de Quito` y `Coca`/`Francisco de Orellana`? ¿Con cuál nombre?
3. ¿Bahía de Caráquez se reasigna a Sucre?
4. Para Marchena y Fernandina: ¿Se mueven a `island` con `islandGroup = Galápagos`?

---

### C2 bis. Once valores más de `county` que no son cantones

**El problema.** Ampliación de la tabla de C2 con los valores que faltaban.

| Valor | Qué es realmente |
|---|---|
| Tandapi, Lumbaqui, Mompiche, Salango, Crucita, Yahuarcocha | parroquias |
| Macas, Puyo | ciudades, cabeceras de Morona y Pastaza |
| Urbina Jado | nombre histórico del cantón Salitre |
| Maynas | provincia peruana |
| Apure | estado venezolano |

Además, `Distrito Torres Causana` lleva el nivel escrito dentro del valor, igual que `Parroquia Pacto`, y `Buena Fé` se escribe con tilde cuando la denominación oficial es `Buena Fe`.

**Preguntas.**
1. ¿Reemplazo cada uno por su cantón, o los muevo al campo que corresponde a su nivel real?
2. ¿`Urbina Jado` debe modernizarse a `Salitre` o conservarse como estaba al momento de la colecta?
3. ¿Autorizan quitar la tilde de `Buena Fé`?

---

### C3. Doce registros con parroquia pero sin cantón

**El problema.** Tienen `municipality` poblado y `county` vacío: se declara la parroquia sin el cantón que la contiene. La jerarquía queda con un hueco intermedio.

**Filas afectadas.** Catálogos 460, 2950, 2951, 2952, 3766, 3767, 4914, 5075, 5550, 5591, 6168, 6169.

**Pregunta.** ¿Pueden completar el cantón de estas doce, o las dejo como jerarquía incompleta documentada?

---

### C4. Veintitrés localidades con coordenadas escritas dentro del texto

**El problema.** El campo `locality` contiene la coordenada embebida en la descripción, por ejemplo: `Reserva Biológica Limoncocha.Laguna Limoncocha 18N 321429/9957040 236msnm`. Mezcla tres datos —localidad, coordenada UTM y altitud— en un campo que debería contener solo la descripción del sitio.

**Filas afectadas.** 23 registros, catálogos 2462 a 2484.

**Preguntas.**
1. ¿Extraigo la coordenada y la altitud a sus campos propios y dejo `locality` solo con el texto?
2. Esas coordenadas embebidas, ¿coinciden con las que ya están en `verbatimCoordinates`, o son una fuente distinta?

---

### C5. Dos correcciones de topónimo que necesitan visto bueno

**El problema.** Apliqué o dejé pendientes dos cambios que no son ortográficos sino léxicos, y quiero confirmarlos antes de darlos por cerrados.
- **`Araujo` → `Arajuno` (22 filas).** No existe ningún cantón «Araujo» en Ecuador; Arajuno sí, en Pastaza. La corrección ya está aplicada.
- **`PescadeRío` (catálogos 683 y 684).** No la corregí porque no puedo determinar el original. Podría ser `Pescadero` o `Pesca de Río`. El contexto es `PescadeRío. luego de desfogue del agua de las piscinas`.

**Preguntas.**
1. ¿Confirman que `Araujo` era `Arajuno`?
2. ¿Qué decía la ficha original en los catálogos 683 y 684?

---

### C5 bis. Dos grafías del mismo distrito peruano, en dos niveles distintos

**El problema.** Los catálogos 2950–2952 declaran `stateProvince = Maynas` y `municipality = Torres Causoma`. Los catálogos 2532–2538 declaran `stateProvince = Loreto`, `county = Maynas` y `municipality = Distrito Torres Causana`. Es la misma zona del Perú modelada en dos niveles distintos, y `Causoma` parece errata de `Causana`.

**Preguntas.**
1. ¿`Torres Causoma` es errata de `Torres Causana`?
2. ¿Adopto Loreto como provincia y Maynas como cantón para los siete, o al revés?

---

### C6. ¿Quién georreferenció la colección?

**El problema.** El campo `georeferencedBy` tiene un único valor en todo el dataset —`Mateo Andrés Vega Yánez`— en 3.501 registros, y está vacío en 2.926. De esos 2.926 sin georreferenciador, **2.676 sí tienen coordenada**: el punto existe pero no consta quién lo determinó.

**Por qué importa.** Si el nombre corresponde a la persona que efectivamente georreferenció esos 3.501 registros, es un dato de procedencia valioso para la dimensión Persona. Si es un valor asignado en bloque durante una migración del portal, no significa nada y no debe modelarse como una autoría.

**Preguntas.**
1. ¿Las 3.501 georreferenciaciones son efectivamente de esta persona, o es un valor por defecto del portal?
2. Los 2.676 registros con coordenada y sin georreferenciador, ¿fueron georreferenciados por otra persona, o la coordenada venía ya en la ficha de campo?

---

### C7. Códigos de estación dentro de `locality`

**El problema.** Hay registros con códigos como `ICT-1`…`ICT-9`, `ICT-001`, `ICT-004`, `IC-01`, `WAM-306`…`WAM-359`, `CAMP 1`, `P.B.` (catálogos 530 y 531, escritos además con espaciado incoherente entre sí: `P.B. 1.2` y `P.B.2.2`), `ICT-06-GLI-OR`, `PC23` y `PC24`, y `18 M` (que es la localidad completa de 37 registros y no un fragmento) dentro de la localidad, mientras que `fieldNumber`, `eventID` y `recordNumber` están vacíos en las 6.427 filas. 

**Preguntas.**
1. ¿`ICT-1`, `ICT-01` e `ICT-001` son la misma estación?
2. ¿Estos códigos deben ir a `fieldNumber` o a `eventID`?

---

### C8. Valores administrativos que no corresponden al lugar

**El problema.** 
- `San Roque (Cab. en San Vicente)` en 8 filas del cantón Shushufindi: el paréntesis es el desambiguador INEC de la parroquia homónima de Antonio Ante, Imbabura.
- 14 filas con `municipality = Shushufindi` y `locality = Zábalo`, a 108 km de la parroquia Shushufindi.

**Pregunta.** ¿Se corrigen estas inconsistencias reasignando a sus ubicaciones reales?

---

### C9. Conflictos de denominación o ubicación en topónimos específicos

**El problema.** Se detectaron varios casos irresolubles automáticamente donde nombres o ubicaciones se contradicen:

- **Río Colimbo (3142–3143) vs Río Columbo (1653–1655):** Misma provincia, cantón y parroquia. Son 3 contra 2, sin mayoría clara.
- **pozo primare (6, cat. 290–295) vs Pozo Pimare (5, cat. 326–329, 394, 407):** Mismo pozo, Bloque 31, PN Yasuní.
- **Punta km 13+501 (cat. 5641) vs Punta km 13+500 (13 filas):** Todas en Chiruisla.
- **Cinco topónimos irresolubles desde el archivo:** Río Mashpi Grande y Chicho (3394, 3397), Masphien (2403), laguna redondo cocha (2950–2952), Río átun playa cocha (3730–3732), Salinas.006 (583). La capitalización ya la resuelve el propio archivo: existen cuatro filas con Laguna Redondo Cocha correctamente escrita y tres con Sector Redondococha. La consulta se reduce a decidir si el topónimo va junto, separado o con guion.
- **Siglas como localidad:** `Pod` (cat. 59) y `ECY` (5600, 5650), localidades de tres letras sin resolver.
- **Catálogo 1555:** Declara `Río Aguarico … Pisorie` en Carchi / Tulcán / Tobar Donoso, pero eso está a más de 300 km del resto del lote Pisorie.
- **Catálogo 310:** Localidad dice `2.5 m. Norte Río Nashiño`. ¿Son 2,5 m o 2,5 km?

**Preguntas.**
¿Pueden revisar y confirmar la grafía/ubicación correcta para cada uno de estos casos concretos?

---

## BLOQUE D — Coordenadas

*(Estas 328 filas están en el anexo `reporte_coordenadas_revision.csv`, con su categoría, método de reconstrucción y distancia fuera de la provincia.)*

### D1. Ochenta y cinco coordenadas que se arreglan invirtiendo la latitud (y un punto por defecto)

**El problema.** El punto cae en el hemisferio equivocado. Al invertir el signo de la latitud, la coordenada entra dentro de la provincia declarada. Estas coordenadas venían así en el dataset. 

**Excepción masiva:** El punto `-0.871270 / -79.858440` (con latitud negativa) lo comparten 65 filas de cuatro provincias distintas (Esmeraldas 62, Orellana 1, Pichincha 1, Bolívar 1). Esto indica que no es un signo invertido al azar, sino un **punto por defecto** o de referencia mal propagado.

**Preguntas.**
1. ¿Autorizan invertir el signo de la latitud en las 20 filas restantes donde el módulo sí coincide con la localidad descrita?
2. Para las 65 filas en `-0.871270 / -79.858440`: ¿corresponden a una coordenada de referencia del sistema que sobreescribió a la real?

---

### D2. El ingreso QCAZ concentra el 72 % de las discordancias

**El problema.** El ingreso QCAZ concentra la inmensa mayoría de los errores de contención. Los registros cuyo `recordedBy` contiene `QCAZ` (598 con coordenada) fallan la contención provincial en el 27,9 % de los casos; el resto de la colección, en el 1,1 %. Es decir, tienen veinticinco veces más discordancias.

De las 231 discordancias geográficas totales, 167 están en los catálogos ~5100–5799. En el tramo 5600–5699, 42 de cada 100 filas son discordantes y 76 de cada 100 no tienen localidad.

**Pregunta.** ¿Cómo se cargaron esos registros? ¿Fueron una migración desde otro sistema, una carga masiva sin georreferenciación propia, o se asignaron puntos por defecto al lote completo?

---

### D3. Catorce coordenadas donde el hemisferio es genuinamente ambiguo

**El problema.** El registro original no trae letra de hemisferio (`N`/`S`) ni signo. Mi script prueba todas las lecturas posibles y, cuando más de una cae dentro de Ecuador, desempata comprobando cuál queda dentro de la provincia declarada. En estas 14 el polígono no resolvió: o ninguna lectura cae en la provincia o caen varias. **No elegí por mi cuenta**: quedaron marcadas como `signo_ambiguo`.

**Filas afectadas.** 14, identificables en el anexo por la columna `signo_ambiguo = TRUE`. Incluyen los catálogos 3765, 4183, 4289, 5246, 5648, 5674 y 5678.

**Pregunta.** ¿Puede el curador determinar el hemisferio de estas 14 desde la localidad descrita?

---

### D4. Doce coordenadas con minutos o segundos mayores que 59

**El problema.** En notación sexagesimal, minutos y segundos van de 0 a 59. Estas doce declaran valores imposibles. 

Al analizar los patrones, el archivo resuelve tres de los cinco grupos:
- Catálogo 4184: `0.75''` (los hermanos 4196–4198 traen la longitud idéntica).
- Catálogo 4151: `07.3''` (sus hermanos 4149 y 4150 caen en el mismo minuto 34').
- Bobonaza (7 filas): `01°92'` es en realidad `01°52'` (la serie de colecta va de 43' a 52', y los 5904–5906 están en 01°52'57.2'').

Siguen abiertos solo los catálogos 4212/4213 (`3°55'64''S`) y el caso múltiple del 3765 (76 segundos, ver sección F/G).

**Pregunta.** Para 4212, 4213 y 3765: ¿Pueden verificar la coordenada en la libreta de campo?

---

### D5. Nueve registros en el mar, alrededor de Galápagos

**El problema.** Caen entre 11,3 y 25,3 km de la costa. Para una colección ictiológica esto es esperable —son capturas marinas—, así que no los marqué como error sino con la categoría propia `fuera_de_tierra_firme`. Los revisé uno por uno y son plausibles: quedan cerca de Marchena, Pinta y Darwin.

**Pregunta.** ¿Confirman que son capturas marinas legítimas? Solo necesito el visto bueno para dejar constancia de que se revisaron.

---

### D6. Doscientos cincuenta registros sin coordenada, por tres causas distintas

**El problema.** No son un solo caso; los separé porque la acción es distinta en cada uno:

| Causa | n | Situación |
|---|---|---|
| `sin_dato_origen` | 183 | Nunca hubo coordenada, ni decimal ni verbatim |
| `irreparable` | 66 | Hay `verbatimCoordinates` pero es ilegible o no reconstruible |
| `descartada_fuera_de_rango` | 1 | Catálogo 5170: traía `−14,95103 / −77,9968`, que es el sur de Perú, declarado como Pastaza. Sin verbatim para reconstruir |

**Preguntas.**
1. Para las 66 irreparables: ¿existe la coordenada en el libro de campo?
2. Para el catálogo 5170: ¿es un ejemplar peruano mal asignado a Pastaza, o la coordenada pertenece a otro registro?

---

### D6 bis. Las 66 coordenadas irrecuperables son cinco problemas distintos

**El problema.** El bloque D6 las describe como un solo grupo ilegible. Al clasificarlas por patrón resulta que dos familias sí son reconstruibles y que una ni siquiera es una coordenada.

| Familia | Filas | Situación |
|---|---|---|
| Prefijo de zona UTM pegado al easting | 4033, 4035 | `17828629 / 9809829` es zona 17, E 828629, N 9809829, y cae en Pastaza. `18193103 / 9823038` es zona 18 y también cae en Pastaza |
| Easting y northing invertidos | 5013 | `09993222/0746084` es N 9993222 / E 746084, par válido en zona 17S |
| Punto decimal perdido | 4947–5013, 13 filas | El catálogo 5011 trae `0016647/7887937`, dígito por dígito el mismo valor que el 4948 `00.16647/78.87937`, que sí se leyó |
| Easting corto de un dígito | El Oro 3897–3917 (20) y Pastaza 3518–3526 (9) | `65536 / 9612584`: el northing es válido, al easting le falta un dígito. Admite dos lecturas y ambas caen en la provincia |
| Rango en lugar de punto | 4222–4227, 6 filas | `78.28°W / 01.27°N / 00.01°S` son tres valores: una longitud y **dos latitudes** |
| Easting válido, northing fuera de rango | 3875–3879, 5 filas | Northing irrecuperable de forma automática |

El catálogo 4187 declara `01°40'45.55 / 71°54'53''`. La latitud coincide con la del 4201 (`01°40'45.551''`) hasta el centésimo de segundo, pero la longitud no comparte ni los minutos (54 frente a 59) ni los segundos (53 frente a 53.448). La hipótesis de sustitución de dígito se sostiene únicamente para el grado (71 frente a 91). El registro quedó clasificado como irrecuperable.

**Preguntas.**
1. Para 4033 y 4035: ¿confirman que el `17` y el `18` iniciales son la zona UTM? Si sí, esas dos se recuperan sin supuestos.
2. Para el bloque 4222–4227: ¿fue un transecto entre 01°27'N y 00°01'S, o una de las dos latitudes está de más?
3. Para el catálogo 4187: ¿es 91°54'53"W?
4. Para los bloques de El Oro y Pastaza y los catálogos 3875-3879: ¿existe libreta de campo? Con un solo punto verificado se resuelven.

---

### D7. Cincuenta y seis registros comparten coordenada con otra provincia y están en la minoría

**El problema.** 525 registros comparten una misma coordenada exacta con registros de otra provincia. En 469 casos el registro pertenece a la provincia mayoritaria de esa coordenada; en 56 está en la minoría. No es necesariamente un error —puede ser un punto exactamente en un límite provincial— pero es el patrón típico de una coordenada copiada de un registro vecino.

**Filas afectadas.** 56, marcadas en el anexo con `provincia_minoritaria = TRUE`.

**Pregunta.** ¿Estos 56 comparten evento de colecta con los demás de su coordenada, o se les asignó una coordenada de referencia por lote?

---

### D8. Cuatro registros con coordenada y sin provincia declarada

**El problema.** Tienen coordenada válida pero `stateProvince` vacío, así que no hay contra qué contrastarla. Quedaron como `no_evaluable`.

**Pregunta.** ¿Pueden completar la provincia, o la derivo de la coordenada y lo documento como derivación?

---

### D9. Cuatrocientos setenta registros con coordenada y sin datum declarado

**El problema.** Declaré `WGS84` únicamente en las 1.013 filas donde la conversión UTM lo determina por definición. En el resto —coordenadas que solo se leyeron o a las que se corrigió el signo— el datum de origen es desconocido y **decidí no suponerlo**. GBIF lo marca como `GEODETIC_DATUM_ASSUMED_WGS84` en 470 filas. El validador de GBIF confirma esta cifra con la incidencia `GEODETIC_DATUM_ASSUMED_WGS84` = 471, que incluye un registro adicional del bloque transfronterizo.

**Pregunta.** ¿Qué datum usaba la colección históricamente? Si fue PSAD56 en los registros antiguos, la diferencia con WGS84 puede llegar a varios cientos de metros y sí importa.

---

### D10. Ciento noventa y un registros con altitud máxima y sin altitud mínima

**El problema.** `minimumElevationInMeters` y `maximumElevationInMeters` delimitan un rango y van en pareja. En 191 filas solo está el máximo. Además 1.715 registros no tienen ninguna de las dos (Reparto: 4.519 solo mínima, 191 solo máxima, 2 ambas, 1.715 ninguna).

**Pregunta.** ¿El valor presente es la altitud puntual del sitio (y entonces mínimo y máximo deben ser iguales) o falta realmente el extremo inferior?

---

### D11. Falta de atributos de masas de agua en capturas marinas

**El problema.** Galápagos: 24 filas tienen `island`, `islandGroup` y `waterBody` vacíos al 100 %, incluidas las 9 capturas marinas. Con la coordenada ya reconstruida se pueden poblar esos campos derivados.

**Pregunta.** ¿Autorizan derivar `island` desde el polígono y declarar `waterBody`?

---

### D12. Localidad "Varios Sitios" con falsa precisión

**El problema.** Siete registros con `locality = "Varios Sitios"` declaran una incertidumbre de 100 m. Esa cifra no proviene del origen: es el piso tecnológico que el bloque 13b aplica a las colectas anteriores al año 2000. La precisión declarada en el origen de los siete es `decimal_6d`, que corresponde a 10 m. La pregunta al curador no es por qué declararon 100 m, sino qué radio real cubre un lote descrito como "Varios Sitios". Cuatro de los siete caen además fuera del polígono terrestre de Galápagos.

**Pregunta.** ¿Qué coordenada se digitó allí? ¿Se incrementa el radio de incertidumbre para reflejar la realidad del lote?

---

## BLOQUE E — Personas

### E1. Un mismo colector con tres grafías del apellido

**El problema.** Conviven `M. Ampam` (240 registros), `M. Ampak` (23) y `Miguel Ampa` (21). `Ampam` y `Ampak` son terminaciones válidas en shuar, así que no puedo decidir cuál es la correcta sin conocer a la persona. Si no se unifica, la dimensión Persona tendrá tres miembros para un solo colector y sus 284 registros aparecerán repartidos.

**Pregunta.** ¿Cuál es la grafía correcta del nombre de esta persona?

---

### E2. Instituciones y proyectos escritos en el campo de colector

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

**Preguntas.**
1. ¿Estas entidades deben moverse a `institutionCode` / `associatedReferences` y salir de `recordedBy`?
2. ¿`Indígenas` corresponde a colectores comunitarios de los que exista registro nominal?
3. ¿Qué significa `JVDC`?

---

### E3. La misma persona registrada como abreviatura y como nombre completo

**El problema.** Cinco pares que muy probablemente son la misma persona, pero no puedo unificarlos sin confirmación: una abreviatura puede corresponder a dos personas con el mismo apellido.

| Abreviatura | Nombre completo | Registros |
|---|---|---|
| `K. Swing` | `Kelly Swing` | 58 / 59 |
| `Belén Carrillo` | `María Belén Carrillo` | 12 / 54 |
| `L. Coloma` | `Luis Coloma` | 3 / 4 |
| `R. Ramírez` | `Raúl Ramírez` | 3 / 3 |
| `C. Vásquez` / `J. Vásquez` | — | 3 / 9 |
| `L. Guarderas` | `Lida Guarderas` | 1 / 309 |
| `E. Calvache` | `Evelyn Calvache` | 1 / 180 |
| `S. Vega` | `Santiago Vega` | 6 / 6 |
| `R. Boada` | `Ruth Boada` | 2 / 2 |
| `F. Ulloa` / `J. Ulloa` | `Fausto Ulloa` | — |
| `S. Abril` | `Sara Abril` | — |
| `P. Paredes` | `Patricia Paredes` | — |
| `M. Gaybor` | `Margarita Gaybor` | — |
| `A. Galarza` | `M. A. Galarza` | — |
| `Omar Domínguez` | `Omar Domínguez Domínguez` | — |
| `C. Puertas` | `Cecilia Puertas Donoso` | — |
| `L. Chuim` | `Liseth Chuim` | — |
| `G. Narankas` | `Germán Narankas` | — |
| `I. Narankas` | `Israel Narankas` | — |
| `J. Córdova` | ¿Jorge o José? | — |
| `M. Sánchez` | ¿M. E. o M. G.? | — |
| `N. Narankas` | (mayoritario de tres Narankas) | 264 |
| `P. Chuim` | frente a `L. Chuim` | 22 |
| `S. Paredes` | — | 3 |
| `E. Grijalva` | — | 1 |
| `D. Sánchez` | — | 2 |
| `H. Casco` / `P. Casco` | — | 5 / 7 |

**Preguntas.**
1. ¿Puedo unificar cada par al nombre completo?
2. `C. Vásquez` y `J. Vásquez`, ¿son dos personas distintas?

---

### E4. Nombres incompletos que no permiten identificar a la persona

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

**Pregunta.** ¿A quién corresponden estas iniciales? Aparecen juntas en los mismos registros, así que probablemente sean un equipo de campo identificable.

---

### E5. Nombres con grafía dudosa

**El problema.** Nombres que parecen erratas pero que no toco, porque un nombre propio puede escribirse de forma inesperada y corregirlo por mi cuenta sería inventar una identidad.

| Como aparece | Posible forma correcta | Registros |
|---|---|---|
| `Fermando Romero` | ¿Fernando? | 1 |
| `Agusta Córdova` | Convive con `Agusto Córdova` (5689) y `A. Córdova` (5735) en el mismo lote QCAZ | 1 |
| `Edwin Carrilo` | ¿Carrillo? | 1 |
| `A. Guiterez` | ¿Frente a `Sara Gutiérrez`? | — |
| `M. Grijalva` | ¿Frente a `Mario Grijalba`? | — |
| `M. Peñaherera` | ¿Frente a `S. Peñaherrera`? | — |
| `Francis Boily` | ¿Frente a `Francis Boyle` / `Dylan Boily`? | — |
| `Paola Nallely Plamerín Serrano` | ¿Palmerín? | — |
| `Paúl Ramírez` | ¿Errata de `Raúl Ramírez`? | — |
| `Paul Regalado` | ¿Paúl? | — |
| `Pablo Arguello` | ¿Argüello? | — |
| `Martin Cuji` | ¿Martín? | — |
| `Guillermo Orti` | ¿Ortí? | — |
| `Yarlnyn Jaramillo` | ¿Yarlyn? ¿Marilyn? | 1 |
| `Rossana Manosalva` / `Rosa Manosalva` | ¿La misma persona? | 2 / 1 |
| `J. Críollo` | ¿Criollo, sin tilde? | 7 |
| `Santiago Villamarín Cortéz` | ¿Cortés o Cortez? | 131 |

**Pregunta.** ¿Pueden confirmar la grafía correcta de cada uno? El de Villamarín afecta a 131 registros.

---

## BLOQUE F — Taxonomía

### F1. Nueve registros repartidos en dos banderas cuya familia pertenece a un orden distinto al del género

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

**Pregunta.** ¿Corrijo la familia desde el backbone de FishBase, igual que hice con las familias vacías, o prefieren revisarlas?

---

### F2. Noventa y tres registros con familia minoritaria dentro de su género

**El problema.** Un género tiene registros repartidos en dos familias distintas. A diferencia de F1, aquí ambas familias son del mismo orden, lo que apunta a eventos de reclasificación taxonómica reales y no a errores. Los bloques mayores:

| Familia declarada | Familia mayoritaria del género | Filas |
|---|---|---|
| Characidae | Iguanodectidae | 17 |
| Triportheidae | Characidae | 16 |
| Characidae | Bryconidae | 12 |
| Stevardiidae | Characidae | 6 |
| Characidae | Curimatidae | 5 |
| Pimelodidae | Heptapteridae | 5 |
| Acestrorhamphidae | Characidae | 4 |

**Preguntas.**
1. ¿Se unifica cada género a una sola familia según la clasificación vigente, o se conserva la familia con la que se determinó cada ejemplar?
2. Si se unifica, ¿qué clasificación se toma como referencia: FishBase, Eschmeyer's Catalog of Fishes, u otra?

---

### F3. Veintiséis registros donde el nombre atomizado contradice el nombre completo

**El problema.** Darwin Core guarda el nombre dos veces: completo en `scientificName` y desglosado en `genus` + `specificEpithet`. En estas filas las dos versiones no dicen lo mismo. **No los corregí**: elegir cuál manda es una decisión taxonómica.

**Doce donde discrepa el género** (marcadas con `flag_genus_no_coincide_con_nombre`):

| catalogNumber | `scientificName` | `genus` declarado |
|---|---|---|
| 531 | Pimelodella lateristriga | Pimelodus |
| 1980 | Hoplerythrinus unitaeniatus | Erythrinus |
| 2008 | Astyanax villwocki | Tetragonopterus |
| 2208, 2234, 2339 | Anablepsoides urophthalmus | Rivulus |
| 2358 | Curimata vittata | Steindachnerina |
| 1801 | Anablepsoides | Rivulus |
| 2004 | Anablepsoides | Rivulus |
| 1808 | Knodus | Bryconamericus |
| 1823 | Jupiaba | Astyanax |
| 1843 | Astyanax | Hemigrammus |

**Doce donde discrepa el epíteto (y 3 en ambas)** (marcadas con `flag_epiteto_no_coincide_con_nombre`):

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

Varios pares son sinónimos conocidos (`Rivulus`/`Anablepsoides`), lo que sugiere que el campo atomizado quedó con el nombre anterior. Otros no lo son.

**Pregunta.** ¿Manda `scientificName` o el par `genus` + `specificEpithet`?

---

### F4. Dos grafías de género que no se pudieron resolver

**El problema.** No están en FishBase con ninguna grafía y difieren de un nombre válido en una o dos letras, pero no los incluí en el mapa de erratas porque la corrección no es evidente. (Nota: Sí se corrigieron 19 grafías más en 40 filas, ).

| Como aparece | catalogNumber | Observación |
|---|---|---|
| `Saxatilia lucius` | 5891 | Resuelto: Saxatalia → Saxatilia unificado por mayoría interna (1 fila) |
| `Cynoponthicus coniceps` | 5177 | ¿`Cynoponticus`? |

**Pregunta.** Para el catálogo 5177: ¿Cuál es la grafía correcta?

---

### F5. Siete registros con ejemplar y sin identificación taxonómica

**El problema.** Tienen colector, fecha, localidad, coordenada, preparación y número de ejemplares — todo menos el taxón. Uno de ellos declara 134 ejemplares.

| catalogNumber | Colector | Fecha | Localidad | Ejemplares |
|---|---|---|---|---|
| 1309 | Martha Buenaño Carriel | 2008-12-22 | Noreste de Tarapoa | 2 |
| 1343 | Martha Buenaño Carriel | 2009-01-11 | Cuyabeno | **134** |
| 1455 | Martha Buenaño Carriel | 2009-01-10 | Río Cuyabeno | 1 |
| 1733 | Jonathan Valdiviezo | 2010-03-22 | Lago Agrio, Estero Chananguecillo | 4 |
| 1743 | Jonathan Valdiviezo | 2010-04-19 | Comunidad Santa Elena, Estero Cuencano | 8 |
| 3794 | Lida Guarderas | 2005-09-01 | Morete Yacua | 4 |
| 4322 | Paúl Tufiño | 2019-10-23 | Quebrada S/N | 1 |

**Por qué importa.** En el modelo dimensional son hechos sin dimensión Taxón. O se les asigna un miembro "sin determinar" o quedan fuera de todo análisis taxonómico.

**Preguntas.**
1. ¿Estos ejemplares están sin determinar en el depósito o se perdió la determinación al digitalizar?
2. ¿Los incluyo como "sin determinar" o los excluyo?

---

### F6. Cuatro registros que solo tienen un nombre de familia

**El problema.** Catálogos 4371, 4372, 4373 y 4374. Su `scientificName` es únicamente un nombre de familia (`Aspredinidae` el primero, `Characidae` los otros tres) y todo lo demás está vacío: sin colector, sin fecha, sin localidad, sin número de ejemplares.

**Pregunta.** ¿Son registros reales pendientes de catalogar, o filas de prueba que quedaron en el sistema?

---

### F7. Cinco determinaciones con cualificador que no encajan en ningún rango

**El problema.** Su `scientificName` lleva un cualificador de incertidumbre, así que no es ni un binomio limpio ni un nombre de género, y quedaron sin `taxonRank`. Son cinco determinaciones con cualificador (5146, 6395, 6396, 4323, 4325). El campo `taxonRank` queda vacío en doce filas: estas cinco más las siete de la duda F5, que no tienen determinación alguna.

| catalogNumber | `scientificName` |
|---|---|
| 5146 | `Lycengraulis cf.batesii` |
| 6395, 6396 | `Hypostomus gr. cochliodon` |
| 4323, 4325 | `Chaetostoma complex microps` |

**Pregunta.** ¿Se registran como `species` con el cualificador en `identificationQualifier`, o Darwin Core prevé otro tratamiento para `gr.` y `complex`?

---

### F8. Veinticuatro registros determinados solo hasta familia

**El problema.** No es un error —es una determinación legítima a nivel de familia— pero conviene confirmarlo. Los nombres involucrados: `Aspredinidae`, `Aulopidae`, `Characidae`, `Heptapteridae`, `Lebiasinidae`, `Loricariidae`, `Loricariinae`, `Sternopygidae`.

Nota: `Loricariinae` (catálogo 4306) es una **subfamilia**, no una familia, aunque está marcada con `taxonRank = family`.

**Preguntas.**
1. ¿Confirman que son determinaciones a nivel de familia y no identificaciones incompletas pendientes?

---

### F9. Diecinueve identificadores de taxón apuntan a más de un nombre

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
| 35663 | Knodus · **knodus** (solo mayúscula) |
| *(y once más)* | |

Algunos son sinonimias razonables (`Rivulus`/`Anablepsoides`); otros cruzan géneros distintos.

**Por qué importa.** Impide usar `taxonID` como clave natural de la dimensión Taxón: habría que generar una clave sustituta.

**Pregunta.** ¿El `taxonID` es un identificador estable del portal o se reasigna al redeterminar? Determina si sirve como clave o solo como referencia.

---

### F10. Géneros no resueltos en el backbone

**El problema.** Quince géneros no resuelven en FishBase y afectan a 64 registros. Cinco de ellos concentran 52: `Lipopterichthys` (16, Loricariidae), `Cochliodon` (13, Loricariidae), `Piabucina` (11, Lebiasinidae), `Peckoltichthys` (6, Loricariidae) y `Saxatilia` (6, Cichlidae). La consulta es si son sinónimos con combinación vigente distinta o géneros válidos ausentes del backbone.

**Pregunta.** ¿Son sinónimos con combinación vigente distinta o géneros válidos ausentes del backbone?

---


### F12. Dos familias con order en dos estados

**El problema.** Dentro de una misma familia, un registro tiene un orden declarado distinto al resto del grupo. No obedece al criterio de vaciado: son registros defectuosos.
- `Haemulidae` (16 filas sin orden, 1 con Perciformes): la fila rara es el catálogo 5367, determinado como `Orthropristis` (errata de `Orthopristis`).
- `Pomacentridae` (14 sin orden, 1 con Acanthuriformes): la fila rara es el catálogo 4201, determinado como `Holacanthus` (que es `Pomacanthidae` en el backbone, no `Pomacentridae`).

**Preguntas.**
1. Para el catálogo 5367: ¿se corrige la errata `Orthropristis` → `Orthopristis`?
2. Para el catálogo 4201: ¿se corrige la familia a `Pomacanthidae` acorde con el género `Holacanthus`?

---

### F13. Registros con inconsistencias cruzadas (Holotipos, taxones y coordenadas)

**El problema.** Hay registros que presentan múltiples fallos de concepto o procedencia en simultáneo, afectando incluso a holotipos:

- **Catálogo 4358 (Holotipo sin datos):** Declara `typeStatus = Holotype`, `stateProvince = Galápagos`, familia `Haemulidae`. Sin embargo, no tiene colector, fecha, localidad, número de ejemplares, ni identificador. Es uno de los dos únicos tipos de la colección. ¿Es un holotipo real o un typeStatus mal asignado?
- **Catálogo 3944 (Holotipo en hemisferio equivocado):** Es el otro holotipo y tiene la latitud errónea. Sus seis números en el verbatim son idénticos a los 3762–3764 (que traen `N` explícita y salen a `+0,091267`). El portal guardó `-0,091267` (una diferencia de 20 km), y Quebrada Sune está en Pacto, Pichincha, en el hemisferio Norte.
- **Catálogo 3765 (Contaminación doble):** Ya mencionado en taxonomía (`identifications` dice `Microglanis` y el core arrastra `Xyliphius melanopterus` de sus vecinos). Además, declara Orellana cuando sus cuatro hermanas sitúan Quebrada Sune en Pichincha/Pacto, y su coordenada sexagesimal trae 76 segundos. Está corrupto en los ejes taxonómico y geográfico.
- **Catálogo 6294:** Única fila de `Parodon` con `family = Lebiasinidae` frente a cinco con `Parodontidae`.
- **Veintinueve filas con `identificationQualifier = "sp."` sobre un binomio completo:** Vienen así del origen. "sp." significa especie indeterminada y contradice directamente la existencia del binomio completo.

**Preguntas.**
1. ¿Los catálogos 4358 y 3944 son verdaderamente holotipos? Si es así, se requiere completar la ficha del 4358 y confirmar la corrección de hemisferio del 3944.
2. ¿Qué se hace con el catálogo 3765, que parece una suma de errores de digitación en todos los ejes?
3. ¿Se corrige la familia de `Parodon` a `Parodontidae` en el 6294?
4. En los 29 binomios completos con "sp.", ¿se elimina el cualificador o se recorta el binomio a género?

---

## BLOQUE G — Estructura y alcance del dataset

### G1. Setecientos noventa y cuatro registros forman grupos idénticos

**El problema.** Al agrupar filas con especie, fecha, localidad, colector y provincia poblados, resultan 277 grupos donde varios registros comparten especie, fecha, localidad, colector y provincia, difiriendo solo en el número de catálogo. En una colección de museo esto es normal —son ejemplares del mismo lote, cada uno con su frasco— pero hay que decidirlo explícitamente porque cambia todos los conteos.

**Preguntas.**
1. ¿Confirman que son ejemplares individuales de un mismo lote y no duplicados de digitación?
2. ¿La unidad de análisis del dashboard es el ejemplar, el lote o el evento de colecta?

---

### G2. `identifications.csv` no es un historial, pero contiene información que el core no tiene

**El problema.** Esperaba una tabla de redeterminaciones. No lo es: 6.427 filas y 6.427 `coreid` distintos, exactamente una determinación por ocurrencia. Como dimensión de historial taxonómico no aporta nada. Y en cobertura es peor que el core en todo: 4.299 géneros frente a 6.386, 3.229 epítetos frente a 5.160, y `taxonRank`, `infraspecificEpithet`, `identificationReferences` e `identificationRemarks` vacías al 100%. Sus 6.424 `dateIdentified` incluyen 271 con los placeholders `sin datos` y `s.d.` que en el core ya limpié.

Al comparar contra el core crudo, y tras descartar los falsos positivos por espacios duros, el archivo aporta:
- **803 autorías** (`scientificNameAuthorship`) que el core no trae.
- **0 `identifiedBy`** útiles (los 7 que tiene son una fecha y cinco `unknown`).
- **23 redeterminaciones confirmadas** (van a `previousIdentifications`).
- Las 59 diferencias dudosas (ver bloque J1).

**Mi propuesta.** No incorporar `identifications.csv` como tabla al modelo. Extraerle solo los aportes válidos (autorías y las 23 redeterminaciones comprobadas) y dejarla fuera del alcance con justificación numérica escrita. Incorporarla obligaría a limpiar 52 formas distintas de `identifiedBy` para reconstruir una dimensión que en el core ya está conformada.

**Preguntas.**
1. ¿Confirman que el portal no guarda historial completo de redeterminaciones, o existe en otro lado y esta exportación no lo trae?
2. ¿Autorizan tomar las 803 autorías y las 23 redeterminaciones y dejarlas integradas al core?

---

### G3. `materialSample.csv` viene vacío

**El problema.** El archivo tiene 0 filas y 32 columnas declaradas (`materialSampleID`, `sampleType`, `preservationType`, `concentration`, `ratioOfAbsorbance260_280`…). Son campos de muestras de tejido y extractos de ADN. La extensión está declarada en el `meta.xml` del archivo Darwin Core pero nunca se pobló.

**Preguntas.**
1. ¿La colección conserva muestras de tejido o extractos de ADN de estos ejemplares?
2. Si no, ¿debería retirarse la extensión del `meta.xml`? Declarar una extensión vacía sugiere una capacidad que el dataset no tiene.
3. Si sí, ¿existen en otro sistema y podrían incorporarse?

---

### G4. Solo el 5,4% de la colección tiene fotografía

**El problema.** 430 imágenes para 346 ocurrencias de 6.427. De esas 346, hay 262 con una imagen y 84 con dos. El 94,6% de la colección no tiene registro visual.

**Preguntas.**
1. ¿Existe un plan de digitalización fotográfica en curso?
2. ¿Vale la pena incluir la disponibilidad de imagen como atributo en el dashboard, o el porcentaje es tan bajo que no aporta?

---

## BLOQUE H — Lotes con anomalías acumuladas

### H1. Treinta y cinco registros en una sola coordenada de Guayaquil

**El problema.** Treinta y cinco filas caen dentro de un metro del mismo punto (`-2.091522 / -79.392815`, Guayaquil): la mayoría declara Sucumbíos. 33 de las 35 no tienen `locality` ni `county`. El rango de catálogo abarca del 5185 al 5658, por lo que no es un lote contiguo. La coordenada viene del origen: no la produjo ninguna conversión nuestra.

Esto indica que no es un error de digitación individual, sino una coordenada inyectada masivamente. Las 35 están clasificadas como discordantes y con `georeferenceVerificationStatus = requires verification`.

**Pregunta.** ¿De dónde salió esa coordenada? ¿Es un punto por defecto del sistema o una referencia institucional mal asignada?

---

### H2. Quince coordenadas anómalas por posible error de digitación en el *northing*

**El problema.** La hipótesis de error en la zona UTM fue refutada por cálculo: ninguna de estas 15 coordenadas mejora cambiando de zona (y GBIF lo confirma con `COUNTRY_COORDINATE_MISMATCH` para puntos como `-5.063108`). 

La pregunta pasa a ser un posible error en el *northing*, con hipótesis concretas:
- `9440090` → ¿`9940090`? (Caería en Orellana, afecta a 5 filas: cat. 5684, 4022, 4023, 4024, 4025)
- `9956191` → ¿`9656191`? (Caería en El Oro, afecta a 5 filas)
- `9890000` → ¿`9800000`? (Caería en Pastaza, afecta a 3 filas)

**Pregunta.**
¿Pueden confirmar con el libro de campo si estos *northing* tienen un dígito mal digitado según estas hipótesis?

---

### H3. Un registro con el dígito de los grados mal tipeado

**El problema.** El catálogo 4195 declara `stateProvince = Manabí` y su coordenada es `0.901611 / -90.647778`, cayendo en Galápagos. Sin embargo, el catálogo 4195 comparte el verbatim exacto con 4180, 4181, 4182, 4190 y 4200, salvo en el grado de longitud (90 en vez de 80). Los cinco declaran Manabí y caen en Manabí. La provincia está bien; la coordenada tiene un error de digitación (9 por 8).

**Confirmación.** Se documenta el hallazgo para la corrección a 80°.

---

## BLOQUE I — Contradicciones biogeográficas

### I1. Dos especies marinas del Pacífico registradas en la Amazonía

**El problema.** Cada campo es válido por separado; la combinación describe algo que no ocurre.

| catalogNumber | Especie | Familia | Provincia declarada |
|---|---|---|---|
| 5313 | *Epinephelus analogus* (mero del Pacífico) | Epinephelidae | Napo |
| 5453 | *Trachinotus rhodopus* (pámpano del Pacífico) | Carangidae | Sucumbíos |

Ninguna de las dos familias tiene representantes dulceacuícolas en la cuenca amazónica ecuatoriana.

**Preguntas.**
1. ¿El error está en la determinación o en la procedencia?
2. ¿Los ejemplares siguen disponibles para revisión física?

---

### I2. Diecinueve registros solitarios en la vertiente contraria

**El problema.** Diecinueve especies presentes a ambos lados de los Andes tienen un único registro en una de las dos vertientes. Un registro solitario en la vertiente minoritaria es candidato a error de determinación o de procedencia, aunque también puede ser un hallazgo real de distribución.

**Pregunta.** ¿Cuáles de estos diecinueve son ampliaciones de distribución conocidas y cuáles conviene revisar?

---

### I3. Ochenta registros a una altitud fuera del rango de su propia especie

**El problema.** Comparando cada registro contra la mediana de altitud de su misma especie **dentro de esta colección**, ochenta se desvían más de seis desviaciones absolutas medianas. Afecta a 32 especies. Ejemplos:

| catalogNumber | Especie | Altitud declarada | Mediana de la especie |
|---|---|---|---|
| 1573 | *Anablepsoides rubrolineatus* | 1.140 m | 260 m |
| 1021, 1037, 1071 | *Charax tectifer* | 894–910 m | 271 m |
| 1023, 1077 | *Bujurquina mariae / moriorum* | 910 m | 270 m |
| 1002, 1193, 1197 | *Ceratobranchia elatior* | 269–483 m | 905 m |
| 1724 | *Creagrutus muelleri* | 940 m | 1.585 m |

No afirmo que la altitud sea incorrecta: puede ser una población de altura real, o la altitud puede pertenecer a otro registro del lote. Las especies con más casos son *Creagrutus muelleri* (7), *Charax tectifer* (4), *Bujurquina mariae* (4) y *Ancistrus malacops* (4).

**Preguntas.**
1. ¿Estas especies tienen rangos altitudinales tan amplios, o la altitud está mal asignada?
2. ¿La altitud se tomó en campo o se derivó de la coordenada a posteriori?

---

## BLOQUE J — Determinaciones previas

### J1. Cincuenta y nueve casos donde `identifications.csv` y el core discrepan

**El problema.** De los 88 nombres distintos del CSV (incluyendo 29 falsos por espacio duro que fueron corregidos), resultan 59 diferencias netas: 25 sin fecha comparable, 18 con literal `undefined`, 10 truncados y 6 con la misma fecha. (Y 23 casos que sí tenían fecha anterior pasaron a `previousIdentifications`). 

Quedan varios casos dudosos o problemáticos:

- **Veinticinco sin fecha comparable.** `identifications` dice `sin datos` donde el core sí tiene fecha (casi todos del lote de julio 2023). No se puede probar cuál determinación es anterior.
- **Seis con la misma fecha.** 
- **Catálogos 3766 y 3767 (Intercambio probado):** El `tidInterpreted` está intercambiado exactamente igual que el nombre (3766: core 35266 / ident 36078; 3767 al revés). Es un desalineamiento de filas probado, no una redeterminación. Ya no es duda.
- **Catálogo 4336:** `identifications` dice `Gymnotus` (2019) y el core `Gymnotus coatesi` (2023). Con fecha anterior parecería una redeterminación de género a especie, pero la tabla pierde el epíteto de forma sistemática en 1.111 filas.
- **Catálogo 4322:** `identifications` trae `Characidae` donde el core no tiene ningún nombre. Es el único aporte taxonómico neto de toda la tabla.
- **Dieciocho filas con el texto `undefined`**.

*(Nota: el catálogo 3765, que también presentaba discrepancias, se trata integralmente en la sección de anomalías cruzadas F13).*

**Preguntas.**
1. Para los 25 sin fecha: ¿el lote de julio 2023 fue una redeterminación masiva?
2. Para 4336: ¿Fue una determinación real a nivel de género en 2019 o es la misma pérdida de dato (truncamiento)?
3. Para 4322: ¿Se acepta `Characidae` como determinación?
4. ¿`undefined` significa "no determinado" o es un fallo de exportación?

---

### J2. Cuatro campos declarados en `meta.xml` que ningún archivo entrega

**El problema.** `taxonRank`, `infraspecificEpithet`, `identificationReferences` e `identificationRemarks` están declarados en la extensión y vacíos en las 6.427 filas.

**Pregunta.** ¿El portal los tiene poblados internamente y no se exportaron, o nunca se usaron?

---

## BLOQUE K — Configuración del portal

### K1. Las URLs de `references` apuntan a localhost

**El problema.** Los 6.427 valores de `dc:references` son `https://localhost/bndb/collections/individual/index.php?occid=...`. Fuera del servidor no resuelven, y GBIF los publicaría así.

### K2. La colección no está registrada en GRSciColl

**El problema.** GBIF devuelve `COLLECTION_MATCH_NONE` en los 6.427 registros: el `collectionID` `b636a8df-9e83-45fe-a0ae-dacfbb36c300` no corresponde a ninguna colección registrada.

### K6. Código de institución discordante

**El problema.** GBIF devuelve `INSTITUTION_MATCH_FUZZY` en los 6.427 registros, debido al desajuste entre `institutionCode = INABIOEC` y `ownerInstitutionCode = INABIO`.

### K7. El campo `dcterms:modified` no se actualiza

**El problema.** La marca de agua `dcterms:modified` no se actualiza al redeterminar un ejemplar. 4.124 filas conservan el sello `2020-01-08T16:10:25` a pesar de declarar determinaciones de 2023. El portal sí registra la modificación, pero lo hace en el timestamp de la extensión `identifications` (con un rango `2023-10-20` → `2025-11-03`, que es posterior al del core en 4.567 filas).

**Pregunta.** ¿Es el comportamiento esperado del portal? Esto determina cuál debe ser la marca de agua a leer en la carga incremental del Data Warehouse.

### K8. El `eml.xml` no tiene contacto completo

**El problema.** El validador devuelve `RESOURCE_CONTACTS_MISSING_OR_INCOMPLETE`.

**Pregunta.** ¿Quién debe figurar como contacto del recurso, con qué rol y qué correo institucional?

### K4. `rightsHolder` sin espacio

**El problema.** El campo `rightsHolder` dice "Gobierno del Ecuador- INABIO" en las 6.427 filas, sin espacio antes del guion. Es configuración del portal, igual que las URLs con localhost.

### K5. Uso de `taxonID` como clave interna

**El problema.** `taxonID` trae la clave interna de Symbiota. GBIF devuelve `TAXON_ID_NOT_FOUND` en 5.568 registros. Además 19 identificadores apuntan a más de un nombre y 445 filas comparten nombre con otro identificador.

**Preguntas.**
1. ¿Cuál es el dominio público del portal, para reemplazar localhost?
2. ¿Está prevista la inscripción de MECN-DP en GRSciColl?
3. ¿Cuál es el código institucional correcto, INABIO o INABIOEC?
4. ¿El portal puede exportar un LSID válido en `taxonID`, o se debe dejar vacío y usar solo la jerarquía textual?

---

## BLOQUE L — Criterios que necesitan visto bueno del Ing. Guevara

*(Estos no son para INABIO: son decisiones metodológicas ya tomadas que deben quedar avaladas y redactadas.)*

**L1. Tratamiento asimétrico de los valores «desconocido» e «Indeterminado».** Conservé el valor en `sex` y `establishmentMeans` porque el vocabulario Darwin Core contempla términos equivalentes (`undetermined` y `uncertain`), y lo vacié en `lifeStage` y `reproductiveCondition` porque no existe término equivalente. La regla no es "borrar los placeholders" sino "conservar el valor cuando el vocabulario del término lo contempla".

**L2. Idioma de los vocabularios controlados.** Llevé a inglés los campos con vocabulario controlado (`basisOfRecord`, `sex`, `establishmentMeans`, `taxonRank`, `typeStatus`, `language`) y dejé en español los de texto libre (`preparations`, `disposition`). Es reversible como bloque si se prefiere todo en español.

**L3. Criterio asimétrico con `family`.** Las familias vacías se derivan del backbone; las que contradicen el orden solo se marcan. Hay que decidir si se unifica el criterio (ver F1).

**L4. Orden de los colectores.** Detecté y revertí diez celdas donde la consolidación automática de variantes había invertido el orden de los colectores. Darwin Core establece que el colector principal va primero, así que el orden es información, no formato.

**L5. Autoridad única para la jerarquía taxonómica superior.** Se adoptó FishBase como autoridad única para `order` en todos los géneros resolubles contra su backbone. La decisión reclasifica 624 registros de cíclidos de `Perciformes` a `Cichliformes` y modifica el orden en 941 filas (el parche 5c-ter reclasificó 6 filas de Saxatilia) respecto al valor de origen, que se conserva íntegro en `order_verbatim`. Los 26 géneros que no resuelven contra el backbone conservan el orden del origen (el filtro del reporte usaba la anotación en vez de la pertenencia al backbone y ocultaba 8 géneros de condrictios); su listado está en `generos_no_resueltos_backbone.csv`.

**L6. Continente calculado sobre islas.** Llenar `continent` en las 6.427 filas genera `CONTINENT_COORDINATE_MISMATCH` en 13 registros del archipiélago, porque el polígono de GBIF no devuelve continente sobre el mar. Decisión: se conserva el campo y se documenta el aviso.

**L8. Comparación contra el verbatim (redeterminaciones).** Se declara que la discriminación de redeterminaciones se hace contra `scientificName_verbatim` y no contra el core limpio. Comparar contra el limpio convertía 46 correcciones ortográficas propias en falsas discordancias (y elevaba de 59 a 99 casos).

**L9. Reglas autorreferenciales.** Tres reglas de plausibilidad usan la propia colección como población de referencia (altitud fuera del rango, único registro en la vertiente, año atípico para el colector). Con 1.218 coordenadas distintas para 6.177 registros, la colección no es una muestra representativa: se declara explícitamente para evitar malas interpretaciones de "outliers" como errores absolutos.



---

## BLOQUE N — Nuevas Dudas (Ronda 4)

### Bloque toponímico — sin mayoría que decida

| Caso | Cifras |
|---|---|
| Chobacocha / Chubacocha / Chabacocha | 1 fila cada una, mismo colector, mismo lote de Pastaza |
| Chuyayaku (2) / Chayayaku (1) | mismo colector que Chobacocha |
| Anacocha (1) frente a Pañacocha (62) | nuevo |
| Piñacocha (1) frente a Pañacocha (62) | nuevo |
| Sábalo (5) / Zábalo (14) / Río Sabalos (11) | los Sábalo son de Touzet 1985, los Zábalo de 2024 |
| Río Pishira (14) / Río Pichira (8) | misma parroquia (Limoncocha) |
| Indiyana (6) / Indillana (10) / Indiyalla (4) | tres campos distintos; el Indiyana es de 1993 y declara Napo, coherente con Indillana antes de crearse Orellana |
| Río Tarapuy (75) / Río Tanipuy (1) | misma coordenada, misma fecha, mismo colector: es el mismo sitio |
| Munchimkim (24) / Muchinkin Chico (24) | empate exacto |
| Campamento T. Pisorie Setsacco (2) / Campamento 1 (21) | fechas consecutivas, misma coordenada; la T. no es un número |
| Huiririma Cucha (7) / Huiririma Sacha (2) | misma coordenada; en kichwa cucha es laguna y sacha selva |
| a Saguangal (8) / al Saguangal (1) | misma carretera |
| Seis pares de género gramatical | Bermeja/Bermejo, Kenkim/Kenkin, Monsoya/Mansoya, Chague/Changue, Chumunde/Chumende, Malimpia/Malimpio |
| Sufijo kichwa yacu / yacua / yawa | Morete Yacua(30)/Yacu(27), Carlos Yacua(22)/Yawa(22), Chulla chaqui Yacua(18)/Chullachaquiyawa(18). Es una convención, no cuatro erratas |
| Cuatro grafías de Lagarto-cocha | Lagarto-cocha(26), Lagarto-Cocha(10), Lagarto Cocha(10), Lagartococha(4) |
| Chorera (1) | ¿Chorrera? |
| Distrito: Torres Causana dentro de locality | 7 celdas, mismo caso que Parroquia Pacto |

### Bloque taxonómico

| Caso | Cifras |
|---|---|
| Holotipo 3944 | Sus tres hermanas de Quebrada Sune (3762–3764), con el mismo verbatim numérico y la letra N explícita, resuelven en +0.091267; el 3944 sale en −0.091267. 20 km. ¿Se corrige la latitud de un tipo nomenclatural? |
| Chaetostoma marginatum / marginatus | empate 1-1 |
| Cochliodon oculeus (2) / oculus (4) | y Cochliodon no resuelve en el backbone |
| 48 nombres con más de una familia | 575 filas, 74 en la minoría. Peores: Moenkhausia oligolepis 69/1, Hoplias malabaricus 59/1, Distocyclus conirostris 20/1, Pimelodella lateristriga con tres familias |
| flag_family_discrepa_backbone: 1.729 filas (27 %) | Characidae frente a Acestrorhamphidae/Stevardiidae. ¿La dimensión Taxón usa la familia del origen o la del backbone? |
| Cinco registros de Scorpaeniformes | 31, 2452, 4188, 5702, 5703: el origen es más específico que el clado informal de FishBase |
| Cynoponthicus coniceps (5177) y Orthropristis chalceus (5367) | siguen sin resolver |

### Bloque de lote y de determinaciones

| Caso | Cifras |
|---|---|
| Catálogos 6228–6424 | 197 filas contiguas, Fernando Sánchez, Pastaza, 2024-25, con los ejes transpuestos en el 100 % del lote. ¿Defecto de la plantilla de carga del portal? |
| Catálogos 3766 / 3767 | Intercambio recíproco entre Trichomycterus y Brachyhypopomus en identifications.csv |
| Catálogo 3765 | identifications dice Microglanis, el core dice Xyliphius melanopterus. Arrastre de las tres filas anteriores |
| Catálogos 2336 y 3775 | Misma fecha, dos nombres, discordancia real. Con el 3765 son tres casos que necesitan al curador, no dos |

---

## ANEXO — Verificado y descartado (no son errores)

Para que quede constancia documental ante futuras revisiones, los siguientes casos fueron comprobados en el proceso de limpieza y confirmados como datos correctos:

- **Pacayaku (Pastaza) vs Pacayacu (Sucumbíos):** Son dos parroquias reales y distintas.
- **Río Mindo vs Río Pindo:** Ambos existen.
- **Pares ortográficos verificados (Mira/Mera, Tarapoa/Taracoa, Anodus/Knodus, Conodon/Cynodon, Synodontidae/Cynodontidae):** El script los excluye por lista explícita por ser pares reales y no erratas (falsos positivos).
- **Cantones homónimos de su provincia:** Verificado y cerrado: 583 filas en Pastaza, Orellana, Esmeraldas, Sucumbíos y Loja, todas legítimas.
- **Las 33 celdas de `scientificNameAuthorship` con ".,":** Es formato ICZN correcto.
- **Las 144 celdas de `recordedBy` de 200 caracteres exactos:** Es la expansión completa del nombre, no hay truncamiento de campo de base de datos.
