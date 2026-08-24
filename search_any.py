import json
import os

brain_dir = r'C:\Users\Administrator\.gemini\antigravity-cli\brain'
best_content = ""
best_size = 0
best_path = ""

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
                                    name = tc['name']
                                    if 'write' in name or 'replace' in name:
                                        args = tc.get('arguments', {})
                                        if 'main.cpp' in str(args):
                                            if 'CodeContent' in args:
                                                content = args['CodeContent']
                                                if len(content) > best_size:
                                                    best_size = len(content)
                                                    best_content = content
                                                    best_path = path
                                            elif 'ReplacementContent' in args:
                                                content = args['ReplacementContent']
                                                if len(content) > best_size:
                                                    best_size = len(content)
                                                    best_content = content
                                                    best_path = path
                except Exception as e:
                    pass

if best_content:
    with open(r'C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\ResourceAlchemyHacker_GUI\main_recovered.cpp', 'w', encoding='utf-8') as out:
        out.write(best_content)
    print(f"Recovered size {best_size} from {best_path}")
else:
    print("Not found.")
