import json, os, time
from deep_translator import GoogleTranslator

import sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'backend')))

strings_to_translate = set([
    "SYMPTOMS", "ROOT CAUSE", "TREATMENT", "PREVENTION", "ECONOMIC IMPACT",
    "Export PDF Report", "Generating PDF Report...",
    "Consult local agricultural officer for specific treatment details."
])

try:
    from disease_info import DISEASE_DATABASE
    for d in DISEASE_DATABASE.values():
        if isinstance(d.get('causes'), str): strings_to_translate.add(d['causes'])
        if isinstance(d.get('favorable_conditions'), str): strings_to_translate.add(d['favorable_conditions'])
        if isinstance(d.get('economic_impact'), str): strings_to_translate.add(d['economic_impact'])
        if isinstance(d.get('urgency'), str): strings_to_translate.add(d['urgency'])
        
        for k in ['symptoms', 'treatment', 'prevention']:
            if isinstance(d.get(k), list):
                for item in d[k]:
                    if isinstance(item, str): strings_to_translate.add(item)
except Exception as e:
    print(f"Dataset load error: {e}")

strings_to_translate = list(strings_to_translate)
print(f"Total strings to auto-translate: {len(strings_to_translate)}")

lang_map = {'kn': 'kn', 'hi': 'hi', 'ta': 'ta', 'ml': 'ml'}
translation_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'mobile_app', 'assets', 'translations'))

for lang_code, g_code in lang_map.items():
    print(f"Translating to {lang_code}...")
    try:
        translator = GoogleTranslator(source='en', target=g_code)
        jpath = os.path.join(translation_dir, f"{lang_code}.json")
        with open(jpath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        new_adds = 0
        for s in strings_to_translate:
            if s not in data:
                try:
                    res = translator.translate(s)
                    data[s] = res
                    new_adds += 1
                except Exception as e:
                    pass
        if new_adds > 0:
            with open(jpath, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
    except Exception as e:
        print(f"Error initializing language {lang_code}: {e}")

jpath = os.path.join(translation_dir, "en.json")
with open(jpath, 'r', encoding='utf-8') as f:
    data = json.load(f)
for s in strings_to_translate:
    if s not in data: data[s] = s
with open(jpath, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Translation script complete!")
