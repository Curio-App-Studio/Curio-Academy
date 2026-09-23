import os
from PIL import Image

artifacts_dir = r"C:\Users\vivek\.gemini\antigravity\brain\c84f467a-bb93-4024-a5e5-d170bef9d128"
output_dir = r"d:\AI Learning\store_listing\graphics\phone_screenshots"
os.makedirs(output_dir, exist_ok=True)

candidates = [
    {
        "file": "curio_home_clean.png",
        "title": "screenshot_1_math_dashboard.png",
        "label": "1. Math Curriculum & Chapter Exploration"
    },
    {
        "file": "screen_english_active_verified.png",
        "title": "screenshot_2_english_dashboard.png",
        "label": "2. English Dual Subject with Phonics & Grammar"
    },
    {
        "file": "curio_circle_correct.png",
        "title": "screenshot_3_interactive_challenge.png",
        "label": "3. Interactive Questions with Instant Feedback & Scratchpad"
    },
    {
        "file": "curio_concept_lesson.png",
        "title": "screenshot_4_chapter_lessons.png",
        "label": "4. Structured Chapter Practice & Teacher Concept Notes"
    },
    {
        "file": "curio_board_switcher.png",
        "title": "screenshot_5_board_and_class_selector.png",
        "label": "5. Multi-Board (CBSE, ICSE, State) & Grade Selector (LKG-Class 8)"
    },
    {
        "file": "screen_english_dashboard.png",
        "title": "screenshot_6_early_learning_practice.png",
        "label": "6. Early Childhood Numeracy & Phonics Practice"
    }
]

for item in candidates:
    src_path = os.path.join(artifacts_dir, item["file"])
    if not os.path.exists(src_path):
        print(f"Missing: {src_path}")
        continue
    
    img = Image.open(src_path).convert("RGB")
    w, h = img.size
    print(f"{item['title']}: {w}x{h} -> {item['label']}")
    
    # Save direct full-res phone screenshot (1080x2340)
    out_path = os.path.join(output_dir, item["title"])
    img.save(out_path, "PNG", optimize=True)

print("All 6 showcase screenshots prepared successfully!")
