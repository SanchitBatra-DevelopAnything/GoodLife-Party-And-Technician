"""Sync remaining missing localization keys."""
import json
import re
from pathlib import Path

from deep_translator import GoogleTranslator

FILE = Path('lib/l10n/app_localizations.dart')
CACHE_FILE = Path('l10n_translate_cache.json')

LANG_MAP = {'or': 'or', 'ml': 'ml', 'pa': 'pa', 'gu': 'gu'}


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
        chunk_size = 40
        translated_all: list[str] = []
        for start in range(0, len(pending_texts), chunk_size):
            chunk = pending_texts[start:start + chunk_size]
            try:
                translated_all.extend(
                    GoogleTranslator(source='en', target=target).translate_batch(chunk)
                )
            except Exception:
                translated_all.extend(chunk)

        for idx, raw, tokens in zip(pending_indices, translated_all, pending_maps):
            final = restore_placeholders(raw, tokens)
            results[idx] = final
            cache[f'{target}::{values[idx]}'] = final

    return [r if r is not None else values[i] for i, r in enumerate(results)]


def inject_keys(content: str, locale: str, keys: list[str], en: dict[str, str], cache: dict[str, str]) -> str:
    if not keys:
        return content
    target = LANG_MAP[locale]
    translated = translate_batch([en[k] for k in keys], target, cache)
    inserts = [f"      '{key}': '{escape(val)}'," for key, val in zip(keys, translated)]
    marker = f"'{locale}': {{"
    idx = content.find(marker)
    close_idx = content.find('\n    },', idx)
    return content[:close_idx] + '\n' + '\n'.join(inserts) + content[close_idx:]


def main() -> None:
    content = FILE.read_text(encoding='utf-8')
    cache = json.loads(CACHE_FILE.read_text(encoding='utf-8')) if CACHE_FILE.exists() else {}
    en = extract_locale_dict(content, 'en')

    for locale in LANG_MAP:
        current = extract_locale_dict(content, locale)
        missing = [k for k in en if k not in current]
        print(f'{locale}: missing {len(missing)}')
        if missing:
            content = inject_keys(content, locale, missing, en, cache)
            FILE.write_text(content, encoding='utf-8')
            CACHE_FILE.write_text(json.dumps(cache, ensure_ascii=False, indent=2), encoding='utf-8')
            print(f'  injected {len(missing)}')

    print('Done.')


if __name__ == '__main__':
    main()
