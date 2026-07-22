import re

file_path = 'lib/l10n/app_localizations.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix the duplicate statusClosedByTechnician in English block
content = content.replace("      'statusClosedByTechnician': 'Closed by Technician',\n      'paidByCash': 'Paid by Cash',\n      'paidByUpi': 'Paid by UPI',\n      'statusClosedByTechnician': 'Closed by Technician',\n      'paidByCash': 'Paid by Cash',\n      'paidByUpi': 'Paid by UPI',\n", "      'statusClosedByTechnician': 'Closed by Technician',\n      'paidByCash': 'Paid by Cash',\n      'paidByUpi': 'Paid by UPI',\n")

getters_to_add = """
  String get branch => _translate('branch');
  String get accountNumber => _translate('accountNumber');
  String get ifscCode => _translate('ifscCode');
  String get accountType => _translate('accountType');
  String get swiftCode => _translate('swiftCode');
  String get accountName => _translate('accountName');
  String get bankName => _translate('bankName');
  String get scanQrCodeToPay => _translate('scanQrCodeToPay');
  String get scanUpiHint => _translate('scanUpiHint');
  String get documentsText => _translate('documentsText');
  String documentNumber(int number) => _translate('documentNumber', {'number': number.toString()});
  String get openText => _translate('openText');
  String itemsCountLabel(int count) => _translate('itemsCountLabel', {'count': count.toString()});
  String qty(int count) => _translate('qty', {'count': count.toString()});
  String priceEach(String p) => _translate('priceEach', {'p': p});
  String get paymentRejectedStatus => _translate('paymentRejectedStatus');
  String get paymentVerificationStatus => _translate('paymentVerificationStatus');
  String get paymentVerifiedStatus => _translate('paymentVerifiedStatus');
  String get orderDispatchedStatus => _translate('orderDispatchedStatus');
  String get describeProductHint => _translate('describeProductHint');
  String get customInquiry => _translate('customInquiry');
"""

# Insert getters right before _localizedValues
content = re.sub(r'(  static const Map<String, Map<String, String>> _localizedValues = \{)', getters_to_add + r'\n\1', content)

missing_keys = {
    'branch': 'Branch',
    'accountNumber': 'Account Number',
    'ifscCode': 'IFSC Code',
    'accountType': 'Account Type',
    'swiftCode': 'SWIFT Code',
    'accountName': 'Account Name',
    'bankName': 'Bank Name',
    'scanQrCodeToPay': 'Scan QR Code to Pay',
    'scanUpiHint': 'Scan using PhonePe, Google Pay, Paytm, BHIM or any UPI app',
    'documentsText': 'Documents',
    'documentNumber': 'Document {number}',
    'openText': 'Open',
    'itemsCountLabel': 'Items ({count})',
    'qty': 'Qty {count}',
    'priceEach': '₹{p} each',
    'paymentRejectedStatus': 'Payment Rejected',
    'paymentVerificationStatus': 'Payment Verification',
    'paymentVerifiedStatus': 'Payment Verified',
    'orderDispatchedStatus': 'Order Dispatched',
    'describeProductHint': 'Describe the product, quantity, size, brand or any other details...',
    'customInquiry': 'Custom Inquiry',
}

# For every language block in the _localizedValues map, inject the missing keys if they don't exist
def inject_missing_keys(match):
    locale = match.group(1)
    block = match.group(2)
    
    inserts = []
    for key, val in missing_keys.items():
        if f"'{key}':" not in block:
            inserts.append(f"      '{key}': '{val}',")
            
    if inserts:
        # Find the last closing brace in the block
        last_brace_idx = block.rfind('}')
        new_block = block[:last_brace_idx] + '\n' + '\n'.join(inserts) + '\n    }'
        return f"'{locale}': {{{new_block}"
    
    return match.group(0)

pattern = r"'([a-z]{2})': \{([^}]+?)\n    \}"
content = re.sub(pattern, inject_missing_keys, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Restored missing translations!')
