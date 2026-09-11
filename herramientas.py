# -*- coding: utf-8 -*-
"""
Script unificado de herramientas para la tesis de Ictiología (INABIO).
Contiene utilidades que no son nativas de R o que son más fáciles en Python.

Ejecuta este archivo directamente desde tu IDE para ver el menú interactivo,
o úsalo por línea de comandos:
  python herramientas.py dpa
  python herramientas.py dwca
"""

import sys
import os
import argparse
from pathlib import Path
from urllib.parse import urlparse, parse_qs

# =============================================================================
# FUNCIONALIDAD 1: DESCARGA Y PARSEO DE DPA (INEC)
# =============================================================================
def generar_dpa():
    import pandas as pd
    import requests
    import io
    import re
    import unicodedata
    
    URL_DPA = 'https://aplicaciones2.ecuadorencifras.gob.ec/SIN/descargas/cge2025.xls'
    # Las rutas asumen que el script se ejecuta en la raíz del proyecto
    OUTPUT_DIR = os.path.join('pipeline-r', 'datos', '00_referencia')

    def normalize_text(text):
        if not text: return ''
        text = text.lower()
        text = unicodedata.normalize('NFD', text).encode('ascii', 'ignore').decode('utf-8')
        text = re.sub(r'\s+', ' ', text).strip()
        return text

    print(f'Descargando archivo desde {URL_DPA} ...')
    respuesta = requests.get(URL_DPA)
    respuesta.raise_for_status()
    print('Descarga completada. Leyendo en memoria...')
    
    df = pd.read_excel(io.BytesIO(respuesta.content), sheet_name='DPA 2025')
    
    provincias = {}
    cantones = {}
    parroquias = {}
    
    print('Parseando el archivo...')
    for idx, row in df.iterrows():
        vals = row.tolist()
        
        def clean_str(v):
            if pd.isna(v): return ''
            return str(v).strip().replace('\n', ' ').replace('\r', '')
            
        def process_block(v_prov, v_cant, v_parr, v_name):
            if not v_name or pd.isna(v_name): return
            p = str(v_prov).strip() if pd.notna(v_prov) and str(v_prov).strip() != '' else ''
            c = str(v_cant).strip() if pd.notna(v_cant) and str(v_cant).strip() != '' else ''
            pr = str(v_parr).strip() if pd.notna(v_parr) and str(v_parr).strip() != '' else ''
            name = clean_str(v_name)
            
            if p.endswith('.0'): p = p[:-2]
            if c.endswith('.0'): c = c[:-2]
            if pr.endswith('.0'): pr = pr[:-2]
            
            if p.isdigit(): p = p.zfill(2)
            if c.isdigit(): c = c.zfill(2)
            if pr.isdigit(): pr = pr.zfill(2)
            
            if p.isdigit() and not c.isdigit() and not pr.isdigit():
                if 'PROVINCIA' in name.upper():
                    name = re.sub(r'^PROVINCIA\s+DE(L)?\s+', '', name, flags=re.IGNORECASE)
                    name = normalize_text(name)
                    provincias[p] = name
            elif p.isdigit() and c.isdigit() and not pr.isdigit():
                if 'CANT' in name.upper():
                    name = re.sub(r'^CANT.N\s+', '', name, flags=re.IGNORECASE)
                    name = normalize_text(name)
                    cantones[p + c] = {'provincia_cod': p, 'canton_cod': p + c, 'nombre': name}
            elif p.isdigit() and c.isdigit() and pr.isdigit():
                name = re.sub(r', CABECERA CANTONAL.*', '', name, flags=re.IGNORECASE)
                name = re.sub(r' \(CAB\. EN.*', '', name, flags=re.IGNORECASE)
                name = name.replace('*', '')
                name = normalize_text(name)
                parroquias[p + c + pr] = {'provincia_cod': p, 'canton_cod': p + c, 'parroquia_cod': p + c + pr, 'nombre': name}
                
        if len(vals) >= 5:
            process_block(vals[1], vals[2], vals[3], vals[4])
        if len(vals) >= 9:
            process_block(vals[5], vals[6], vals[7], vals[8])

    df_prov = pd.DataFrame([{'provincia_cod': k, 'nombre': v} for k, v in provincias.items()])
    df_cant = pd.DataFrame(list(cantones.values()))
    df_parr = pd.DataFrame(list(parroquias.values()))
    
    print(f'Extraídas: {len(df_prov)} provincias, {len(df_cant)} cantones, {len(df_parr)} parroquias.')
    
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    df_prov.to_csv(os.path.join(OUTPUT_DIR, 'dpa_provincias.csv'), index=False, encoding='utf-8')
    df_cant.to_csv(os.path.join(OUTPUT_DIR, 'dpa_cantones.csv'), index=False, encoding='utf-8')
    df_parr.to_csv(os.path.join(OUTPUT_DIR, 'dpa_parroquias.csv'), index=False, encoding='utf-8')
    print(f'Archivos CSV de DPA generados con éxito en {OUTPUT_DIR}.')


# =============================================================================
# FUNCIONALIDAD 2: CONSTRUCCIÓN DEL DATASET DARWIN CORE (GBIF)
# =============================================================================
def construir_dwca():
    import pandas as pd
    import xml.etree.ElementTree as ET
    import zipfile
    import re
    import datetime
    
    ROOT_DIR = Path(__file__).resolve().parent
    timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
    zip_basename = f'dataset_dwca_{timestamp}.zip'
    CRUDOS_DIR = ROOT_DIR / 'pipeline-r' / 'datos' / '01_crudos'
    INTERMEDIOS_DIR = ROOT_DIR / 'pipeline-r' / 'datos' / '02_intermedios'

    print("==========================================")
    print("1. ACTUALIZANDO META.XML PARA TÉRMINOS NUEVOS")
    print("==========================================")
    
    POSIBLES_NUEVOS_TERMINOS = [
        'occurrenceStatus', 'continent', 'establishmentMeans', 'dynamicProperties', 
        'waterBody', 'islandGroup', 'island', 'previousIdentifications', 'countryCode'
    ]

    input_csv = INTERMEDIOS_DIR / 'ocurrences_con_identifications.csv'
    if not input_csv.exists():
        print(f"Error: No se encontró el dataset limpio en {input_csv}")
        print("Ejecuta todo el pipeline de R primero.")
        return

    print(f"Leyendo archivo core: {input_csv}")
    df = pd.read_csv(input_csv, dtype=str, low_memory=False).fillna('')
    
    # Resolver countryCode a partir de country para evitar advertencias de GBIF
    if 'countryCode' not in df.columns and 'country' in df.columns:
        mapping = {'Ecuador': 'EC', 'Perú': 'PE', 'Venezuela': 'VE'}
        df['countryCode'] = df['country'].map(mapping).fillna('')

    tree = ET.parse(CRUDOS_DIR / 'meta.xml')
    root = tree.getroot()
    namespaces = {'dwc': 'http://rs.tdwg.org/dwc/text/'}
    core = root.find('dwc:core', namespaces)
    if core is None: core = root.find('{http://rs.tdwg.org/dwc/text/}core')

    expected_columns = {}
    existing_terms = []
    max_index = -1

    id_field = core.find('{http://rs.tdwg.org/dwc/text/}id')
    if id_field is not None and 'index' in id_field.attrib:
        idx = int(id_field.attrib['index'])
        expected_columns[idx] = 'id'
        if idx > max_index: max_index = idx

    for field in core.findall('{http://rs.tdwg.org/dwc/text/}field'):
        idx = int(field.attrib['index'])
        if idx > max_index: max_index = idx
        col_name = field.attrib['term'].split('/')[-1]
        
        # ELIMINAR taxonID para no disparar TAXON_ID_NOT_FOUND en el validador GBIF
        if col_name == 'taxonID':
            core.remove(field)
            added_any = True
            print("  - Removido taxonID de meta.xml (para evitar TAXON_ID_NOT_FOUND en GBIF)")
            continue
            
        expected_columns[idx] = col_name
        existing_terms.append(col_name)

    added_any = False
    for term in POSIBLES_NUEVOS_TERMINOS:
        if term in df.columns and term not in existing_terms:
            max_index += 1
            new_field = ET.SubElement(core, '{http://rs.tdwg.org/dwc/text/}field')
            new_field.set('index', str(max_index))
            new_field.set('term', f'http://rs.tdwg.org/dwc/terms/{term}')
            expected_columns[max_index] = term
            print(f"  + Añadido {term} al meta.xml en el índice {max_index}")
            added_any = True

    extensions = root.findall('{http://rs.tdwg.org/dwc/text/}extension')
    if extensions:
        for ext in extensions: root.remove(ext)
        added_any = True
        print("  - Extensiones removidas de meta.xml (solo se empaquetará el Core)")

    ordered_columns = [expected_columns[i] for i in sorted(expected_columns.keys())]

    # Reindexar ANTES de escribir. Al quitar taxonID queda un hueco en los indices
    # del meta.xml, pero el CSV se escribe con las columnas ya compactadas: si el
    # XML se guarda antes del reindexado, cada termino posterior al hueco lee la
    # columna siguiente y el archivo entero sale desalineado. El validador NO lo
    # denuncia (el archivo es formalmente valido e indexa las 6.427 filas): solo
    # se nota mirando los valores, y para entonces el informe ya es basura.
    if id_field is not None and 'id' in ordered_columns:
        id_field.set('index', str(ordered_columns.index('id')))
    for field in core.findall('{http://rs.tdwg.org/dwc/text/}field'):
        col_name = field.attrib['term'].split('/')[-1]
        if col_name in ordered_columns:
            field.set('index', str(ordered_columns.index(col_name)))

    meta_out = ROOT_DIR / 'meta_temp.xml'
    tree.write(meta_out, xml_declaration=True, encoding='utf-8')

    idxs = [int(f.attrib['index']) for f in core.findall('{http://rs.tdwg.org/dwc/text/}field')]
    if id_field is not None and 'index' in id_field.attrib:
        idxs.append(int(id_field.attrib['index']))
    assert max(idxs) == len(ordered_columns) - 1, \
        f"meta.xml llega al indice {max(idxs)} y el CSV tiene {len(ordered_columns)} columnas"
    print(f"meta_temp.xml escrito y reindexado: {len(ordered_columns)} columnas.")

    print("\n==========================================")
    print("2. LIMPIANDO DATOS (OCCURRENCES.CSV)")
    print("==========================================")
    for col in [c for c in ordered_columns if c not in df.columns]: df[col] = ''
    df_final = df[ordered_columns]
    
    occ_out = ROOT_DIR / 'occurrences_temp.csv'
    df_final.to_csv(occ_out, index=False)
    print("occurrences_temp.csv limpio y creado.")

    print("  Comprobacion de alineacion (termino <- primer valor real):")
    for t in ['modified', 'country', 'individualCount', 'typeStatus', 'georeferencedBy']:
        if t in df_final.columns:
            print(f"    {t:20s} <- {str(df_final[t].iloc[0])[:45]!r}")

    print("\n==========================================")
    print("3. REPARANDO EML.XML (METADATOS)")
    print("==========================================")
    with open(CRUDOS_DIR / 'eml.xml', 'r', encoding='utf-8') as f:
        eml_text = f.read()

    eml_text = eml_text.replace('eml-gbif-profile/1.0.1/eml.xsd', 'eml-gbif-profile/1.2/eml.xsd')
    eml_text = eml_text.replace('eml-gbif-profile/1.1/eml.xsd', 'eml-gbif-profile/1.2/eml.xsd')
    eml_text = re.sub(r'<symbiota[^>]*>', '<gbif>', eml_text).replace('</symbiota>', '</gbif>')
    
    eml_text = re.sub(r'<collection\s[^>]*>', '<collection>', eml_text)
    collection_match = re.search(r'<collection>(.*?)</collection>', eml_text, flags=re.DOTALL)
    if collection_match:
        inner = re.sub(r'<alternateIdentifier[^>]*>.*?</alternateIdentifier>', '', collection_match.group(1), flags=re.DOTALL)
        eml_text = eml_text.replace(collection_match.group(1), inner)

    eml_text = eml_text.replace('<externallyDefinedFormat><formatName>Darwin Core Archive</formatName></externallyDefinedFormat>',
                                '<externallyDefinedFormat><formatName>Darwin Core Archive</formatName><formatVersion>1.0</formatVersion></externallyDefinedFormat>')
    
    eml_text = re.sub(r'<additionalInfo>(?!<para>)(.*?)</additionalInfo>', r'<additionalInfo><para>\1</para></additionalInfo>', eml_text, flags=re.DOTALL)
    
    parties = re.findall(r'<associatedParty>.*?</associatedParty>', eml_text, flags=re.DOTALL)
    if parties:
        for p in parties: eml_text = eml_text.replace(p, '')
        eml_text = re.sub(r'(<pubDate>)', ''.join(parties) + r'\1', eml_text)

    license_xml = '<intellectualRights><para>This work is licensed under a <ulink url="http://creativecommons.org/licenses/by-nc/4.0/legalcode"><citetitle>Creative Commons Attribution Non Commercial (CC-BY-NC) 4.0 License</citetitle></ulink>.</para></intellectualRights>'
    match_rights = re.search(r'<intellectualRights>.*?</intellectualRights>', eml_text, flags=re.DOTALL)
    if match_rights:
        eml_text = eml_text.replace(match_rights.group(0), '')
    eml_text = re.sub(r'(<contact>)', license_xml + r'\n\1', eml_text)

    if '<contact>' not in eml_text:
        contacto = ('<contact><individualName><givenName>Said</givenName>'
                    '<surName>Cotacachi</surName></individualName>'
                    '<organizationName>INABIO</organizationName>'
                    '<electronicMailAddress>TU_CORREO</electronicMailAddress>'
                    '<role>pointOfContact</role></contact>')
        eml_text = re.sub(r'(</dataset>)', contacto + r'\1', eml_text)

    distribution_xml = '<distribution><online><url function="download">https://bndb.sisbioecuador.bio/</url></online></distribution>'
    if '<distribution>' not in eml_text and '<physical>' in eml_text:
        eml_text = eml_text.replace('</physical>', f'{distribution_xml}</physical>')

    eml_text = re.sub(r'<characterEncoding>.*?</characterEncoding>', '', eml_text)
    eml_text = re.sub(r'(<surName>.*?</surName>)\s*(<givenName>.*?</givenName>)', r'\2\1', eml_text)
    eml_text = re.sub(r'(<physical>)\s*(<dataFormat>)', r'\1<objectName>' + zip_basename + r'</objectName>\2', eml_text)
    eml_text = eml_text.replace('<addr>', '<address>').replace('</addr>', '</address>')

    def sort_party_block(match):
        tag, inner = match.group(1), match.group(2)
        order = ['individualName', 'organizationName', 'positionName', 'address', 
                 'phone', 'electronicMailAddress', 'onlineUrl', 'userId', 'role']
        extracted = {}
        for t in order:
            pattern = f'<{t}(?: [^>]*)?>.*?</{t}>'
            matches = re.findall(pattern, inner, flags=re.DOTALL)
            if matches:
                extracted[t] = matches
                inner = re.sub(pattern, '', inner, flags=re.DOTALL)
        rebuilt = ''
        for t in order:
            if t in extracted:
                for item in extracted[t]: rebuilt += item
            elif t == 'role' and tag == 'associatedParty':
                rebuilt += '<role>pointOfContact</role>'
        return f'<{tag}>{rebuilt}</{tag}>'

    for party_tag in ['creator', 'metadataProvider', 'contact', 'associatedParty']:
        eml_text = re.sub(f'<({party_tag})>(.*?)</{party_tag}>', sort_party_block, eml_text, flags=re.DOTALL)

    def clean_collection(match):
        inner = match.group(1)
        valid_tags = []
        for tag in ['parentCollectionIdentifier', 'collectionIdentifier', 'collectionName']:
            m = re.search('<' + tag + '>.*?</' + tag + '>', inner)
            if m: valid_tags.append(m.group(0))
        return '<collection>' + ''.join(valid_tags) + '</collection>'

    eml_text = re.sub(r'<collection>(.*?)</collection>', clean_collection, eml_text, flags=re.DOTALL)

    eml_out = ROOT_DIR / 'eml_temp.xml'
    with open(eml_out, 'w', encoding='utf-8') as f:
        f.write(eml_text)
    print("eml_temp.xml creado exitosamente con la estructura corregida.")

    print("\n==========================================")
    print("4. EMPAQUETANDO ARCHIVO ZIP (DwC-A)")
    print("==========================================")
    
    # Eliminar archivos .zip anteriores que empiecen con dataset_dwca
    for old_zip in ROOT_DIR.glob('dataset_dwca*.zip'):
        try:
            old_zip.unlink()
            print(f"Eliminado zip anterior: {old_zip.name}")
        except Exception as e:
            print(f"Advertencia: No se pudo eliminar {old_zip.name}: {e}")
            
    zip_filename = ROOT_DIR / zip_basename
    files_to_zip = {
        occ_out: 'occurrences.csv',
        meta_out: 'meta.xml',
        eml_out: 'eml.xml'
    }

    with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for temp_file, zip_arcname in files_to_zip.items():
            original_file = CRUDOS_DIR / zip_arcname
            # Sin respaldo al archivo crudo: si el temporal no existe, el ZIP
            # llevaria el meta.xml original de Symbiota (con taxonID, con las
            # extensiones y con los indices viejos) contra un CSV reordenado.
            if not temp_file.exists():
                raise FileNotFoundError(f"No se genero {temp_file.name}; se aborta el empaquetado.")
            zipf.write(temp_file, arcname=zip_arcname)

    for temp_file in files_to_zip.keys():
        if temp_file.exists():
            try: os.remove(temp_file)
            except Exception as e: print(f"Advertencia: No se pudo eliminar temporal {temp_file}: {e}")

    print(f"¡Listo! Archivo {zip_filename} creado exitosamente en la raíz. Listo para el validador.")


# =============================================================================
# FUNCIONALIDAD 3: AUTOMATIZACIÓN DE OPENREFINE
# =============================================================================
def ejecutar_openrefine():
    import requests
    import json
    
    URL = "http://localhost:3333"
    ROOT_DIR = Path(__file__).resolve().parent
    INPUT_CSV = ROOT_DIR / 'pipeline-r' / 'datos' / '01_crudos' / 'occurrences.csv'
    REGLAS_JSON = ROOT_DIR / 'openrefine' / 'Reglas.json'
    OUTPUT_CSV = ROOT_DIR / 'pipeline-r' / 'datos' / '02_intermedios' / 'ocurrences_openrefine.csv'
    
    if not INPUT_CSV.exists():
        print(f"Error: No se encontró el archivo de entrada en {INPUT_CSV}")
        return
    if not REGLAS_JSON.exists():
        print(f"Error: No se encontró el archivo de reglas en {REGLAS_JSON}")
        return
        
    print(f"Conectando con OpenRefine en {URL}...")
    try:
        session = requests.Session()
        resp = session.get(f"{URL}/command/core/get-csrf-token", timeout=5)
        resp.raise_for_status()
        csrf = resp.json()["token"]
    except requests.exceptions.RequestException as e:
        print(f"Error: No se pudo conectar a OpenRefine. Asegúrate de que esté abierto (puerto 3333).\nDetalles: {e}")
        return

    print("Subiendo occurrences.csv y creando el proyecto...")
    files = {
        'project-file': ('occurrences.csv', open(INPUT_CSV, 'rb'), 'text/csv')
    }
    data = {
        'project-name': 'tesis_ictio_temp',
        'format': 'text/line-based/*sv',
        'options': json.dumps({'separator': ',', 'headerLines': 1})
    }
    res_create = session.post(f"{URL}/command/core/create-project-from-upload?csrf_token={csrf}", data=data, files=files)
    
    parsed = urlparse(res_create.url)
    qs = parse_qs(parsed.query)
    if 'project' not in qs:
        print(f"Error al crear el proyecto. Respuesta: {res_create.text}")
        return
    pid = qs['project'][0]
    
    print("Aplicando reglas desde Reglas.json (esto puede tardar unos segundos)...")
    with open(REGLAS_JSON, "r", encoding="utf-8") as f:
        operations = f.read()

    res_apply = session.post(
        f"{URL}/command/core/apply-operations?project={pid}&csrf_token={csrf}",
        data={'operations': operations}
    )
    
    if res_apply.json().get("code") != "ok":
        print(f"Error al aplicar las reglas: {res_apply.text}")
    
    print("Exportando el resultado...")
    OUTPUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    res_export = session.post(f"{URL}/command/core/export-rows/tesis_ictio.csv?project={pid}&format=csv&csrf_token={csrf}")
    with open(OUTPUT_CSV, "wb") as f:
        f.write(res_export.content)
        
    print("Limpiando (borrando el proyecto temporal)...")
    session.post(f"{URL}/command/core/delete-project?project={pid}&csrf_token={csrf}")
    
    print(f"¡Listo! Archivo generado exitosamente en {OUTPUT_CSV}")


# =============================================================================
# FUNCIONALIDAD 4: DESCARGA AUTOMÁTICA DESDE SYMBIOTA (BNDB)
# =============================================================================
def descargar_simbiota():
    import requests
    import zipfile
    import io
    
    URL = "https://bndb.sisbioecuador.bio/bndb/collections/download/downloadhandler.php"
    ROOT_DIR = Path(__file__).resolve().parent
    OUTPUT_DIR = ROOT_DIR / 'pipeline-r' / 'datos' / '01_crudos'
    
    data = {
        "schema": "dwc",
        "identifications": "1",
        "images": "1",
        "materialsample": "1",
        "format": "csv",
        "cset": "utf-8",
        "zip": "1",
        "publicsearch": "1",
        "taxonFilterCode": "0",
        "sourcepage": "specimen",
        "searchvar": "db=6",
        "submitaction": ""
    }

    print("Iniciando descarga desde Symbiota (BNDB)...")
    try:
        session = requests.Session()
        # Obtener cookies iniciales por si acaso
        session.get("https://bndb.sisbioecuador.bio/bndb/collections/download/index.php", timeout=10)
        
        response = session.post(URL, data=data, timeout=30)
        response.raise_for_status()
        
        if response.content.startswith(b'PK'):
            print(f"ZIP descargado correctamente ({len(response.content) // 1024} KB).")
            print(f"Descomprimiendo en {OUTPUT_DIR}...")
            
            OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
            
            with zipfile.ZipFile(io.BytesIO(response.content)) as z:
                z.extractall(OUTPUT_DIR)
                
            print("¡Archivos extraídos exitosamente!")
        else:
            print("Error: El servidor no devolvió un archivo ZIP válido.")
            print(f"Respuesta del servidor (primeros 200 caracteres): {response.text[:200]}")
            
    except requests.exceptions.RequestException as e:
        print(f"Error de conexión al intentar descargar: {e}")
    except zipfile.BadZipFile:
        print("Error: El archivo descargado está corrupto y no es un ZIP válido.")


# =============================================================================
# FUNCIONALIDAD 0: PREPARAR ENTORNO (INSTALAR DEPENDENCIAS)
# =============================================================================
def preparar_entorno():
    import subprocess
    import sys
    import venv
    
    ROOT_DIR = Path(__file__).resolve().parent
    req_file = ROOT_DIR / 'requirements.txt'
    venv_dir = ROOT_DIR / 'venv'
    
    print("\n" + "="*60)
    print(" PREPARANDO ENTORNO DE PYTHON")
    print("="*60 + "\n")
    
    # 1. Crear entorno virtual si no existe
    if not venv_dir.exists():
        print("Creando entorno virtual (venv)...")
        venv.create(venv_dir, with_pip=True)
        print("¡Entorno virtual creado exitosamente!")
    else:
        print("El entorno virtual ya existe. Omitiendo creación.")
        
    # Identificar el ejecutable de python dentro del venv recién creado
    if os.name == 'nt':
        venv_python = venv_dir / 'Scripts' / 'python.exe'
    else:
        venv_python = venv_dir / 'bin' / 'python'

    # 2. Instalar requerimientos usando el python del venv
    if req_file.exists():
        print(f"\nInstalando paquetes desde {req_file.name} dentro del venv...")
        try:
            subprocess.run([str(venv_python), "-m", "pip", "install", "-r", str(req_file)], check=True)
            print("\n¡Dependencias de Python instaladas correctamente en el venv!")
            
            print(f"\nIMPORTANTE: Recuerda activar el entorno virtual antes de correr el script:")
            if os.name == 'nt':
                print("  .\\venv\\Scripts\\activate")
            else:
                print("  source venv/bin/activate")
                
        except subprocess.CalledProcessError:
            print("\nError al instalar las dependencias de Python.")
    else:
        print("No se encontró el archivo requirements.txt para Python.")
        
    print("\nNota para R: Para instalar las dependencias de R, abre RStudio,")
    print("selecciona el proyecto y ejecuta el comando: renv::restore()")
    print("\n" + "="*60 + "\n")


# =============================================================================
# FUNCIONALIDAD 5: PIPELINE COMPLETO END-TO-END
# =============================================================================
def ejecutar_pipeline_completo():
    import subprocess
    import time
    
    ROOT_DIR = Path(__file__).resolve().parent
    scripts_r = [
        "Coordenadas.R",
        "Fishbase.R",
        "UnirIdentificationsOcurrences.R",
        "ValidacionPlausibilidad.R"
    ]
    
    print("\n" + "="*60)
    print(" INICIANDO PIPELINE COMPLETO DE TESIS ICTIOLOGÍA (END-TO-END)")
    print("="*60 + "\n")
    
    # 1. Simbiota
    print(">>> PASO 1: Descarga de datos crudos (Symbiota)...")
    descargar_simbiota()
    
    # 2. DPA
    print("\n>>> PASO 2: Descarga de datos espaciales (DPA INEC)...")
    generar_dpa()
    
    # 3. OpenRefine
    print("\n>>> PASO 3: Limpieza automatizada (OpenRefine)...")
    ejecutar_openrefine()
    
    # 4. R Scripts
    print("\n>>> PASO 4: Ejecución de scripts en R (Taxonomía, Coordenadas, Validación)...")
    for script in scripts_r:
        script_path = ROOT_DIR / "pipeline-r" / "scripts" / script
        print(f"\n--- Ejecutando {script} ---")
        try:
            # Ejecuta Rscript y redirige la salida en tiempo real
            subprocess.run(["Rscript", str(script_path)], cwd=str(ROOT_DIR / "pipeline-r"), check=True)
        except subprocess.CalledProcessError as e:
            print(f"\n[ERROR] El script {script} falló. Abortando pipeline completo.")
            return
        except FileNotFoundError:
            print("\n[ERROR] No se encontró 'Rscript' en el sistema. Asegúrate de tener R instalado y en el PATH.")
            return
            
    # 5. DWCA
    print("\n>>> PASO 5: Empaquetado final (Darwin Core Archive)...")
    construir_dwca()
    
    print("\n" + "="*60)
    print(" PIPELINE COMPLETO EJECUTADO CON ÉXITO")
    print("="*60 + "\n")


# =============================================================================
# MENÚ INTERACTIVO Y CLI
# =============================================================================
def main():
    parser = argparse.ArgumentParser(description="Herramientas para el pipeline de Ictiología (INABIO)")
    parser.add_argument("comando", nargs="?", choices=["setup", "simbiota", "dpa", "refine", "dwca", "all"], 
                        help="Comando a ejecutar: setup, simbiota, dpa, refine, dwca o all (pipeline completo)")
    
    args = parser.parse_args()

    if args.comando == "setup":
        preparar_entorno()
    elif args.comando == "simbiota":
        descargar_simbiota()
    elif args.comando == "dpa":
        generar_dpa()
    elif args.comando == "refine":
        ejecutar_openrefine()
    elif args.comando == "dwca":
        construir_dwca()
    elif args.comando == "all":
        ejecutar_pipeline_completo()
    else:
        # Menú interactivo (cuando se ejecuta con el botón "Run" del IDE sin argumentos)
        print("\n" + "="*50)
        print("  HERRAMIENTAS PYTHON - TESIS ICTIOLOGÍA INABIO")
        print("="*50)
        print("-1. Preparar entorno (Instalar dependencias de Python)")
        print("0. Ejecutar pipeline completo (End-to-End)")
        print("1. Descargar dataset crudo desde Symbiota (BNDB)")
        print("2. Descargar y parsear división política (DPA INEC)")
        print("3. Ejecutar reglas de OpenRefine automáticamente")
        print("4. Construir Darwin Core Archive (dataset_dwca.zip)")
        print("5. Salir")
        print("="*50)
        
        while True:
            opcion = input("\nElige una opción (-1, 0, 1, 2, 3, 4 o 5): ").strip()
            if opcion == '-1':
                preparar_entorno()
                break
            elif opcion == '0':
                ejecutar_pipeline_completo()
                break
            elif opcion == '1':
                descargar_simbiota()
                break
            elif opcion == '2':
                generar_dpa()
                break
            elif opcion == '3':
                ejecutar_openrefine()
                break
            elif opcion == '4':
                construir_dwca()
                break
            elif opcion == '5':
                print("Saliendo...")
                break
            else:
                print("Opción no válida. Intenta de nuevo.")

if __name__ == '__main__':
    main()
