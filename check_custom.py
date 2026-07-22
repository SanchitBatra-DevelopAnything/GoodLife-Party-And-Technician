import sys
import re
sys.stdout.reconfigure(encoding='utf-8')
with open('lib/l10n/app_localizations.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Check customInquiry in en block
en_block_start = content.find("'en': {")
hi_block_start = content.find("'hi': {")
en_block = content[en_block_start:hi_block_start]
print('customInquiry in en block:', ('customInquiry' in en_block))
print('customInquiry total count:', content.count('customInquiry'))

# Check all supported locales have a block
locales = re.findall(r"'([a-z]{2})': \{", content)
print('Language blocks found:', locales)
