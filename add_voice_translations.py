import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('lib/l10n/app_localizations.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# New keys to add
new_getters = """  String get tapToRecordVoiceNote => _translate('tapToRecordVoiceNote');
  String get uptoOneMinuteRecording => _translate('uptoOneMinuteRecording');
  String get micAccessRequired => _translate('micAccessRequired');
  String get micAccessMessage => _translate('micAccessMessage');
  String get cancelRecording => _translate('cancelRecording');
  String get voiceNoteSection => _translate('voiceNoteSection');
"""

# Insert before the _localizedValues map
marker = '  static const Map<String, Map<String, String>> _localizedValues = {'
if 'tapToRecordVoiceNote' not in content:
    content = content.replace(marker, new_getters + '\n' + marker)

# New translations per language
new_keys = {
    'en': {
        'tapToRecordVoiceNote': 'Tap to Record Voice Note',
        'uptoOneMinuteRecording': 'Upto 1 minute recording allowed',
        'micAccessRequired': 'Microphone Access Required',
        'micAccessMessage': 'This app needs microphone access to record a voice note. Please enable it in Settings.',
        'cancelRecording': 'Cancel',
        'voiceNoteSection': 'Voice Note',
    },
    'hi': {
        'tapToRecordVoiceNote': 'वॉयस नोट रिकॉर्ड करने के लिए टैप करें',
        'uptoOneMinuteRecording': 'अधिकतम 1 मिनट की रिकॉर्डिंग की अनुमति है',
        'micAccessRequired': 'माइक्रोफ़ोन एक्सेस आवश्यक है',
        'micAccessMessage': 'इस ऐप को वॉयस नोट रिकॉर्ड करने के लिए माइक्रोफ़ोन एक्सेस चाहिए। कृपया सेटिंग में इसे सक्षम करें।',
        'cancelRecording': 'रद्द करें',
        'voiceNoteSection': 'वॉयस नोट',
    },
    'bn': {
        'tapToRecordVoiceNote': 'ভয়েস নোট রেকর্ড করতে ট্যাপ করুন',
        'uptoOneMinuteRecording': 'সর্বোচ্চ ১ মিনিটের রেকর্ডিং অনুমোদিত',
        'micAccessRequired': 'মাইক্রোফোন অ্যাক্সেস প্রয়োজন',
        'micAccessMessage': 'ভয়েস নোট রেকর্ড করতে এই অ্যাপের মাইক্রোফোন অ্যাক্সেস প্রয়োজন। অনুগ্রহ করে সেটিংসে এটি সক্ষম করুন।',
        'cancelRecording': 'বাতিল করুন',
        'voiceNoteSection': 'ভয়েস নোট',
    },
    'mr': {
        'tapToRecordVoiceNote': 'व्हॉईस नोट रेकॉर्ड करण्यासाठी टॅप करा',
        'uptoOneMinuteRecording': 'जास्तीत जास्त 1 मिनिटाची रेकॉर्डिंग परवानगी आहे',
        'micAccessRequired': 'मायक्रोफोन प्रवेश आवश्यक आहे',
        'micAccessMessage': 'व्हॉईस नोट रेकॉर्ड करण्यासाठी या ॲपला मायक्रोफोन प्रवेश आवश्यक आहे. कृपया सेटिंग्जमध्ये ते सक्षम करा.',
        'cancelRecording': 'रद्द करा',
        'voiceNoteSection': 'व्हॉईस नोट',
    },
    'te': {
        'tapToRecordVoiceNote': 'వాయిస్ నోట్ రికార్డ్ చేయడానికి నొక్కండి',
        'uptoOneMinuteRecording': 'గరిష్ఠంగా 1 నిమిషం రికార్డింగ్ అనుమతించబడుతుంది',
        'micAccessRequired': 'మైక్రోఫోన్ యాక్సెస్ అవసరం',
        'micAccessMessage': 'వాయిస్ నోట్ రికార్డ్ చేయడానికి ఈ యాప్‌కు మైక్రోఫోన్ యాక్సెస్ అవసరం. దయచేసి సెట్టింగ్‌లలో దీన్ని ఎనేబుల్ చేయండి.',
        'cancelRecording': 'రద్దు చేయండి',
        'voiceNoteSection': 'వాయిస్ నోట్',
    },
    'ta': {
        'tapToRecordVoiceNote': 'குரல் குறிப்பை பதிவு செய்ய தட்டவும்',
        'uptoOneMinuteRecording': 'அதிகபட்சம் 1 நிமிட பதிவு அனுமதிக்கப்படுகிறது',
        'micAccessRequired': 'மைக்ரோஃபோன் அணுகல் தேவை',
        'micAccessMessage': 'குரல் குறிப்பை பதிவு செய்ய இந்த ஆப்புக்கு மைக்ரோஃபோன் அணுகல் தேவை. தயவுசெய்து அமைப்புகளில் இதை இயக்கவும்.',
        'cancelRecording': 'ரத்துசெய்',
        'voiceNoteSection': 'குரல் குறிப்பு',
    },
    'gu': {
        'tapToRecordVoiceNote': 'વૉઇસ નોટ રેકોર્ડ કરવા માટે ટૅપ કરો',
        'uptoOneMinuteRecording': 'મહત્તમ 1 મિનિટ રેકોર્ડિંગ મંજૂર છે',
        'micAccessRequired': 'માઇક્રોફોન ઍક્સેસ જરૂરી છે',
        'micAccessMessage': 'વૉઇસ નોટ રેકોર્ડ કરવા માટે આ ઍપ્લિકેશનને માઇક્રોફોન ઍક્સેસ જોઈએ છે. કૃપા કરીને સેટિંગ્સમાં તેને સક્ષમ કરો.',
        'cancelRecording': 'રદ કરો',
        'voiceNoteSection': 'વૉઇસ નોટ',
    },
    'kn': {
        'tapToRecordVoiceNote': 'ಧ್ವನಿ ಟಿಪ್ಪಣಿ ರೆಕಾರ್ಡ್ ಮಾಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ',
        'uptoOneMinuteRecording': 'ಗರಿಷ್ಠ 1 ನಿಮಿಷ ರೆಕಾರ್ಡಿಂಗ್ ಅನುಮತಿ ಇದೆ',
        'micAccessRequired': 'ಮೈಕ್ರೊಫೋನ್ ಪ್ರವೇಶ ಅಗತ್ಯವಿದೆ',
        'micAccessMessage': 'ಧ್ವನಿ ಟಿಪ್ಪಣಿ ರೆಕಾರ್ಡ್ ಮಾಡಲು ಈ ಅಪ್ಲಿಕೇಶನ್‌ಗೆ ಮೈಕ್ರೊಫೋನ್ ಪ್ರವೇಶ ಬೇಕು. ದಯವಿಟ್ಟು ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಅದನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ.',
        'cancelRecording': 'ರದ್ದು ಮಾಡಿ',
        'voiceNoteSection': 'ಧ್ವನಿ ಟಿಪ್ಪಣಿ',
    },
    'or': {
        'tapToRecordVoiceNote': 'ଭଏସ ନୋଟ ରେକର୍ଡ କରିବାକୁ ଟ୍ୟାପ୍ କରନ୍ତୁ',
        'uptoOneMinuteRecording': 'ସର୍ବାଧିକ 1 ମିନିଟ୍ ରେକର୍ଡିଂ ଅନୁମୋଦିତ',
        'micAccessRequired': 'ମାଇକ୍ରୋଫୋନ୍ ଆକ୍ସେସ୍ ଆବଶ୍ୟକ',
        'micAccessMessage': 'ଭଏସ ନୋଟ ରେକର୍ଡ କରିବାକୁ ଏହି ଆପ୍‌ର ମାଇକ୍ରୋଫୋନ୍ ଆକ୍ସେସ୍ ଦରକାର। ଦୟାକରି ସେଟିଂରେ ଏହାକୁ ସକ୍ଷମ କରନ୍ତୁ।',
        'cancelRecording': 'ବାତିଲ କରନ୍ତୁ',
        'voiceNoteSection': 'ଭଏସ ନୋଟ',
    },
    'ml': {
        'tapToRecordVoiceNote': 'വോയ്‌സ് നോട്ട് റെക്കോർഡ് ചെയ്യാൻ ടാപ്പ് ചെയ്യുക',
        'uptoOneMinuteRecording': 'പരമാവധി 1 മിനിറ്റ് റെക്കോർഡിംഗ് അനുവദനീയമാണ്',
        'micAccessRequired': 'മൈക്രോഫോൺ ആക്‌സസ് ആവശ്യമാണ്',
        'micAccessMessage': 'വോയ്‌സ് നോട്ട് റെക്കോർഡ് ചെയ്യാൻ ഈ ആപ്പിന് മൈക്രോഫോൺ ആക്‌സസ് ആവശ്യമാണ്. ദയവായി ക്രമീകരണങ്ങളിൽ ഇത് പ്രവർത്തനക്ഷമമാക്കുക.',
        'cancelRecording': 'റദ്ദാക്കുക',
        'voiceNoteSection': 'വോയ്‌സ് നോട്ട്',
    },
    'pa': {
        'tapToRecordVoiceNote': 'ਵੌਇਸ ਨੋਟ ਰਿਕਾਰਡ ਕਰਨ ਲਈ ਟੈਪ ਕਰੋ',
        'uptoOneMinuteRecording': 'ਵੱਧ ਤੋਂ ਵੱਧ 1 ਮਿੰਟ ਦੀ ਰਿਕਾਰਡਿੰਗ ਦੀ ਆਗਿਆ ਹੈ',
        'micAccessRequired': 'ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਪਹੁੰਚ ਦੀ ਲੋੜ ਹੈ',
        'micAccessMessage': 'ਵੌਇਸ ਨੋਟ ਰਿਕਾਰਡ ਕਰਨ ਲਈ ਇਸ ਐਪ ਨੂੰ ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਪਹੁੰਚ ਦੀ ਲੋੜ ਹੈ। ਕਿਰਪਾ ਕਰਕੇ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਇਸਨੂੰ ਚਾਲੂ ਕਰੋ।',
        'cancelRecording': 'ਰੱਦ ਕਰੋ',
        'voiceNoteSection': 'ਵੌਇਸ ਨੋਟ',
    },
}

import re

def add_keys_to_lang_block(content, lang, keys_dict):
    # Find the lang block
    lang_marker = f"'{lang}': {{"
    idx = content.find(lang_marker)
    if idx == -1:
        print(f"WARNING: Language block '{lang}' not found!")
        return content
    
    # Insert after the opening brace
    insert_pos = idx + len(lang_marker)
    new_entries = ''
    for key, val in keys_dict.items():
        if f"'{key}'" not in content[idx:idx+50000]:  # check within reasonable bounds of this block
            escaped = val.replace("'", "\\'")
            new_entries += f"\n      '{key}': '{escaped}',"
    
    if new_entries:
        content = content[:insert_pos] + new_entries + content[insert_pos:]
        print(f"  Added {len(keys_dict)} keys to '{lang}' block")
    else:
        print(f"  Keys already exist in '{lang}' block - skipping")
    
    return content

for lang, keys in new_keys.items():
    content = add_keys_to_lang_block(content, lang, keys)

with open('lib/l10n/app_localizations.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('\nDone! Voice note translations added to all language blocks.')
