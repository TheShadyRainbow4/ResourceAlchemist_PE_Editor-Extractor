import json
import os

path = r'C:\Users\Administrator\.gemini\antigravity-cli\brain\c4bc0fea-70d1-411c-885c-ce63ff647b35\.system_generated\logs\transcript_full.jsonl'
main_cpp_content = None

with open(path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            step = json.loads(line)
            if 'tool_calls' in step:
                for tc in step['tool_calls']:
                    # Look for write_to_file or edit calls
                    if tc['name'] == 'default_api:write_to_file':
                        args = tc['arguments']
                        if 'main.cpp' in args.get('TargetFile', ''):
                            main_cpp_content = args.get('CodeContent')
                    elif tc['name'] == 'default_api:run_command':
                        args = tc['arguments']
                        cmd = args.get('CommandLine', '')
                        if 'main.cpp' in cmd and 'Set-Content' in cmd:
                            # Might be hard to parse, but let's check
                            pass
            if 'tool_responses' in step:
                for tr in step['tool_responses']:
                    if tr['name'] == 'default_api:run_command':
                        if '156303 main.cpp' in tr.get('output', ''):
                            # just listing
                            pass
                        elif 'Get-Content ResourceAlchemyHacker_GUI\\main.cpp -Raw' in step.get('content', ''):
                            pass
        except Exception as e:
            pass

if main_cpp_content:
    with open('recovered_main.cpp', 'w', encoding='utf-8') as out:
        out.write(main_cpp_content)
    print("Recovered from write_to_file!")
else:
    print("Not found in write_to_file. Need to search deeper.")
