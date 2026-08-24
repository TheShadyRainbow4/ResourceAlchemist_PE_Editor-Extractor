import json

path = r'C:\Users\Administrator\.gemini\antigravity-cli\brain\c4bc0fea-70d1-411c-885c-ce63ff647b35\.system_generated\logs\transcript_full.jsonl'
with open(path, 'r', encoding='utf-8') as f:
    for line in f:
        if 'main.cpp' in line and 'Set-Content' in line:
            print("Found a Set-Content for main.cpp!")
            # We can't print the whole thing, but we can save it.
