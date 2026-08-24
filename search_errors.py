import json

path = r'C:\Users\Administrator\.gemini\antigravity-cli\brain\c4bc0fea-70d1-411c-885c-ce63ff647b35\.system_generated\logs\transcript_full.jsonl'

with open(path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            step = json.loads(line)
            if 'tool_calls' in step:
                for tc in step['tool_calls']:
                    if tc['name'] == 'default_api:write_to_file':
                        print("Found write_to_file:", tc.get('arguments', {}).get('TargetFile'))
                    elif tc['name'] == 'default_api:replace_file_content':
                        print("Found replace_file_content:", tc.get('arguments', {}).get('TargetFile'))
                    elif tc['name'] == 'default_api:multi_replace_file_content':
                        print("Found multi_replace_file_content:", tc.get('arguments', {}).get('TargetFile'))
        except Exception as e:
            print("ERROR parsing JSON line:", e)
