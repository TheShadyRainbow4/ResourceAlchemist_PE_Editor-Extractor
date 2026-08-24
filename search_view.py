import json

path = r'C:\Users\Administrator\.gemini\antigravity-cli\brain\c4bc0fea-70d1-411c-885c-ce63ff647b35\.system_generated\logs\transcript_full.jsonl'
with open(path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            step = json.loads(line)
            if 'tool_responses' in step:
                for tr in step['tool_responses']:
                    if tr['name'] == 'default_api:view_file':
                        output = tr.get('output', '')
                        if 'ResourceAlchemyHacker_GUI\\\\main.cpp' in step.get('content', '') or 'main.cpp' in output:
                            print(f"Found view_file output size: {len(output)}")
                            with open('view_file_output.txt', 'w', encoding='utf-8') as out:
                                out.write(output)
        except:
            pass
