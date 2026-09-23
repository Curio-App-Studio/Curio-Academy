import json
import os

# Build complete, comprehensive curriculum for CBSE and ICSE across all classes
# LKG, UKG, Class 1, Class 2, Class 3, Class 4, Class 5, Class 6, Class 7, Class 8

chapters = []

def add_chapter(board, grade, num, title, icon, desc, concepts, rules, ex_q, ex_exp, ex_ans, fact, advice):
    clean_grade = grade.lower().replace(' ', '')
    clean_board = board.lower()
    ch_id = f"{clean_board}_{clean_grade}_ch{num:02d}"
    if clean_board == 'all':
        ch_id = f"{clean_grade}_ch{num:02d}"
    
    chapters.append({
        "chapterId": ch_id,
        "chapterNumber": num,
        "title": title,
        "grade": grade,
        "board": board.lower(),
        "icon": icon,
        "description": desc,
        "keyConcepts": concepts,
        "rules": rules,
        "exampleQuestion": ex_q,
        "exampleExplanation": ex_exp,
        "exampleAnswer": ex_ans,
        "funFact": fact,
        "mascotAdvice": advice,
        "activityIds": []
    })

print("Compiling curriculum dataset...")
