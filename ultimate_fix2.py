import re

file_path = 'lib/l10n/app_localizations.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

getters_to_add = """
  String get serviceComplaintTab => _translate('serviceComplaintTab');
  String get statusClosedByTechnician => _translate('statusClosedByTechnician');
  String get paidByCash => _translate('paidByCash');
  String get paidByUpi => _translate('paidByUpi');
  String get paymentScreenshot => _translate('paymentScreenshot');
  String get choosePaymentOption => _translate('choosePaymentOption');
  String get paymentProcessingWarning => _translate('paymentProcessingWarning');
"""

# Insert new getters right before _localizedValues
if "String get serviceComplaintTab" not in content:
    content = re.sub(r'(  static const Map<String, Map<String, String>> _localizedValues = \{)', getters_to_add + r'\n\1', content)

missing_keys = {
    'serviceComplaintTab': 'Service/Complaint',
    'statusClosedByTechnician': 'Closed by Technician',
    'paidByCash': 'Paid by Cash',
    'paidByUpi': 'Paid by UPI',
    'paymentScreenshot': 'Payment Screenshot',
    'choosePaymentOption': 'Choose Payment Option',
    'paymentProcessingWarning': 'Payment Processing Warning',
}

def remove_duplicates_in_block(block_content):
    lines = block_content.split('\n')
    seen_keys = set()
    new_lines = []
    
    i = 0
    while i < len(lines):
        line = lines[i]
        line_stripped = line.strip()
        m = re.match(r"^'([^']+)'\s*:", line_stripped)
        if m:
            key = m.group(1)
            if key in seen_keys:
                while i < len(lines) and not lines[i].strip().endswith(','):
                    i += 1
            else:
                seen_keys.add(key)
                new_lines.append(line)
        else:
            new_lines.append(line)
        i += 1
        
    for key, val in missing_keys.items():
        if key not in seen_keys:
            val_escaped = val.replace("'", "\\'")
            new_lines.append(f"      '{key}': '{val_escaped}',")
            seen_keys.add(key)
            
    return '\n'.join(new_lines)


def process_language_block(match):
    locale = match.group(1)
    block_content = match.group(2)
    new_block_content = remove_duplicates_in_block(block_content)
    return f"'{locale}': {{{new_block_content}\n    }}"

pattern = r"'([a-z]{2})': \{([^}]+?)\n    \}"
content = re.sub(pattern, process_language_block, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Fully deduplicated keys and added MORE missing translations!')
