# Mapa de renumeración — cuestionario-inabio.md

Archivo interno de trabajo. No se referencia desde cuestionario-inabio.md ni se
entrega a INABIO. Sirve para localizar en el historial del proyecto (Planner,
commits, esta conversación) una pregunta citada con su código antiguo.

## Equivalencias

| Código anterior | Código nuevo |
|---|---|
| A3 | A1 |
| A3 bis | A2 |
| B1 | B1 |
| B1 bis | B2 |
| B2 | B3 |
| B3 | B4 |
| B4 | B5 |
| B5 | B6 |
| C1 | C1 |
| C1 bis | C2 |
| C2 | C3 |
| C2 bis | C4 |
| C3 | C5 |
| C5 | C6 |
| C5 bis | C7 |
| C6 | C8 |
| C7 | C9 |
| C8 | C10 |
| C9 | C11 |
| C10 | C12 |
| C11 | C13 |
| C12 | C14 |
| C13 | C15 |
| C14 | C16 |
| C15 | C17 |
| C17 | C18 |
| C18 | C19 |
| C19 | C20 |
| C20 | C21 |
| C21 | C22 |
| C22 | C23 |
| C23 | C24 |
| C24 | C25 |
| C25 | C26 |
| C26 | C27 |
| C27 | C28 |
| C28 | C29 |
| C29 | C30 |
| C30 | C31 |
| C31 | C32 |
| C32 | C33 |
| C33 | C34 |
| C34 | C35 |
| D1 | D1 |
| D2 | D2 |
| D3 | D3 |
| D4 | D4 |
| D5 | D5 |
| D6 | D6 |
| D6 bis | D7 |
| D7 | D8 |
| D8 | D9 |
| D9 | D10 |
| D10 | D11 |
| D11 | D12 |
| D12 | D13 |
| D13 | D14 |
| D14 | D15 |
| D15 | D16 |
| D17 | D17 |
| E1–E5 | sin cambio |
| F1 | F1 |
| F2 | F2 |
| F3 | F3 |
| F5 | F4 |
| F6 | F5 |
| F8 | F6 |
| F9 | F7 |
| F10 | F8 |
| F12 | F9 (contenido corregido, ver nota) |
| F13 | F10 |
| F14 | F11 |
| F15 | F12 |
| F16 | F13 |
| F17 | F14 |
| F18 | F15 |
| F21 | F16 |
| F22 | F17 |
| F23 | F18 |
| G2 | G1 |
| H1 | H1 |
| H2 | H2 |
| I1–I3 | sin cambio |
| J1–J4 | sin cambio |
| K7 | K1 |
| K8 | K2 |

## Preguntas retiradas (no reciben código nuevo)

| Código anterior | Motivo del retiro |
|---|---|
| A3, pregunta 2 | Decisión de modelado del equipo de desarrollo (atributo degenerado vs. relación entre colecciones), no una pregunta que competa al curador |
| C4 | Resuelta con sustento suficiente (dos fuentes independientes). Ver "Cambios ya aplicados" |
| C16 | Normalización de formato sin efecto en ninguna dimensión del modelo |
| F7 | Resuelta con sustento suficiente (tratamiento Darwin Core de cf./gr./complex). Ver "Cambios ya aplicados" |
| F19 | No es pregunta para el curador. Es un hallazgo metodológico: el `taxonID` de origen no es un identificador resoluble ni estable, evidencia de que la dimensión Taxón requiere clave sustituta. Ver docs/criterios-y-hallazgos.md |
| F20 | No es pregunta para el curador. Es un hallazgo documentado sin acción posible: divergencia entre dos puntos de entrada al mismo backbone de GBIF (*Eretmobrycon dahli*). Ver docs/criterios-y-hallazgos.md |
| H3 | Resuelta con sustento suficiente (comparación de verbatim con catálogos vecinos, error de digitación 90→80). Ver "Cambios ya aplicados" |
| K9 | La extensión multimedia no se publica en el Darwin Core Archive ni alimenta el modelo dimensional. La pregunta no desbloquea nada del alcance de la tesis |

Nota sobre F9 (antes F12): se retiró la pregunta original sobre el catálogo 4201,
que ya está en "Cambios ya aplicados", y se sustituyó por una pregunta nueva
sobre las ocho filas restantes de discrepancia de orden dentro de familia, que
en la versión anterior del cuestionario no tenían ninguna pregunta asociada.

## Casos que salieron por completo del cuestionario, hacia otro documento

| Código anterior | Destino |
|---|---|
| Bloque L completo (L1–L16) | docs/criterios-y-hallazgos.md, sección "Criterios metodológicos" |
| Contraste con el validador de GBIF | docs/criterios-y-hallazgos.md, sección "Hallazgos documentados sin pregunta" |
| D9, F6, F17 (antiguas "RESUELTAS") | Reincorporadas al cuestionario en sus bloques originales (ahora D10, F5, F14), porque ninguna tenía respuesta real del curador. Nunca debieron marcarse como resueltas |

## Convención para respuestas futuras

Cuando una pregunta reciba respuesta real de INABIO, se retira por completo de
`cuestionario-inabio.md` (no se marca ni se deja en una sección aparte) y se
traslada íntegra, con pregunta, respuesta, quién respondió y fecha, a un archivo
nuevo `docs/respuestas-inabio.md`, que se creará en ese momento. El cuestionario
contiene en todo momento únicamente preguntas pendientes.