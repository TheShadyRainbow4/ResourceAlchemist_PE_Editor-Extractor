import json
import os

brain_dir = r'C:\Users\Administrator\.gemini\antigravity-cli\brain'
best_content = None
best_size = 0
best_path = None

for root, dirs, files in os.walk(brain_dir):
    for f in files:
        if f == 'transcript_full.jsonl':
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8') as file:
                try:
                    for line in file:
                        if 'InsetWndProc' in line and 'WM_DRAWITEM' in line:
                            step = json.loads(line)
                            if 'tool_responses' in step:
                                for tr in step['tool_responses']:
                                    if tr['name'] == 'default_api:view_file':
                                        output = tr.get('output', '')
                                        if 'InsetWndProc' in output and 'WM_DRAWITEM' in output:
                                            if len(output) > best_size:
                                                best_size = len(output)
                                                best_content = output
                                                best_path = path
                                                print(f"Found view_file output size {best_size} in {path}")
                                    elif tr['name'] == 'default_api:run_command':
                                        output = tr.get('output', '')
                                        if 'InsetWndProc' in output and 'WM_DRAWITEM' in output:
                                            if len(output) > best_size:
                                                best_size = len(output)
                                                best_content = output
                                                best_path = path
                                                print(f"Found run_command output size {best_size} in {path}")
                except Exception as e:
                    pass

if best_content:
    with open(r'C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\ResourceAlchemyHacker_GUI\main.cpp', 'w', encoding='utf-8') as out:
        out.write(best_content)
    print(f"Recovered main.cpp! Final size: {best_size} from {best_path}")
else:
    print("Not found anywhere in tool responses.")
