import re
with open('lib/l10n/app_localizations.dart', 'r', encoding='utf-8') as f:
    text = f.read()

getters = set(re.findall(r'String (?:get )?([a-zA-Z0-9_]+).*?=> _translate', text))
print('Total getters:', len(getters))

def extract_keys(locale):
    pattern = f"'{locale}': {{(.*?)    }},"
    match = re.search(pattern, text, re.DOTALL)
    if not match:
        pattern = f"'{locale}': {{(.*?)\n  }};"
        match = re.search(pattern, text, re.DOTALL)
        if not match: return set()
    return set(re.findall(r"'([^']+)':", match.group(1)))

en_keys = extract_keys('en')
hi_keys = extract_keys('hi')
bn_keys = extract_keys('bn')

print('Missing in EN:', len(getters - en_keys))
for k in getters - en_keys: print(k)
print('Missing in HI:', len(getters - hi_keys))
for k in getters - hi_keys: print(k)
print('Missing in BN:', len(getters - bn_keys))
for k in getters - bn_keys: print(k)
