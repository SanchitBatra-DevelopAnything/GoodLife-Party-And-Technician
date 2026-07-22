import sys
import re
sys.stdout.reconfigure(encoding='utf-8')

with open('lib/l10n/app_localizations.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Lines to remove (1-indexed) - the DUPLICATE occurrences (second appearance)
# Based on check_dupes.py output:
lines_to_remove = {
    572,   # hi - customInquiry (duplicate)
    666,   # bn - statusClosedByTechnician (duplicate)
    667,   # bn - paidByCash (duplicate)
    668,   # bn - paidByUpi (duplicate)
    816,   # mr - statusClosedByTechnician (duplicate)
    817,   # mr - paidByCash (duplicate)
    818,   # mr - paidByUpi (duplicate)
    966,   # te - statusClosedByTechnician (duplicate)
    967,   # te - paidByCash (duplicate)
    968,   # te - paidByUpi (duplicate)
    1116,  # ta - statusClosedByTechnician (duplicate)
    1117,  # ta - paidByCash (duplicate)
    1118,  # ta - paidByUpi (duplicate)
    1266,  # kn - statusClosedByTechnician (duplicate)
    1267,  # kn - paidByCash (duplicate)
    1268,  # kn - paidByUpi (duplicate)
    1416,  # or - statusClosedByTechnician (duplicate)
    1417,  # or - paidByCash (duplicate)
    1418,  # or - paidByUpi (duplicate)
    1566,  # ml - statusClosedByTechnician (duplicate)
    1567,  # ml - paidByCash (duplicate)
    1568,  # ml - paidByUpi (duplicate)
    1716,  # pa - statusClosedByTechnician (duplicate)
    1717,  # pa - paidByCash (duplicate)
    1718,  # pa - paidByUpi (duplicate)
}

# Also add 'customInquiry' to English block and all other language blocks that don't have it yet
# First, let's also add customInquiry to English - find en block's serviceComplaintTab key and add before it
# Also need to add customInquiry for all other languages

new_lines = []
for i, line in enumerate(lines, 1):
    if i not in lines_to_remove:
        new_lines.append(line)

with open('lib/l10n/app_localizations.dart', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print('Removed all duplicate lines successfully!')
print(f'File went from {len(lines)} lines to {len(new_lines)} lines')
