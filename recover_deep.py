import json
import re

paths = [
    r'C:\Users\Administrator\.gemini\antigravity-cli\brain\2e9b556a-f048-43df-9a76-b3d5f818df37\.system_generated\logs\transcript_full.jsonl',
    r'C:\Users\Administrator\.gemini\antigravity-cli\brain\cb64d116-8dfb-46bc-9939-4f0d278f86b3\.system_generated\logs\transcript_full.jsonl',
    r'C:\Users\Administrator\.gemini\antigravity-cli\brain\d1bf936d-79af-4121-b3c9-778a232b38be\.system_generated\logs\transcript_full.jsonl',
    r'C:\Users\Administrator\.gemini\antigravity-cli\brain\ed515fe4-b9f7-40cc-9703-7a454d32b96c\.system_generated\logs\transcript_full.jsonl',
    r'C:\Users\Administrator\.gemini\antigravity-cli\brain\f9ca31a6-013c-41fa-84ae-6dccea2f6d76\.system_generated\logs\transcript_full.jsonl'
]

best_code = ""

def search_dict(d):
    global best_code
    if isinstance(d, dict):
        for k, v in d.items():
            search_dict(v)
    elif isinstance(d, list):
        for item in d:
            search_dict(item)
    elif isinstance(d, str):
        if 'InsetWndProc' in d and 'WM_DRAWITEM' in d:
            if len(d) > len(best_code):
                best_code = d

for p in paths:
    with open(p, 'r', encoding='utf-8') as f:
        for line in f:
            try:
                data = json.loads(line)
                search_dict(data)
            except:
                pass

if best_code:
    with open(r'C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\ResourceAlchemyHacker_GUI\main.cpp', 'w', encoding='utf-8') as out:
        out.write(best_code)
    print(f"Recovered main.cpp! Size: {len(best_code)}")
else:
    print("Could not find full code block.")
