import sys
sys.stdout.reconfigure(encoding='utf-8')
import json
import os

from data_kindergarten import kindergarten_chapters
from data_cbse_primary import cbse_primary_chapters
from data_cbse_middle import cbse_middle_chapters
from data_icse_primary import icse_primary_chapters
from data_icse_middle import icse_middle_chapters
from data_icse_class7_8 import icse_class7_8_chapters

from data_cbse_class4_5 import cbse_class4_5_chapters

# Combine all lists
all_raw = []
all_raw.extend(kindergarten_chapters)
all_raw.extend(cbse_primary_chapters)
all_raw.extend(cbse_class4_5_chapters)
all_raw.extend(cbse_middle_chapters)
all_raw.extend(icse_primary_chapters)
all_raw.extend(icse_middle_chapters)
all_raw.extend(icse_class7_8_chapters)

final_chapters = []
seen_ids = set()

for ch in all_raw:
    board = ch.get('board', 'cbse').lower()
    grade = ch.get('grade', 'Class 1')
    num = ch.get('chapterNumber', 1)
    title = ch.get('title', 'Untitled')

    clean_grade = grade.lower().replace(' ', '')
    if board == 'all':
        cid = f"{clean_grade}_ch{num:02d}"
    else:
        cid = f"{board}_{clean_grade}_ch{num:02d}"
    
    # Avoid duplicate IDs
    base_cid = cid
    idx = 1
    while cid in seen_ids:
        cid = f"{base_cid}_{idx}"
        idx += 1
    seen_ids.add(cid)

    # Validate exampleQuestion & answer
    ex_q = ch.get('exampleQuestion', '')
    ex_ans = ch.get('exampleAnswer', '')
    if not ex_q or len(ex_q) < 15 or ex_q.lower().endswith('problem:') or ex_ans in ['Correct!', 'Correct', '']:
        print(f"WARNING: Incomplete example in {board.upper()} {grade} Ch {num}: {title}")

    final_obj = {
        "chapterId": cid,
        "chapterNumber": num,
        "title": title,
        "grade": grade,
        "board": board,
        "icon": ch.get('icon', '📖'),
        "description": ch.get('description', f"Explore {title} in {grade} ({board.upper()})"),
        "keyConcepts": ch.get('keyConcepts', [title]),
        "rules": ch.get('rules', []),
        "exampleQuestion": ex_q,
        "exampleExplanation": ch.get('exampleExplanation', ''),
        "exampleAnswer": ex_ans,
        "funFact": ch.get('funFact', ''),
        "mascotAdvice": ch.get('mascotAdvice', ''),
        "activityIds": ch.get('activityIds', [])
    }
    final_chapters.append(final_obj)

print(f"\nTotal assembled chapters: {len(final_chapters)}")

# Print breakdown by board and class
breakdown = {}
for c in final_chapters:
    k = (c['board'], c['grade'])
    breakdown.setdefault(k, []).append(c)

for (b, g), clist in sorted(breakdown.items()):
    print(f"[{b.upper()}] {g}: {len(clist)} chapters (Sample: Ch 1 '{clist[0]['title']}', Ch 2 '{clist[1]['title'] if len(clist)>1 else ''}')")

# Write to assets/curriculum/chapters_data.json
out_path = r'assets/curriculum/chapters_data.json'
with open(out_path, 'w', encoding='utf-8') as f:
    json.dump(final_chapters, f, indent=2, ensure_ascii=False)

print(f"\nSaved {len(final_chapters)} authentic chapters successfully to {out_path}!")
