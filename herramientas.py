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
    
    ROOT_DIR = Path(__file__).resolve().parent
    CRUDOS_DIR = ROOT_DIR / 'pipeline-r' / 'datos' / '01_crudos'
    INTERMEDIOS_DIR = ROOT_DIR / 'pipeline-r' / 'datos' / '02_intermedios'

    print("==========================================")
    print("1. ACTUALIZANDO META.XML PARA TÉRMINOS NUEVOS")
    print("==========================================")
    
    POSIBLES_NUEVOS_TERMINOS = [
        'occurrenceStatus', 'continent', 'establishmentMeans', 'dynamicProperties', 
        'waterBody', 'islandGroup', 'island', 'previousIdentifications'
    ]

    input_csv = INTERMEDIOS_DIR / 'ocurrences_con_identifications.csv'
    if not input_csv.exists():
        print(f"Error: No se encontró el dataset limpio en {input_csv}")
        print("Ejecuta todo el pipeline de R primero.")
        return

    print(f"Leyendo archivo core: {input_csv}")
    df = pd.read_csv(input_csv, dtype=str, low_memory=False).fillna('')

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

    meta_out = ROOT_DIR / 'meta_temp.xml'
    if added_any:
        tree.write(meta_out, xml_declaration=True, encoding='utf-8')
        print("meta_temp.xml actualizado con nuevos términos y sin extensiones.")
    else:
        print("meta.xml ya contenía todos los términos y ninguna extensión.")

    ordered_columns = [expected_columns[i] for i in sorted(expected_columns.keys())]

    print("\n==========================================")
    print("2. LIMPIANDO DATOS (OCCURRENCES.CSV)")
    print("==========================================")
    for col in [c for c in ordered_columns if c not in df.columns]: df[col] = ''
    df_final = df[ordered_columns]
    
    occ_out = ROOT_DIR / 'occurrences_temp.csv'
    df_final.to_csv(occ_out, index=False)
    print("occurrences_temp.csv limpio y creado.")

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

    distribution_xml = '<distribution><online><url function="download">https://bndb.sisbioecuador.bio/</url></online></distribution>'
    if '<distribution>' not in eml_text and '<physical>' in eml_text:
        eml_text = eml_text.replace('</physical>', f'{distribution_xml}</physical>')

    eml_text = re.sub(r'<characterEncoding>.*?</characterEncoding>', '', eml_text)
    eml_text = re.sub(r'(<surName>.*?</surName>)\s*(<givenName>.*?</givenName>)', r'\2\1', eml_text)
    eml_text = re.sub(r'(<physical>)\s*(<dataFormat>)', r'\1<objectName>dataset_dwca.zip</objectName>\2', eml_text)
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
    zip_filename = ROOT_DIR / 'dataset_dwca.zip'
    files_to_zip = {
        occ_out: 'occurrences.csv',
        meta_out: 'meta.xml',
        eml_out: 'eml.xml'
    }

    with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for temp_file, zip_arcname in files_to_zip.items():
            original_file = CRUDOS_DIR / zip_arcname
            if temp_file.exists():
                zipf.write(temp_file, arcname=zip_arcname)
            elif original_file.exists():
                zipf.write(original_file, arcname=zip_arcname)

    for temp_file in files_to_zip.keys():
        if temp_file.exists():
            try: os.remove(temp_file)
            except Exception as e: print(f"Advertencia: No se pudo eliminar temporal {temp_file}: {e}")

    print(f"¡Listo! Archivo {zip_filename} creado exitosamente en la raíz. Listo para el validador.")


# =============================================================================
# MENÚ INTERACTIVO Y CLI
# =============================================================================
def main():
    parser = argparse.ArgumentParser(description="Herramientas para el pipeline de Ictiología (INABIO)")
    parser.add_argument("comando", nargs="?", choices=["dpa", "dwca"], 
                        help="Comando a ejecutar: dpa (descargar DPA) o dwca (empaquetar dataset)")
    
    args = parser.parse_args()

    if args.comando == "dpa":
        generar_dpa()
    elif args.comando == "dwca":
        construir_dwca()
    else:
        # Menú interactivo (cuando se ejecuta con el botón "Run" del IDE sin argumentos)
        print("\n" + "="*50)
        print("  HERRAMIENTAS PYTHON - TESIS ICTIOLOGÍA INABIO")
        print("="*50)
        print("1. Descargar y parsear división política (DPA INEC)")
        print("2. Construir Darwin Core Archive (dataset_dwca.zip)")
        print("3. Salir")
        print("="*50)
        
        while True:
            opcion = input("\nElige una opción (1, 2 o 3): ").strip()
            if opcion == '1':
                generar_dpa()
                break
            elif opcion == '2':
                construir_dwca()
                break
            elif opcion == '3':
                print("Saliendo...")
                break
            else:
                print("Opción no válida. Intenta de nuevo.")

if __name__ == '__main__':
    main()
