import json

path = r'C:\Users\Administrator\.gemini\antigravity-cli\brain\c4bc0fea-70d1-411c-885c-ce63ff647b35\.system_generated\logs\transcript_full.jsonl'
with open(path, 'r', encoding='utf-8') as f:
    for line in f:
        if 'replace_file_content' in line:
            print("Found replace_file_content!")
