import re

file_path = r'c:\Users\itsam\Downloads\client-work\GoodLife-Party-And-Technician\lib\screens\order_success_screen.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

replacements = [
    (r"import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../l10n/app_localizations.dart';"),
    
    (r"  Widget build\(BuildContext context\) \{\n    return Scaffold\(", 
     "  Widget build(BuildContext context) {\n    final l10n = AppLocalizations.of(context);\n    return Scaffold("),

    (r"const Text\(\n\s*'Your order has been placed successfully!',", "Text(\n                  l10n.orderPlacedSuccessfullyTitle,"),
    
    (r"Text\(\n\s*widget\.paymentDone\n\s*\? 'Your payment screenshot has been uploaded successfully\.\\n\\nYour order is currently under payment verification\.\\nWe will start processing your order once the payment is verified\.'\n\s*: 'Your order has been placed successfully\.\\n\\nPlease complete your payment soon so that we can start processing your order\.\\n\\nPlease contact us to get your payment verified\.',", 
     "Text(\n                  widget.paymentDone\n                      ? l10n.orderPlacedSuccessWithPayment\n                      : l10n.orderPlacedSuccessWithoutPayment,"),

    (r"const Text\(\n\s*'Continue',", "Text(\n                  l10n.continueBtn,")
]

new_content = content
for pattern, replacement in replacements:
    new_content = re.sub(pattern, replacement, new_content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print('Done!')
