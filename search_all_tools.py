import json
import os
import glob
import re

brain_dir = r'C:\Users\Administrator\.gemini\antigravity-cli\brain'
best_content = None

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
                                    args = tc.get('arguments', {})
                                    if 'write_to_file' in name or 'replace_file_content' in name:
                                        target = args.get('TargetFile', '')
                                        if 'main.cpp' in target:
                                            print(f"FOUND in {path}: {name} -> {target}")
                except Exception as e:
                    pass
