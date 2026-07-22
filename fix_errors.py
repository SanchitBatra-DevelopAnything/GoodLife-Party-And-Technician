import re

with open(r'c:\Users\itsam\Downloads\client-work\GoodLife-Party-And-Technician\lib\l10n\app_localizations.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Fix duplicate getter for qrCode
text = re.sub(r"  String get qrCode => _translate\('qrCode'\);\n", "", text, count=1)

# Fix duplicate keys for qrCode in maps
text = re.sub(r"      'qrCode': 'QR Code',\n", "", text, count=1) # English
text = re.sub(r"      'qrCode': 'QR कोड',\n", "", text, count=1) # Hindi
text = re.sub(r"      'qrCode': 'QR কোড',\n", "", text, count=1)
text = re.sub(r"      'qrCode': 'QR कोड',\n", "", text, count=1) # Marathi (could be same as Hindi)
text = re.sub(r"      'qrCode': 'QR కోడ్',\n", "", text, count=1)
text = re.sub(r"      'qrCode': 'QR குறியீடு',\n", "", text, count=1)
text = re.sub(r"      'qrCode': 'QR ಕೋಡ್',\n", "", text, count=1)
text = re.sub(r"      'qrCode': 'QR କୋଡ୍',\n", "", text, count=1)
text = re.sub(r"      'qrCode': 'QR കോഡ്',\n", "", text, count=1)
text = re.sub(r"      'qrCode': 'QR ਕੋਡ',\n", "", text, count=1)

with open(r'c:\Users\itsam\Downloads\client-work\GoodLife-Party-And-Technician\lib\l10n\app_localizations.dart', 'w', encoding='utf-8') as f:
    f.write(text)

with open(r'c:\Users\itsam\Downloads\client-work\GoodLife-Party-And-Technician\lib\widgets\payment_option_bottom_sheet.dart', 'r', encoding='utf-8') as f:
    text2 = f.read()

text2 = text2.replace("l10n.bankTransferTitle", "l10n.bankTransfer")
text2 = text2.replace("const Text(\n              l10n.choosePaymentOption,", "Text(\n              l10n.choosePaymentOption,")
text2 = text2.replace("const Text(\n                l10n.paymentProcessingWarning,", "Text(\n                l10n.paymentProcessingWarning,")

# In case the indentation was different
text2 = re.sub(r"const Text\(\s*l10n\.choosePaymentOption,", r"Text(\n              l10n.choosePaymentOption,", text2)
text2 = re.sub(r"const Text\(\s*l10n\.paymentProcessingWarning,", r"Text(\n                l10n.paymentProcessingWarning,", text2)

with open(r'c:\Users\itsam\Downloads\client-work\GoodLife-Party-And-Technician\lib\widgets\payment_option_bottom_sheet.dart', 'w', encoding='utf-8') as f:
    f.write(text2)

print('Done!')
