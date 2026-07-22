import re

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

translations = {
    'bn': missing_bn,
    'hi': missing_hi
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
new_text = re.sub(pattern, inject_translations, text, flags=re.DOTALL)

with open('lib/l10n/app_localizations.dart', 'w', encoding='utf-8') as f:
    f.write(new_text)

print("Injected missing translations!")
