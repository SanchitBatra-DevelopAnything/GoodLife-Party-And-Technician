import json

file_path = 'lib/l10n/app_localizations.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

translations = {
    'en': {
        'serviceComplaintTab': 'Service/Complaint',
        'rateTechnician': 'Rate Your Technician',
        'rateTechnicianOptional': 'Optional — share your experience with the technician who served you.',
        'ratingCommentHint': 'Add a comment (optional)',
        'submitRating': 'Submit Rating',
        'submittingRating': 'Submitting...',
        'ratingSubmitted': 'Rating submitted',
        'ratingThankYou': 'Thank you for your feedback!',
        'yourRating': 'Your Rating',
        'ratingStars': '{count} out of 5 stars',
    },
    'hi': {
        'serviceComplaintTab': 'सेवा/शिकायत',
        'rateTechnician': 'अपने तकनीशियन को रेट करें',
        'rateTechnicianOptional': 'वैकल्पिक — अपनी सेवा देने वाले तकनीशियन के साथ अपना अनुभव साझा करें।',
        'ratingCommentHint': 'एक टिप्पणी जोड़ें (वैकल्पिक)',
        'submitRating': 'रेटिंग सबमिट करें',
        'submittingRating': 'सबमिट किया जा रहा है...',
        'ratingSubmitted': 'रेटिंग सबमिट की गई',
        'ratingThankYou': 'आपकी प्रतिक्रिया के लिए धन्यवाद!',
        'yourRating': 'आपकी रेटिंग',
        'ratingStars': '5 में से {count} स्टार',
    },
    'bn': {
        'serviceComplaintTab': 'পরিষেবা/অভিযোগ',
        'rateTechnician': 'আপনার টেকনিশিয়ানকে রেট দিন',
        'rateTechnicianOptional': 'ঐচ্ছিক — আপনাকে পরিষেবা প্রদানকারী টেকনিশিয়ানের সাথে আপনার অভিজ্ঞতা শেয়ার করুন।',
        'ratingCommentHint': 'একটি মন্তব্য যোগ করুন (ঐচ্ছিক)',
        'submitRating': 'রেটিং জমা দিন',
        'submittingRating': 'জমা দেওয়া হচ্ছে...',
        'ratingSubmitted': 'রেটিং জমা দেওয়া হয়েছে',
        'ratingThankYou': 'আপনার মতামতের জন্য ধন্যবাদ!',
        'yourRating': 'আপনার রেটিং',
        'ratingStars': '৫ এর মধ্যে {count} স্টার',
    },
    'mr': {
        'serviceComplaintTab': 'सेवा/तक्रार',
        'rateTechnician': 'तुमच्या तंत्रज्ञाला रेट करा',
        'rateTechnicianOptional': 'पर्यायी — तुम्हाला सेवा देणाऱ्या तंत्रज्ञासोबत तुमचा अनुभव शेअर करा.',
        'ratingCommentHint': 'टिप्पणी जोडा (पर्यायी)',
        'submitRating': 'रेटिंग सबमिट करा',
        'submittingRating': 'सबमिट करत आहे...',
        'ratingSubmitted': 'रेटिंग सबमिट केले',
        'ratingThankYou': 'तुमच्या अभिप्रायाबद्दल धन्यवाद!',
        'yourRating': 'तुमचे रेटिंग',
        'ratingStars': '५ पैकी {count} स्टार',
    },
    'te': {
        'serviceComplaintTab': 'సేవ/ఫిర్యాదు',
        'rateTechnician': 'మీ టెక్నీషియన్‌కు రేటింగ్ ఇవ్వండి',
        'rateTechnicianOptional': 'ఐచ్ఛికం — మీకు సేవ చేసిన టెక్నీషియన్‌తో మీ అనుభవాన్ని పంచుకోండి.',
        'ratingCommentHint': 'వ్యాఖ్యను జోడించండి (ఐచ్ఛికం)',
        'submitRating': 'రేటింగ్‌ను సమర్పించండి',
        'submittingRating': 'సమర్పిస్తోంది...',
        'ratingSubmitted': 'రేటింగ్ సమర్పించబడింది',
        'ratingThankYou': 'మీ అభిప్రాయానికి ధన్యవాదాలు!',
        'yourRating': 'మీ రేటింగ్',
        'ratingStars': '5 కి {count} నక్షత్రాలు',
    },
    'ta': {
        'serviceComplaintTab': 'சேவை/புகார்',
        'rateTechnician': 'உங்கள் தொழில்நுட்ப நிபுணரை மதிப்பிடுங்கள்',
        'rateTechnicianOptional': 'விருப்பம் — உங்களுக்கு சேவையளித்த தொழில்நுட்ப நிபுணருடன் உங்கள் அனுபவத்தைப் பகிரவும்.',
        'ratingCommentHint': 'கருத்தைச் சேர்க்கவும் (விருப்பம்)',
        'submitRating': 'மதிப்பீட்டைச் சமர்ப்பிக்கவும்',
        'submittingRating': 'சமர்ப்பிக்கிறது...',
        'ratingSubmitted': 'மதிப்பீடு சமர்ப்பிக்கப்பட்டது',
        'ratingThankYou': 'உங்கள் கருத்துக்கு நன்றி!',
        'yourRating': 'உங்கள் மதிப்பீடு',
        'ratingStars': '5 இல் {count} நட்சத்திரங்கள்',
    },
    'kn': {
        'serviceComplaintTab': 'ಸೇವೆ/ದೂರು',
        'rateTechnician': 'ನಿಮ್ಮ ತಂತ್ರಜ್ಞರನ್ನು ರೇಟ್ ಮಾಡಿ',
        'rateTechnicianOptional': 'ಐಚ್ಛಿಕ — ನಿಮಗೆ ಸೇವೆ ಸಲ್ಲಿಸಿದ ತಂತ್ರಜ್ಞರೊಂದಿಗೆ ನಿಮ್ಮ ಅನುಭವವನ್ನು ಹಂಚಿಕೊಳ್ಳಿ.',
        'ratingCommentHint': 'ಕಾಮೆಂಟ್ ಸೇರಿಸಿ (ಐಚ್ಛಿಕ)',
        'submitRating': 'ರೇಟಿಂಗ್ ಸಲ್ಲಿಸಿ',
        'submittingRating': 'ಸಲ್ಲಿಸಲಾಗುತ್ತಿದೆ...',
        'ratingSubmitted': 'ರೇಟಿಂಗ್ ಸಲ್ಲಿಸಲಾಗಿದೆ',
        'ratingThankYou': 'ನಿಮ್ಮ ಪ್ರತಿಕ್ರಿಯೆಗಾಗಿ ಧನ್ಯವಾದಗಳು!',
        'yourRating': 'ನಿಮ್ಮ ರೇಟಿಂಗ್',
        'ratingStars': '5 ರಲ್ಲಿ {count} ನಕ್ಷತ್ರಗಳು',
    },
    'or': {
        'serviceComplaintTab': 'ସେବା/ଅଭିଯୋଗ',
        'rateTechnician': 'ଆପଣଙ୍କର ଟେକ୍ନିସିଆନ୍‌ଙ୍କୁ ରେଟ୍ କରନ୍ତୁ',
        'rateTechnicianOptional': 'ଇଚ୍ଛାଧୀନ — ଆପଣଙ୍କୁ ସେବା ପ୍ରଦାନ କରିଥିବା ଟେକ୍ନିସିଆନ୍‌ଙ୍କ ସହିତ ଆପଣଙ୍କର ଅଭିଜ୍ଞତା ସେୟାର କରନ୍ତୁ।',
        'ratingCommentHint': 'ଏକ ମନ୍ତବ୍ୟ ଯୋଡନ୍ତୁ (ଇଚ୍ଛାଧୀନ)',
        'submitRating': 'ରେଟିଂ ଦାଖଲ କରନ୍ତୁ',
        'submittingRating': 'ଦାଖଲ କରୁଛି...',
        'ratingSubmitted': 'ରେଟିଂ ଦାଖଲ କରାଯାଇଛି',
        'ratingThankYou': 'ଆପଣଙ୍କର ମତାମତ ପାଇଁ ଧନ୍ୟବାଦ!',
        'yourRating': 'ଆପଣଙ୍କର ରେଟିଂ',
        'ratingStars': '5 ରୁ {count} ଷ୍ଟାର୍',
    },
    'ml': {
        'serviceComplaintTab': 'സേവനം/പരാതി',
        'rateTechnician': 'നിങ്ങളുടെ ടെക്നീഷ്യനെ റേറ്റുചെയ്യുക',
        'rateTechnicianOptional': 'ഓപ്ഷണൽ — നിങ്ങളെ സേവിച്ച ടെക്നീഷ്യനുമായുള്ള നിങ്ങളുടെ അനുഭവം പങ്കിടുക.',
        'ratingCommentHint': 'ഒരു അഭിപ്രായം ചേർക്കുക (ഓപ്ഷണൽ)',
        'submitRating': 'റേറ്റിംഗ് സമർപ്പിക്കുക',
        'submittingRating': 'സമർപ്പിക്കുന്നു...',
        'ratingSubmitted': 'റേറ്റിംഗ് സമർപ്പിച്ചു',
        'ratingThankYou': 'നിങ്ങളുടെ ഫീഡ്‌ബാക്കിന് നന്ദി!',
        'yourRating': 'നിങ്ങളുടെ റേറ്റിംഗ്',
        'ratingStars': '5 ൽ {count} നക്ഷത്രങ്ങൾ',
    },
    'pa': {
        'serviceComplaintTab': 'ਸੇਵਾ/ਸ਼ਿਕਾਇਤ',
        'rateTechnician': 'ਆਪਣੇ ਟੈਕਨੀਸ਼ੀਅਨ ਨੂੰ ਰੇਟ ਕਰੋ',
        'rateTechnicianOptional': 'ਵਿਕਲਪਿਕ — ਆਪਣੀ ਸੇਵਾ ਕਰਨ ਵਾਲੇ ਟੈਕਨੀਸ਼ੀਅਨ ਨਾਲ ਆਪਣਾ ਅਨੁਭਵ ਸਾਂਝਾ ਕਰੋ।',
        'ratingCommentHint': 'ਇੱਕ ਟਿੱਪਣੀ ਸ਼ਾਮਲ ਕਰੋ (ਵਿਕਲਪਿਕ)',
        'submitRating': 'ਰੇਟਿੰਗ ਦਰਜ ਕਰੋ',
        'submittingRating': 'ਦਰਜ ਕਰ ਰਿਹਾ ਹੈ...',
        'ratingSubmitted': 'ਰੇਟਿੰਗ ਦਰਜ ਕੀਤੀ ਗਈ',
        'ratingThankYou': 'ਤੁਹਾਡੇ ਫੀਡਬੈਕ ਲਈ ਧੰਨਵਾਦ!',
        'yourRating': 'ਤੁਹਾਡੀ ਰੇਟਿੰਗ',
        'ratingStars': '5 ਵਿੱਚੋਂ {count} ਸਟਾਰ',
    }
}

new_lines = []
current_locale = None
current_locale_block_lines = []

for i, line in enumerate(lines):
    # Detect start of a locale map, e.g. "    'en': {\n"
    if line.strip().startswith("'") and "': {" in line:
        current_locale = line.split("'")[1]
        current_locale_block_lines = []
    
    if current_locale:
        current_locale_block_lines.append(line)

    # Check if we are at the end of the locale map
    if current_locale and line.strip() == "}," or (line.strip() == "}" and current_locale == 'pa'):
        if current_locale in translations:
            block = "".join(current_locale_block_lines)
            for key, val in translations[current_locale].items():
                if f"'{key}':" not in block:
                    new_lines.append(f"      '{key}': '{val}',\n")
        current_locale = None
        current_locale_block_lines = []

    new_lines.append(line)

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print('Updated translations in app_localizations.dart correctly')
