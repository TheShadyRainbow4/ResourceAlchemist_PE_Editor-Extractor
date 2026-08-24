import json
import os

path = r'C:\Users\Administrator\.gemini\antigravity-cli\brain\f70dc7de-a2db-4107-a3fb-1d9774cbcd80\.system_generated\logs\transcript_full.jsonl'
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
                            print(f"Found write_to_file main.cpp, size: {len(best_content)}")
                    elif tc['name'] == 'default_api:replace_file_content':
                        args = tc.get('arguments', {})
                        if 'main.cpp' in args.get('TargetFile', ''):
                            target = args.get('TargetContent', '')
                            rep = args.get('ReplacementContent', '')
                            if best_content and target in best_content:
                                best_content = best_content.replace(target, rep)
                                print("Applied replace_file_content")
                    elif tc['name'] == 'default_api:multi_replace_file_content':
                        args = tc.get('arguments', {})
                        if 'main.cpp' in args.get('TargetFile', ''):
                            if best_content:
                                for chunk in args.get('ReplacementChunks', []):
                                    target = chunk.get('TargetContent', '')
                                    rep = chunk.get('ReplacementContent', '')
                                    if target in best_content:
                                        best_content = best_content.replace(target, rep)
                                print("Applied multi_replace_file_content")
        except Exception as e:
            pass

if best_content:
    with open(r'ResourceAlchemyHacker_GUI\main.cpp', 'w', encoding='utf-8') as out:
        out.write(best_content)
    print(f"Recovered main.cpp! Final size: {len(best_content)}")
else:
    print("Not found in old transcript either.")
