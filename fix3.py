import re

file_path = 'lib/l10n/app_localizations.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add customInquiry back if it's missing
if "String get customInquiry" not in content:
    content = re.sub(
        r'(  static const Map<String, Map<String, String>> _localizedValues = \{)', 
        r"  String get customInquiry => _translate('customInquiry');\n\1", 
        content
    )

# Now manually delete the exact duplicate lines from the string
# The lines are exactly:
#       'statusClosedByTechnician': 'तकनीशियन द्वारा बंद किया गया',
#       'paidByCash': 'नकद भुगतान किया गया',
#       'paidByUpi': 'UPI द्वारा भुगतान किया गया',

duplicate_lines = [
    "      'statusClosedByTechnician': 'तकनीशियन द्वारा बंद किया गया',",
    "      'paidByCash': 'नकद भुगतान किया गया',",
    "      'paidByUpi': 'UPI द्वारा भुगतान किया गया',"
]

for dup_line in duplicate_lines:
    # Find all occurrences of the line
    occurrences = [m.start() for m in re.finditer(re.escape(dup_line), content)]
    
    # If there are duplicates, we keep the first one and delete all subsequent ones
    if len(occurrences) > 1:
        print(f"Found {len(occurrences)} occurrences of {dup_line.strip()}, removing duplicates...")
        # To delete them properly, we can split the string or just replace all but first
        # It's easier to just do it via regex substitution with a count
        first_pos = occurrences[0]
        # split into two parts: before the first occurrence (including it), and after
        part1 = content[:first_pos + len(dup_line)]
        part2 = content[first_pos + len(dup_line):]
        
        # replace the remaining occurrences in part2 with empty string
        part2 = part2.replace(dup_line + "\n", "")
        part2 = part2.replace(dup_line, "")
        
        content = part1 + part2

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Done fixing!')
