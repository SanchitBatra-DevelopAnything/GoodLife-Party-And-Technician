import re

file_path = r'c:\Users\itsam\Downloads\client-work\GoodLife-Party-And-Technician\lib\widgets\payment_option_bottom_sheet.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

replacements = [
    (r"import 'package:uuid/uuid.dart';", "import 'package:uuid/uuid.dart';\nimport '../l10n/app_localizations.dart';"),
    
    (r"  Widget build\(BuildContext context\) \{\n    return SafeArea\(", 
     "  Widget build(BuildContext context) {\n    final l10n = AppLocalizations.of(context);\n    return SafeArea("),

    (r"  Widget build\(BuildContext context\) \{\n    final orderProvider = Provider.of<OrderProvider>\(context\);\n\n    return SafeArea\(", 
     "  Widget build(BuildContext context) {\n    final orderProvider = Provider.of<OrderProvider>(context);\n    final l10n = AppLocalizations.of(context);\n\n    return SafeArea("),

    (r"  Widget build\(BuildContext context\) \{\n    final screenWidth = MediaQuery.of\(context\).size.width;\n\n    return Scaffold\(",
     "  Widget build(BuildContext context) {\n    final screenWidth = MediaQuery.of(context).size.width;\n    final l10n = AppLocalizations.of(context);\n\n    return Scaffold("),

    (r"  Widget build\(BuildContext context\) \{\n    return Scaffold\(",
     "  Widget build(BuildContext context) {\n    final l10n = AppLocalizations.of(context);\n    return Scaffold("),

    (r"'Choose Payment Option'", "l10n.choosePaymentOption"),
    (r"'Your order will be processed only after the payment is received and verified.\n\nPlease make sure to attach the payment screenshot after completing the payment.'", "l10n.paymentProcessingWarning"),
    (r"const Text\('Pay Now'\)", "Text(l10n.payNow)"),
    
    (r"const Text\(\n\s*'Select Payment Method',", "Text(\n              l10n.selectPaymentMethod,"),
    (r"title: const Text\('QR Code'\),", "title: Text(l10n.qrCode),"),
    (r"title: const Text\('Bank Transfer'\),", "title: Text(l10n.bankTransferTitle),"),
    (r"const Text\(\n\s*'Attach Payment Screenshot',", "Text(\n              l10n.attachPaymentScreenshot,"),
    (r"const Text\('Upload Screenshot'\),", "Text(l10n.uploadScreenshotHint),"),
    (r"const Text\(\n\s*'Please attach payment screenshot',", "Text(\n                l10n.pleaseAttachPaymentScreenshot,"),
    (r"Text\(\n\s*'\$\{uploadProgress.toStringAsFixed\(0\)\}% Uploading',\n\s*\),", 
     "Text(\n                            l10n.uploadingProgress(uploadProgress.toStringAsFixed(0)),\n                          ),"),
    (r"const Text\('Submit Payment'\),", "Text(l10n.submitPaymentBtn),"),

    (r"title: const Text\('QR Code Payment'\),", "title: Text(l10n.scanQrCodeToPay),"),
    (r"const Text\(\n\s*'Scan QR Code to Pay',", "Text(\n                  l10n.scanQrCodeToPay,"),
    (r"const Text\(\n\s*'Scan using PhonePe, Google Pay, Paytm, BHIM or any UPI app',", "Text(\n                  l10n.scanUpiHint,"),

    (r"_InfoTile\(\n\s*title: 'Account Name',", "_InfoTile(\n                  title: l10n.accountName,"),
    (r"_InfoTile\(\n\s*title: 'Bank Name',", "_InfoTile(\n                  title: l10n.bankName,"),
    (r"_InfoTile\(\n\s*title: 'Branch',", "_InfoTile(\n                  title: l10n.branch,"),
    (r"_InfoTile\(\n\s*title: 'Account Number',", "_InfoTile(\n                  title: l10n.accountNumber,"),
    (r"_InfoTile\(\n\s*title: 'IFSC Code',", "_InfoTile(\n                  title: l10n.ifscCode,"),
    (r"_InfoTile\(\n\s*title: 'Account Type',", "_InfoTile(\n                  title: l10n.accountType,"),
    (r"_InfoTile\(\n\s*title: 'SWIFT Code',", "_InfoTile(\n                  title: l10n.swiftCode,")
]

new_content = content
for pattern, replacement in replacements:
    new_content = re.sub(pattern, replacement, new_content)

new_content = re.sub(r"children: const \[", "children: [", new_content)
new_content = re.sub(r"children: const \[\n\s*Icon\(Icons.upload_file, size: 34\),", "children: [\n                          const Icon(Icons.upload_file, size: 34),", new_content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print('Done!')
