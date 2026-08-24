import json

path = r'C:\Users\Administrator\.gemini\antigravity-cli\brain\c4bc0fea-70d1-411c-885c-ce63ff647b35\.system_generated\logs\transcript_full.jsonl'
best_content = None
best_size = 0

with open(path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            step = json.loads(line)
            if 'tool_responses' in step:
                for tr in step['tool_responses']:
                    if tr['name'] == 'default_api:view_file':
                        output = tr.get('output', '')
                        if 'WM_CREATE' in output and 'HWND' in output:
                            if len(output) > best_size:
                                best_size = len(output)
                                best_content = output
        except:
            pass

if best_content:
    with open('found_view.txt', 'w', encoding='utf-8') as out:
        out.write(best_content)
    print(f"Found view_file output of size {best_size}")
else:
    print("Not found.")
