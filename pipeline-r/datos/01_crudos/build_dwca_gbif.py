import pandas as pd
import xml.etree.ElementTree as ET
import zipfile
import os
import re

print("==========================================")
print("1. ACTUALIZANDO META.XML PARA TÉRMINOS NUEVOS")
print("==========================================")
# GBIF exige que cualquier columna que vaya en el CSV esté declarada en meta.xml.
# El script de R ha añadido términos oficiales de DwC (occurrenceStatus, continent, etc).
# Debemos inyectarlos al meta.xml dinámicamente si no están.

# Términos oficiales de Darwin Core que sabemos que el R podría estar creando y queremos enviar.
# (Se descartan los de trazabilidad interna, que el R ya filtra en df_dwca).
POSIBLES_NUEVOS_TERMINOS = [
    'occurrenceStatus', 'continent', 'establishmentMeans', 'dynamicProperties', 
    'waterBody', 'islandGroup', 'island', 'previousIdentifications'
]

import sys

# Archivo a empaquetar. Por defecto usaremos el intermedio que quieres validar ahora, 
# pero puedes pasar cualquier otra ruta ejecutando: python build_dwca_gbif.py "ruta/al/archivo.csv"
input_csv = sys.argv[1] if len(sys.argv) > 1 else r'..\02_intermedios\ocurrences_con_identifications.csv'
print(f"Leyendo archivo core: {input_csv}")

# Leemos el dataset ya limpio (df_dwca)
df = pd.read_csv(input_csv, dtype=str, low_memory=False)
df = df.fillna('')

tree = ET.parse('meta.xml')
root = tree.getroot()
namespaces = {'dwc': 'http://rs.tdwg.org/dwc/text/'}
core = root.find('dwc:core', namespaces)
if core is None: core = root.find('{http://rs.tdwg.org/dwc/text/}core')

# Extraer columnas actuales
expected_columns = {}
existing_terms = []
max_index = -1

# ¡CRÍTICO! El campo <id> no es un <field>, es un tag especial. Si lo omitimos, 
# se pierde la columna 0 y todo se desplaza un índice a la izquierda (off-by-one).
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

# Inyectar columnas faltantes en meta.xml
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

# Remover los nodos de extension ya que solo validaremos el Core
extensions = root.findall('{http://rs.tdwg.org/dwc/text/}extension')
if extensions:
    for ext in extensions:
        root.remove(ext)
    added_any = True
    print("  - Extensiones removidas de meta.xml (solo se empaquetará el Core)")

if added_any:
    tree.write('meta_temp.xml', xml_declaration=True, encoding='utf-8')
    print("meta_temp.xml actualizado con nuevos términos Darwin Core y sin extensiones.")
else:
    print("meta.xml ya contenía todos los términos necesarios y ninguna extensión.")

ordered_columns = [expected_columns[i] for i in sorted(expected_columns.keys())]

print("\n==========================================")
print("2. LIMPIANDO DATOS (OCCURRENCES.CSV)")
print("==========================================")
# Añadir columnas vacías si faltan en el dataset pero las exige el meta.xml
missing_cols = [col for col in ordered_columns if col not in df.columns]
for col in missing_cols:
    df[col] = ''

# Recortar estrictamente a lo definido en meta.xml. 
# Esto elimina cualquier bandera de trazabilidad interna si es que quedó alguna.
df_final = df[ordered_columns]
df_final.to_csv('occurrences_temp.csv', index=False)
print("occurrences_temp.csv limpio y creado.")


print("\n==========================================")
print("3. REPARANDO EML.XML (METADATOS)")
print("==========================================")
# Utilizamos un enfoque más robusto para que soporte múltiples ejecuciones
# y evite romper la estructura del esquema de GBIF.
with open('eml.xml', 'r', encoding='utf-8') as f:
    eml_text = f.read()

# 1. Esquema 1.2
eml_text = eml_text.replace('eml-gbif-profile/1.0.1/eml.xsd', 'eml-gbif-profile/1.2/eml.xsd')
eml_text = eml_text.replace('eml-gbif-profile/1.1/eml.xsd', 'eml-gbif-profile/1.2/eml.xsd')

# 2. Convertir <symbiota> a <gbif>
eml_text = re.sub(r'<symbiota[^>]*>', '<gbif>', eml_text)
eml_text = eml_text.replace('</symbiota>', '</gbif>')

# 3. Limpiar <collection> (Symbiota añade atributos ilegales como identifier o id)
# Usamos \s para no afectar a <collectionName> o <collectionIdentifier>
eml_text = re.sub(r'<collection\s[^>]*>', '<collection>', eml_text)
# Remover alternateIdentifier dentro de collection
collection_match = re.search(r'<collection>(.*?)</collection>', eml_text, flags=re.DOTALL)
if collection_match:
    inner = collection_match.group(1)
    inner = re.sub(r'<alternateIdentifier[^>]*>.*?</alternateIdentifier>', '', inner, flags=re.DOTALL)
    eml_text = eml_text.replace(collection_match.group(1), inner)

# 4. Formato de externallyDefinedFormat
eml_text = eml_text.replace('<externallyDefinedFormat><formatName>Darwin Core Archive</formatName></externallyDefinedFormat>',
                            '<externallyDefinedFormat><formatName>Darwin Core Archive</formatName><formatVersion>1.0</formatVersion></externallyDefinedFormat>')

# 5. additionalInfo necesita <para>
eml_text = re.sub(r'<additionalInfo>(?!<para>)(.*?)</additionalInfo>', r'<additionalInfo><para>\1</para></additionalInfo>', eml_text, flags=re.DOTALL)

# 6. Mover associatedParty ANTES de pubDate
# Extraer todos los associatedParty y ponerlos juntos antes de pubDate
parties = re.findall(r'<associatedParty>.*?</associatedParty>', eml_text, flags=re.DOTALL)
if parties:
    # Quitarlos de su lugar original
    for p in parties:
        eml_text = eml_text.replace(p, '')
    # Insertarlos antes del pubDate
    eml_text = re.sub(r'(<pubDate>)', ''.join(parties) + r'\1', eml_text)

# 7. Licencia (intellectualRights) DEBE ir ANTES de contact
match_rights = re.search(r'<intellectualRights>.*?</intellectualRights>', eml_text, flags=re.DOTALL)
if match_rights:
    rights_block = match_rights.group(0)
    eml_text = eml_text.replace(rights_block, '')
    # Forzar el formato legal
    license_xml = '<intellectualRights><para>This work is licensed under a <ulink url="http://creativecommons.org/licenses/by-nc/4.0/legalcode"><citetitle>Creative Commons Attribution Non Commercial (CC-BY-NC) 4.0 License</citetitle></ulink>.</para></intellectualRights>'
    eml_text = re.sub(r'(<contact>)', license_xml + r'\n\1', eml_text)
else:
    license_xml = '<intellectualRights><para>This work is licensed under a <ulink url="http://creativecommons.org/licenses/by-nc/4.0/legalcode"><citetitle>Creative Commons Attribution Non Commercial (CC-BY-NC) 4.0 License</citetitle></ulink>.</para></intellectualRights>'
    eml_text = re.sub(r'(<contact>)', license_xml + r'\n\1', eml_text)

# 8. Agregar distribution block
distribution_xml = '<distribution><online><url function="download">https://bndb.sisbioecuador.bio/</url></online></distribution>'
if '<distribution>' not in eml_text and '<physical>' in eml_text:
    eml_text = eml_text.replace('</physical>', f'{distribution_xml}</physical>')

# 9. Limpiar <characterEncoding> dentro de <physical> (solo puede ser UTF-8 u otro objeto, pero a veces trae basura)
eml_text = re.sub(r'<characterEncoding>.*?</characterEncoding>', '', eml_text) # Lo eliminamos porque GBIF no lo exige y evita errores

# 10. Arreglar el orden de <givenName> y <surName>
# EML exige que <givenName> vaya ANTES de <surName> dentro de <individualName>.
eml_text = re.sub(r'(<surName>.*?</surName>)\s*(<givenName>.*?</givenName>)', r'\2\1', eml_text)

# 11. Agregar <objectName> a <physical> (obligatorio en schema)
eml_text = re.sub(r'(<physical>)\s*(<dataFormat>)', r'\1<objectName>dataset_dwca.zip</objectName>\2', eml_text)

# 12. Reparar <addr> y ordenar estrictamente los bloques de contactos (ResponsibleParty)
# Symbiota exporta <addr> en lugar de <address>, y desordena las etiquetas (ej. positionName después de email)
eml_text = eml_text.replace('<addr>', '<address>').replace('</addr>', '</address>')

def sort_party_block(match):
    tag = match.group(1)
    inner = match.group(2)
    # Orden estricto exigido por EML 2.1.1
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
            for item in extracted[t]:
                rebuilt += item
        elif t == 'role' and tag == 'associatedParty':
            # GBIF EML requiere que <associatedParty> tenga obligatoriamente un <role>.
            # Si Symbiota exportó un associatedParty sin rol, se lo inyectamos.
            rebuilt += '<role>pointOfContact</role>'
    return f'<{tag}>{rebuilt}</{tag}>'

for party_tag in ['creator', 'metadataProvider', 'contact', 'associatedParty']:
    eml_text = re.sub(f'<({party_tag})>(.*?)</{party_tag}>', sort_party_block, eml_text, flags=re.DOTALL)

# 13. Limpiar el bloque <collection> (schema muy estricto)
# GBIF EML solo permite parentCollectionIdentifier, collectionIdentifier y collectionName dentro de <collection>.
# Symbiota inyecta ahí abstract, additionalInfo, onlineUrl, etc.
def clean_collection(match):
    inner = match.group(1)
    valid_tags = []
    for tag in ['parentCollectionIdentifier', 'collectionIdentifier', 'collectionName']:
        m = re.search('<' + tag + '>.*?</' + tag + '>', inner)
        if m:
            valid_tags.append(m.group(0))
    return '<collection>' + ''.join(valid_tags) + '</collection>'

eml_text = re.sub(r'<collection>(.*?)</collection>', clean_collection, eml_text, flags=re.DOTALL)

# Guardar
with open('eml_temp.xml', 'w', encoding='utf-8') as f:
    f.write(eml_text)
print("eml_temp.xml creado exitosamente con la estructura corregida.")

print("\n==========================================")
print("4. EMPAQUETANDO ARCHIVO ZIP (DwC-A)")
print("==========================================")
zip_filename = 'dataset_dwca.zip'
files_to_zip = {
    'occurrences_temp.csv': 'occurrences.csv',
    'meta_temp.xml': 'meta.xml',
    'eml_temp.xml': 'eml.xml'
}

with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for temp_file, real_file in files_to_zip.items():
        if os.path.exists(temp_file):
            zipf.write(temp_file, arcname=real_file)
        elif os.path.exists(real_file):
            # Si no se modificó (ej. no se generó meta_temp.xml), usar el original
            zipf.write(real_file, arcname=real_file)

# Limpiar archivos temporales después de cerrar el zip
for temp_file in files_to_zip.keys():
    if os.path.exists(temp_file):
        try:
            os.remove(temp_file)
        except Exception as e:
            print(f"Advertencia: No se pudo eliminar el archivo temporal {temp_file}: {e}")

print(f"¡Listo! Archivo {zip_filename} creado exitosamente. Listo para subir al validador de GBIF.")
