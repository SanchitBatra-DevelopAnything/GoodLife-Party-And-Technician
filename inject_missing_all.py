with open('lib/l10n/app_localizations.dart', 'r', encoding='utf-8') as f:
    text = f.read()

missing_en = {
    'priceEach': 'Price: {price} each',
    'qty': 'Qty: {count}',
    'itemsCountLabel': '{count} Items',
    'itemsCount': '{count} Items',
    'uploadFailed': 'Upload failed: {error}',
    'failedToUploadPayment': 'Failed to upload payment: {error}',
    'dispatchedOnText': 'Dispatched on: {date}',
    'documentNumber': 'Document: {docNo}',
    'uploadingProgress': 'Uploading... {progress}%',
    'photosUploadedCount': '{count} Photos Uploaded',
    'errorPlayingAudio': 'Error playing audio: {error}'
}

missing_hi = {
    'priceEach': 'कीमत: {price} प्रत्येक',
    'qty': 'मात्रा: {count}',
    'itemsCountLabel': '{count} आइटम',
    'itemsCount': '{count} आइटम',
    'uploadFailed': 'अपलोड विफल: {error}',
    'failedToUploadPayment': 'भुगतान अपलोड करने में विफल: {error}',
    'dispatchedOnText': 'इस दिन भेजा गया: {date}',
    'documentNumber': 'दस्तावेज़: {docNo}',
    'uploadingProgress': 'अपलोड हो रहा है... {progress}%',
    'photosUploadedCount': '{count} तस्वीरें अपलोड की गईं',
    'errorPlayingAudio': 'ऑडियो चलाने में त्रुटि: {error}'
}

missing_bn = {
    'priceEach': 'প্রতিটির দাম: {price}',
    'qty': 'পরিমাণ: {count}',
    'itemsCountLabel': '{count} টি আইটেম',
    'itemsCount': '{count} টি আইটেম',
    'uploadFailed': 'আপলোড ব্যর্থ হয়েছে: {error}',
    'failedToUploadPayment': 'পেমেন্ট আপলোড করতে ব্যর্থ: {error}',
    'dispatchedOnText': 'পাঠানো হয়েছে: {date}',
    'documentNumber': 'নথি: {docNo}',
    'uploadingProgress': 'আপলোড হচ্ছে... {progress}%',
    'photosUploadedCount': '{count} টি ছবি আপলোড করা হয়েছে',
    'errorPlayingAudio': 'অডিও চালাতে ত্রুটি: {error}'
}

for locale, trans in [('en', missing_en), ('hi', missing_hi), ('bn', missing_bn)]:
    search_str = f"'{locale}': {{"
    idx = text.find(search_str)
    if idx != -1:
        end_of_line_idx = text.find('\n', idx)
        if end_of_line_idx != -1:
            inserts = []
            for key, val in trans.items():
                if f"'{key}':" not in text[idx:idx+15000]:
                    inserts.append(f"      '{key}': '{val}',")
            
            if inserts:
                insert_str = '\n' + '\n'.join(inserts)
                text = text[:end_of_line_idx] + insert_str + text[end_of_line_idx:]

with open('lib/l10n/app_localizations.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("Injected all missing keys via direct find!")
