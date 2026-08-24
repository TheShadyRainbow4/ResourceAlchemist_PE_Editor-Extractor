import json
import os
import re

brain_dir = r'C:\Users\Administrator\.gemini\antigravity-cli\brain'
best_content = None
best_size = 0

for root, dirs, files in os.walk(brain_dir):
    for f in files:
        if f == 'transcript_full.jsonl':
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8') as file:
                try:
                    for line in file:
                        if 'main.cpp' in line:
                            step = json.loads(line)
                            if 'tool_calls' in step:
                                for tc in step['tool_calls']:
                                    args = tc.get('arguments', {})
                                    
                                    if 'main.cpp' in str(args):
                                        for key, val in args.items():
                                            if isinstance(val, str) and 'InsetWndProc' in val and 'WM_DRAWITEM' in val:
                                                if len(val) > best_size:
                                                    best_size = len(val)
                                                    best_content = val
                                                    print(f"Found in {tc['name']} arg {key}, size {best_size}")
                                            elif isinstance(val, list):
                                                for chunk in val:
                                                    if isinstance(chunk, dict):
                                                        for k2, v2 in chunk.items():
                                                            if isinstance(v2, str) and 'InsetWndProc' in v2 and 'WM_DRAWITEM' in v2:
                                                                if len(v2) > best_size:
                                                                    best_size = len(v2)
                                                                    best_content = v2
                                                                    print(f"Found in {tc['name']} chunk arg {k2}, size {best_size}")
                except Exception as e:
                    pass

if best_content:
    with open(r'C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\ResourceAlchemyHacker_GUI\main.cpp', 'w', encoding='utf-8') as out:
        out.write(best_content)
    print(f"Recovered main.cpp! Final size: {best_size}")
else:
    print("Not found anywhere in tool args.")
