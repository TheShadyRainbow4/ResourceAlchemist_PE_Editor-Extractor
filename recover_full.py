import json
import os

target_file_path = r'ResourceAlchemyHacker_GUI\main.cpp'
transcript_path = r'C:\Users\Administrator\.gemini\antigravity-cli\brain\c4bc0fea-70d1-411c-885c-ce63ff647b35\.system_generated\logs\transcript_full.jsonl'

# git checkout to reset
os.system(f'git checkout {target_file_path}')

with open(target_file_path, 'r', encoding='utf-8') as f:
    content = f.read()

with open(transcript_path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            step = json.loads(line)
            if 'tool_calls' in step:
                for tc in step['tool_calls']:
                    if tc['name'] == 'default_api:replace_file_content':
                        args = tc.get('arguments', {})
                        if 'main.cpp' in args.get('TargetFile', ''):
                            target_str = args.get('TargetContent', '')
                            rep_str = args.get('ReplacementContent', '')
                            if target_str in content:
                                content = content.replace(target_str, rep_str)
                            else:
                                print("WARNING: target not found in replace_file_content")
                    elif tc['name'] == 'default_api:multi_replace_file_content':
                        args = tc.get('arguments', {})
                        if 'main.cpp' in args.get('TargetFile', ''):
                            for chunk in args.get('ReplacementChunks', []):
                                target_str = chunk.get('TargetContent', '')
                                rep_str = chunk.get('ReplacementContent', '')
                                if target_str in content:
                                    content = content.replace(target_str, rep_str)
                                else:
                                    print("WARNING: target not found in multi_replace_file_content")
        except:
            pass

with open(target_file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print(f"Recovered size: {len(content)}")
