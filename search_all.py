import json

path = r'C:\Users\Administrator\.gemini\antigravity-cli\brain\c4bc0fea-70d1-411c-885c-ce63ff647b35\.system_generated\logs\transcript_full.jsonl'
best_content = None

with open(path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            step = json.loads(line)
            if 'tool_calls' in step:
                for tc in step['tool_calls']:
                    if tc['name'] == 'default_api:write_to_file':
                        args = tc.get('arguments', {})
                        if 'main.cpp' in args.get('TargetFile', ''):
                            best_content = args.get('CodeContent', '')
                            print(f"write_to_file main.cpp, size: {len(best_content)}")
                    elif tc['name'] == 'default_api:replace_file_content':
                        args = tc.get('arguments', {})
                        if 'main.cpp' in args.get('TargetFile', ''):
                            print(f"replace_file_content main.cpp, size of replacement: {len(args.get('ReplacementContent', ''))}")
                    elif tc['name'] == 'default_api:multi_replace_file_content':
                        args = tc.get('arguments', {})
                        if 'main.cpp' in args.get('TargetFile', ''):
                            print(f"multi_replace_file_content main.cpp")
                    elif tc['name'] == 'default_api:run_command':
                        args = tc.get('arguments', {})
                        cmd = args.get('CommandLine', '')
                        if 'main.cpp' in cmd and 'Set-Content' in cmd:
                            print(f"run_command Set-Content main.cpp, cmd length: {len(cmd)}")
                            if len(cmd) > 10000:
                                best_content = cmd
        except Exception as e:
            pass
