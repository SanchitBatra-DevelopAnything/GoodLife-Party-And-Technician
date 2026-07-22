import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('lib/l10n/app_localizations.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Translations for describeProductHint across all supported languages
translations = {
    'en': "Describe the product you need — include model, part number, quantity, or any other relevant details...",
    'hi': "जो उत्पाद आपको चाहिए उसे वर्णित करें — मॉडल, पार्ट नंबर, मात्रा या कोई अन्य प्रासंगिक विवरण शामिल करें...",
    'bn': "আপনার প্রয়োজনীয় পণ্যটি বর্ণনা করুন — মডেল, পার্ট নম্বর, পরিমাণ বা অন্য যেকোনো প্রাসঙ্গিক তথ্য অন্তর্ভুক্ত করুন...",
    'mr': "तुम्हाला हवा असलेला उत्पाद वर्णन करा — मॉडेल, पार्ट नंबर, प्रमाण किंवा इतर कोणतीही संबंधित माहिती समाविष्ट करा...",
    'te': "మీకు అవసరమైన ఉత్పత్తిని వివరించండి — మోడల్, పార్ట్ నంబర్, పరిమాణం లేదా ఏదైనా ఇతర సంబంధిత వివరాలు చేర్చండి...",
    'ta': "நீங்கள் தேவைப்படும் தயாரிப்பை விவரிக்கவும் — மாதிரி, பகுதி எண், அளவு அல்லது வேறு ஏதேனும் தொடர்புடைய விவரங்களை சேர்க்கவும்...",
    'kn': "ನಿಮಗೆ ಬೇಕಾದ ಉತ್ಪನ್ನವನ್ನು ವಿವರಿಸಿ — ಮಾದರಿ, ಭಾಗ ಸಂಖ್ಯೆ, ಪ್ರಮಾಣ ಅಥವಾ ಯಾವುದೇ ಇತರ ಸಂಬಂಧಿತ ವಿವರಗಳನ್ನು ಸೇರಿಸಿ...",
    'or': "ଆପଣଙ୍କୁ ଦରକାର ଉତ୍ପାଦ ବର୍ଣ୍ଣନା କରନ୍ତୁ — ମଡେଲ, ପାର୍ଟ ନମ୍ବର, ପରିମାଣ ବା ଅନ୍ୟ ସୂଚନା ଅନ୍ତର୍ଭୁକ୍ତ କରନ୍ତୁ...",
    'ml': "നിങ്ങൾക്ക് ആവശ്യമായ ഉൽ‌പ്പന്നം വിവരിക്കുക — മോഡൽ, പാർട്ട് നമ്പർ, അളവ് അല്ലെങ്കിൽ മറ്റ് പ്രസക്തമായ വിശദാംശങ്ങൾ ഉൾപ്പെടുത്തുക...",
    'pa': "ਜੋ ਉਤਪਾਦ ਤੁਹਾਨੂੰ ਚਾਹੀਦਾ ਹੈ ਉਸਦਾ ਵਰਣਨ ਕਰੋ — ਮਾਡਲ, ਪਾਰਟ ਨੰਬਰ, ਮਾਤਰਾ ਜਾਂ ਕੋਈ ਹੋਰ ਸੰਬੰਧਿਤ ਵੇਰਵੇ ਸ਼ਾਮਲ ਕਰੋ...",
}

key = 'describeProductHint'
added = 0

for lang, val in translations.items():
    lang_marker = f"'{lang}': {{"
    idx = content.find(lang_marker)
    if idx == -1:
        print(f"WARNING: Language block '{lang}' not found!")
        continue

    # Check if key already exists in this block
    # Find next language block to limit search
    next_lang_idx = content.find("': {", idx + len(lang_marker))
    block_content = content[idx:next_lang_idx] if next_lang_idx != -1 else content[idx:]

    if f"'{key}'" in block_content:
        print(f"  '{lang}': key already exists, skipping")
        continue

    # Insert after opening brace
    insert_pos = idx + len(lang_marker)
    escaped = val.replace("'", "\\'")
    entry = f"\n      '{key}': '{escaped}',"
    content = content[:insert_pos] + entry + content[insert_pos:]
    added += 1
    print(f"  '{lang}': added key")

with open('lib/l10n/app_localizations.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print(f'\nDone! Added {added} language entries for "{key}"')
