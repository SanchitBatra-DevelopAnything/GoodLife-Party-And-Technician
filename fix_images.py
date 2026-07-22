import re

files = [
    r'c:\Users\itsam\Downloads\client-work\GoodLife-Party-And-Technician\lib\widgets\inventory_item.dart',
    r'c:\Users\itsam\Downloads\client-work\GoodLife-Party-And-Technician\lib\widgets\category_item.dart',
]

for file_path in files:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Add errorWidget and placeholder to CachedNetworkImage calls that don't have them
    # For the dialog/fullscreen CachedNetworkImage that only has imageUrl + fit
    pattern = r'(child: CachedNetworkImage\(\s*imageUrl: ([\w.]+),\s*fit: BoxFit\.contain,\s*\))'

    def add_error_widget(m):
        url_var = re.search(r'imageUrl: ([\w.]+),', m.group(1)).group(1)
        return f"""child: {url_var}.isEmpty
                          ? const Center(child: Icon(Icons.image, color: Colors.grey, size: 60))
                          : CachedNetworkImage(
                              imageUrl: {url_var},
                              fit: BoxFit.contain,
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.image_not_supported),
                            )"""

    new_content = re.sub(pattern, add_error_widget, content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

print('Done!')
