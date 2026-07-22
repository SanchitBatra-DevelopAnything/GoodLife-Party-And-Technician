import re

file_path = r'c:\Users\itsam\Downloads\client-work\GoodLife-Party-And-Technician\lib\l10n\app_localizations.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# English
en_add = '''      'choosePaymentOption': 'Choose Payment Option',
      'paymentProcessingWarning': 'Your order will be processed only after the payment is received and verified.\\n\\nPlease make sure to attach the payment screenshot after completing the payment.',
      'qrCode': 'QR Code',
      'addToCart': 'Add to Cart',
      'orderPlacedSuccessfullyTitle': 'Your order has been placed successfully!',
      'orderPlacedSuccessWithPayment': 'Your payment screenshot has been uploaded successfully.\\n\\nYour order is currently under payment verification.\\nWe will start processing your order once the payment is verified.',
      'orderPlacedSuccessWithoutPayment': 'Your order has been placed successfully.\\n\\nPlease complete your payment soon so that we can start processing your order.\\n\\nPlease contact us to get your payment verified.',
      'continueBtn': 'Continue','''

# Hindi
hi_add = '''      'choosePaymentOption': 'भुगतान विकल्प चुनें',
      'paymentProcessingWarning': 'भुगतान प्राप्त होने और सत्यापित होने के बाद ही आपके आदेश पर कार्रवाई की जाएगी।\\n\\nकृपया भुगतान पूरा करने के बाद भुगतान स्क्रीनशॉट संलग्न करना सुनिश्चित करें।',
      'qrCode': 'QR कोड',
      'addToCart': 'कार्ट में डालें',
      'orderPlacedSuccessfullyTitle': 'आपका आदेश सफलतापूर्वक दे दिया गया है!',
      'orderPlacedSuccessWithPayment': 'आपका भुगतान स्क्रीनशॉट सफलतापूर्वक अपलोड कर दिया गया है।\\n\\nआपका आदेश वर्तमान में भुगतान सत्यापन के अधीन है।\\nभुगतान सत्यापित होने के बाद हम आपके आदेश पर कार्रवाई शुरू करेंगे।',
      'orderPlacedSuccessWithoutPayment': 'आपका आदेश सफलतापूर्वक दे दिया गया है।\\n\\nकृपया अपना भुगतान जल्द पूरा करें ताकि हम आपके आदेश पर कार्रवाई शुरू कर सकें।\\n\\nकृपया अपना भुगतान सत्यापित कराने के लिए हमसे संपर्क करें।',
      'continueBtn': 'जारी रखें','''

# Bengali
bn_add = '''      'choosePaymentOption': 'পেমেন্ট বিকল্প চয়ন করুন',
      'paymentProcessingWarning': 'পেমেন্ট গ্রহণ এবং যাচাই করার পরেই আপনার অর্ডার প্রক্রিয়া করা হবে।\\n\\nপেমেন্ট সম্পূর্ণ করার পরে দয়া করে পেমেন্ট স্ক্রিনশট সংযুক্ত করতে ভুলবেন না।',
      'qrCode': 'QR কোড',
      'addToCart': 'কার্টে যোগ করুন',
      'orderPlacedSuccessfullyTitle': 'আপনার অর্ডার সফলভাবে দেওয়া হয়েছে!',
      'orderPlacedSuccessWithPayment': 'আপনার পেমেন্ট স্ক্রিনশট সফলভাবে আপলোড হয়েছে।\\n\\nআপনার অর্ডারটি বর্তমানে পেমেন্ট যাচাইয়ের অধীনে রয়েছে।\\nপেমেন্ট যাচাই হওয়ার পর আমরা আপনার অর্ডার প্রক্রিয়া শুরু করব।',
      'orderPlacedSuccessWithoutPayment': 'আপনার অর্ডার সফলভাবে দেওয়া হয়েছে।\\n\\nদয়া করে আপনার পেমেন্ট শীঘ্রই সম্পূর্ণ করুন যাতে আমরা আপনার অর্ডার প্রক্রিয়া শুরু করতে পারি।\\n\\nআপনার পেমেন্ট যাচাই করতে দয়া করে আমাদের সাথে যোগাযোগ করুন।',
      'continueBtn': 'চালিয়ে যান','''

# Marathi
mr_add = '''      'choosePaymentOption': 'पेमेंट पर्याय निवडा',
      'paymentProcessingWarning': 'पेमेंट प्राप्त झाल्यानंतर आणि पडताळणी झाल्यानंतरच तुमच्या ऑर्डरवर प्रक्रिया केली जाईल.\\n\\nकृपया पेमेंट पूर्ण केल्यानंतर पेमेंट स्क्रीनशॉट जोडण्याची खात्री करा.',
      'qrCode': 'QR कोड',
      'addToCart': 'कार्टमध्ये जोडा',
      'orderPlacedSuccessfullyTitle': 'तुमची ऑर्डर यशस्वीरित्या दिली गेली आहे!',
      'orderPlacedSuccessWithPayment': 'तुमचा पेमेंट स्क्रीनशॉट यशस्वीरित्या अपलोड झाला आहे.\\n\\nतुमची ऑर्डर सध्या पेमेंट पडताळणी अंतर्गत आहे.\\nपेमेंट पडताळणी झाल्यावर आम्ही तुमच्या ऑर्डरवर प्रक्रिया सुरू करू.',
      'orderPlacedSuccessWithoutPayment': 'तुमची ऑर्डर यशस्वीरित्या दिली गेली:\\n\\nकृपया तुमचे पेमेंट लवकर पूर्ण करा जेणेकरून आम्ही तुमच्या ऑर्डरवर प्रक्रिया सुरू करू शकू.\\n\\nतुमचे पेमेंट पडताळण्यासाठी कृपया आमच्याशी संपर्क साधा.',
      'continueBtn': 'पुढे जा','''

# Telugu
te_add = '''      'choosePaymentOption': 'చెల్లింపు ఎంపికను ఎంచుకోండి',
      'paymentProcessingWarning': 'చెల్లింపు స్వీకరించిన మరియు ధృవీకరించిన తర్వాత మాత్రమే మీ ఆర్డర్ ప్రాసెస్ చేయబడుతుంది.\\n\\nదయచేసి చెల్లింపు పూర్తి చేసిన తర్వాత చెల్లింపు స్క్రీన్‌షాట్‌ను జతచేయాలని నిర్ధారించుకోండి.',
      'qrCode': 'QR కోడ్',
      'addToCart': 'కార్ట్‌కు జోడించండి',
      'orderPlacedSuccessfullyTitle': 'మీ ఆర్డర్ విజయవంతంగా ఉంచబడింది!',
      'orderPlacedSuccessWithPayment': 'మీ చెల్లింపు స్క్రీన్‌షాట్ విజయవంతంగా అప్‌లోడ్ చేయబడింది.\\n\\nమీ ఆర్డర్ ప్రస్తుతం చెల్లింపు ధృవీకరణలో ఉంది.\\nచెల్లింపు ధృవీకరించబడిన తర్వాత మేము మీ ఆర్డర్ ప్రాసెసింగ్‌ను ప్రారంభిస్తాము.',
      'orderPlacedSuccessWithoutPayment': 'మీ ఆర్డర్ విజయవంతంగా ఉంచబడింది.\\n\\nమేము మీ ఆర్డర్ ప్రాసెసింగ్‌ను ప్రారంభించడానికి దయచేసి మీ చెల్లింపును త్వరలో పూర్తి చేయండి.\\n\\nమీ చెల్లింపును ధృవీకరించడానికి దయచేసి మమ్మల్ని సంప్రదించండి.',
      'continueBtn': 'కొనసాగించు','''

# Tamil
ta_add = '''      'choosePaymentOption': 'கட்டண விருப்பத்தைத் தேர்வுசெய்க',
      'paymentProcessingWarning': 'கட்டணம் பெறப்பட்டு சரிபார்க்கப்பட்ட பின்னரே உங்கள் ஆர்டர் செயலாக்கப்படும்.\\n\\nகட்டணத்தை முடித்த பிறகு கட்டண ஸ்கிரீன்ஷாட்டை இணைப்பதை உறுதிசெய்யவும்.',
      'qrCode': 'QR குறியீடு',
      'addToCart': 'கார்ட்டில் சேர்',
      'orderPlacedSuccessfullyTitle': 'உங்கள் ஆர்டர் வெற்றிகரமாக வைக்கப்பட்டுள்ளது!',
      'orderPlacedSuccessWithPayment': 'உங்கள் கட்டண ஸ்கிரீன்ஷாட் வெற்றிகரமாக பதிவேற்றப்பட்டது.\\n\\nஉங்கள் ஆர்டர் தற்போது கட்டண சரிபார்ப்பில் உள்ளது.\\nகட்டணம் சரிபார்க்கப்பட்டதும் உங்கள் ஆர்டரைச் செயலாக்கத் தொடங்குவோம்.',
      'orderPlacedSuccessWithoutPayment': 'உங்கள் ஆர்டர் வெற்றிகரமாக வைக்கப்பட்டுள்ளது.\\n\\nநாங்கள் உங்கள் ஆர்டரைச் செயலாக்கத் தொடங்க, தயவுசெய்து உங்கள் கட்டணத்தை விரைவில் முடிக்கவும்.\\n\\nஉங்கள் கட்டணத்தை சரிபார்க்க தயவுசெய்து எங்களை தொடர்பு கொள்ளவும்.',
      'continueBtn': 'தொடரவும்','''

# Kannada
kn_add = '''      'choosePaymentOption': 'ಪಾವತಿ ಆಯ್ಕೆಯನ್ನು ಆರಿಸಿ',
      'paymentProcessingWarning': 'ಪಾವತಿಯನ್ನು ಸ್ವೀಕರಿಸಿದ ಮತ್ತು ಪರಿಶೀಲಿಸಿದ ನಂತರವೇ ನಿಮ್ಮ ಆದೇಶವನ್ನು ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಲಾಗುತ್ತದೆ.\\n\\nಪಾವತಿಯನ್ನು ಪೂರ್ಣಗೊಳಿಸಿದ ನಂತರ ಪಾವತಿ ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಅನ್ನು ಲಗತ್ತಿಸಲು ಖಚಿತಪಡಿಸಿಕೊಳ್ಳಿ.',
      'qrCode': 'QR ಕೋಡ್',
      'addToCart': 'ಕಾರ್ಟ್‌ಗೆ ಸೇರಿಸಿ',
      'orderPlacedSuccessfullyTitle': 'ನಿಮ್ಮ ಆದೇಶವನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಇರಿಸಲಾಗಿದೆ!',
      'orderPlacedSuccessWithPayment': 'ನಿಮ್ಮ ಪಾವತಿ ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಅನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಅಪ್‌ಲೋಡ್ ಮಾಡಲಾಗಿದೆ.\\n\\nನಿಮ್ಮ ಆದೇಶವು ಪ್ರಸ್ತುತ ಪಾವತಿ ಪರಿಶೀಲನೆಯಲ್ಲಿದೆ.\\nಪಾವತಿ ಪರಿಶೀಲಿಸಿದ ನಂತರ ನಾವು ನಿಮ್ಮ ಆದೇಶವನ್ನು ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಲು ಪ್ರಾರಂಭಿಸುತ್ತೇವೆ.',
      'orderPlacedSuccessWithoutPayment': 'ನಿಮ್ಮ ಆದೇಶವನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಇರಿಸಲಾಗಿದೆ.\\n\\nನಾವು ನಿಮ್ಮ ಆದೇಶವನ್ನು ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಲು ಪ್ರಾರಂಭಿಸಲು ದಯವಿಟ್ಟು ಶೀಘ್ರದಲ್ಲೇ ನಿಮ್ಮ ಪಾವತಿಯನ್ನು ಪೂರ್ಣಗೊಳಿಸಿ.\\n\\nನಿಮ್ಮ ಪಾವತಿಯನ್ನು ಪರಿಶೀಲಿಸಲು ದಯವಿಟ್ಟು ನಮ್ಮನ್ನು ಸಂಪರ್ಕಿಸಿ.',
      'continueBtn': 'ಮುಂದುವರಿಯಿರಿ','''

# Odia
or_add = '''      'choosePaymentOption': 'ଦେୟ ବିକଳ୍ପ ବାଛନ୍ତୁ',
      'paymentProcessingWarning': 'ଦେୟ ପ୍ରାପ୍ତ ଏବଂ ଯାଞ୍ଚ ହେବା ପରେ ହିଁ ଆପଣଙ୍କ ଅର୍ଡର ପ୍ରକ୍ରିୟାକରଣ କରାଯିବ।\\n\\nଦୟାକରି ଦେୟ ସମ୍ପୂର୍ଣ୍ଣ କରିବା ପରେ ଦେୟ ସ୍କ୍ରିନ୍‌ଶଟ୍ ସଂଲଗ୍ନ କରିବାକୁ ନିଶ୍ଚିତ କରନ୍ତୁ।',
      'qrCode': 'QR କୋଡ୍',
      'addToCart': 'କାର୍ଟରେ ଯୋଡନ୍ତୁ',
      'orderPlacedSuccessfullyTitle': 'ଆପଣଙ୍କ ଅର୍ଡର ସଫଳତାର ସହ ଦିଆଯାଇଛି!',
      'orderPlacedSuccessWithPayment': 'ଆପଣଙ୍କ ଦେୟ ସ୍କ୍ରିନ୍‌ଶଟ୍ ସଫଳତାର ସହ ଅପଲୋଡ୍ ହୋଇଛି।\\n\\nଆପଣଙ୍କ ଅର୍ଡର ବର୍ତ୍ତମାନ ଦେୟ ଯାଞ୍ଚ ଅଧୀନରେ ଅଛି।\\nଦେୟ ଯାଞ୍ଚ ହେବା ପରେ ଆମେ ଆପଣଙ୍କ ଅର୍ଡର ପ୍ରକ୍ରିୟାକରଣ ଆରମ୍ଭ କରିବୁ।',
      'orderPlacedSuccessWithoutPayment': 'ଆପଣଙ୍କ ଅର୍ଡର ସଫଳତାର ସହ ଦିଆଯାଇଛି।\\n\\nଦୟାକରି ଆପଣଙ୍କ ଦେୟ ଶୀଘ୍ର ସମ୍ପୂର୍ଣ୍ଣ କରନ୍ତୁ ଯାହାଫଳରେ ଆମେ ଆପଣଙ୍କ ଅର୍ଡର ପ୍ରକ୍ରିୟାକରଣ ଆରମ୍ଭ କରିପାରିବୁ।\\n\\nଆପଣଙ୍କ ଦେୟ ଯାଞ୍ଚ କରିବା ପାଇଁ ଦୟାକରି ଆମ ସହିତ ଯୋଗାଯୋଗ କରନ୍ତୁ।',
      'continueBtn': 'ଜାରି ରଖନ୍ତୁ','''

# Malayalam
ml_add = '''      'choosePaymentOption': 'പേമെന്റ് ഓപ്ഷൻ തിരഞ്ഞെടുക്കുക',
      'paymentProcessingWarning': 'പേമെന്റ് ലഭിച്ച് സ്ഥിരീകരിച്ചതിന് ശേഷം മാത്രമേ നിങ്ങളുടെ ഓർഡർ പ്രോസസ്സ് ചെയ്യുകയുള്ളൂ.\\n\\nപേമെന്റ് പൂർത്തിയാക്കിയ ശേഷം പേമെന്റ് സ്ക്രീൻഷോട്ട് അറ്റാച്ചുചെയ്യാൻ ഉറപ്പാക്കുക.',
      'qrCode': 'QR കോഡ്',
      'addToCart': 'കാർട്ടിലേക്ക് ചേർക്കുക',
      'orderPlacedSuccessfullyTitle': 'നിങ്ങളുടെ ഓർഡർ വിജയകരമായി നൽകി!',
      'orderPlacedSuccessWithPayment': 'നിങ്ങളുടെ പേമെന്റ് സ്ക്രീൻഷോട്ട് വിജയകരമായി അപ്‌ലോഡ് ചെയ്‌തു.\\n\\nനിങ്ങളുടെ ഓർഡർ നിലവിൽ പേമെന്റ് പരിശോധനയിലാണ്.\\nപേമെന്റ് സ്ഥിരീകരിച്ചതിന് ശേഷം ഞങ്ങൾ നിങ്ങളുടെ ഓർഡർ പ്രോസസ്സ് ചെയ്യാൻ തുടങ്ങും.',
      'orderPlacedSuccessWithoutPayment': 'നിങ്ങളുടെ ഓർഡർ വിജയകരമായി നൽകി.\\n\\nഞങ്ങൾ നിങ്ങളുടെ ഓർഡർ പ്രോസസ്സ് ചെയ്യാൻ തുടങ്ങുന്നതിനായി നിങ്ങളുടെ പേമെന്റ് ഉടൻ പൂർത്തിയാക്കുക.\\n\\nനിങ്ങളുടെ പേമെന്റ് പരിശോധിക്കാൻ ദയവായി ഞങ്ങളെ ബന്ധപ്പെടുക.',
      'continueBtn': 'തുടരുക','''

# Punjabi
pa_add = '''      'choosePaymentOption': 'ਭੁਗਤਾਨ ਵਿਕਲਪ ਚੁਣੋ',
      'paymentProcessingWarning': 'ਭੁਗਤਾਨ ਪ੍ਰਾਪਤ ਹੋਣ ਅਤੇ ਤਸਦੀਕ ਹੋਣ ਤੋਂ ਬਾਅਦ ਹੀ ਤੁਹਾਡੇ ਆਰਡਰ \\'ਤੇ ਕਾਰਵਾਈ ਕੀਤੀ ਜਾਵੇਗੀ।\\n\\nਕਿਰਪਾ ਕਰਕੇ ਭੁਗਤਾਨ ਪੂਰਾ ਕਰਨ ਤੋਂ ਬਾਅਦ ਭੁਗਤਾਨ ਸਕ੍ਰੀਨਸ਼ਾਟ ਜੋੜਨਾ ਯਕੀਨੀ ਬਣਾਓ।',
      'qrCode': 'QR ਕੋਡ',
      'addToCart': 'ਕਾਰਟ ਵਿੱਚ ਸ਼ਾਮਲ ਕਰੋ',
      'orderPlacedSuccessfullyTitle': 'ਤੁਹਾਡਾ ਆਰਡਰ ਸਫਲਤਾਪੂਰਵਕ ਦੇ ਦਿੱਤਾ ਗਿਆ ਹੈ!',
      'orderPlacedSuccessWithPayment': 'ਤੁਹਾਡਾ ਭੁਗਤਾਨ ਸਕ੍ਰੀਨਸ਼ਾਟ ਸਫਲਤਾਪੂਰਵਕ ਅਪਲੋਡ ਹੋ ਗਿਆ ਹੈ।\\n\\nਤੁਹਾਡਾ ਆਰਡਰ ਵਰਤਮਾਨ ਵਿੱਚ ਭੁਗਤਾਨ ਤਸਦੀਕ ਅਧੀਨ ਹੈ।\\nਭੁਗਤਾਨ ਤਸਦੀਕ ਹੋਣ ਤੋਂ ਬਾਅਦ ਅਸੀਂ ਤੁਹਾਡੇ ਆਰਡਰ \\'ਤੇ ਕਾਰਵਾਈ ਸ਼ੁਰੂ ਕਰਾਂਗੇ।',
      'orderPlacedSuccessWithoutPayment': 'ਤੁਹਾਡਾ ਆਰਡਰ ਸਫਲਤਾਪੂਰਵਕ ਦੇ ਦਿੱਤਾ ਗਿਆ ਹੈ।\\n\\nਕਿਰਪਾ ਕਰਕੇ ਆਪਣਾ ਭੁਗਤਾਨ ਜਲਦੀ ਪੂਰਾ ਕਰੋ ਤਾਂ ਜੋ ਅਸੀਂ ਤੁਹਾਡੇ ਆਰਡਰ \\'ਤੇ ਕਾਰਵਾਈ ਸ਼ੁਰੂ ਕਰ ਸਕੀਏ।\\n\\nਆਪਣਾ ਭੁਗਤਾਨ ਤਸਦੀਕ ਕਰਵਾਉਣ ਲਈ ਕਿਰਪਾ ਕਰਕੇ ਸਾਡੇ ਨਾਲ ਸੰਪਰਕ ਕਰੋ।',
      'continueBtn': 'ਜਾਰੀ ਰੱਖੋ','''


langs = {
    'en': en_add,
    'hi': hi_add,
    'bn': bn_add,
    'mr': mr_add,
    'te': te_add,
    'ta': ta_add,
    'kn': kn_add,
    'or': or_add,
    'ml': ml_add,
    'pa': pa_add
}

new_content = content
for lang, txt in langs.items():
    # Find the language block start
    start_match = re.search(rf"'{lang}': {{\s*", new_content)
    if start_match:
        start_idx = start_match.end()
        # Find swiftCode inside this block
        swift_match = re.search(r"'swiftCode': [^\n]+\n", new_content[start_idx:])
        if swift_match:
            insert_pos = start_idx + swift_match.end()
            new_content = new_content[:insert_pos] + txt + '\n' + new_content[insert_pos:]

# Add getters
getters = '''  String get choosePaymentOption => _translate('choosePaymentOption');
  String get paymentProcessingWarning => _translate('paymentProcessingWarning');
  String get qrCode => _translate('qrCode');
  String get addToCart => _translate('addToCart');
  String get orderPlacedSuccessfullyTitle => _translate('orderPlacedSuccessfullyTitle');
  String get orderPlacedSuccessWithPayment => _translate('orderPlacedSuccessWithPayment');
  String get orderPlacedSuccessWithoutPayment => _translate('orderPlacedSuccessWithoutPayment');
  String get continueBtn => _translate('continueBtn');
'''
getters_pos = new_content.find('  String get appTitle')
if getters_pos != -1:
    new_content = new_content[:getters_pos] + getters + new_content[getters_pos:]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)
print('Done!')
