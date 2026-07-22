import re

with open('lib/l10n/app_localizations.dart', 'r', encoding='utf-8') as f:
    text = f.read()

getters = set(re.findall(r'String (?:get )?([a-zA-Z0-9_]+)(?:\(.*?\) )?=> _translate', text))
en_match = re.search(r"'en': \{(.*?)\n    \},", text, re.DOTALL)
if not en_match:
    en_match = re.search(r"'en': \{(.*?)\n  \};", text, re.DOTALL)
en_keys = set(re.findall(r"'([^']+)':", en_match.group(1)))

missing = getters - en_keys
print('Missing in EN:')
for k in missing: print(k)
