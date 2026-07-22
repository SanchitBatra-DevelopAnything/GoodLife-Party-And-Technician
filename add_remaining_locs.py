import re
import os

file_path = 'lib/l10n/app_localizations.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

getters = '''  String errorPlayingAudio(String error) => _translate('errorPlayingAudio', {'error': error});
  String get failedToSubmitRating => _translate('failedToSubmitRating');
  String get refresh => _translate('refresh');'''

# Insert the getters right before _localizedValues
if 'String get refresh =>' not in content:
    content = re.sub(
        r'(  // Getters\r?\n.*?)(?=\r?\n  static const Map<String, Map<String, String>> _localizedValues)',
        r'\1\n' + getters,
        content,
        flags=re.DOTALL
    )

translations = {
    'en': {
        'errorPlayingAudio': 'Error playing audio: {error}',
        'failedToSubmitRating': 'Failed to submit rating. Please try again.',
        'refresh': 'Refresh',
    },
    'hi': {
        'errorPlayingAudio': 'ऑडियो चलाने में त्रुटि: {error}',
        'failedToSubmitRating': 'रेटिंग सबमिट करने में विफल। कृपया पुनः प्रयास करें।',
        'refresh': 'रीफ्रेश करें',
    },
    'bn': {
        'errorPlayingAudio': 'অডিও চালাতে ত্রুটি: {error}',
        'failedToSubmitRating': 'রেটিং জমা দিতে ব্যর্থ। আবার চেষ্টা করুন।',
        'refresh': 'রিফ্রেশ',
    },
    'mr': {
        'errorPlayingAudio': 'ऑडिओ प्ले करण्यात त्रुटी: {error}',
        'failedToSubmitRating': 'रेटिंग सबमिट करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.',
        'refresh': 'रिफ्रेश करा',
    },
    'te': {
        'errorPlayingAudio': 'ఆడియో ప్లే చేయడంలో లోపం: {error}',
        'failedToSubmitRating': 'రేటింగ్‌ను సమర్పించడంలో విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.',
        'refresh': 'రిఫ్రెష్ చేయండి',
    },
    'ta': {
        'errorPlayingAudio': 'ஆடியோவை இயக்குவதில் பிழை: {error}',
        'failedToSubmitRating': 'மதிப்பீட்டைச் சமர்ப்பிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.',
        'refresh': 'புதுப்பி',
    },
    'gu': {
        'errorPlayingAudio': 'ઑડિયો ચલાવવામાં ભૂલ: {error}',
        'failedToSubmitRating': 'રેટિંગ સબમિટ કરવામાં નિષ્ફળ. કૃપા કરીને ફરી પ્રયાસ કરો.',
        'refresh': 'રિફ્રેશ કરો',
    },
    'kn': {
        'errorPlayingAudio': 'ಆಡಿಯೊ ಪ್ಲೇ ಮಾಡುವಾಗ ದೋಷ: {error}',
        'failedToSubmitRating': 'ರೇಟಿಂಗ್ ಸಲ್ಲಿಸಲು ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.',
        'refresh': 'ರಿಫ್ರೆಶ್ ಮಾಡಿ',
    },
    'or': {
        'errorPlayingAudio': 'ଅଡିଓ ଚଲାଇବାରେ ତ୍ରୁଟି: {error}',
        'failedToSubmitRating': 'ରେଟିଂ ଦାଖଲ କରିବାରେ ବିଫଳ | ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ |',
        'refresh': 'ରିଫ୍ରେସ୍ କରନ୍ତୁ',
    },
    'ml': {
        'errorPlayingAudio': 'ഓഡിയോ പ്ലേ ചെയ്യുന്നതിൽ പിശക്: {error}',
        'failedToSubmitRating': 'റേറ്റിംഗ് സമർപ്പിക്കുന്നതിൽ പരാജയപ്പെട്ടു. വീണ്ടും ശ്രമിക്കുക.',
        'refresh': 'റിഫ്രഷ് ചെയ്യുക',
    },
    'pa': {
        'errorPlayingAudio': 'ਆਡੀਓ ਚਲਾਉਣ ਵਿੱਚ ਗਲਤੀ: {error}',
        'failedToSubmitRating': 'ਰੇਟਿੰਗ ਦਰਜ ਕਰਨ ਵਿੱਚ ਅਸਫਲ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।',
        'refresh': 'ਰੀਫ੍ਰੈਸ਼ ਕਰੋ',
    }
}

def inject_translations(match):
    locale = match.group(1)
    existing_content = match.group(2)
    
    if locale in translations:
        inserts = []
        for key, val in translations[locale].items():
            if f"'{key}':" not in existing_content:
                inserts.append(f"      '{key}': '{val}',")
        
        if inserts:
            last_brace_index = existing_content.rfind('}')
            new_content = existing_content[:last_brace_index] + '\\n' + '\\n'.join(inserts) + '\\n    }'
            return f"'{locale}': {{{new_content}"
    return match.group(0)

pattern = r"'([a-z]{2})': \{([^}]+?)\n    \}"
content = re.sub(pattern, inject_translations, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Done')
