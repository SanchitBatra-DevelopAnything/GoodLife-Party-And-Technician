import re

with open('lib/l10n/app_localizations.dart', 'r', encoding='utf-8') as f:
    text = f.read()

def extract_keys(locale):
    pattern = f"'{locale}': {{(.*?)    }},"
    match = re.search(pattern, text, re.DOTALL)
    if not match:
        pattern = f"'{locale}': {{(.*?)\n  }};"
        match = re.search(pattern, text, re.DOTALL)
        if not match:
            return set()
    
    content = match.group(1)
    keys = re.findall(r"'([^']+)':", content)
    return set(keys)

en_keys = extract_keys('en')
bn_keys = extract_keys('bn')
hi_keys = extract_keys('hi')

print(f'EN keys: {len(en_keys)}')
print(f'BN keys: {len(bn_keys)}')
print(f'HI keys: {len(hi_keys)}')

missing_in_bn = en_keys - bn_keys
print('Missing in BN:')
for k in missing_in_bn: print(k)
