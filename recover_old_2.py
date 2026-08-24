import json
import re

path = r'C:\Users\Administrator\.gemini\antigravity-cli\brain\f70dc7de-a2db-4107-a3fb-1d9774cbcd80\.system_generated\logs\transcript_full.jsonl'
best_content = None

with open(path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            step = json.loads(line)
            if 'tool_calls' in step:
                for tc in step['tool_calls']:
                    if tc['name'] == 'default_api:run_command':
                        cmd = tc.get('arguments', {}).get('CommandLine', '')
                        if 'Set-Content' in cmd and 'main.cpp' in cmd:
                            m = re.search(r'\\s*=\s*@"(.*?)["\r\n]*"@\s*.*?Set-Content.*?main\.cpp', cmd, re.DOTALL)
                            if m:
                                print(f"Found Set-Content cmd with size {len(m.group(1))}")
                                if best_content is None or len(m.group(1)) > len(best_content):
                                    best_content = m.group(1)
        except Exception as e:
            pass

if best_content:
    with open(r'ResourceAlchemyHacker_GUI\main.cpp', 'w', encoding='utf-8') as out:
        out.write(best_content)
    print(f"Recovered main.cpp! Final size: {len(best_content)}")
else:
    print("Still not found via Set-Content in old transcript.")
