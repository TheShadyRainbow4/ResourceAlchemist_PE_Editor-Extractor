import json
import re

path = r'C:\Users\Administrator\.gemini\antigravity-cli\brain\c4bc0fea-70d1-411c-885c-ce63ff647b35\.system_generated\logs\transcript_full.jsonl'
best_content = None

with open(path, 'r', encoding='utf-8') as f:
    for line in f:
        if 'main.cpp' in line:
            step = json.loads(line)
            if 'tool_calls' in step:
                for tc in step['tool_calls']:
                    if tc['name'] == 'default_api:run_command':
                        cmd = tc.get('arguments', {}).get('CommandLine', '')
                        if 'Set-Content' in cmd and 'main.cpp' in cmd:
                            # Let's find  = @" ... "@
                            m = re.search(r'\ = @"(.*?)["\r\n]*"@\s*.*?Set-Content.*main\.cpp', cmd, re.DOTALL)
                            if m:
                                best_content = m.group(1)
                            else:
                                m = re.search(r'\ = @"(.*?)["\r\n]*"@\s*.*?Out-File.*main\.cpp', cmd, re.DOTALL)
                                if m:
                                    best_content = m.group(1)
            
            # what if it was replace_file_content?
            if 'tool_responses' in step:
                # Can't easily get it from response
                pass

if best_content:
    with open('ResourceAlchemyHacker_GUI/main.cpp', 'w', encoding='utf-8') as out:
        out.write(best_content)
    print("Recovered from Set-Content!")
else:
    print("Still not found.")
