"""
Genera las tres tablas CSV planas que el prompt del dashboard de Power BI
requiere como entrada:
  1. gbif_incidencias.csv  — incidencias del validador GBIF, original vs limpio
  2. gbif_completitud.csv  — completitud por término DwC, original vs limpio
  3. preguntas.csv         — preguntas al curador extraídas del cuestionario

Lee: Original.json, Limpio.json, docs/cuestionario-inabio.md
Escribe en: dashboard/
"""
import json, csv, re, os

ROOT = os.path.dirname(os.path.abspath(__file__))
DASH = os.path.join(ROOT, "dashboard")

# ── 1. Cargar JSONs ──────────────────────────────────────────────────────────

with open(os.path.join(ROOT, "gbif-validacion", "gbif_validacion_dataset_original.json"), encoding="utf-8") as f:
    orig = json.load(f)
with open(os.path.join(ROOT, "gbif-validacion", "gbif_validacion_dataset_limpio.json"), encoding="utf-8") as f:
    limpio = json.load(f)


def get_issues(data):
    """Extrae {issue: count} del archivo CORE (occurrences.csv)."""
    issues = {}
    for file_block in data["metrics"]["files"]:
        if file_block.get("fileType") == "CORE":
            for iss in file_block.get("issues", []):
                issues[iss["issue"]] = iss.get("count", 0)
        # También incluir issues de METADATA (eml.xml)
        if file_block.get("fileType") == "METADATA":
            for iss in file_block.get("issues", []):
                # Los de metadata no tienen count, van como 1 cada uno
                key = iss["issue"]
                issues[key] = issues.get(key, 0) + 1
    return issues


def get_completitud(data):
    """Extrae {termino_dwc: rawIndexed} del archivo CORE."""
    comp = {}
    for file_block in data["metrics"]["files"]:
        if file_block.get("fileType") == "CORE":
            total = file_block.get("count", 0)
            for term in file_block.get("terms", []):
                short = term["term"].split("/")[-1]
                comp[short] = term.get("rawIndexed", 0)
            return comp, total
    return comp, 0


# ── 2. gbif_incidencias.csv ──────────────────────────────────────────────────

orig_issues = get_issues(orig)
limp_issues = get_issues(limpio)
all_issues = sorted(set(orig_issues) | set(limp_issues))

# Categorías basadas en el issueCategory del JSON
def get_category(issue_name, data):
    for file_block in data["metrics"]["files"]:
        for iss in file_block.get("issues", []):
            if iss["issue"] == issue_name:
                return iss.get("issueCategory", "UNKNOWN")
    return "UNKNOWN"

rows_inc = []
for iss in all_issues:
    co = orig_issues.get(iss, 0)
    cl = limp_issues.get(iss, 0)
    cat = get_category(iss, orig) or get_category(iss, limpio)
    rows_inc.append({
        "incidencia": iss,
        "categoria": cat,
        "conteo_original": co,
        "conteo_limpio": cl
    })

with open(os.path.join(DASH, "gbif_incidencias.csv"), "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["incidencia", "categoria", "conteo_original", "conteo_limpio"])
    w.writeheader()
    w.writerows(rows_inc)

print(f"gbif_incidencias.csv: {len(rows_inc)} filas")

# ── 3. gbif_completitud.csv ─────────────────────────────────────────────────

orig_comp, orig_total = get_completitud(orig)
limp_comp, limp_total = get_completitud(limpio)
all_terms = sorted(set(orig_comp) | set(limp_comp))

rows_comp = []
for term in all_terms:
    rows_comp.append({
        "termino_dwc": term,
        "poblado_original": orig_comp.get(term, 0),
        "poblado_limpio": limp_comp.get(term, 0)
    })

with open(os.path.join(DASH, "gbif_completitud.csv"), "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["termino_dwc", "poblado_original", "poblado_limpio"])
    w.writeheader()
    w.writerows(rows_comp)

print(f"gbif_completitud.csv: {len(rows_comp)} filas")

# ── 4. preguntas.csv ────────────────────────────────────────────────────────

md_path = os.path.join(ROOT, "docs", "cuestionario-inabio.md")
with open(md_path, encoding="utf-8") as f:
    md = f.read()

# Parsear secciones ### como preguntas
# Formato: ### A3. Título de la pregunta
sections = re.split(r'\n### ', md)
rows_preg = []

# Mapeo manual de id_pregunta → regla_vinculada y columna_bandera
# Basado en el contenido del cuestionario y las flags del pipeline
vinculaciones = {
    "A3":    {"regla": None, "bandera": None},
    "A3bis": {"regla": None, "bandera": None},
    "B1":    {"regla": None, "bandera": None},
    "B1bis": {"regla": None, "bandera": None},
    "B2":    {"regla": None, "bandera": None},
    "B3":    {"regla": None, "bandera": None},
    "B4":    {"regla": None, "bandera": None},
    "B5":    {"regla": None, "bandera": None},
    "C1":    {"regla": "coherencia_provincia", "bandera": "coherencia_provincia"},
    "C1bis": {"regla": None, "bandera": None},
    "C2":    {"regla": None, "bandera": None},
    "C2bis": {"regla": None, "bandera": None},
    "C3":    {"regla": None, "bandera": None},
    "C4":    {"regla": None, "bandera": None},
    "C5":    {"regla": None, "bandera": None},
    "C5bis": {"regla": None, "bandera": None},
    "C6":    {"regla": None, "bandera": None},
    "C7":    {"regla": None, "bandera": None},
    "C8":    {"regla": None, "bandera": None},
    "C9":    {"regla": None, "bandera": None},
    "D1":    {"regla": "signo_invertido", "bandera": "flag_signo_contradice_hermanas"},
    "D2":    {"regla": "coherencia_provincia", "bandera": "coherencia_provincia"},
    "D3":    {"regla": "signo_ambiguo", "bandera": "signo_ambiguo"},
    "D4":    {"regla": "dms_rango_invalido", "bandera": "dms_rango_invalido"},
    "D5":    {"regla": None, "bandera": None},
    "D6":    {"regla": "sin_coordenada", "bandera": None},
    "D6bis": {"regla": "sin_coordenada", "bandera": None},
    "D7":    {"regla": "provincia_minoritaria", "bandera": "provincia_minoritaria"},
    "D8":    {"regla": None, "bandera": None},
    "D9":    {"regla": None, "bandera": None},
    "D10":   {"regla": None, "bandera": None},
    "D11":   {"regla": None, "bandera": None},
    "D12":   {"regla": None, "bandera": None},
    "E1":    {"regla": None, "bandera": None},
    "E2":    {"regla": None, "bandera": None},
    "E3":    {"regla": None, "bandera": None},
    "E4":    {"regla": None, "bandera": None},
    "E5":    {"regla": None, "bandera": None},
    "F1":    {"regla": "familia_orden_discrepante", "bandera": "flag_family_orden_discrepante"},
    "F2":    {"regla": "familia_minoritaria", "bandera": "flag_family_minoritaria"},
    "F3":    {"regla": "genus_no_coincide", "bandera": "flag_genus_no_coincide_con_nombre"},
    "F4":    {"regla": None, "bandera": None},
    "F5":    {"regla": "sin_taxonomia", "bandera": "flag_sin_taxonomia"},
    "F6":    {"regla": "registro_incompleto", "bandera": "registro_incompleto"},
    "F7":    {"regla": None, "bandera": None},
    "F8":    {"regla": "identificado_a_nivel_familia", "bandera": "identificado_a_nivel_familia"},
}

for section in sections[1:]:  # skip content before first ###
    lines = section.strip().split('\n')
    header = lines[0].strip()

    # Extraer id: "A3. Uso del campo..." → "A3"
    # o "A3 bis. Números..." → "A3bis"
    match = re.match(r'^([A-Z]\d+)\s*(bis)?\.?\s+(.*)', header)
    if not match:
        continue

    base_id = match.group(1)
    is_bis = match.group(2)
    titulo = match.group(3).strip()

    id_pregunta = base_id + ("bis" if is_bis else "")

    # Extraer bloque (letra del id)
    bloque_map = {"A": "Identificadores", "B": "Fechas", "C": "Geografía", "D": "Coordenadas", "E": "Personas", "F": "Taxonomía"}
    bloque = bloque_map.get(base_id[0], base_id[0])

    vinc = vinculaciones.get(id_pregunta, {})

    rows_preg.append({
        "id_pregunta": id_pregunta,
        "enunciado": titulo,
        "bloque_duda": bloque,
        "estado": "pendiente",
        "regla_vinculada": vinc.get("regla", ""),
        "columna_bandera": vinc.get("bandera", "")
    })

with open(os.path.join(DASH, "preguntas.csv"), "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["id_pregunta", "enunciado", "bloque_duda", "estado", "regla_vinculada", "columna_bandera"])
    w.writeheader()
    w.writerows(rows_preg)

print(f"preguntas.csv: {len(rows_preg)} filas")
print("\n¡Listo! Archivos generados en dashboard/")
