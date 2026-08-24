import json
import os

path = r'C:\Users\Administrator\.gemini\antigravity-cli\brain\f70dc7de-a2db-4107-a3fb-1d9774cbcd80\.system_generated\logs\transcript_full.jsonl'

with open(path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            step = json.loads(line)
            if 'tool_calls' in step:
                for tc in step['tool_calls']:
                    if tc['name'] == 'default_api:view_file':
                        args = tc.get('arguments', {})
                        if 'main.cpp' in args.get('AbsolutePath', ''):
                            print(f"Found view_file: {args}")
        except:
            pass
