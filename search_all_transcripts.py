import json
import os
import glob
import re

brain_dir = r'C:\Users\Administrator\.gemini\antigravity-cli\brain'
best_content = None
best_size = 0

for root, dirs, files in os.walk(brain_dir):
    for f in files:
        if f == 'transcript_full.jsonl':
            path = os.path.join(root, f)
            try:
                with open(path, 'r', encoding='utf-8') as file:
                    for line in file:
                        if 'main.cpp' in line:
                            step = json.loads(line)
                            if 'tool_calls' in step:
                                for tc in step['tool_calls']:
                                    name = tc['name']
                                    args = tc.get('arguments', {})
                                    
                                    if name == 'default_api:write_to_file' and 'main.cpp' in args.get('TargetFile', ''):
                                        c = args.get('CodeContent', '')
                                        if len(c) > best_size:
                                            best_size = len(c)
                                            best_content = c
                                            print(f"Found write_to_file in {path} (size {best_size})")
                                            
                                    elif name == 'default_api:run_command':
                                        cmd = args.get('CommandLine', '')
                                        if 'main.cpp' in cmd and len(cmd) > 1000:
                                            m = re.search(r'\\s*=\s*@"(.*?)["\r\n]*"@\s*.*?Set-Content.*?main\.cpp', cmd, re.DOTALL)
                                            if m:
                                                c = m.group(1)
                                                if len(c) > best_size:
                                                    best_size = len(c)
                                                    best_content = c
                                                    print(f"Found Set-Content in {path} (size {best_size})")
                                            m2 = re.search(r'\\s*=\s*@"(.*?)["\r\n]*"@\s*.*?Out-File.*?main\.cpp', cmd, re.DOTALL)
                                            if m2:
                                                c = m2.group(1)
                                                if len(c) > best_size:
                                                    best_size = len(c)
                                                    best_content = c
                                                    print(f"Found Out-File in {path} (size {best_size})")
                                                    
            except Exception as e:
                pass

if best_content:
    with open(r'C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\ResourceAlchemyHacker_GUI\main.cpp', 'w', encoding='utf-8') as out:
        out.write(best_content)
    print(f"Recovered main.cpp! Final size: {best_size}")
else:
    print("Not found anywhere.")
