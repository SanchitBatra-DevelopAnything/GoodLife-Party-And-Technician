import re

file_path = 'lib/l10n/app_localizations.dart'
with open(file_path, 'rb') as f:
    content = f.read().decode('utf-8')

getters = '''  String get statusClosedByTechnician => _translate('statusClosedByTechnician');
  String get paidByCash => _translate('paidByCash');
  String get paidByUpi => _translate('paidByUpi');'''

content = re.sub(r'(  // Getters\r?\n.*?)(?=\r?\n  static const Map<String, Map<String, dynamic>> _localizedValues)', r'\1\n' + getters, content, flags=re.DOTALL)

langs = {
    'en': {
        'statusClosedByTechnician': 'Closed by Technician',
        'paidByCash': 'Paid by Cash',
        'paidByUpi': 'Paid by UPI',
    },
    'hi': {
        'statusClosedByTechnician': 'तकनीशियन द्वारा बंद किया गया',
        'paidByCash': 'नकद भुगतान किया गया',
        'paidByUpi': 'UPI द्वारा भुगतान किया गया',
    },
    'bn': {
        'statusClosedByTechnician': 'টেকনিশিয়ান দ্বারা বন্ধ',
        'paidByCash': 'নগদে পেমেন্ট করা হয়েছে',
        'paidByUpi': 'UPI দ্বারা পেমেন্ট করা হয়েছে',
    },
    'mr': {
        'statusClosedByTechnician': 'तंत्रज्ञाद्वारे बंद केले',
        'paidByCash': 'रोखीने पैसे दिले',
        'paidByUpi': 'UPI द्वारे पैसे दिले',
    },
    'te': {
        'statusClosedByTechnician': 'టెక్నీషియన్ ద్వారా మూసివేయబడింది',
        'paidByCash': 'నగదు ద్వారా చెల్లించబడింది',
        'paidByUpi': 'UPI ద్వారా చెల్లించబడింది',
    },
    'ta': {
        'statusClosedByTechnician': 'தொழில்நுட்ப வல்லுநரால் மூடப்பட்டது',
        'paidByCash': 'பணமாக செலுத்தப்பட்டது',
        'paidByUpi': 'UPI மூலம் செலுத்தப்பட்டது',
    },
    'gu': {
        'statusClosedByTechnician': 'ટેકનિશિયન દ્વારા બંધ કરાયેલ',
        'paidByCash': 'રોકડ દ્વારા ચૂકવેલ',
        'paidByUpi': 'UPI દ્વારા ચૂકવેલ',
    },
    'kn': {
        'statusClosedByTechnician': 'ತಂತ್ರಜ್ಞರಿಂದ ಮುಚ್ಚಲಾಗಿದೆ',
        'paidByCash': 'ನಗದು ಮೂಲಕ ಪಾವತಿಸಲಾಗಿದೆ',
        'paidByUpi': 'UPI ಮೂಲಕ ಪಾವತಿಸಲಾಗಿದೆ',
    },
    'or': {
        'statusClosedByTechnician': 'ଟେକ୍ନିସିଆନଙ୍କ ଦ୍ୱାରା ବନ୍ଦ କରାଯାଇଛି',
        'paidByCash': 'ନଗଦ ଦ୍ୱାରା ଦେୟ ଦିଆଯାଇଛି',
        'paidByUpi': 'UPI ଦ୍ୱାରା ଦେୟ ଦିଆଯାଇଛି',
    },
    'ml': {
        'statusClosedByTechnician': 'ടെക്നീഷ്യൻ അടച്ചു',
        'paidByCash': 'പണമായി അടച്ചു',
        'paidByUpi': 'UPI വഴി അടച്ചു',
    },
    'pa': {
        'statusClosedByTechnician': 'ਤਕਨੀਸ਼ੀਅਨ ਦੁਆਰਾ ਬੰਦ ਕੀਤਾ ਗਿਆ',
        'paidByCash': 'ਨਕਦ ਦੁਆਰਾ ਭੁਗਤਾਨ ਕੀਤਾ ਗਿਆ',
        'paidByUpi': 'UPI ਦੁਆਰਾ ਭੁਗਤਾਨ ਕੀਤਾ ਗਿਆ',
    }
}

for lang, trans in langs.items():
    search_str = f"'{lang}': {{"
    idx = content.find(search_str)
    if idx != -1:
        # Find the end of this line
        end_of_line_idx = content.find('\n', idx)
        if end_of_line_idx != -1:
            insert_str = ''.join([f"\n      '{k}': '{v}'," for k, v in trans.items()])
            content = content[:end_of_line_idx] + insert_str + content[end_of_line_idx:]

with open(file_path, 'wb') as f:
    f.write(content.encode('utf-8'))

print('Updated app_localizations.dart successfully')
