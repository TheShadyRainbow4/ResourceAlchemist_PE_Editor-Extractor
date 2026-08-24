import json

path = r'C:\Users\Administrator\.gemini\antigravity-cli\brain\c4bc0fea-70d1-411c-885c-ce63ff647b35\.system_generated\logs\transcript_full.jsonl'
with open(path, 'r', encoding='utf-8') as f:
    for line in f:
        if 'main.cpp' in line and 'Set-Content' in line:
            step = json.loads(line)
            if 'tool_calls' in step:
                for tc in step['tool_calls']:
                    if tc['name'] == 'default_api:run_command':
                        cmd = tc.get('arguments', {}).get('CommandLine', '')
                        if 'Set-Content' in cmd and 'main.cpp' in cmd:
                            with open('found_cmd.txt', 'a', encoding='utf-8') as out:
                                out.write("--- CMD START ---\n")
                                out.write(cmd)
                                out.write("\n--- CMD END ---\n")
