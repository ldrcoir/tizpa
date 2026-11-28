#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""gen17_cars — نسل جدید اسپرایت واقع‌گرایانه از بالا (top-down) برای تیز پا.
هدف: ماشین واقعی، نه اسباب‌بازی — شیشه‌ی واضح با بازتاب آسمان، ستون A،
سقف باریک، هایلایت اسپکولار، رینگ، آرک چرخ، رنگ‌های خودرویی ملایم.
ماشین‌ها رو به راست (+X)؛ سوپرسمپل 4x + LANCZOS."""
import os, math, random
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

OUT = os.environ.get("GEN17_OUT", "/tmp/cars17")
SS = 4                      # سوپرسمپل
L = 176                     # طول نهایی
W = 74                      # عرض نهایی — نسبت 2.38:1

def _P(v):
    return v * SS

def body_profile(t, style):
    """پهنای بدنه در طول ماشین t∈[0..1] (جلو=0) — کلاف واقعی خودرورو."""
    if style == "coupe":
        k = [0.42, 0.62, 0.86, 0.96, 1.00, 0.99, 0.97, 0.98, 1.00, 0.95, 0.84, 0.68, 0.48]
    elif style == "sedan":
        k = [0.42, 0.68, 0.90, 0.99, 0.98, 0.96, 0.95, 0.97, 1.00, 0.97, 0.92, 0.75, 0.50]
    elif style == "hatch":
        k = [0.40, 0.70, 0.92, 1.00, 0.97, 0.94, 0.95, 0.98, 1.00, 0.99, 0.97, 0.90, 0.76]
    elif style == "muscle":
        k = [0.50, 0.76, 0.94, 1.00, 0.98, 0.96, 0.96, 0.98, 1.00, 0.98, 0.93, 0.78, 0.56]
    elif style == "van":
        k = [0.58, 0.92, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 0.98, 0.90]
    else:
        k = [0.42, 0.68, 0.90, 0.99, 0.98, 0.96, 0.95, 0.97, 1.00, 0.97, 0.92, 0.75, 0.50]
    x = t * (len(k) - 1)
    i = min(int(x), len(k) - 2)
    f = x - i
    return (k[i] * (1 - f) + k[i + 1] * f)

def _cabin_bounds(style):
    return {"coupe": (0.375, 0.715), "sedan": (0.345, 0.735), "hatch": (0.325, 0.70),
            "muscle": (0.36, 0.70), "van": (0.185, 0.435)}.get(style, (0.345, 0.735))

def make_car(spec):
    rnd = random.Random(spec.get("seed", 7))
    style = spec["style"]
    base = spec["base"]
    dark = spec.get("dark", tuple(int(c * 0.58) for c in base))
    roofc = spec.get("roof", tuple(min(255, int(c * 0.72 + 8)) for c in base))
    cw, ch = _P(L + 30), _P(W + 30)
    img = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    cx, cy = cw / 2, ch / 2
    hl, hw = _P(L), _P(W)

    def px(t):
        return cx - hl / 2 + t * hl

    cab0, cab1 = _cabin_bounds(style)

    # ── بدنه از پروفایل + گرادیان واقعی (مرکز روشن، لبه تیره، اسپکولار مورب)
    N = 96
    top, bot = [], []
    for i in range(N + 1):
        t = i / N
        w = body_profile(t, style) * hw / 2
        top.append((px(t), cy - w))
        bot.append((px(t), cy + w))
    sil = top + bot[::-1]
    mask = Image.new("L", (cw, ch), 0)
    ImageDraw.Draw(mask).polygon(sil, fill=255)
    bm = np.asarray(mask, dtype=np.float32) / 255.0
    ero = np.asarray(mask.filter(ImageFilter.MinFilter(_P(5) + 1)), dtype=np.float32) / 255.0
    edge = np.clip(bm - ero, 0, 1)          # حلقه‌ی لبه‌ی داخلی برای AO
    yy = np.linspace(-1, 1, ch, dtype=np.float32)[:, None]
    xx = np.linspace(-1, 1, cw, dtype=np.float32)[None, :]
    arr = np.zeros((ch, cw, 4), dtype=np.float32)
    for c in range(3):
        col = np.array(base[c], dtype=np.float32)
        lat = 1.0 - 0.52 * (yy ** 2)                                  # گرادیان عرضی قوی
        spec_band = np.clip(1.0 - np.abs(yy + 0.32 - xx * 0.06) * 9.0, 0, 1) * 0.42  # نوار بازتاب آسمان
        lon = 1.0 + 0.10 * np.clip(np.cos(xx * 1.1), 0, 1)            # انحنای کاپوت/صندوق
        nose = 1.0 - 0.18 * np.clip((np.abs(xx) - 0.75) * 4.0, 0, 1)  # دماغه/ته تیره‌تر
        v = (col * lat * lon * nose) + 255.0 * spec_band * nose
        v = v * (1.0 - edge * 0.55)                                   # AO لبه
        arr[:, :, c] = np.clip(v * bm, 0, 255)
    arr[:, :, 3] = bm * 255
    img = Image.fromarray(arr.astype(np.uint8), "RGBA")
    d = ImageDraw.Draw(img)

    # ── آرک چرخ + لاستیک‌ها
    ax_f, ax_r = px(0.205), px(0.795)
    for ax in (ax_f, ax_r):
        for sgn in (-1, 1):
            y0 = cy + sgn * (hw / 2) - (_P(7) if sgn < 0 else _P(9))
            y1 = cy + sgn * (hw / 2) + (_P(9) if sgn > 0 else _P(7))
            d.rounded_rectangle([ax - _P(20), y0, ax + _P(20), y1],
                                radius=_P(4), fill=tuple(int(c * 0.42) for c in base) + (150,))
    for ax in (ax_f, ax_r):
        for sgn in (-1, 1):
            wy = cy + sgn * (hw / 2 + _P(1.5))
            d.rounded_rectangle([ax - _P(16), wy - _P(7.5), ax + _P(16), wy + _P(7.5)],
                                radius=_P(4), fill=(12, 12, 15, 255))
            d.rounded_rectangle([ax - _P(12), wy - _P(4), ax + _P(12), wy + _P(4)],
                                radius=_P(2.5), fill=(30, 30, 36, 255))

    # ── کابین شیشه‌ای — بزرگ و واضح با بازتاب آسمان
    cabw = 0.84
    top2, bot2 = [], []
    for i in range(31):
        t = cab0 + (cab1 - cab0) * i / 30
        w = body_profile(t, style) * hw / 2 * cabw
        top2.append((px(t), cy - w))
        bot2.append((px(t), cy + w))
    glass_poly = top2 + bot2[::-1]
    gmask = Image.new("L", (cw, ch), 0)
    ImageDraw.Draw(gmask).polygon(glass_poly, fill=255)
    gm = np.asarray(gmask, dtype=np.float32) / 255.0
    base_arr = np.asarray(img, dtype=np.float32)
    garr = np.zeros((ch, cw, 4), dtype=np.float32)
    refl = np.clip(1.0 - np.abs(xx + 0.25) * 3.2, 0, 1) * np.clip(1.0 - np.abs(yy) * 1.6, 0, 1)
    for c, gcol in enumerate((12.0, 16.0, 24.0)):
        garr[:, :, c] = np.clip(gcol + refl * 120.0, 0, 255)
    garr[:, :, 3] = 255.0
    out_arr = np.where(gm[:, :, None] > 0, garr, base_arr)
    img = Image.fromarray(out_arr.astype(np.uint8), "RGBA")
    d = ImageDraw.Draw(img)

    # ── سقف باریک + ستون‌ها
    rf0, rf1 = cab0 + 0.085, cab1 - 0.085
    roofw = 0.60                # سقف باریک‌تر از شیشه — نوار شیشه‌ی کناری دیده می‌شود
    top3, bot3 = [], []
    for i in range(21):
        t = rf0 + (rf1 - rf0) * i / 20
        w = body_profile(t, style) * hw / 2 * cabw * roofw
        top3.append((px(t), cy - w))
        bot3.append((px(t), cy + w))
    # درز تیره دور سقف (سایه‌ی شیشه) بعد خود سقف
    d.polygon([(x0, y0 - _P(1.2)) for (x0, y0) in top3] + [(x1, y1 + _P(1.2)) for (x1, y1) in bot3[::-1]],
              fill=(10, 12, 18, 200))
    d.polygon(top3 + bot3[::-1], fill=roofc + (255,))
    rc_edge = tuple(max(0, int(c * 0.80)) for c in roofc)
    d.line(top3 + bot3[::-1] + [top3[0]], fill=rc_edge + (200,), width=SS, joint="curve")
    d.line([(px((rf0 + rf1) / 2 - 0.045), cy), (px((rf0 + rf1) / 2 + 0.045), cy)],
           fill=rc_edge + (120,), width=SS)
    pillar = tuple(int(c * 0.66) for c in base)
    for t in (cab0 + 0.012, cab1 - 0.012):
        w = body_profile(t, style) * hw / 2 * cabw
        d.line([(px(t), cy - w + _P(1)), (px(t), cy + w - _P(1))], fill=pillar + (220,), width=int(_P(1.6)))

    # ── درزها + دستگیره + آینه
    seam = tuple(max(0, int(c * 0.52)) for c in base)
    for t in (cab0 - 0.014, cab1 + 0.016):
        w = body_profile(t, style) * hw / 2
        d.line([(px(t), cy - w + _P(2.5)), (px(t), cy + w - _P(2.5))], fill=seam + (170,), width=SS)
    for sgn in (-1, 1):
        d.line([(px(0.10), cy + sgn * hw * 0.43), (px(0.94), cy + sgn * hw * 0.39)],
               fill=seam + (140,), width=SS)
    for sgn in (-1, 1):
        d.rounded_rectangle([px((cab0 + cab1) / 2 + 0.06), cy + sgn * hw * 0.335 - _P(1.5),
                             px((cab0 + cab1) / 2 + 0.13), cy + sgn * hw * 0.335 + _P(1.5)],
                            radius=_P(1), fill=seam + (200,))
    for sgn in (-1, 1):
        d.rounded_rectangle([px(cab0) - _P(3), cy + sgn * (hw / 2 + _P(0.5)) - _P(5),
                             px(cab0) + _P(7), cy + sgn * (hw / 2 + _P(0.5)) + _P(5)],
                            radius=_P(2), fill=dark + (255,))

    # ── نوار رگلی / لivery
    if spec.get("stripe"):
        sc = spec["stripe"]
        for off in (-_P(6), _P(6)):
            d.line([(px(0.03), cy + off), (px(0.99), cy + off)], fill=sc + (235,), width=_P(5))
    if spec.get("livery"):
        lc = spec["livery"]
        for sgn in (-1, 1):
            d.polygon([(px(0.06), cy + sgn * hw * 0.30), (px(0.34), cy + sgn * hw * 0.34),
                       (px(0.30), cy + sgn * hw * 0.46), (px(0.04), cy + sgn * hw * 0.42)], fill=lc + (255,))

    # ── ورودی هوا / هود کربن
    if spec.get("scoop"):
        d.rounded_rectangle([px(0.14), cy - _P(9), px(0.26), cy + _P(9)], radius=_P(4), fill=(14, 14, 18, 255))
        d.rounded_rectangle([px(0.15), cy - _P(6), px(0.25), cy + _P(6)], radius=_P(3), fill=(30, 30, 38, 255))
    if spec.get("carbon_hood"):
        hmask = Image.new("L", (cw, ch), 0)
        hp = []
        for i in range(21):
            t = 0.03 + (cab0 - 0.03) * i / 20
            w = body_profile(t, style) * hw / 2
            hp.append((px(t), cy - w))
            hp.insert(0, (px(t), cy + w))
        ImageDraw.Draw(hmask).polygon(hp, fill=95)
        carbon = Image.new("RGBA", (cw, ch), (24, 24, 29, 255))
        carr = np.asarray(carbon, dtype=np.uint8).copy()
        chk = (np.add.outer(np.arange(ch) // _P(3), np.arange(cw) // _P(3)) % 2).astype(np.uint8) * 16
        carr[:, :, 0] = np.clip(carr[:, :, 0].astype(int) + chk, 0, 255).astype(np.uint8)
        carr[:, :, 1] = np.clip(carr[:, :, 1].astype(int) + chk, 0, 255).astype(np.uint8)
        carbon = Image.fromarray(carr)
        img.paste(carbon, (0, 0), hmask)
        d = ImageDraw.Draw(img)

    # ── چراغ جلو (گرم) با پروژکتور + هاله
    hx0, hx1 = px(0.008), px(0.06)
    halo = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    dh = ImageDraw.Draw(halo)
    for sgn in (-1, 1):
        wy = cy + sgn * hw * 0.27
        dh.ellipse([hx0 - _P(6), wy - _P(11), hx1 + _P(10), wy + _P(11)], fill=(255, 236, 180, 120))
    halo = halo.filter(ImageFilter.GaussianBlur(_P(4)))
    img = Image.alpha_composite(img, halo)
    d = ImageDraw.Draw(img)
    for sgn in (-1, 1):
        wy = cy + sgn * hw * 0.27
        d.rounded_rectangle([hx0, wy - _P(7), hx1, wy + _P(7)], radius=_P(3), fill=(255, 246, 212, 255))
        d.ellipse([hx0 + _P(1), wy - _P(3.5), hx0 + _P(8), wy + _P(3.5)], fill=(255, 255, 236, 255))
    d.line([(hx0 + _P(2), cy - hw * 0.16), (hx0 + _P(2), cy + hw * 0.16)],
           fill=(255, 240, 190, 200), width=_P(2))
    d.rounded_rectangle([hx0 + _P(1), cy - hw * 0.13, hx0 + _P(7), cy + hw * 0.13],
                        radius=_P(2), fill=(16, 16, 20, 255))
    # ── چراغ عقب قرمز + هاله + اگزوز
    tx0, tx1 = px(0.955), px(0.992)
    halo2 = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    dh2 = ImageDraw.Draw(halo2)
    for sgn in (-1, 1):
        wy = cy + sgn * hw * 0.28
        dh2.ellipse([tx0 - _P(6), wy - _P(10), tx1 + _P(8), wy + _P(10)], fill=(255, 52, 40, 110))
    halo2 = halo2.filter(ImageFilter.GaussianBlur(_P(4)))
    img = Image.alpha_composite(img, halo2)
    d = ImageDraw.Draw(img)
    for sgn in (-1, 1):
        wy = cy + sgn * hw * 0.28
        d.rounded_rectangle([tx0, wy - _P(7), tx1, wy + _P(7)], radius=_P(3), fill=(235, 46, 38, 255))
    d.line([(tx1 - _P(1), cy - hw * 0.20), (tx1 - _P(1), cy + hw * 0.20)],
           fill=(255, 70, 55, 230), width=_P(2))
    for sgn in (-1, 1):
        d.ellipse([px(0.985) - _P(3), cy + sgn * hw * 0.12 - _P(3),
                   px(0.985) + _P(3), cy + sgn * hw * 0.12 + _P(3)], fill=(20, 20, 24, 255))

    # ── اسپویلر
    if spec.get("wing"):
        wc = spec.get("wing_col", (18, 18, 23))
        d.rounded_rectangle([px(0.955), cy - hw / 2 - _P(3), px(0.99), cy + hw / 2 + _P(3)],
                            radius=_P(3), fill=wc + (255,))
        d.line([(px(0.93), cy - hw * 0.2), (px(0.955), cy - hw * 0.2)], fill=wc + (255,), width=_P(3))
        d.line([(px(0.93), cy + hw * 0.2), (px(0.955), cy + hw * 0.2)], fill=wc + (255,), width=_P(3))

    # ── شماره‌ی رگلی روی سقف
    if spec.get("num"):
        r = _P(13)
        npos = (px((rf0 + rf1) / 2), cy)
        d.ellipse([npos[0] - r, npos[1] - r, npos[0] + r, npos[1] + r], fill=(245, 245, 248, 255))
        try:
            f = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", _P(17))
            d.text(npos, str(spec["num"]), font=f, fill=(20, 20, 26), anchor="mm")
        except Exception:
            pass

    # ── پلاک + هایلایت نرم (فقط روی بدنه، نه شیشه/سقف) + خط دور بدنه
    d.rounded_rectangle([px(0.008), cy - _P(6), px(0.024), cy + _P(6)], radius=_P(1),
                        fill=(205, 205, 210, 255))
    sheen = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    ds = ImageDraw.Draw(sheen)
    ds.ellipse([cx - hl * 0.44, cy - hw * 0.30, cx + hl * 0.20, cy + hw * 0.30],
               fill=(255, 255, 255, 26))
    sheen = sheen.filter(ImageFilter.GaussianBlur(_P(9)))
    no_glass = Image.new("L", (cw, ch), 0)
    nd = ImageDraw.Draw(no_glass)
    nd.polygon(glass_poly, fill=255)
    nd.polygon(top3 + bot3[::-1], fill=255)
    sheen.putalpha(Image.composite(Image.new("L", (cw, ch), 0), sheen.split()[3], no_glass))
    img = Image.alpha_composite(img, sheen)
    d.line(sil + [sil[0]], fill=tuple(max(0, int(c * 0.45)) for c in base) + (210,), width=SS, joint="curve")
    return img

def formula_car(spec):
    """ماشین فرمول — بدنه باریک، چرخ باز، بال جلو/عقب."""
    base = spec["base"]
    cw, ch = _P(L + 30), _P(W + 44)
    img = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = cw / 2, ch / 2
    hl = _P(L)
    def px(t): return cx - hl / 2 + t * hl
    for ax in (px(0.16), px(0.80)):
        for sgn in (-1, 1):
            wy = cy + sgn * _P(19)
            d.ellipse([ax - _P(16), wy - _P(15), ax + _P(16), wy + _P(15)], fill=(10, 10, 13, 255))
            d.ellipse([ax - _P(8), wy - _P(8), ax + _P(8), wy + _P(8)], fill=(48, 48, 56, 255))
            d.ellipse([ax - _P(3), wy - _P(3), ax + _P(3), wy + _P(3)], fill=(120, 122, 132, 255))
    d.rounded_rectangle([px(0.01), cy - _P(21), px(0.075), cy + _P(21)], radius=_P(3), fill=base + (255,))
    d.rounded_rectangle([px(0.01), cy - _P(21), px(0.03), cy + _P(21)], radius=_P(2), fill=(20, 20, 26, 255))
    body = [(px(0.06), cy - _P(7)), (px(0.30), cy - _P(10)), (px(0.72), cy - _P(11)),
            (px(0.93), cy - _P(13)), (px(0.93), cy + _P(13)), (px(0.72), cy + _P(11)),
            (px(0.30), cy + _P(10)), (px(0.06), cy + _P(7))]
    d.polygon(body, fill=base + (255,))
    d.polygon([(px(0.34), cy - _P(7)), (px(0.55), cy - _P(8)), (px(0.55), cy + _P(8)),
               (px(0.34), cy + _P(7))], fill=(14, 16, 24, 255))
    d.arc([px(0.40), cy - _P(12), px(0.58), cy + _P(12)], 200, 340, fill=(30, 30, 38, 255), width=_P(3))
    d.polygon([(px(0.58), cy - _P(6)), (px(0.75), cy - _P(4)), (px(0.75), cy + _P(4)),
               (px(0.58), cy + _P(6))], fill=tuple(int(c * 0.7) for c in base) + (255,))
    d.rounded_rectangle([px(0.93), cy - _P(20), px(0.985), cy + _P(20)], radius=_P(3), fill=base + (255,))
    d.rounded_rectangle([px(0.985), cy - _P(20), px(0.995), cy + _P(20)], radius=_P(2), fill=(20, 20, 26, 255))
    try:
        f = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", _P(13))
        d.text((px(0.24), cy), str(spec.get("num", 7)), font=f, fill=(250, 250, 252), anchor="mm")
    except Exception:
        pass
    return img

CARS = {
    "helia":        {"style": "coupe", "base": (26, 138, 148), "stripe": (16, 20, 22), "seed": 1},
    "boghi":        {"style": "coupe", "base": (212, 78, 38), "carbon_hood": True, "stripe": (24, 22, 22), "seed": 2},
    "boghi_yellow": {"style": "coupe", "base": (224, 178, 52), "stripe": (26, 24, 20), "seed": 3},
    "tiba":         {"style": "hatch", "base": (148, 164, 178), "seed": 4},
    "pride":        {"style": "hatch", "base": (182, 48, 42), "seed": 5},
    "pejo":         {"style": "hatch", "base": (162, 172, 156), "seed": 6},
    "samand":       {"style": "sedan", "base": (98, 106, 120), "seed": 7},
    "dena":         {"style": "sedan", "base": (138, 42, 46), "seed": 8},
    "nissan":       {"style": "muscle", "base": (88, 108, 130), "seed": 9},
    "pejo_race":    {"style": "hatch", "base": (224, 224, 230), "livery": (216, 62, 44), "wing": True, "num": 21, "seed": 10},
    "shahin":       {"style": "sedan", "base": (46, 116, 126), "seed": 11},
    "quick":        {"style": "hatch", "base": (162, 202, 64), "seed": 12},
    "dena_race":    {"style": "sedan", "base": (30, 30, 36), "stripe": (216, 52, 42), "wing": True, "num": 8, "seed": 13},
    "pride_blue":   {"style": "hatch", "base": (42, 94, 192), "stripe": (238, 238, 244), "wing": True, "num": 14, "seed": 14},
    "pejo_green":   {"style": "hatch", "base": (38, 142, 90), "stripe": (238, 238, 244), "wing": True, "num": 33, "seed": 15},
    "shahin_white": {"style": "sedan", "base": (214, 218, 224), "roof": (116, 120, 130), "seed": 16},
    "dena_red":     {"style": "sedan", "base": (180, 36, 42), "roof": (62, 20, 20), "seed": 17},
    "nissan_blue":  {"style": "muscle", "base": (46, 86, 172), "stripe": (248, 248, 250), "seed": 18},
    "formula_red":  {"style": "formula", "base": (216, 48, 38), "num": 1, "seed": 19},
    "formula_blue": {"style": "formula", "base": (38, 96, 208), "num": 7, "seed": 20},
    "formula_black":{"style": "formula", "base": (34, 34, 42), "num": 0, "seed": 21},
    "traf_white":   {"style": "sedan", "base": (200, 202, 206), "seed": 22},
    "traf_gray":    {"style": "sedan", "base": (116, 122, 132), "seed": 23},
    "traf_taxi":    {"style": "sedan", "base": (222, 174, 36), "seed": 24},
    "traf_van":     {"style": "van", "base": (192, 194, 200), "seed": 25},
}

def main():
    os.makedirs(OUT, exist_ok=True)
    for cid, spec in CARS.items():
        if spec["style"] == "formula":
            img = formula_car(spec)
        else:
            img = make_car(spec)
        if cid == "traf_taxi":
            d = ImageDraw.Draw(img)
            cw, ch = img.size
            cx, cy = cw / 2, ch / 2
            d.rounded_rectangle([cx - _P(11), cy - _P(8), cx + _P(11), cy + _P(8)],
                                radius=_P(2), fill=(40, 40, 44, 255))
            d.rectangle([cx - _P(9), cy - _P(6), cx + _P(9), cy + _P(6)], fill=(255, 214, 64, 255))
            try:
                f = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", _P(9))
                d.text((cx, cy), "TAXI", font=f, fill=(30, 26, 10), anchor="mm")
            except Exception:
                pass
        fw, fh = img.size
        fin = img.resize((fw // SS, fh // SS), Image.LANCZOS)
        fin.save(os.path.join(OUT, cid + "_top.png"))
        print("car:", cid, fin.size, flush=True)
    cols, rows = 7, 4
    tw, th = 230, 140
    sheet = Image.new("RGB", (cols * tw, rows * th), (16, 18, 26))
    sd = ImageDraw.Draw(sheet)
    for i, cid in enumerate(CARS):
        x = (i % cols) * tw
        y = (i // cols) * th
        car = Image.open(os.path.join(OUT, cid + "_top.png"))
        car = car.rotate(90, expand=True)
        sheet.paste(car, (x + (tw - car.size[0]) // 2, y + (th - car.size[1]) // 2), car)
    sheet.save(os.path.join(OUT, "preview_cars.png"))
    print("sheet saved", flush=True)

if __name__ == "__main__":
    main()
