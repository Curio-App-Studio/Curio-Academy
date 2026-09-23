import os
from PIL import Image, ImageDraw, ImageFont

def create_feature_graphic():
    width = 1024
    height = 500

    img = Image.new("RGBA", (width, height), (255, 255, 255, 255))
    draw = ImageDraw.Draw(img)

    # Vibrant, warm educational gradient
    for y in range(height):
        t = y / float(height)
        # Soft warm sunrise gradient
        r = int(255 - t * 6)
        g = int(248 - t * 16)
        b = int(242 - t * 26)
        draw.line([(0, y), (width, y)], fill=(r, g, b, 255))

    # Decorative floating circles with soft opacity
    bubbles = [
        (90, 70, 75, (255, 123, 37, 28)),
        (160, 430, 95, (255, 184, 0, 30)),
        (940, 80, 85, (99, 102, 241, 28)),
        (880, 420, 80, (16, 185, 129, 28)),
        (530, 50, 45, (236, 72, 153, 24)),
        (970, 240, 50, (245, 158, 11, 32)),
        (60, 260, 40, (14, 165, 233, 25)),
    ]
    for cx, cy, rad, color in bubbles:
        draw.ellipse([cx - rad, cy - rad, cx + rad, cy + rad], fill=color)

    # Load Curio Logo
    logo_path = "assets/images/curio_logo_transparent.png"
    if not os.path.exists(logo_path):
        logo_path = "assets/images/curio_logo_1024.png"

    if os.path.exists(logo_path):
        logo = Image.open(logo_path).convert("RGBA")
        logo_size = 310
        logo_resized = logo.resize((logo_size, logo_size), Image.Resampling.LANCZOS)
        logo_x = 60
        logo_y = (height - logo_size) // 2
        img.paste(logo_resized, (logo_x, logo_y), logo_resized)

    # Fonts
    def get_font(size, bold=False):
        font_names = [
            "C:\\Windows\\Fonts\\segoeui.ttf",
            "C:\\Windows\\Fonts\\arial.ttf",
            "C:\\Windows\\Fonts\\calibri.ttf"
        ]
        if bold:
            font_names = [
                "C:\\Windows\\Fonts\\segoeuib.ttf",
                "C:\\Windows\\Fonts\\arialbd.ttf",
                "C:\\Windows\\Fonts\\calibrib.ttf"
            ]
        for f in font_names:
            if os.path.exists(f):
                try:
                    return ImageFont.truetype(f, size)
                except Exception:
                    pass
        return ImageFont.load_default()

    font_title = get_font(54, bold=True)
    font_sub = get_font(26, bold=True)
    font_desc = get_font(19, bold=False)
    font_badge = get_font(18, bold=True)
    font_bullets = get_font(18, bold=True)

    text_x = 400

    # Title
    draw.text((text_x, 68), "Curio Academy", font=font_title, fill=(30, 41, 59, 255))
    
    # Subtitle
    draw.text((text_x, 140), "Interactive Math & English Learning", font=font_sub, fill=(234, 88, 12, 255))

    # Description
    draw.text((text_x, 185), "Fun, gamified foundational learning from Pre-K (LKG) to Class 8", font=font_desc, fill=(71, 85, 105, 255))
    draw.text((text_x, 214), "Algorithmic Practice • Phonics • Bubble Pop • Voice TTS Guidance", font=font_desc, fill=(100, 116, 139, 255))

    # Badges (using clean text without missing emoji glyphs)
    badges = [
        ("LKG to Class 8", (254, 243, 199), (180, 83, 9)),
        ("CBSE & ICSE", (224, 231, 255), (67, 56, 202)),
        ("Interactive Bubble Pop", (224, 242, 254), (3, 105, 161)),
        ("100% Kid Safe & Offline", (220, 252, 231), (21, 128, 61)),
    ]

    # Row 1
    b_y = 270
    b_x = text_x
    for text, bg_col, text_col in badges[:2]:
        bbox = font_badge.getbbox(text)
        bw = (bbox[2] - bbox[0]) + 36
        bh = 38
        draw.rounded_rectangle([b_x, b_y, b_x + bw, b_y + bh], radius=19, fill=bg_col)
        # Small colored indicator dot
        draw.ellipse([b_x + 14, b_y + 14, b_x + 24, b_y + 24], fill=text_col)
        draw.text((b_x + 30, b_y + 7), text, font=font_badge, fill=text_col)
        b_x += bw + 14

    # Row 2
    b_y2 = 322
    b_x2 = text_x
    for text, bg_col, text_col in badges[2:]:
        bbox = font_badge.getbbox(text)
        bw = (bbox[2] - bbox[0]) + 36
        bh = 38
        draw.rounded_rectangle([b_x2, b_y2, b_x2 + bw, b_y2 + bh], radius=19, fill=bg_col)
        # Small colored indicator dot
        draw.ellipse([b_x2 + 14, b_y2 + 14, b_x2 + 24, b_y2 + 24], fill=text_col)
        draw.text((b_x2 + 30, b_y2 + 7), text, font=font_badge, fill=text_col)
        b_x2 += bw + 14

    # Feature points with clean bullet dots
    bullet_y1 = 388
    draw.ellipse([text_x, bullet_y1 + 5, text_x + 10, bullet_y1 + 15], fill=(234, 88, 12, 255))
    draw.text((text_x + 20, bullet_y1), "500+ syllabus-matched topics with progressive hints & solutions", font=font_bullets, fill=(30, 41, 59, 255))

    bullet_y2 = 422
    draw.ellipse([text_x, bullet_y2 + 5, text_x + 10, bullet_y2 + 15], fill=(16, 185, 129, 255))
    draw.text((text_x + 20, bullet_y2), "Child-friendly voice narration so non-readers never feel stuck", font=font_bullets, fill=(51, 65, 85, 255))

    # Outer crisp border
    draw.rectangle([0, 0, width - 1, height - 1], outline=(226, 232, 240, 255), width=2)

    os.makedirs("store_listing/graphics", exist_ok=True)
    out_path = "store_listing/graphics/feature_graphic_1024x500.png"
    img.save(out_path, "PNG")
    print(f"Refined Feature graphic saved: {out_path} ({width}x{height})")

if __name__ == "__main__":
    create_feature_graphic()
