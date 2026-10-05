"""アプリアイコン（1024px）を描く。SnapBP と同じ作風で、レンズの中にカプセル薬。

python3 tools/icon/make_icon.py && dart run flutter_launcher_icons
"""
from PIL import Image, ImageDraw

S = 4  # 縮小時のなめらかさのため4倍で描く
W = 1024 * S


def lerp(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


img = Image.new("RGB", (W, W))
d = ImageDraw.Draw(img)
top, bottom = (0x17, 0x9A, 0x82), (0x0A, 0x62, 0x55)
for y in range(W):
    d.line([(0, y), (W, y)], fill=lerp(top, bottom, y / W))


def box(x0, y0, x1, y1):
    return [x0 * S, y0 * S, x1 * S, y1 * S]


white = (255, 255, 255)
# カメラ本体とファインダー
d.rounded_rectangle(box(300, 250, 520, 360), radius=40 * S, fill=white)
d.rounded_rectangle(box(150, 330, 874, 800), radius=110 * S, fill=white)
d.ellipse(box(700, 390, 780, 440), fill=(0xC8, 0xE3, 0xDC))
# レンズ
d.ellipse(box(337, 390, 687, 740), fill=(0x12, 0x86, 0x70))
d.ellipse(box(367, 420, 657, 710), fill=(0x0A, 0x55, 0x49))

# カプセル（斜め）。別画像に描いて回転して重ねる。
cap = Image.new("RGBA", (W, W), (0, 0, 0, 0))
c = ImageDraw.Draw(cap)
cx, cy, half_len, r = 512, 565, 78, 46
left = box(cx - half_len - r, cy - r, cx, cy + r)
right = box(cx, cy - r, cx + half_len + r, cy + r)
c.rounded_rectangle(left, radius=r * S, fill=white)
c.rectangle(box(cx - r, cy - r, cx, cy + r), fill=white)
c.rounded_rectangle(right, radius=r * S, fill=(0xFF, 0xC8, 0x4A))
c.rectangle(box(cx, cy - r, cx + r, cy + r), fill=(0xFF, 0xC8, 0x4A))
cap = cap.rotate(35, center=(cx * S, cy * S), resample=Image.BICUBIC)
img.paste(cap, (0, 0), cap)

img = img.resize((1024, 1024), Image.LANCZOS)
img.save("assets/icon/app_icon.png")
print("assets/icon/app_icon.png")
