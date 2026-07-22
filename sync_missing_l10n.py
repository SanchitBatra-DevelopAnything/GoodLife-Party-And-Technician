"""Sync missing localization keys using batched Google Translate with cache."""
import json
import re
from pathlib import Path

from deep_translator import GoogleTranslator

FILE = Path('lib/l10n/app_localizations.dart')
CACHE_FILE = Path('l10n_translate_cache.json')

LANG_MAP = {
    'hi': 'hi',
    'mr': 'mr',
    'te': 'te',
    'ta': 'ta',
    'gu': 'gu',
    'kn': 'kn',
    'or': 'or',
    'ml': 'ml',
    'pa': 'pa',
}


def load_text() -> str:
    return FILE.read_text(encoding='utf-8')


def extract_locale_dict(content: str, locale: str) -> dict[str, str]:
    pattern = rf"'{locale}': \{{(.*?)\n    \}},"
    match = re.search(pattern, content, re.DOTALL)
    if not match:
        return {}
    return {
        k: v.replace("\\'", "'").replace("\\n", "\n")
        for k, v in re.findall(r"'([^']+)': '((?:\\'|[^'])*)'", match.group(1))
    }


def escape(val: str) -> str:
    return val.replace('\\', '\\\\').replace("'", "\\'").replace('\n', '\\n')


def protect_placeholders(s: str) -> tuple[str, dict[str, str]]:
    tokens: dict[str, str] = {}

    def repl(match: re.Match[str]) -> str:
        token = f'__PH{len(tokens)}__'
        tokens[token] = match.group(0)
        return token

    return re.sub(r'\{[^}]+\}', repl, s), tokens


def restore_placeholders(s: str, tokens: dict[str, str]) -> str:
    for token, original in tokens.items():
        s = s.replace(token, original)
    return s


def load_cache() -> dict[str, str]:
    if CACHE_FILE.exists():
        return json.loads(CACHE_FILE.read_text(encoding='utf-8'))
    return {}


def save_cache(cache: dict[str, str]) -> None:
    CACHE_FILE.write_text(json.dumps(cache, ensure_ascii=False, indent=2), encoding='utf-8')


def translate_batch(values: list[str], target: str, cache: dict[str, str]) -> list[str]:
    results: list[str | None] = [None] * len(values)
    pending_indices: list[int] = []
    pending_texts: list[str] = []
    pending_maps: list[dict[str, str]] = []

    for i, value in enumerate(values):
        cache_key = f'{target}::{value}'
        if cache_key in cache:
            results[i] = cache[cache_key]
            continue
        protected, tokens = protect_placeholders(value)
        pending_indices.append(i)
        pending_texts.append(protected)
        pending_maps.append(tokens)

    if pending_texts:
        try:
            translated = GoogleTranslator(source='en', target=target).translate_batch(pending_texts)
        except Exception:
            translated = pending_texts
        for idx, raw, tokens in zip(pending_indices, translated, pending_maps):
            final = restore_placeholders(raw, tokens)
            results[idx] = final
            cache[f'{target}::{values[idx]}'] = final

    return [r if r is not None else values[i] for i, r in enumerate(results)]


def inject_keys(content: str, locale: str, keys: list[str], en: dict[str, str], cache: dict[str, str]) -> str:
    if not keys:
        return content

    target = LANG_MAP[locale]
    values = [en[k] for k in keys]
    translated = translate_batch(values, target, cache)

    inserts = [
        f"      '{key}': '{escape(val)}',"
        for key, val in zip(keys, translated)
    ]

    marker = f"'{locale}': {{"
    idx = content.find(marker)
    if idx == -1:
        return content
    close_idx = content.find('\n    },', idx)
    if close_idx == -1:
        return content
    return content[:close_idx] + '\n' + '\n'.join(inserts) + content[close_idx:]


def create_locale_block(content: str, locale: str, en: dict[str, str], cache: dict[str, str]) -> str:
    target = LANG_MAP[locale]
    keys = list(en.keys())
    translated = translate_batch([en[k] for k in keys], target, cache)

    lines = [f"    '{locale}': {{"]
    for key, val in zip(keys, translated):
        lines.append(f"      '{key}': '{escape(val)}',")
    lines.append('    },')

    insert_at = content.rfind('  };')
    if insert_at == -1:
        return content
    return content[:insert_at] + '\n'.join(lines) + '\n' + content[insert_at:]


def main() -> None:
    content = load_text()
    cache = load_cache()
    en = extract_locale_dict(content, 'en')

    # Fix placeholder mismatch used by documentNumber getter.
    content = content.replace("'documentNumber': 'Document: {docNo}'", "'documentNumber': 'Document {number}'")
    content = content.replace("'documentNumber': 'दस्तावेज़: {docNo}'", "'documentNumber': 'दस्तावेज़ {number}'")
    content = content.replace("'documentNumber': 'নথি: {docNo}'", "'documentNumber': 'নথি {number}'")

    manual = {
        'hi': {'address': 'पता'},
    }

    for locale, extras in manual.items():
        missing = [k for k in extras if k not in extract_locale_dict(content, locale)]
        if missing:
            inserts = [f"      '{k}': '{escape(extras[k])}'," for k in missing]
            marker = f"'{locale}': {{"
            idx = content.find(marker)
            close_idx = content.find('\n    },', idx)
            content = content[:close_idx] + '\n' + '\n'.join(inserts) + content[close_idx:]

    for locale in LANG_MAP:
        current = extract_locale_dict(content, locale)
        missing = [k for k in en if k not in current]
        print(f'{locale}: missing {len(missing)}')
        if locale == 'gu' and not current:
            content = create_locale_block(content, locale, en, cache)
            save_cache(cache)
            FILE.write_text(content, encoding='utf-8')
            print('  created gu block')
            continue
        if missing:
            content = inject_keys(content, locale, missing, en, cache)
            save_cache(cache)
            FILE.write_text(content, encoding='utf-8')
            print(f'  injected {len(missing)}')

    FILE.write_text(content, encoding='utf-8')
    print('Done.')


if __name__ == '__main__':
    main()
