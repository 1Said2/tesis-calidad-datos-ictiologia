# Criterios metodologicos y hallazgos documentados

Contenido extraido de cuestionario-inabio.md por no constituir una pregunta dirigida al curador. Son decisiones tomadas por el equipo de desarrollo y hallazgos registrados sin accion pendiente. Sirven de insumo para el capitulo de metodologia y para el de resultados.

## Criterios metodologicos

*(Estos no son para INABIO: son decisiones metodológicas ya tomadas que deben quedar avaladas y redactadas.)*

**L1. Tratamiento asimétrico de los valores «desconocido» e «Indeterminado».** Conservé el valor en `sex` y `establishmentMeans` porque el vocabulario Darwin Core contempla términos equivalentes (`undetermined` y `uncertain`), y lo vacié en `lifeStage` y `reproductiveCondition` porque no existe término equivalente. La regla no es "borrar los placeholders" sino "conservar el valor cuando el vocabulario del término lo contempla".

**L2. Idioma de los vocabularios controlados.** Llevé a inglés los campos con vocabulario controlado (`basisOfRecord`, `sex`, `establishmentMeans`, `taxonRank`, `typeStatus`, `language`) y dejé en español los de texto libre (`preparations`, `disposition`). Es reversible como bloque si se prefiere todo en español.

**L3. Criterio asimétrico con `family`.** Las familias vacías se derivan del backbone; las que contradicen el orden solo se marcan. Hay que decidir si se unifica el criterio (ver F1).

**L4. Orden de los colectores.** Detecté y revertí diez celdas donde la consolidación automática de variantes había invertido el orden de los colectores. Darwin Core establece que el colector principal va primero, así que el orden es información, no formato.

**L5. Autoridad única para la jerarquía taxonómica superior.** Se adoptó FishBase como autoridad única para `order` en todos los géneros resolubles contra su backbone. La decisión reclasifica 624 registros de cíclidos de `Perciformes` a `Cichliformes` y modifica el orden en 827 filas respecto al valor de origen: 765 que traían un valor previo y 62 que estaban vacías. El valor de origen se conserva íntegro en `order_verbatim`. Los 15 géneros que no resuelven contra el backbone conservan el orden del origen; estos casos se identifican con la bandera `genero_fuera_de_backbone_fishbase` en el archivo principal.

**L6. Continente calculado sobre islas — RESUELTA.** Lo escribe el bloque 8b de `Fishbase.R`: 6.398 registros con `South America`, 4 omitidos por falta de país y coordenada, 25 omitidos por insularidad. Nota adicional: la omisión en los insulares no evitó el aviso —GBIF rederivó el continente desde las coordenadas en 12 registros y aun así marcó `CONTINENT_COORDINATE_MISMATCH` en uno (catálogo 4289)—.

**L8. Comparación contra el verbatim (redeterminaciones).** Se declara que la discriminación de redeterminaciones se hace contra `scientificName_verbatim` y no contra el core limpio. Comparar contra el limpio convertía 46 correcciones ortográficas propias en falsas discordancias (y elevaba de 59 a 99 casos).

**L9. Reglas autorreferenciales.** Tres reglas de plausibilidad usan la propia colección como población de referencia (altitud fuera del rango, único registro en la vertiente, año atípico para el colector). Con 1.219 coordenadas distintas para 6.178 registros, la colección no es una muestra representativa: se declara explícitamente para evitar malas interpretaciones de "outliers" como errores absolutos.

**L10. Unidad de análisis del tablero.** En 274 grupos de la colección varios catálogos comparten especie, fecha, localidad, colector y provincia, y difieren solo en el número de catálogo. El tamaño medio del grupo es 2,6 ejemplares y el máximo 31. Se declara que el catálogo es el ejemplar y no el lote, de modo que compartir punto, fecha y especie es la estructura normal de una colecta y no una duplicación de digitación. La regla que lo mide pasó a `reporte_plausibilidad_verificadas.csv`. Hay que confirmar que la unidad de análisis del tablero es el ejemplar y no el lote ni el evento de colecta, porque cambia todos los conteos.

**L11. `references` con host `localhost` y `rightsHolder` con guion asimétrico.** El conjunto no se publicará en GBIF; ambos campos se conservan tal como los entrega el portal. El validador de GBIF se emplea como instrumento externo de medición para el Capítulo IV, no como destino de publicación.

**L12. `km` en minúscula al inicio de valor.** 14 celdas. La regla de capitalización inicial cede ante el símbolo de unidad del SI.

**L13. Redondeo a seis decimales de la coordenada publicada.** 354 filas: es normalización de formato, no corrección de valor; el desplazamiento máximo es inferior a 0,1 m y el valor íntegro se conserva en `verbatimLatitude` y `verbatimLongitude`.

**L14. Ausencia de fecha tratada como anterior al año 2000.** En el piso tecnológico de incertidumbre (493 registros con coordenada y sin `eventDate`).

**L15. Fin de línea y empaquetado.** El `meta.xml` debe declarar el mismo número de columnas que el CSV. Un desajuste no lo denuncia el validador como error de estructura.

**L16. Contradiccion de licencia en multimedia.csv, se documenta y no se pregunta.** Las 430 filas de la extension declaran tres cosas distintas sobre la misma licencia. El campo `rights` indica `http://creativecommons.org/licenses/by-nc/4.0/`, el campo `UsageTerms` indica `CC BY-NC-SA` y el campo `WebStatement`, que por definicion debe contener la URL de la declaracion de derechos, contiene el texto libre `Sin fines de lucro`. La decision es institucional y no afecta a ningun entregable, porque la extension multimedia no se publica en el Darwin Core Archive. Se registra como hallazgo de la auditoria propia y no se eleva como pregunta al curador, para no competir por su atencion con las decisiones que si bloquean el modelo dimensional.

## Hallazgos documentados sin pregunta

### F19. `TAXON_ID_NOT_FOUND` en las 5.568 filas con `taxonID` poblado

**El problema.** Darwin Core espera que `dwc:taxonID` sea un identificador resoluble del concepto taxonómico (LSID, URI o clave de GBIF); el `tid` numérico interno de Symbiota no lo es. El campo se retira del paquete que va al validador y se conserva en el archivo interno, donde sostiene la duda F9.

Consecuencia para el modelo: el taxonID de origen no es un identificador resoluble ni estable, por lo que la dimension Taxon requiere clave sustituta.

---

### F20. `Eretmobrycon dahli` (8 filas)

**El problema.** El backbone de GBIF consultado por API devuelve `EXACT` con confianza 100; el validador, sobre el mismo backbone, devuelve `TAXON_MATCH_HIGHERRANK`. Enviar también `scientificNameAuthorship` en la consulta no elimina la divergencia. Es una diferencia entre dos puntos de entrada al mismo backbone, no un defecto del dato. Se documenta sin resolver.

---

### Contraste con el validador de GBIF

El conjunto se empaquetó como Darwin Core Archive y se sometió al validador de GBIF antes y después del pipeline. Las incidencias se agrupan en tres categorías porque no todas dependen del dato.

| Grupo | Original | Limpio | Variación |
|---|---|---|---|
| Registro e identificador | 18.286 | 12.854 | −29,7 % |
| Interpretación suplida por GBIF | 13.259 | 490 | −96,3 % |
| **Contenido del dato** | **2.508** | **146** | **−94,2 %** |
| Total | 34.053 | 13.490 | −60,4 % |

El primer grupo no depende del pipeline: `INSTITUTION_MATCH_FUZZY` y `COLLECTION_MATCH_NONE` se originan en el registro de la institución en GRSciColl, y `TAXON_ID_NOT_FOUND` desaparece únicamente porque el identificador local de Symbiota se retiró del paquete.

Siete incidencias desaparecen por completo: `COORDINATE_ROUNDED` (562), `PRESUMED_SWAPPED_COORDINATE` (197), `IDENTIFIED_DATE_INVALID` (177), `PRESUMED_NEGATED_LONGITUDE` (162), `BASIS_OF_RECORD_INVALID` (68), `GEODETIC_DATUM_INVALID` (8) y `EML_GBIF_SCHEMA` (13).

De las 146 incidencias de contenido que persisten, el pipeline tenía marcadas previamente todas menos las ocho filas de `Eretmobrycon dahli` (duda F20). La relación entre bandera propia e incidencia externa es de **contención, no de equivalencia**: el pipeline marca 232 coordenadas discordantes con la provincia declarada y el validador señala seis de ellas.

Aparece una incidencia nueva: `CONTINENT_COORDINATE_MISMATCH` en un registro (catálogo 4289), que el pipeline ya tenía marcado como `signo_ambiguo`.
