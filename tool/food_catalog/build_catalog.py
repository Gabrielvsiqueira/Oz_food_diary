"""Gera assets/data/foods.json a partir das tabelas do IBGE (POF 2008-2009).

Uso, na raiz do projeto:

    python3 -m pip install xlrd==2.0.1
    python3 tool/food_catalog/build_catalog.py

As planilhas oficiais estão em .xls (formato antigo do Excel), por isso o
script precisa do `xlrd`. Os .zip são os arquivos baixados do FTP do IBGE,
sem alteração:
ftp.ibge.gov.br/Orcamentos_Familiares/Pesquisa_de_Orcamentos_Familiares_2008_2009/

Fontes (reprodução permitida citando a fonte):
- IBGE. POF 2008-2009: Tabelas de Composição Nutricional dos Alimentos
  Consumidos no Brasil. Rio de Janeiro, 2011. (Tabela 1)
- IBGE. POF 2008-2009: Tabela de Medidas Referidas para os Alimentos
  Consumidos no Brasil. Rio de Janeiro, 2011.
"""

import json
import unicodedata
import zipfile
from pathlib import Path

import xlrd

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
COMPOSITION = HERE / 'ibge_composicao_tab01.zip'
MEASURES = HERE / 'ibge_medidas_bd.zip'
OUTPUT = ROOT / 'assets' / 'data' / 'foods.json'

# Preparo "Não se aplica": o alimento já é consumido como está.
NO_PREPARATION = 99

# Nomes errados na planilha oficial. O 8500904 é a lasanha comum: a tabela
# de medidas o chama de "LAZANHA" e o light é o 8508004.
NAME_FIXES = {
    8500904: 'Lasanha',
    7903109: 'Leite aromatizado',  # "aRomãtizado" na planilha
    6803601: 'Pera',
    6704001: 'Pepino',
}

# Até quantas medidas caseiras cada alimento oferece, além de gramas.
MAX_PORTIONS = 5

# Preparo do IBGE -> (masculino, feminino) usado no nome do alimento.
PREPARATIONS = {
    'Cru(a)': ('cru', 'crua'),
    'Cozido(a)': ('cozido', 'cozida'),
    'Frito(a)': ('frito', 'frita'),
    'Assado(a)': ('assado', 'assada'),
    'Refogado(a)': ('refogado', 'refogada'),
    'Ensopado': ('ensopado', 'ensopada'),
    'Grelhado(a)/brasa/churrasco': ('grelhado', 'grelhada'),
    'Empanado(a)/à milanesa': ('empanado', 'empanada'),
    'Molho vermelho': ('ao molho vermelho',) * 2,
    'Molho branco': ('ao molho branco',) * 2,
    'Ao vinagrete': ('ao vinagrete',) * 2,
    'Ao alho e óleo': ('ao alho e óleo',) * 2,
    'Com manteiga/óleo': ('com manteiga ou óleo',) * 2,
    'Sopa': ('em sopa',) * 2,
    'Mingau': ('em mingau',) * 2,
}

# Gênero pela primeira palavra (sem acentos): terminada em "a" é feminina,
# salvo as exceções abaixo.
FEMININE = {'carne', 'couve', 'couve-flor', 'batata-doce', 'vagem', 'mao',
            'parte', 'ovas'}
MASCULINE = {'cara', 'jaba', 'tracaja', 'goia'}

# Medida do IBGE -> PortionUnit do app, na ordem de preferência. Pratos,
# garrafas, litros e medidas vagas (punhado, garfada) ficam de fora: no IBGE
# muitas delas são estimadas a partir de outra medida.
UNITS = {
    'UNIDADE': 'unit',
    'FATIA': 'slice',
    'PEDACO': 'piece',
    'BIFE': 'steak',
    'FILE': 'fillet',
    'POSTA': 'fishSteak',
    'PEITO': 'breast',
    'COXA': 'drumstick',
    'SOBRECOXA': 'thigh',
    'ASA': 'wing',
    'CONCHA': 'ladle',
    'COLHER DE ARROZ/SERVIR': 'servingSpoon',
    'ESCUMADEIRA': 'skimmer',
    'COLHER DE SOPA': 'tablespoon',
    'COLHER DE SOBREMESA': 'dessertSpoon',
    'COLHER DE CHA': 'teaspoon',
    'PONTA DE FACA': 'knifeTip',
    'COPO MEDIO': 'glass',
    'COPO AMERICANO': 'americanGlass',
    'XICARA DE CHA': 'cup',
    'XICARA DE CAFE': 'coffeeCup',
    'LATA (350 ML)': 'can',
    'TACA': 'wineGlass',
    'DOSE': 'dose',
    'TIGELA': 'bowl',
    'POTE': 'pot',
    'PACOTE': 'packet',
    'BARRA': 'bar',
    'RODELA': 'round',
    'FOLHA': 'leaf',
    'PEGADOR': 'tongs',
    'UNIDADE PEQUENA': 'smallUnit',
    'PORCAO': 'serving',
}
UNIT_ORDER = list(UNITS)

# Limite em gramas das medidas pequenas: algumas foram estimadas pelo IBGE a
# partir de outra medida e saíram absurdas (colher de chá de 110 g).
MAX_GRAMS = {'teaspoon': 15, 'dessertSpoon': 30, 'tablespoon': 60,
             'knifeTip': 30, 'coffeeCup': 100}

# Outros nomes pelos quais o alimento é procurado.
ALIASES = {
    'Pão de sal': ['pão francês', 'pãozinho', 'cacetinho'],
    'Aipim': ['mandioca', 'macaxeira'],
    'Mandioca': ['aipim', 'macaxeira'],
    'Mandioquinha salsa (batata-baroa)': ['batata-salsa'],
    'Pizza muçarela': ['mussarela'],
    'Queijo muçarela': ['mussarela'],
    'Pizza calabreza': ['calabresa'],
    'Refrigerante de cola tradicional': ['coca-cola', 'refri'],
    'Biscoito salgado': ['bolacha'],
    'Biscoito doce': ['bolacha'],
}

def normalize(text):
    text = unicodedata.normalize('NFKD', text.lower())
    return ''.join(c for c in text if not unicodedata.combining(c))


def read_sheet(zip_path):
    with zipfile.ZipFile(zip_path) as z:
        (name,) = z.namelist()
        book = xlrd.open_workbook(file_contents=z.read(name))
    sheet = book.sheet_by_index(0)
    return [[cell.value for cell in sheet.row(r)] for r in range(sheet.nrows)]


def is_feminine(name):
    words = normalize(name).replace(',', ' ').split()
    if words[0] == 'mini' and len(words) > 1:
        words = words[1:]
    first = words[0]
    if first in FEMININE:
        return True
    if first in MASCULINE:
        return False
    return first.endswith('a')


def _label(prep_label, name):
    masculine, feminine = PREPARATIONS[prep_label]
    return feminine if is_feminine(name) else masculine


def _measure(measures, code, preps):
    """Medidas do primeiro preparo, completadas pelas dos outros preparos."""
    found = [measures[(code, p)] for p in preps if (code, p) in measures]
    if not found:
        return None
    standard, grams = found[0][0], {}
    for _, other in found:
        for unit, value in other.items():
            grams.setdefault(unit, value)
    return standard, grams


def read_composition():
    """Linhas (código, nome, preparo, descrição do preparo, nutrientes).

    Os nutrientes são (kcal, proteína, gordura, carboidrato) por 100 g.
    """
    rows, skipped = [], []
    for row in read_sheet(COMPOSITION):
        first = row[0]
        # Títulos, grupos e notas da planilha.
        if isinstance(first, str):
            continue
        code = int(first)
        name = NAME_FIXES.get(code) or ' '.join(row[1].split())
        values = row[4:8]
        # "-" é valor ausente no IBGE. Sem calorias o alimento fica de fora
        # (adoçantes, refrigerantes diet); num macro vale zero, como o "NA"
        # da TACO (carboidrato da carne, gordura do açúcar).
        if not isinstance(values[0], float):
            skipped.append(name)
            continue
        nutrients = tuple(round(v, 1) if isinstance(v, float) else 0.0 for v in values)
        rows.append((code, name, int(row[2]), row[3].strip(), nutrients))
    return rows, skipped


def read_measures():
    """{(código, preparo): (medida padrão, {medida: gramas})}."""
    measures = {}
    for row in read_sheet(MEASURES):
        if not isinstance(row[0], float):
            continue
        key = (int(row[0]), int(row[2]))
        standard, grams = measures.setdefault(key, (row[7].strip(), {}))
        grams.setdefault(row[5].strip(), round(row[8], 1))
    return measures


def portions_for(measure):
    if measure is None:
        return []
    standard, grams = measure
    units = sorted(
        (u for u in grams
         if u in UNITS and 0 < grams[u] <= MAX_GRAMS.get(UNITS[u], 5000)),
        key=lambda u: (u != standard, UNIT_ORDER.index(u)),
    )
    return [{'unit': UNITS[u], 'grams': grams[u]} for u in units[:MAX_PORTIONS]]


def main():
    rows, skipped = read_composition()
    measures = read_measures()

    # O IBGE só muda os valores quando o preparo muda a composição (fritura,
    # molho). Os preparos com os mesmos valores do preparo base viram um
    # alimento só, e os nomes deles entram como palavras de busca ("ovo
    # cozido" encontra "Ovo de galinha"). Os demais ganham nome próprio.
    by_code = {}
    for row in rows:
        by_code.setdefault(row[0], []).append(row)

    foods = []
    for code, variants in by_code.items():
        groups = {}
        for row in variants:
            groups.setdefault(row[4], []).append(row)
        base = next(
            (g for g in groups.values() if any(r[2] == NO_PREPARATION for r in g)),
            max(groups.values(), key=len),
        )
        for row in variants:
            _, name, prep, prep_label, nutrients = row
            keywords, preps = [], [prep]
            if row in base:
                if row is not next((r for r in base if r[2] == NO_PREPARATION), base[0]):
                    continue
                keywords = [_label(r[3], name) for r in base if r[2] != NO_PREPARATION]
                preps += [r[2] for r in base if r[2] != prep]
            else:
                name = f'{name}, {_label(prep_label, name)}'
            kcal, protein, fat, carbs = nutrients
            food = {
                'id': f'ibge-{code}-{prep}',
                'name': name,
                'kcal': kcal,
                'carbs': carbs,
                'protein': protein,
                'fat': fat,
                'portions': portions_for(_measure(measures, code, preps)),
            }
            keywords += ALIASES.get(name, [])
            if keywords:
                food['keywords'] = keywords
            foods.append(food)

    names = [normalize(f['name']) for f in foods]
    duplicated = sorted({n for n in names if names.count(n) > 1})
    if duplicated:
        raise SystemExit(f'Nomes repetidos: {duplicated}')

    foods.sort(key=lambda f: normalize(f['name']))
    OUTPUT.write_text(json.dumps(foods, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    with_portions = sum(1 for f in foods if f['portions'])
    print(f'{len(foods)} alimentos ({with_portions} com medidas caseiras) -> {OUTPUT.relative_to(ROOT)}')
    print('Fora do catálogo (valores ausentes):', '; '.join(skipped))


if __name__ == '__main__':
    main()
