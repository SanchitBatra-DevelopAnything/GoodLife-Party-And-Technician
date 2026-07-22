with open('lib/l10n/app_localizations.dart', 'r', encoding='utf-8') as f:
    text = f.read()

missing_bn = {
    'afterService': 'পরিষেবার পরে',
    'statusPending': 'অপেক্ষমান',
    'voiceNoteTitle': 'রেকর্ড করা ভয়েস নোট',
    'statusVerified': 'যাচাই করা হয়েছে',
    'statusClosed': 'বন্ধ',
    'technicianLabel': 'টেকনিশিয়ান',
    'address': 'ঠিকানা',
    'paymentLabel': 'পেমেন্ট',
    'submittedPhotos': 'জমা দেওয়া ছবি',
    'statusAssigned': 'নিযুক্ত',
    'invoiceUploadedNotice': 'আপনার চালান অ্যাডমিন দ্বারা আপলোড করা হয়েছে।',
    'typeLabel': 'ধরন',
    'tapToViewInvoice': 'পুরো চালান দেখতে আলতো চাপুন',
    'timeLabel': 'সময়',
    'tapToCopy': 'কপি করতে কোডে আলতো চাপুন',
    'cleaningDone': 'পরিষ্কার করা হয়েছে',
    'paidVia': '{mode} এর মাধ্যমে পেমেন্ট করা হয়েছে',
    'technicianWorkPhotos': 'টেকনিশিয়ানের কাজের ছবি',
    'statusInProgress': 'চলমান',
    'statusResolved': 'সমাধান করা হয়েছে',
    'statusLabel': 'স্ট্যাটাস',
    'serviceDone': 'পরিষেবা সম্পন্ন',
    'statusApproved': 'অনুমোদিত',
    'beforeService': 'পরিষেবার আগে',
    'dateLabel': 'তারিখ',
    'invoiceLabel': 'চালান',
    'areaLabel': 'এলাকা'
}

missing_hi = {
    'paidVia': '{mode} के माध्यम से भुगतान किया गया'
}

for locale, trans in [('bn', missing_bn), ('hi', missing_hi)]:
    search_str = f"'{locale}': {{"
    idx = text.find(search_str)
    if idx != -1:
        end_of_line_idx = text.find('\n', idx)
        if end_of_line_idx != -1:
            inserts = []
            for key, val in trans.items():
                if f"'{key}':" not in text[idx:idx+10000]:  # roughly check if already exists
                    inserts.append(f"      '{key}': '{val}',")
            
            if inserts:
                insert_str = '\n' + '\n'.join(inserts)
                text = text[:end_of_line_idx] + insert_str + text[end_of_line_idx:]

with open('lib/l10n/app_localizations.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("Injected via direct find!")
