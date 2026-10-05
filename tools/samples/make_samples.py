"""文字読み取りの確認用の見本画像（架空の医療機関・薬局）。

python3 tools/samples/make_samples.py  →  tools/samples/out/*.jpg
シミュレータで `--dart-define=DEMO_ENTRY=<画像のパス>` を付けて起動すると、
その画像で確認画面が開く（lib/debug/demo_mode.dart）。
"""
import os
from PIL import Image, ImageDraw, ImageFont

OUT = os.path.join(os.path.dirname(__file__), "out")
os.makedirs(OUT, exist_ok=True)
JP = "/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc"
JPB = "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc"
EN = "/System/Library/Fonts/Helvetica.ttc"


def font(path, size):
    return ImageFont.truetype(path, size)


def jp_sheet():
    img = Image.new("RGB", (1240, 1754), "white")
    d = ImageDraw.Draw(img)
    d.text((60, 50), "お薬の説明書", font=font(JPB, 56), fill="black")
    d.text((60, 140), "山田 花子 様", font=font(JP, 36), fill="black")
    d.text((640, 140), "調剤日 令和8年9月30日", font=font(JP, 34), fill="black")
    d.text((60, 200), "処方医療機関 さくら内科クリニック", font=font(JP, 34), fill="black")
    y = 290
    d.line([(60, y), (1180, y)], fill="black", width=3)
    d.text((80, y + 10), "薬の名前", font=font(JPB, 30), fill="black")
    d.text((560, y + 10), "飲み方・効果", font=font(JPB, 30), fill="black")
    d.line([(60, y + 60), (1180, y + 60)], fill="black", width=2)
    meds = [
        ("ロキソプロフェンNa錠60mg「サワイ」", "1回1錠 1日3回 毎食後", "痛みや炎症をおさえるお薬です。"),
        ("レバミピド錠100mg「オーツカ」", "1回1錠 1日3回 毎食後", "胃の粘膜を保護するお薬です。"),
        ("アムロジピンOD錠5mg「トーワ」", "1回1錠 1日1回 朝食後", "血圧を下げるお薬です。"),
        ("モーラステープ20mg", "1日1回 患部に貼付", "痛みをやわらげる貼り薬です。"),
    ]
    y += 90
    for name, how, what in meds:
        d.text((80, y), name, font=font(JPB, 32), fill="black")
        d.text((560, y + 50), how, font=font(JP, 30), fill="black")
        d.text((560, y + 95), what, font=font(JP, 30), fill="black")
        y += 190
        d.line([(60, y - 20), (1180, y - 20)], fill="#999999", width=1)
    d.text((60, 1560), "つばめ薬局 駅前店", font=font(JPB, 36), fill="black")
    d.text((60, 1620), "東京都中央区1-2-3 TEL 03-0000-0000", font=font(JP, 28), fill="black")
    d.text((640, 1560), "次回予約 2026年10月14日", font=font(JP, 30), fill="black")
    img.save(os.path.join(OUT, "jp_sheet.jpg"), quality=90)


def us_label():
    img = Image.new("RGB", (1400, 800), "white")
    d = ImageDraw.Draw(img)
    d.rectangle([(20, 20), (1380, 780)], outline="black", width=4)
    d.text((60, 50), "Maple Street Pharmacy", font=font(EN, 54), fill="black")
    d.text((60, 120), "100 Main St, Springfield  Tel (555) 010-0000", font=font(EN, 30), fill="black")
    d.text((60, 200), "Rx# 7012345      Date Filled: 09/28/2026", font=font(EN, 36), fill="black")
    d.text((60, 260), "JANE SMITH", font=font(EN, 40), fill="black")
    d.text((60, 330), "TAKE 1 CAPSULE BY MOUTH THREE TIMES DAILY", font=font(EN, 38), fill="black")
    d.text((60, 380), "UNTIL ALL TAKEN", font=font(EN, 38), fill="black")
    d.text((60, 470), "AMOXICILLIN 500MG CAPSULE", font=font(EN, 46), fill="black")
    d.text((60, 550), "Qty: 30    Refills: 0", font=font(EN, 34), fill="black")
    d.text((60, 610), "Prescriber: Dr. John Doe", font=font(EN, 34), fill="black")
    d.text((60, 670), "Discard after: 09/28/2027", font=font(EN, 34), fill="black")
    img.save(os.path.join(OUT, "us_label.jpg"), quality=90)


jp_sheet()
us_label()
print(OUT)
