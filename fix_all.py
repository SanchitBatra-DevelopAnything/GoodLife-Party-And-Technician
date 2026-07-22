import re
import json

file_path = 'lib/l10n/app_localizations.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

getters_to_add = """
  String get orderPlacedSuccessfullyTitle => _translate('orderPlacedSuccessfullyTitle');
  String get orderPlacedSuccessWithPayment => _translate('orderPlacedSuccessWithPayment');
  String get orderPlacedSuccessWithoutPayment => _translate('orderPlacedSuccessWithoutPayment');
  String get continueBtn => _translate('continueBtn');
  String uploadFailed(String error) => _translate('uploadFailed', {'error': error});
  String get paymentScreenshotUploadedSuccess => _translate('paymentScreenshotUploadedSuccess');
  String failedToUploadPayment(String error) => _translate('failedToUploadPayment', {'error': error});
  String get selectPaymentMethod => _translate('selectPaymentMethod');
  String get attachPaymentScreenshot => _translate('attachPaymentScreenshot');
  String get uploadScreenshotHint => _translate('uploadScreenshotHint');
  String get pleaseAttachPaymentScreenshot => _translate('pleaseAttachPaymentScreenshot');
  String uploadingProgress(String progress) => _translate('uploadingProgress', {'progress': progress});
  String get submitPaymentBtn => _translate('submitPaymentBtn');
"""

# Insert new getters right before _localizedValues
if "String get orderPlacedSuccessfullyTitle" not in content:
    content = re.sub(r'(  static const Map<String, Map<String, String>> _localizedValues = \{)', getters_to_add + r'\n\1', content)

missing_keys = {
    'orderPlacedSuccessfullyTitle': 'Order Placed Successfully',
    'orderPlacedSuccessWithPayment': 'Your order has been placed successfully. It will be processed after payment verification.',
    'orderPlacedSuccessWithoutPayment': 'Your order has been placed successfully.',
    'continueBtn': 'Continue',
    'uploadFailed': 'Upload Failed: {error}',
    'paymentScreenshotUploadedSuccess': 'Payment screenshot uploaded successfully',
    'failedToUploadPayment': 'Failed to upload payment: {error}',
    'selectPaymentMethod': 'Select Payment Method',
    'attachPaymentScreenshot': 'Attach Payment Screenshot',
    'uploadScreenshotHint': 'Upload Screenshot',
    'pleaseAttachPaymentScreenshot': 'Please attach payment screenshot',
    'uploadingProgress': '{progress}% Uploading',
    'submitPaymentBtn': 'Submit Payment',
}

# Find the start and end of _localizedValues
start_idx = content.find("static const Map<String, Map<String, String>> _localizedValues = {")
# Find the matching closing brace for _localizedValues
# It's at the end of the file basically, but let's be precise.
# We will use regex to find each language block and rebuild it, deduplicating keys in the process.

def process_language_block(match):
    locale = match.group(1)
    block_content = match.group(2)
    
    # Extract key-value pairs
    # Note: Values might contain escaped characters, but in dart they are usually single-quoted
    # Let's just use a simple regex to extract them
    kv_pattern = r"^\s*'([^']+)'\s*:\s*'((?:[^'\\]|\\.)*)'\s*,"
    
    seen_keys = set()
    new_lines = []
    
    # Process line by line to preserve order but deduplicate
    for line in block_content.split('\n'):
        line_stripped = line.strip()
        if not line_stripped:
            continue
            
        m = re.match(r"'([^']+)'\s*:\s*'(.*)'\s*,", line_stripped)
        if m:
            key = m.group(1)
            if key not in seen_keys:
                seen_keys.add(key)
                new_lines.append(line)
        else:
            # Maybe it's multi-line or formatted differently, just keep it
            new_lines.append(line)
            
    # Add any missing keys
    for key, val in missing_keys.items():
        if key not in seen_keys:
            # Escape single quotes in val if any
            val_escaped = val.replace("'", "\\'")
            new_lines.append(f"      '{key}': '{val_escaped}',")
            seen_keys.add(key)
            
    return f"'{locale}': {{\n" + "\n".join(new_lines) + "\n    }"

pattern = r"'([a-z]{2})': \{([^}]+?)\n    \}"
content = re.sub(pattern, process_language_block, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Deduplicated keys and added new missing translations!')
