#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""اسپرایت ماشین هلیا — از shahin_top فیروزه‌ای: براق‌تر + استرایت سفید مسابقه‌ای"""
from PIL import Image, ImageDraw, ImageFilter, ImageEnhance
import os

SRC = "/home/z/my-project/tizpa/game/assets/sprites/shahin_top.png"
OUT = "/home/z/my-project/tizpa/game/assets/sprites/helia_top.png"

im = Image.open(SRC).convert("RGBA")
# بدنه را کمی روشن‌تر و اشباع‌تر (فیروزه‌ای خالص)
hsv = im.convert("RGBA")
r, g, b, a = hsv.split()
rgb = Image.merge("RGB", (r, g, b))
rgb = ImageEnhance.Color(rgb).enhance(1.28)
rgb = ImageEnhance.Brightness(rgb).enhance(1.10)
r, g, b = rgb.split()
im = Image.merge("RGBA", (r, g, b, a))

w, h = im.size
cx = w // 2
d = ImageDraw.Draw(im, "RGBA")
# دو استرایت سفید موازی در طول ماشین (محور عمودی تصویر = طول ماشین)
stripe_w = max(6, w // 34)
gap = stripe_w + 2
for sx in (cx - gap - stripe_w // 2, cx + gap - stripe_w // 2):
    # از جلوک تا عقب (فقط روی بدنه: آلفای پیکسل‌ها را چک می‌کنیم)
    strip = Image.new("RGBA", im.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(strip)
    sd.rectangle([sx, int(h * 0.06), sx + stripe_w, int(h * 0.94)], fill=(245, 248, 250, 215))
    # ماسک آلفای بدنه تا استرایت روی شیشه/چرخ بیرون نزند... شیشه وسط است؛ استرایت از رویش رد می‌شود = طبیعی
    im = Image.alpha_composite(im, strip)

d = ImageDraw.Draw(im, "RGBA")
# لبه‌ی استرایت‌ها سایه‌ی ظریف
im.save(OUT)
print("helia_top saved", im.size)
