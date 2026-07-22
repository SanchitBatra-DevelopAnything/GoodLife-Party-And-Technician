import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('lib/l10n/app_localizations.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Find duplicate map keys per language block
print('=== Checking for duplicate keys per language block ===')

in_map = False
current_lang = None
lang_keys = {}

for i, line in enumerate(lines, 1):
    stripped = line.strip()
    
    # Detect start of _localizedValues
    if '_localizedValues = {' in line:
        in_map = True
        continue
    
    if not in_map:
        continue
    
    # Detect language block start
    import re
    lang_match = re.match(r"^'([a-z]{2})': \{", stripped)
    if lang_match:
        current_lang = lang_match.group(1)
        lang_keys[current_lang] = {}
        continue
    
    # Detect key-value entry
    kv_match = re.match(r"^'([^']+)'\s*:", stripped)
    if kv_match and current_lang:
        key = kv_match.group(1)
        if key in lang_keys[current_lang]:
            print(f"DUPLICATE: lang={current_lang}, key={key}, line={i}")
        else:
            lang_keys[current_lang][key] = i

print('=== Done checking ===')
print(f'Total languages found: {len(lang_keys)}')
for lang, keys in lang_keys.items():
    print(f'  {lang}: {len(keys)} keys')
