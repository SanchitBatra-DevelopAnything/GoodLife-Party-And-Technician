import re
with open('lib/l10n/app_localizations.dart', 'r', encoding='utf-8') as f:
    text = f.read()

getters = set(re.findall(r'String (?:get )?([a-zA-Z0-9_]+)(?:\(.*?\) )?=> _translate', text))
print('Total getters:', len(getters))
print('choosePaymentOption in getters?', 'choosePaymentOption' in getters)
print('selectPaymentMethod in getters?', 'selectPaymentMethod' in getters)
print('attachPaymentScreenshot in getters?', 'attachPaymentScreenshot' in getters)
print('uploadScreenshotHint in getters?', 'uploadScreenshotHint' in getters)
print('submitPaymentBtn in getters?', 'submitPaymentBtn' in getters)

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
print('Total en_keys:', len(en_keys))
print('choosePaymentOption in en_keys?', 'choosePaymentOption' in en_keys)
print('Missing in EN:')
for k in getters - en_keys: print(k)
print('Missing in HI:')
for k in getters - hi_keys: print(k)
