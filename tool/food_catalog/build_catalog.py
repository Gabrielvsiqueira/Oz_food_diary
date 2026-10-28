"""Gera assets/data/foods.json a partir da TACO 4ª edição e das medidas
caseiras do IBGE (POF 2008-2009).

Uso, na raiz do projeto:  python3 tool/food_catalog/build_catalog.py

Fontes (reprodução permitida citando a fonte):
- NEPA/UNICAMP. Tabela Brasileira de Composição de Alimentos (TACO).
  4. ed. rev. e ampl. Campinas, 2011.
- IBGE. POF 2008-2009: Tabela de Medidas Referidas para os Alimentos
  Consumidos no Brasil. Rio de Janeiro, 2011.

Só usa a biblioteca padrão do Python.
"""

import json
import re
import unicodedata
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
TACO = HERE / 'taco_4ed_2011.xlsx'
PORTIONS = HERE / 'household_portions.json'
OUTPUT = ROOT / 'assets' / 'data' / 'foods.json'

SHEET = 'CMVCol taco3'
NS = {'m': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}

# Colunas da planilha de composição centesimal.
COL_NUMBER, COL_NAME, COL_KCAL, COL_PROTEIN, COL_FAT, COL_CARBS = 0, 1, 3, 5, 6, 8

# '*' = análise em reavaliação pela TACO: o alimento fica de fora.
# Nome truncado na planilha oficial: fica de fora até ser conferido.
EXCLUDED_NUMBERS = {540}

# Notas de rodapé da planilha grudadas no nome (teor alcoólico).
NAME_FIXES = {472: 'Cana, aguardente', 474: 'Cerveja, pilsen'}

# 'Tr' (traço), 'NA' (não se aplica) e células vazias valem zero.
ZERO_MARKERS = {'Tr', 'NA', None, ''}

CATEGORY_EMOJI = {
    'Cereais e derivados': '🌾',
    'Verduras, hortaliças e derivados': '🥬',
    'Frutas e derivados': '🍎',
    'Gorduras e óleos': '🫒',
    'Pescados e frutos do mar': '🐟',
    'Carnes e derivados': '🥩',
    'Leite e derivados': '🥛',
    'Bebidas (alcoólicas e não alcoólicas)': '🥤',
    'Ovos e derivados': '🥚',
    'Produtos açucarados': '🍬',
    'Miscelâneas': '🧂',
    'Outros alimentos industrializados': '🥫',
    'Alimentos preparados': '🍲',
    'Leguminosas e derivados': '🫘',
    'Nozes e sementes': '🥜',
}

# Emoji pelo começo do nome (sem acentos), antes do emoji da categoria.
NAME_EMOJI = [
    ('arroz', '🍚'), ('aveia', '🌾'), ('biscoito', '🍪'), ('bolo', '🍰'),
    ('macarrao', '🍝'), ('lasanha', '🍝'), ('milho', '🌽'), ('pipoca', '🍿'),
    ('pao, de queijo', '🧀'), ('pao', '🍞'), ('torrada', '🍞'), ('pastel', '🥟'),
    ('abacate', '🥑'), ('abacaxi', '🍍'), ('banana', '🍌'), ('cereja', '🍒'),
    ('coco', '🥥'), ('kiwi', '🥝'), ('laranja', '🍊'), ('limao', '🍋'),
    ('maca', '🍎'), ('manga', '🥭'), ('melancia', '🍉'), ('melao', '🍈'),
    ('morango', '🍓'), ('pera', '🍐'), ('pessego', '🍑'), ('tangerina', '🍊'),
    ('mexerica', '🍊'), ('uva', '🍇'), ('batata, doce', '🍠'), ('batata', '🥔'),
    ('berinjela', '🍆'), ('brocolis', '🥦'), ('cebola', '🧅'), ('alho', '🧄'),
    ('cenoura', '🥕'), ('pepino', '🥒'), ('pimentao', '🫑'), ('tomate', '🍅'),
    ('alface', '🥬'), ('mandioca', '🍠'), ('azeite', '🫒'), ('oleo', '🫗'),
    ('manteiga', '🧈'), ('margarina', '🧈'), ('camarao', '🦐'),
    ('caranguejo', '🦀'), ('frango', '🍗'), ('coxinha', '🍗'), ('peru', '🍗'),
    ('hamburguer', '🍔'), ('linguica', '🌭'), ('porco', '🥓'),
    ('toucinho', '🥓'), ('presunto', '🥓'), ('queijo', '🧀'),
    ('iogurte', '🥣'), ('cafe', '☕'), ('cha', '🍵'), ('cerveja', '🍺'),
    ('refrigerante', '🥤'), ('ovo', '🥚'), ('omelete', '🍳'),
    ('chocolate', '🍫'), ('achocolatado', '🍫'), ('acucar', '🍬'),
    ('mel', '🍯'), ('amendoim', '🥜'), ('castanha', '🌰'), ('noz', '🌰'),
    ('feijao', '🫘'), ('sal', '🧂'),
]


def normalize(text):
    text = unicodedata.normalize('NFKD', text.lower())
    return ''.join(c for c in text if not unicodedata.combining(c))


def read_sheet(path, sheet_name):
    with zipfile.ZipFile(path) as z:
        shared = []
        if 'xl/sharedStrings.xml' in z.namelist():
            root = ET.fromstring(z.read('xl/sharedStrings.xml'))
            for si in root.findall('m:si', NS):
                shared.append(''.join(t.text or '' for t in si.iter(f'{{{NS["m"]}}}t')))
        workbook = ET.fromstring(z.read('xl/workbook.xml'))
        names = [s.get('name') for s in workbook.find('m:sheets', NS)]
        sheet = ET.fromstring(z.read(f'xl/worksheets/sheet{names.index(sheet_name) + 1}.xml'))

    def column(ref):
        index = 0
        for char in re.match(r'[A-Z]+', ref).group():
            index = index * 26 + ord(char) - 64
        return index - 1

    rows = []
    for row in sheet.iter(f'{{{NS["m"]}}}row'):
        cells = {}
        for cell in row.findall('m:c', NS):
            value = cell.find('m:v', NS)
            if value is None:
                continue
            text = shared[int(value.text)] if cell.get('t') == 's' else value.text
            cells[column(cell.get('r'))] = text
        if cells:
            rows.append([cells.get(i) for i in range(max(cells) + 1)])
    return rows


def number(value):
    if value in ZERO_MARKERS:
        return 0.0
    return round(float(value), 1)


def emoji_for(name, category):
    normalized = normalize(name)
    for prefix, emoji in NAME_EMOJI:
        if normalized.startswith(prefix):
            return emoji
    return CATEGORY_EMOJI[category]


def main():
    portions = json.loads(PORTIONS.read_text(encoding='utf-8'))
    foods, skipped, category = [], [], None
    for row in read_sheet(TACO, SHEET):
        first = (row[0] or '').strip()
        if first in CATEGORY_EMOJI:
            category = first
            continue
        if not first.isdigit():
            continue
        cells = [row[i] if i < len(row) else None for i in range(COL_CARBS + 1)]
        num = int(first)
        name = NAME_FIXES.get(num) or ' '.join(cells[COL_NAME].split())
        values = [cells[i] for i in (COL_KCAL, COL_PROTEIN, COL_FAT, COL_CARBS)]
        if num in EXCLUDED_NUMBERS or '*' in values:
            skipped.append(f'{num} {name}')
            continue
        kcal, protein, fat, carbs = (number(v) for v in values)
        foods.append({
            'id': f'taco-{num}',
            'name': name,
            'emoji': emoji_for(name, category),
            'kcal': kcal,
            'carbs': carbs,
            'protein': protein,
            'fat': fat,
            'portions': [
                {'unit': unit, 'grams': grams}
                for unit, grams, _ in portions.get(str(num), [])
            ],
        })

    unknown = set(portions) - {'_fonte'} - {f['id'].removeprefix('taco-') for f in foods}
    if unknown:
        raise SystemExit(f'Medidas para alimentos inexistentes: {sorted(unknown)}')

    OUTPUT.write_text(json.dumps(foods, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    with_portions = sum(1 for f in foods if f['portions'])
    print(f'{len(foods)} alimentos ({with_portions} com medidas caseiras) -> {OUTPUT.relative_to(ROOT)}')
    print('Fora do catálogo:', '; '.join(skipped))


if __name__ == '__main__':
    main()
