import re

with open('lib/l10n/app_localizations.dart', 'r', encoding='utf-8') as f:
    text = f.read()

getters = set(re.findall(r'String (?:get )?([a-zA-Z0-9_]+)(?:\(.*?\) )?=> _translate', text))

def extract_keys(locale):
    pattern = f"'{locale}': {{(.*?)    }},"
    match = re.search(pattern, text, re.DOTALL)
    if not match:
        pattern = f"'{locale}': {{(.*?)\n  }};"
        match = re.search(pattern, text, re.DOTALL)
        if not match:
            return set()
    return set(re.findall(r"'([^']+)':", match.group(1)))

langs = ['en', 'hi', 'bn', 'mr', 'te', 'ta', 'gu', 'kn', 'or', 'ml', 'pa']
en_keys = extract_keys('en')
print(f'Getters: {len(getters)}, EN keys: {len(en_keys)}')
print(f'Missing in EN from getters: {sorted(getters - en_keys)}')

for lang in langs:
    keys = extract_keys(lang)
    missing = en_keys - keys
    print(f'{lang}: {len(keys)} keys, missing {len(missing)}')
    if missing and lang != 'en':
        print(' ', sorted(missing)[:30])
