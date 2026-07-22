import re

file_path = 'lib/l10n/app_localizations.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove duplicate getter if I accidentally added it
content = re.sub(r"  String get customInquiry => _translate\('customInquiry'\);\n", "", content)

getters_to_add = """
  String get expressDeliveryOrdersHere => _translate('expressDeliveryOrdersHere');
  String get statusWaitingOnCustomer => _translate('statusWaitingOnCustomer');
  String get poUploadedSuccess => _translate('poUploadedSuccess');
  String get attachPo => _translate('attachPo');
  String get statusInquiry => _translate('statusInquiry');
  String get statusPaymentVerification => _translate('statusPaymentVerification');
  String get statusPaymentRejected => _translate('statusPaymentRejected');
  String get statusPaymentVerified => _translate('statusPaymentVerified');
  String get statusDispatched => _translate('statusDispatched');
  String photosUploadedCount(int count) => _translate('photosUploadedCount', {'count': count.toString()});
  String get quotationReady => _translate('quotationReady');
  String get quotationReadyDesc => _translate('quotationReadyDesc');
  String get verificationInProgress => _translate('verificationInProgress');
  String get verificationInProgressDesc => _translate('verificationInProgressDesc');
  String get orderConfirmed => _translate('orderConfirmed');
  String get orderConfirmedDesc => _translate('orderConfirmedDesc');
  String get actionRequired => _translate('actionRequired');
  String get paymentRejectedDesc => _translate('paymentRejectedDesc');
  String get dispatched => _translate('dispatched');
  String get dispatchedDesc => _translate('dispatchedDesc');
  String get awaitingQuotation => _translate('awaitingQuotation');
  String get awaitingQuotationDesc => _translate('awaitingQuotationDesc');
  String get orderDetailsTitle => _translate('orderDetailsTitle');
  String get priceBreakdown => _translate('priceBreakdown');
  String get itemTotal => _translate('itemTotal');
  String get orderInformation => _translate('orderInformation');
  String get orderId => _translate('orderId');
  String get orderDateStr => _translate('orderDateStr');
  String get orderTimeStr => _translate('orderTimeStr');
  String get orderedBy => _translate('orderedBy');
  String get areaText => _translate('areaText');
  String get dispatchedOnStr => _translate('dispatchedOnStr');
  String itemsCount(int count) => _translate('itemsCount', {'count': count.toString()});
  String dispatchedOnText(String date) => _translate('dispatchedOnText', {'date': date});
  String get viewDetails => _translate('viewDetails');
  String get requestedItems => _translate('requestedItems');
  String get requestMessage => _translate('requestMessage');
  String get additionalDocuments => _translate('additionalDocuments');
  String get proformaInvoice => _translate('proformaInvoice');
  String get piProvidedMsg => _translate('piProvidedMsg');
  String get viewPi => _translate('viewPi');
  String get purchaseOrder => _translate('purchaseOrder');
  String get viewPo => _translate('viewPo');
  String get addToCart => _translate('addToCart');
"""

# Insert new getters right before _localizedValues
if "String get expressDeliveryOrdersHere" not in content:
    content = re.sub(r'(  static const Map<String, Map<String, String>> _localizedValues = \{)', getters_to_add + r'\n\1', content)

missing_keys = {
    'expressDeliveryOrdersHere': 'Express Delivery Orders',
    'statusWaitingOnCustomer': 'Waiting on Customer',
    'poUploadedSuccess': 'PO Uploaded Successfully',
    'attachPo': 'Attach PO',
    'statusInquiry': 'Inquiry',
    'statusPaymentVerification': 'Payment Verification',
    'statusPaymentRejected': 'Payment Rejected',
    'statusPaymentVerified': 'Payment Verified',
    'statusDispatched': 'Dispatched',
    'photosUploadedCount': '{count} Photos Uploaded',
    'quotationReady': 'Quotation Ready',
    'quotationReadyDesc': 'Quotation has been prepared for your inquiry.',
    'verificationInProgress': 'Verification In Progress',
    'verificationInProgressDesc': 'Your payment is being verified.',
    'orderConfirmed': 'Order Confirmed',
    'orderConfirmedDesc': 'Your order has been confirmed.',
    'actionRequired': 'Action Required',
    'paymentRejectedDesc': 'Your payment was rejected.',
    'dispatched': 'Dispatched',
    'dispatchedDesc': 'Your order has been dispatched.',
    'awaitingQuotation': 'Awaiting Quotation',
    'awaitingQuotationDesc': 'We are preparing a quotation for your inquiry.',
    'orderDetailsTitle': 'Order Details',
    'priceBreakdown': 'Price Breakdown',
    'itemTotal': 'Item Total',
    'orderInformation': 'Order Information',
    'orderId': 'Order ID',
    'orderDateStr': 'Order Date',
    'orderTimeStr': 'Order Time',
    'orderedBy': 'Ordered By',
    'areaText': 'Area',
    'dispatchedOnStr': 'Dispatched On',
    'itemsCount': '{count} Items',
    'dispatchedOnText': 'Dispatched on {date}',
    'viewDetails': 'View Details',
    'requestedItems': 'Requested Items',
    'requestMessage': 'Request Message',
    'additionalDocuments': 'Additional Documents',
    'proformaInvoice': 'Proforma Invoice',
    'piProvidedMsg': 'PI has been provided.',
    'viewPi': 'View PI',
    'purchaseOrder': 'Purchase Order',
    'viewPo': 'View PO',
    'addToCart': 'Add to Cart',
}

# The regex approach failed to deduplicate multiline and slightly differently formatted keys.
# Let's fix duplicate keys explicitly:
# We know the duplicate keys are: statusClosedByTechnician, paidByCash, paidByUpi
# We can just use a regex to find all duplicate definitions and remove them!
def remove_duplicates_in_block(block_content):
    # This function uses a simple state to parse key-value lines roughly
    lines = block_content.split('\n')
    seen_keys = set()
    new_lines = []
    
    i = 0
    while i < len(lines):
        line = lines[i]
        line_stripped = line.strip()
        
        # Match something like: 'myKey': 'My Value',
        # Or: 'myKey':
        #        'My multi-line value',
        m = re.match(r"^'([^']+)'\s*:", line_stripped)
        if m:
            key = m.group(1)
            if key in seen_keys:
                # Skip this line, and also skip the next line if it's a continuation
                # (e.g. if this line doesn't end with a comma, skip until we find a comma)
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

print('Fully deduplicated keys and added ALL missing translations!')
