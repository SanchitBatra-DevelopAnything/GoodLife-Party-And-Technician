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

en_keys = extract_keys('en')
hi_keys = extract_keys('hi')
bn_keys = extract_keys('bn')

print(f'EN keys: {len(en_keys)}')
print(f'HI keys: {len(hi_keys)}')
print(f'BN keys: {len(bn_keys)}')
print('Missing in EN:', len(getters - en_keys))
print('Missing in HI:', len(getters - hi_keys))
print('Missing in BN:', len(getters - bn_keys))

missing_hi = getters - hi_keys
missing_bn = getters - bn_keys

print('\nMissing in HI:')
for k in missing_hi: print(k)

print('\nMissing in BN:')
for k in missing_bn: print(k)
