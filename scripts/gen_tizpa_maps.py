#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""تیز پا — بیک ۵ پیست متنوع تهران
هر پیست: فرم مسیر مخصوص + پالت زمان روز + بناهای شناسه (برج میلاد/آزادی/توچال)
خروجی: data/track_<id>.json + assets/sprites/l<id>_map_<q>.jpg (۴ تایل هر پیست)
مبنی بر پایپلاین اثبات‌شده gen16_map.py."""
import os, sys, json, math, random
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

BASE = "/home/z/my-project/tizpa/game"
OUT = os.path.join(BASE, "assets", "sprites")
DATA = os.path.join(BASE, "data")
SS = 2
DS = 1.0
MARGIN = 320.0

# ─────────── پالت‌ها (زمین/آسفالت/پیاده‌رو/بلوک/بام/نئون/نور لامپ/آسمان بیرون) ───────────
PAL = {
    # ۱ ولیعصر — غروب طلایی، خیابان درختی
    "valiasr": {
        "ground": (80, 64, 48), "blk": (100, 80, 62), "walk": (132, 112, 88),
        "asphalt": (68, 63, 60), "curb": (172, 146, 114), "wear": (56, 52, 50),
        "roof": [(110, 86, 64), (126, 96, 66), (100, 84, 74), (134, 102, 70), (90, 78, 68),
                 (118, 92, 80), (138, 108, 76), (104, 90, 80)],
        "neon": [(255, 190, 90), (255, 150, 70), (120, 220, 200), (255, 220, 140)],
        "win": [(255, 206, 122), (255, 222, 158), (214, 228, 246)],
        "lamp": (255, 226, 150), "lamp_a": 108, "tree": (72, 104, 52),
        "night": False, "win_mode": "dusk", "ambient": (1.0, 0.93, 0.83), "under": (0.36, 0.30, 0.24),
        "sky": (104, 74, 52),
    },
    # ۲ اتوبان همت — شب سرعت، آسفالت پهن
    "hemmat": {
        "ground": (13, 14, 20), "blk": (18, 19, 27), "walk": (36, 38, 48),
        "asphalt": (24, 25, 32), "curb": (70, 74, 90), "wear": (20, 21, 27),
        "roof": [(40, 42, 54), (46, 48, 60), (36, 44, 54), (52, 46, 44), (38, 46, 46),
                 (50, 50, 62), (56, 50, 38), (42, 44, 52)],
        "neon": [(80, 225, 255), (255, 150, 70), (255, 90, 150), (140, 255, 170), (255, 220, 110)],
        "win": [(255, 206, 122), (214, 228, 246), (255, 190, 96)],
        "lamp": (255, 236, 180), "lamp_a": 62, "tree": (16, 34, 22),
        "night": True, "win_mode": "night", "ambient": (0.93, 0.95, 1.0), "under": (0.027, 0.031, 0.055),
        "sky": (10, 12, 20),
    },
    # ۳ بازار — روز، کوچه‌های تنگ و پرتراکم
    "bazaar": {
        "ground": (186, 164, 136), "blk": (198, 176, 148), "walk": (222, 206, 180),
        "asphalt": (136, 130, 122), "curb": (210, 196, 172), "wear": (124, 118, 110),
        "roof": [(188, 154, 118), (176, 142, 110), (196, 164, 128), (164, 132, 106),
                 (182, 152, 116), (172, 144, 120), (200, 168, 130)],
        "neon": [(200, 90, 60), (90, 130, 160), (170, 140, 60)],
        "win": [(60, 56, 50), (80, 72, 62), (48, 46, 42)],
        "lamp": (255, 240, 200), "lamp_a": 22, "tree": (74, 110, 58),
        "night": False, "win_mode": "day", "ambient": (1.02, 1.0, 0.95), "under": (0.62, 0.56, 0.47),
        "sky": (178, 156, 128),
    },
    # ۴ تجریش — غروب سرخ کوهستانی
    "tajrish": {
        "ground": (78, 60, 62), "blk": (94, 74, 76), "walk": (124, 106, 106),
        "asphalt": (72, 67, 69), "curb": (172, 152, 150), "wear": (62, 58, 60),
        "roof": [(120, 94, 88), (134, 104, 92), (110, 90, 94), (142, 110, 94), (98, 86, 88),
                 (126, 98, 80), (138, 108, 100)],
        "neon": [(255, 120, 140), (255, 190, 90), (120, 220, 255), (200, 120, 255)],
        "win": [(255, 200, 130), (255, 218, 160), (216, 224, 246)],
        "lamp": (255, 220, 150), "lamp_a": 96, "tree": (66, 100, 60),
        "night": False, "win_mode": "dusk", "ambient": (1.0, 0.90, 0.86), "under": (0.44, 0.33, 0.34),
        "sky": (120, 70, 72),
    },
    # ۵ آزادی — نیمه‌شب نئونی، فینال
    "azadi": {
        "ground": (10, 11, 18), "blk": (14, 15, 23), "walk": (30, 32, 42),
        "asphalt": (20, 21, 28), "curb": (60, 64, 82), "wear": (16, 17, 23),
        "roof": [(32, 34, 46), (38, 40, 52), (30, 38, 48), (44, 38, 38), (32, 40, 40),
                 (42, 42, 56), (48, 42, 32), (36, 38, 46)],
        "neon": [(255, 60, 160), (80, 225, 255), (170, 140, 255), (255, 220, 110), (140, 255, 200)],
        "win": [(255, 206, 122), (180, 214, 246), (255, 170, 90)],
        "lamp": (255, 230, 170), "lamp_a": 58, "tree": (12, 28, 20),
        "night": True, "win_mode": "night", "ambient": (0.90, 0.92, 1.02), "under": (0.020, 0.024, 0.045),
        "sky": (8, 8, 16),
    },
}

# ─────────── فرم مسیرها (۸ تا ۱۰ گوشه، واحد world) ───────────
WPS_SET = {
    # ولیعصر: بلوار کشیده با دو پیچ بزرگ
    "valiasr": [(1500, 1300), (3300, 1250), (4900, 1600), (5350, 2600),
                (5000, 3700), (3800, 4050), (2600, 3900), (1400, 3500), (1050, 2350)],
    # همت: اتوبان پهن، مستقیم‌های طولانی + شیب‌پیچ
    "hemmat": [(1200, 1100), (4800, 1000), (5600, 1900), (5650, 3100),
               (5000, 4200), (3300, 4400), (1500, 4250), (900, 3300), (850, 2000)],
    # بازار: تنگ و پیچ‌دار — چالش فرمان
    "bazaar": [(1500, 1400), (3000, 1150), (4400, 1500), (5300, 2400),
               (4900, 3300), (5100, 4200), (3800, 4600), (2300, 4300),
               (1200, 3700), (900, 2500)],
    # تجریش: مارپیچ کوهستانی
    "tajrish": [(1400, 1500), (2900, 1100), (4600, 1300), (5500, 2300),
                (5200, 3500), (5600, 4400), (4000, 4700), (2500, 4500),
                (1100, 3900), (1000, 2600)],
    # آزادی: میدان بزرگ + فینال بزرگ
    "azadi": [(1300, 1200), (3500, 1050), (5300, 1350), (5750, 2700),
              (5300, 4000), (3500, 4550), (1600, 4300), (950, 3000)],
}

RECT_SET = {
    "valiasr": (200, 200, 5800, 4600),
    "hemmat": (200, 200, 6000, 4800),
    "bazaar": (200, 200, 5750, 5000),
    "tajrish": (200, 200, 6000, 5100),
    "azadi": (200, 200, 6100, 4900),
}

ROAD_HALF_SET = {"valiasr": 150, "hemmat": 185, "bazaar": 115, "tajrish": 135, "azadi": 160}
WALK_HALF_SET = {"valiasr": 225, "hemmat": 245, "bazaar": 185, "tajrish": 205, "azadi": 235}
R_FIL_SET = {"valiasr": 210, "hemmat": 260, "bazaar": 140, "tajrish": 155, "azadi": 230}

# تراکم
TREE_STEP_SET = {"valiasr": 300, "hemmat": 900, "bazaar": 800, "tajrish": 430, "azadi": 620}
LAMP_STEP = {"valiasr": 380, "hemmat": 300, "bazaar": 520, "tajrish": 400, "azadi": 320}


def unit(v):
    l = math.hypot(v[0], v[1]) or 1.0
    return (v[0] / l, v[1] / l)


class Track:
    def __init__(self, tid):
        self.tid = tid
        self.pal = PAL[tid]
        self.wps = WPS_SET[tid]
        self.rect = RECT_SET[tid]
        self.road_half = ROAD_HALF_SET[tid]
        self.walk_half = WALK_HALF_SET[tid]
        self.r_fil = R_FIL_SET[tid]
        self.rng = random.Random(77000 + hash(tid) % 100000)
        self.pts, self.arc_idx, self.pstep = self.build_centerline()
        self.track_len = len(self.pts) * self.pstep

    def build_centerline(self):
        V = [tuple(map(float, p)) for p in self.wps]
        R = self.r_fil
        n = len(V)
        chain = []
        arc_idx = set()
        for i in range(n):
            A, B, C = V[(i - 1) % n], V[i], V[(i + 1) % n]
            d1 = unit((B[0] - A[0], B[1] - A[1]))
            d2 = unit((C[0] - B[0], C[1] - B[1]))
            dot = max(-1.0, min(1.0, d1[0] * d2[0] + d1[1] * d2[1]))
            th = math.acos(dot)
            if th < 0.05:
                chain.append(B)
                continue
            T = min(R * math.tan(th / 2), 0.42 * min(math.hypot(B[0] - A[0], B[1] - A[1]),
                                                     math.hypot(C[0] - B[0], C[1] - B[1])))
            S = (B[0] - d1[0] * T, B[1] - d1[1] * T)
            E = (B[0] + d2[0] * T, B[1] + d2[1] * T)
            side = 1.0 if (d1[0] * d2[1] - d1[1] * d2[0]) > 0 else -1.0
            n1 = (-d1[1] * side, d1[0] * side)
            O = (S[0] + n1[0] * R, S[1] + n1[1] * R)
            a0 = math.atan2(S[1] - O[1], S[0] - O[0])
            a1 = math.atan2(E[1] - O[1], E[0] - O[0])
            if side > 0:
                while a1 < a0:
                    a1 += 2 * math.pi
            else:
                while a1 > a0:
                    a1 -= 2 * math.pi
            steps = max(6, int(abs(a1 - a0) * R / 9))
            base = len(chain)
            for k in range(steps + 1):
                a = a0 + (a1 - a0) * k / steps
                chain.append((O[0] + math.cos(a) * R, O[1] + math.sin(a) * R))
                arc_idx.add(base + k)
            nxt = V[(i + 1) % n]
            d3 = unit((V[(i + 2) % n][0] - nxt[0], V[(i + 2) % n][1] - nxt[1]))
            T3 = min(R * math.tan(math.acos(max(-1, min(1, d2[0] * d3[0] + d2[1] * d3[1]))) / 2), 600.0)
            S3 = (nxt[0] - d3[0] * T3, nxt[1] - d3[1] * T3)
            seg = math.hypot(S3[0] - E[0], S3[1] - E[1])
            for k in range(1, max(1, int(seg / 30))):
                t = k / max(1, int(seg / 30))
                chain.append((E[0] + (S3[0] - E[0]) * t, E[1] + (S3[1] - E[1]) * t))
        chain.append(chain[0])
        dense = []
        step = 40.0
        carry = 0.0
        for i in range(len(chain) - 1):
            ax, ay = chain[i]
            bx, by = chain[i + 1]
            seg = math.hypot(bx - ax, by - ay)
            t = carry
            while t < seg:
                dense.append((ax + (bx - ax) * t / seg, ay + (by - ay) * t / seg))
                t += step
            carry = t - seg
        return dense, arc_idx, step

    def path_at(self, s):
        s = s % self.track_len
        i = int(s / self.pstep) % len(self.pts)
        j = (i + 1) % len(self.pts)
        t = (s - i * self.pstep) / self.pstep
        return (self.pts[i][0] + (self.pts[j][0] - self.pts[i][0]) * t,
                self.pts[i][1] + (self.pts[j][1] - self.pts[i][1]) * t)

    def path_dir(self, s):
        i = int(s / self.pstep) % len(self.pts)
        j = (i + 1) % len(self.pts)
        return unit((self.pts[j][0] - self.pts[i][0], self.pts[j][1] - self.pts[i][1]))

    def ribbon(self, half):
        n = len(self.pts)
        left, right = [], []
        for i in range(n):
            p = self.pts[i]
            d = unit((self.pts[(i + 1) % n][0] - self.pts[(i - 1) % n][0],
                      self.pts[(i + 1) % n][1] - self.pts[(i - 1) % n][1]))
            nx, ny = -d[1], d[0]
            left.append((p[0] + nx * half, p[1] + ny * half))
            right.append((p[0] - nx * half, p[1] - ny * half))
        return left + right[::-1]

    def near_road(self, p, skip_s=-1.0, win=500.0):
        best = 1e18
        b2 = best * best
        for i in range(len(self.pts)):
            ps = i * self.pstep
            if skip_s >= 0:
                dd = abs(ps - skip_s)
                dd = min(dd, self.track_len - dd)
                if dd < win:
                    continue
            dx = p[0] - self.pts[i][0]
            dy = p[1] - self.pts[i][1]
            d2 = dx * dx + dy * dy
            if d2 < b2:
                b2 = d2
        return math.sqrt(b2)


def place_city(T):
    """ساختمان‌ها/چراغ/درخت/پارک‌شده — چسبیده به خیابان (درس v0.16)."""
    pal = T.pal
    rng = T.rng
    R, W = T.rect, T.walk_half
    RH = T.road_half
    buildings, alleys, greens = [], [], []
    # ردیف اول — چسبیده (درس: شرط فاصله نباید جای خودِ ساختمان را رد کند وگرنه شهر خلوت می‌شود)
    for side in (1, -1):
        s = 130.0
        while s < T.track_len - 130.0:
            w = rng.uniform(190, 400)
            depth = rng.uniform(150, 270)
            hd = math.hypot(w, depth) / 2
            off = max(W + 16, RH + 55) + depth / 2
            d = T.path_dir(s)
            nx, ny = -d[1] * side, d[0] * side
            p = T.path_at(s)
            pos = (p[0] + nx * off, p[1] + ny * off)
            if rng.random() < 0.085:
                alleys.append({"pos": (p[0] + nx * (W + 30 + rng.uniform(150, 230)),
                                       p[1] + ny * (W + 30 + rng.uniform(150, 230))),
                               "rot": math.degrees(math.atan2(d[1], d[0])),
                               "len": rng.uniform(300, 520)})
                s += rng.uniform(250, 390)
                continue
            ok = T.near_road(pos, skip_s=s, win=420.0) > RH + max(w, depth) / 2 + 12
            ok = ok and R[0] + 30 < pos[0] < R[2] - 30 and R[1] + 30 < pos[1] < R[3] - 30
            for b in buildings:
                if math.hypot(b["pos"][0] - pos[0], b["pos"][1] - pos[1]) < (hd + b["hd"]) * 0.52:
                    ok = False
                    break
            if ok:
                rot = math.degrees(math.atan2(d[1], d[0])) + rng.uniform(-2.5, 2.5)
                col = pal["roof"][rng.randrange(len(pal["roof"]))]
                front = rng.random() < 0.78
                neon = pal["neon"][rng.randrange(len(pal["neon"]))] if (front and rng.random() < 0.62) else None
                neon2 = pal["neon"][rng.randrange(len(pal["neon"]))]
                buildings.append({"pos": pos, "rot": rot, "w": w, "h": depth, "hd": hd,
                                  "col": col, "neon": neon, "neon2": neon2,
                                  "kind": 0 if front else rng.randrange(3),
                                  "awn": front and rng.random() < 0.6,
                                  "seed": rng.randrange(9999), "row": 1})
            s += w + rng.uniform(4, 14)
    # ردیف دوم
    for side in (1, -1):
        s = 200.0
        while s < T.track_len - 200.0:
            w = rng.uniform(160, 300)
            depth = rng.uniform(130, 210)
            hd = math.hypot(w, depth) / 2
            off = W + 20 + 310 + depth / 2
            d = T.path_dir(s)
            nx, ny = -d[1] * side, d[0] * side
            p = T.path_at(s)
            pos = (p[0] + nx * off, p[1] + ny * off)
            if rng.random() < 0.85:
                ok = T.near_road(pos, skip_s=s, win=210.0) > RH + max(w, depth) / 2 + 12
                ok = ok and R[0] + 30 < pos[0] < R[2] - 30 and R[1] + 30 < pos[1] < R[3] - 30
                for b in buildings:
                    if math.hypot(b["pos"][0] - pos[0], b["pos"][1] - pos[1]) < (hd + b["hd"]) * 0.60:
                        ok = False
                        break
                if ok:
                    rot = math.degrees(math.atan2(d[1], d[0])) + rng.uniform(-9, 9)
                    buildings.append({"pos": pos, "rot": rot, "w": w, "h": depth, "hd": hd,
                                      "col": pal["roof"][rng.randrange(len(pal["roof"]))],
                                      "neon": None, "neon2": pal["neon"][rng.randrange(len(pal["neon"]))],
                                      "kind": rng.randrange(3), "awn": False,
                                      "seed": rng.randrange(9999), "row": 2})
            s += w + rng.uniform(12, 40)
    # پرکردن بلوک
    step = 205.0
    rix = 0
    gy = R[1] + 120
    while gy < R[3] - 120:
        gx = R[0] + 120 + (step * 0.5 if rix % 2 else 0.0)
        while gx < R[2] - 120:
            r = rng.random()
            w = rng.uniform(150, 280)
            h = rng.uniform(140, 250)
            hd = math.hypot(w, h) / 2
            pos = (gx + rng.uniform(-50, 50), gy + rng.uniform(-50, 50))
            far = T.near_road(pos)
            near_alley = any(math.hypot(A["pos"][0] - pos[0], A["pos"][1] - pos[1]) < 250 for A in alleys)
            if r < 0.84 and not near_alley and far - max(w, h) / 2 > W + 8:
                ok = True
                for b in buildings:
                    if math.hypot(b["pos"][0] - pos[0], b["pos"][1] - pos[1]) < (hd + b["hd"]) * 0.66:
                        ok = False
                        break
                if ok:
                    buildings.append({"pos": pos, "rot": rng.choice((0.0, 90.0, rng.uniform(0, 90))),
                                      "w": w, "h": h, "hd": hd,
                                      "col": pal["roof"][rng.randrange(len(pal["roof"]))],
                                      "neon": None, "neon2": pal["neon"][0],
                                      "kind": rng.randrange(3), "awn": False,
                                      "seed": rng.randrange(9999), "row": 3})
            elif r < 0.90 and not near_alley and far > W + 140:
                greens.append({"pos": pos, "r": rng.uniform(48, 92)})
            gx += step
        gy += step * 0.9
        rix += 1

    lamps, trees, parked, crosswalks = [], [], [], []
    s = 700.0
    while s < T.track_len - 400.0:
        d = T.path_dir(s)
        sgn = 1.0 if int(s / 620) % 2 == 0 else -1.0
        p = T.path_at(s)
        lamps.append({"pos": (p[0] - d[1] * (RH + 14) * sgn, p[1] + d[0] * (RH + 14) * sgn), "s": s})
        s += LAMP_STEP[T.tid]
    s = 240.0
    tside = 1.0
    tstep = TREE_STEP_SET[T.tid]
    trange = {"valiasr": (30, 44), "bazaar": (24, 34), "hemmat": (20, 28),
              "tajrish": (24, 34), "azadi": (21, 30)}[T.tid]
    while s < T.track_len - 240.0:
        d = T.path_dir(s)
        p = T.path_at(s)
        trees.append({"pos": (p[0] - d[1] * (W - 24) * tside, p[1] + d[0] * (W - 24) * tside),
                      "r": rng.uniform(trange[0], trange[1]), "s": s})
        s2 = s + tstep * 0.5
        if s2 < T.track_len - 240.0:
            d2 = T.path_dir(s2)
            p2 = T.path_at(s2)
            trees.append({"pos": (p2[0] - d2[1] * (W - 24) * tside, p2[1] + d2[0] * (W - 24) * tside),
                          "r": rng.uniform(trange[0] - 2, trange[1] - 3), "s": s2})
        tside *= -1.0
        s += tstep
    s = 900.0
    while s < T.track_len - 700.0:
        crosswalks.append(s)
        s += 1500.0
    s = 820.0
    pside = 1.0
    while s < T.track_len - 900.0:
        if all(abs(s - c) > 280 for c in crosswalks):
            d = T.path_dir(s)
            p = T.path_at(s + 110)
            parked.append({"pos": (p[0] - d[1] * (RH + 26) * pside, p[1] + d[0] * (RH + 26) * pside),
                           "rot": math.degrees(math.atan2(d[1], d[0])), "s": s})
            if rng.random() < 0.55 and all(abs(s + 62 - c) > 240 for c in crosswalks):
                p2 = T.path_at(s + 174)
                parked.append({"pos": (p2[0] - d[1] * (RH + 26) * pside, p2[1] + d[0] * (RH + 26) * pside),
                               "rot": math.degrees(math.atan2(d[1], d[0])), "s": s + 62})
        pside *= -1.0
        s += 430.0
    lamps = [L for L in lamps if T.near_road(L["pos"], L["s"]) > RH + 20]
    trees = [X for X in trees if T.near_road(X["pos"], X["s"]) > RH + 40]
    parked = [P for P in parked if T.near_road(P["pos"], P["s"]) > RH + 44]
    return buildings, alleys, greens, lamps, trees, parked, crosswalks


def make_roof_sprite(b, pal, night):
    w, h = int(b["w"]), int(b["h"])
    m = 44
    img = Image.new("RGBA", (w + m * 2, h + m * 2), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    bx0, by0 = m, m
    sh = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(sh).rectangle([bx0 + 8, by0 + 10, bx0 + w + 8, by0 + h + 10], fill=(0, 0, 5, 150))
    sh = sh.filter(ImageFilter.GaussianBlur(7))
    img = Image.alpha_composite(img, sh)
    d = ImageDraw.Draw(img)
    col = b["col"]
    d.rectangle([bx0, by0, bx0 + w, by0 + h], fill=col + (255,))
    edge = tuple(min(255, int(c * 1.7 + 12)) for c in col)
    d.rectangle([bx0, by0, bx0 + w, by0 + h], outline=edge + (255,), width=5)
    d.rectangle([bx0 + 7, by0 + 7, bx0 + w - 7, by0 + h - 7], outline=tuple(int(c * 0.7) for c in col) + (255,), width=2)
    rnd = random.Random(b["seed"])
    for yy in range(by0 + 14, by0 + h - 10, 20):
        a = 26 if (yy // 20) % 2 == 0 else 14
        d.line([(bx0 + 8, yy), (bx0 + w - 8, yy)], fill=(255, 255, 255, a), width=1)
    for xx in range(bx0 + 14, bx0 + w - 10, 26):
        d.line([(xx, by0 + 8), (xx, by0 + h - 8)], fill=(0, 0, 0, 22), width=1)
    # پنجره — بر اساس زمان روز (night/dusk/day)
    rndw = random.Random(b["seed"] * 7 + 13)
    win_glow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    wgd = ImageDraw.Draw(win_glow)
    wm = pal.get("win_mode", "night")
    if wm == "night":
        lit_cols = pal["win"] if night else [(48, 52, 62), (56, 60, 70), (44, 48, 58)]
        lit_p = 0.50
        dark_c = (28, 30, 40)
        mid_c = (150, 182, 222)
    elif wm == "dusk":
        lit_cols = pal["win"]
        lit_p = 0.34
        dark_c = (40, 40, 50)
        mid_c = (120, 140, 170)
    else:  # day
        lit_cols = pal["win"]
        lit_p = 0.10
        dark_c = (52, 56, 66)
        mid_c = (86, 92, 104)

    def window_edge(x0, y0, x1, y1, horiz):
        if horiz:
            n = max(2, int((x1 - x0) // 20))
            for i in range(n):
                wx = x0 + i * 20 + 5
                if wx + 12 > x1:
                    break
                rr = rndw.random()
                if rr < lit_p:
                    c = lit_cols[rndw.randrange(len(lit_cols))]
                elif rr < lit_p + 0.12:
                    c = mid_c
                else:
                    c = dark_c
                wgd.rectangle([wx, y0, wx + 11, y0 + 7], fill=c + (255,))
        else:
            n = max(2, int((y1 - y0) // 20))
            for i in range(n):
                wy = y0 + i * 20 + 5
                if wy + 12 > y1:
                    break
                rr = rndw.random()
                if rr < lit_p:
                    c = lit_cols[rndw.randrange(len(lit_cols))]
                elif rr < lit_p + 0.12:
                    c = mid_c
                else:
                    c = dark_c
                wgd.rectangle([x0, wy, x0 + 7, wy + 11], fill=c + (255,))
    ins = 12
    window_edge(bx0 + 10, by0 + ins, bx0 + w - 10, by0 + ins + 7, True)
    window_edge(bx0 + 10, by0 + h - ins - 7, bx0 + w - 10, by0 + h - ins, True)
    window_edge(bx0 + ins, by0 + 12, bx0 + ins + 7, by0 + h - 12, False)
    window_edge(bx0 + w - ins - 7, by0 + 12, bx0 + w - ins, by0 + h - 12, False)
    img = Image.alpha_composite(img, win_glow.filter(ImageFilter.GaussianBlur(3)))
    img = Image.alpha_composite(img, win_glow)
    d = ImageDraw.Draw(img)
    if b.get("awn"):
        aw_cols = [(172, 56, 46), (46, 100, 64), (198, 170, 62), (64, 78, 148), (188, 188, 192)]
        ac = aw_cols[rnd.randrange(len(aw_cols))]
        nst = max(3, int(w // 16))
        for i in range(nst):
            cc = ac if i % 2 == 0 else (232, 228, 220)
            d.rectangle([bx0 + i * 16, by0 - 9, bx0 + i * 16 + 16, by0 - 1], fill=cc + (255,))
        d.line([(bx0, by0 - 1), (bx0 + w, by0 - 1)], fill=(20, 20, 26, 200), width=2)
    for k in range(rnd.randrange(2, 5)):
        ax = rnd.randint(bx0 + 24, bx0 + w - 44)
        ay = rnd.randint(by0 + 24, by0 + h - 44)
        d.rectangle([ax, ay, ax + 26, ay + 22], fill=(24, 25, 32, 255), outline=(52, 54, 66, 255), width=2)
        d.ellipse([ax + 5, ay + 4, ax + 21, ay + 18], outline=(70, 73, 86, 255), width=2)
        d.ellipse([ax + 11, ay + 9, ax + 15, ay + 13], fill=(90, 94, 108, 255))
    if rnd.random() < 0.5:
        sx = rnd.randint(bx0 + 20, max(bx0 + 21, bx0 + w - 70))
        sy = rnd.randint(by0 + 20, max(by0 + 21, by0 + h - 40))
        d.rectangle([sx, sy, sx + 44, sy + 16], fill=(90, 130, 160, 255), outline=(140, 180, 205, 255), width=2)
    if rnd.random() < 0.45:
        wx = rnd.randint(bx0 + 30, max(bx0 + 31, bx0 + w - 60))
        wy = rnd.randint(by0 + 30, max(by0 + 31, by0 + h - 60))
        d.ellipse([wx, wy, wx + 34, wy + 34], fill=(28, 30, 38, 255), outline=(58, 62, 74, 255), width=3)
        d.ellipse([wx + 8, wy + 8, wx + 26, wy + 26], outline=(48, 52, 64, 255), width=2)
    if wm != "day":
        glow = Image.new("RGBA", img.size, (0, 0, 0, 0))
        gd = ImageDraw.Draw(glow)
        ga = 40 if wm == "night" else 24
        gd.rectangle([bx0 - 6, by0 - 6, bx0 + w + 6, by0 + 16], fill=(255, 200, 120, ga))
        if b["kind"] == 1:
            gd.rectangle([bx0 - 6, by0 + h - 16, bx0 + w + 6, by0 + h + 6], fill=(255, 200, 120, ga - 10))
        glow = glow.filter(ImageFilter.GaussianBlur(6))
        img = Image.alpha_composite(img, glow)
        d = ImageDraw.Draw(img)
    if b["neon"] and wm != "day":
        nc = b["neon"]
        strip = Image.new("RGBA", img.size, (0, 0, 0, 0))
        sd = ImageDraw.Draw(strip)
        sd.rectangle([bx0 + 10, by0 + 2, bx0 + w - 10, by0 + 6], fill=nc + (255,))
        sd.rectangle([bx0 + 10, by0 + h - 6, bx0 + w - 10, by0 + h - 2], fill=nc + (200,))
        hal = Image.new("RGBA", img.size, (0, 0, 0, 0))
        hd2 = ImageDraw.Draw(hal)
        hd2.rectangle([bx0 + 2, by0 - 8, bx0 + w - 2, by0 + 14], fill=nc + (110,))
        hal = hal.filter(ImageFilter.GaussianBlur(10))
        img = Image.alpha_composite(img, hal)
        img = Image.alpha_composite(img, strip)
    if b["kind"] == 2:
        nc = b["neon2"] if night else (90, 84, 76)
        sw = min(120, w - 30)
        sx = bx0 + (w - sw) // 2
        img2 = Image.new("RGBA", img.size, (0, 0, 0, 0))
        id2 = ImageDraw.Draw(img2)
        id2.rectangle([sx, by0 + 8, sx + sw, by0 + 26], fill=nc + (235,))
        hal2 = img2.filter(ImageFilter.GaussianBlur(9))
        img = Image.alpha_composite(img, hal2)
        img = Image.alpha_composite(img, img2)
    return img


def make_tree_sprite(r, base_col):
    sz = int(r * 3.2)
    img = Image.new("RGBA", (sz, sz), (0, 0, 0, 0))
    cx = cy = sz / 2
    sh = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(sh).ellipse([cx - r + 4, cy - r + 6, cx + r + 4, cy + r + 6], fill=(0, 0, 4, 130))
    sh = sh.filter(ImageFilter.GaussianBlur(4))
    img = Image.alpha_composite(img, sh)
    d = ImageDraw.Draw(img)
    rnd = random.Random(int(r * 100))
    c1 = base_col
    c2 = tuple(min(255, int(v * 1.45)) for v in base_col)
    c3 = tuple(int(v * 0.6) for v in base_col)
    for k in range(6):
        a = k / 6 * math.tau + rnd.uniform(-0.3, 0.3)
        rr = r * rnd.uniform(0.62, 0.88)
        ox, oy = math.cos(a) * r * 0.3, math.sin(a) * r * 0.3
        d.ellipse([cx + ox - rr, cy + oy - rr, cx + ox + rr, cy + oy + rr], fill=c1 + (255,))
    d.ellipse([cx - r * 0.7, cy - r * 0.7, cx + r * 0.7, cy + r * 0.7], fill=c2 + (255,))
    d.ellipse([cx - r * 0.45, cy - r * 0.5, cx + r * 0.1, cy + r * 0.05], fill=tuple(min(255, int(v * 1.8)) for v in base_col) + (220,))
    d.ellipse([cx - r * 0.16, cy - r * 0.16, cx + r * 0.16, cy + r * 0.16], fill=c3 + (255,))
    return img


def make_alley_sprite(length):
    m = 24
    img = Image.new("RGBA", (110 + m * 2, int(length) + m * 2), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle([m, m, m + 110, m + int(length)], fill=(23, 24, 31, 255))
    d.line([(m, m), (m + 110, m)], fill=(44, 47, 60, 255), width=4)
    d.line([(m, m + int(length)), (m + 110, m + int(length))], fill=(44, 47, 60, 255), width=4)
    for yy in range(m + 30, m + int(length) - 24, 64):
        d.line([(m + 42, yy), (m + 68, yy)], fill=(96, 98, 110, 200), width=3)
    d.ellipse([m + 10, m + 22, m + 30, m + 42], fill=(34, 40, 36, 255), outline=(60, 68, 62, 255), width=2)
    d.ellipse([m + 80, m + int(length) - 46, m + 100, m + int(length) - 26],
              fill=(42, 38, 34, 255), outline=(68, 62, 56, 255), width=2)
    return img


def radial_pool(size, col, amax):
    yy, xx = np.mgrid[0:size, 0:size]
    dist = np.sqrt((xx - size / 2) ** 2 + (yy - size / 2) ** 2) / (size / 2)
    a = np.clip(1 - dist, 0, 1) ** 2.6 * amax
    arr = np.zeros((size, size, 4), dtype=np.uint8)
    arr[:, :, 0] = col[0]
    arr[:, :, 1] = col[1]
    arr[:, :, 2] = col[2]
    arr[:, :, 3] = a.astype(np.uint8)
    return Image.fromarray(arr, "RGBA")


def draw_landmark(d, T, tf):
    """بنای شناسه هر پیست — سایه‌وار روی زمین بلوک‌ها (نه روی مسیر)."""
    tid = T.tid
    R = T.rect
    rng = random.Random(555)

    def near_path(p, dist):
        return T.near_road(p) < dist

    def find_spot(want_far=True):
        for _ in range(400):
            p = (rng.uniform(R[0] + 400, R[2] - 400), rng.uniform(R[1] + 400, R[3] - 400))
            nd = T.near_road(p)
            if want_far and nd > 700:
                return p
            if not want_far and 500 < nd < 900:
                return p
        return (R[0] + 700, R[1] + 700)

    if tid == "valiasr":
        # ردیف درختان بلند ولیعصر داخل بلوک‌ها + برج میلاد دور
        p = find_spot()
        draw_milad(d, tf, p, 1.0)
    elif tid == "hemmat":
        p = find_spot()
        draw_milad(d, tf, p, 0.8)
        p2 = find_spot()
        draw_milad(d, tf, p2, 0.5)
    elif tid == "bazaar":
        p = find_spot()
        draw_bazaar_dome(d, tf, p)
    elif tid == "tajrish":
        draw_tochal(d, tf, R)
    elif tid == "azadi":
        p = find_spot()
        draw_azadi(d, tf, p, 1.0)
        p2 = find_spot()
        draw_milad(d, tf, p2, 0.55)


def draw_milad(d, tf, p, k):
    x, y = tf(p)
    # پایه هشت‌ضلعی + ساقه + سر نیلگون
    s = 1.0 * k
    d.polygon([(x - 60 * s, y + 70 * s), (x - 30 * s, y - 10 * s), (x + 30 * s, y - 10 * s),
               (x + 60 * s, y + 70 * s), (x + 30 * s, y + 120 * s), (x - 30 * s, y + 120 * s)],
              fill=(30, 32, 42, 255), outline=(70, 76, 96, 255))
    d.polygon([(x - 16 * s, y + 10 * s), (x - 9 * s, y - 240 * s), (x + 9 * s, y - 240 * s),
               (x + 16 * s, y + 10 * s)], fill=(38, 40, 52, 255))
    for i in range(9):
        yy = y + 10 * s - i * 26 * s
        d.line([(x - 12 * s, yy), (x + 12 * s, yy)], fill=(60, 64, 82, 255), width=max(1, int(2 * s)))
    d.ellipse([x - 46 * s, y - 300 * s, x + 46 * s, y - 208 * s], fill=(44, 60, 96, 255))
    d.ellipse([x - 30 * s, y - 286 * s, x + 30 * s, y - 222 * s], fill=(70, 96, 150, 255))
    d.ellipse([x - 10 * s, y - 322 * s, x + 10 * s, y - 302 * s], fill=(120, 150, 210, 255))


def draw_azadi(d, tf, p, k):
    x, y = tf(p)
    s = 1.35 * k
    col = (86, 72, 56, 255)
    hl = (128, 108, 82, 255)
    # چهار پایه ی شکل Y — نمای بالا به صورت صلیب با قوس‌های بزرگ
    d.rectangle([x - 200 * s, y - 60 * s, x + 200 * s, y + 60 * s], fill=col, outline=hl, width=3)
    d.rectangle([x - 60 * s, y - 200 * s, x + 60 * s, y + 200 * s], fill=col, outline=hl, width=3)
    d.ellipse([x - 90 * s, y - 90 * s, x + 90 * s, y + 90 * s], outline=hl, width=4)
    d.ellipse([x - 38 * s, y - 38 * s, x + 38 * s, y + 38 * s], fill=(30, 26, 22, 255))
    for q in [(1, 1), (-1, 1), (1, -1), (-1, -1)]:
        cx, cy = x + q[0] * 150 * s, y + q[1] * 150 * s
        d.ellipse([cx - 34 * s, cy - 34 * s, cx + 34 * s, cy + 34 * s], fill=col, outline=hl, width=3)


def draw_tochal(d, tf, R):
    # رشته‌کوه برف‌گرفته در لبه شمالی
    rng = random.Random(99)
    y0 = R[1] + 40
    x = R[0]
    pts = [(tf((x, y0 + 260)))]
    while x < R[2]:
        h = rng.uniform(140, 420)
        pts.append(tf((x, y0 + 260 - h)))
        pts.append(tf((x + rng.uniform(160, 320), y0 + 260 - rng.uniform(40, 160))))
        x += rng.uniform(320, 520)
    pts.append(tf((R[2], y0 + 300)))
    d.polygon(pts, fill=(64, 56, 74, 255))
    # برف قله‌ها — مثلث‌های روشن روی قله‌های بالا
    for i in range(1, len(pts) - 2):
        px, py = pts[i]
        if py < tf((0, y0 + 90))[1]:
            d.polygon([(px - 46, py), (px + 46, py), (px, py + 58)], fill=(210, 214, 228, 255))


def draw_bazaar_dome(d, tf, p):
    x, y = tf(p)
    d.ellipse([x - 130, y - 90, x + 130, y + 170], fill=(96, 78, 60, 255), outline=(140, 116, 88, 255), width=4)
    d.ellipse([x - 96, y - 60, x + 96, y + 140], fill=(122, 98, 72, 255))
    d.ellipse([x - 40, y - 20, x + 40, y + 60], fill=(70, 58, 46, 255))
    d.ellipse([x - 150, y + 60, x + 150, y + 200], fill=(86, 70, 56, 255))


def render_quad(T, qx, qy, buildings, alleys, greens, lamps, trees, parked, crosswalks):
    pal = T.pal
    R = T.rect
    RH, W = T.road_half, T.walk_half
    night = pal["night"]
    QW = (R[2] - R[0]) / 2
    QH = (R[3] - R[1]) / 2
    ox = R[0] + qx * QW - MARGIN
    oy = R[1] + qy * QH - MARGIN
    vw = int((QW + MARGIN * 2) * SS)
    vh = int((QH + MARGIN * 2) * SS)
    img = Image.new("RGB", (vw, vh), pal["sky"])
    d = ImageDraw.Draw(img)

    def Tf(p):
        return ((p[0] - ox) * SS, (p[1] - oy) * SS)

    # زمین + بلوک
    blk = random.Random(777)
    d.rectangle([Tf((R[0] - 50, R[1] - 50)), Tf((R[2] + 50, R[3] + 50))], fill=pal["ground"])
    bx = R[0]
    while bx < R[2]:
        by = R[1]
        while by < R[3]:
            c = tuple(min(255, v + blk.randrange(6)) for v in pal["blk"])
            d.rectangle([Tf((bx + 2, by + 2)), Tf((bx + 334, by + 290))], fill=c)
            by += 292
        bx += 336
    # پیاده‌رو
    d.polygon([Tf(p) for p in T.ribbon(W)], fill=pal["walk"])
    s = 0.0
    while s < T.track_len:
        p = T.path_at(s)
        dv = T.path_dir(s)
        for sgn in (1, -1):
            a = (p[0] - dv[1] * RH * sgn, p[1] + dv[0] * RH * sgn)
            b = (p[0] - dv[1] * W * sgn, p[1] + dv[0] * W * sgn)
            d.line([Tf(a), Tf(b)], fill=tuple(int(v * 0.82) for v in pal["walk"]), width=SS)
        s += 36
    d.line([Tf(p) for p in T.ribbon(RH + 3)], fill=pal["curb"], width=6 * SS, joint="curve")
    d.polygon([Tf(p) for p in T.ribbon(RH)], fill=pal["asphalt"])
    for off in (-62, 62):
        band = []
        for i in range(len(T.pts)):
            p = T.pts[i]
            dv = T.path_dir(i * T.pstep)
            nx, ny = -dv[1], dv[0]
            band.append((p[0] + nx * off - dv[0] * 17, p[1] + ny * off - dv[1] * 17))
        d.line([Tf(p) for p in band], fill=pal["wear"], width=34 * SS, joint="curve")
    rnd = random.Random(4242)
    s = 280.0
    while s < T.track_len - 300.0:
        p = T.path_at(s)
        dv = T.path_dir(s)
        nx, ny = -dv[1], dv[0]
        off = rnd.uniform(-85, 85)
        pc = (p[0] + nx * off, p[1] + ny * off)
        pw, ph = rnd.uniform(90, 190), rnd.uniform(40, 80)
        ang = math.atan2(dv[1], dv[0]) + rnd.uniform(-0.5, 0.5)
        ca, sa = math.cos(ang), math.sin(ang)
        pts = []
        for dx, dy in ((-pw / 2, -ph / 2), (pw / 2, -ph / 2), (pw / 2, ph / 2), (-pw / 2, ph / 2)):
            pts.append(Tf((pc[0] + dx * ca - dy * sa, pc[1] + dx * sa + dy * ca)))
        lite = rnd.random() < 0.4
        d.polygon(pts, fill=tuple(int(v * 1.2) for v in pal["asphalt"]) if lite else tuple(int(v * 0.85) for v in pal["asphalt"]))
        s += rnd.uniform(360, 520)
    s = 300.0
    while s < T.track_len - 300.0:
        p = T.path_at(s)
        dv = T.path_dir(s)
        nx, ny = -dv[1], dv[0]
        pc = (p[0] + nx * rnd.uniform(-80, 80), p[1] + ny * rnd.uniform(-80, 80))
        cx, cy = Tf(pc)
        d.ellipse([cx - 12 * SS, cy - 12 * SS, cx + 12 * SS, cy + 12 * SS], fill=tuple(int(v * 0.8) for v in pal["asphalt"]))
        d.ellipse([cx - 12 * SS, cy - 12 * SS, cx + 12 * SS, cy + 12 * SS], outline=pal["wear"], width=2 * SS)
        s += 760
    # خط‌کشی
    for off in (-116, 116):
        band = []
        for i in range(len(T.pts)):
            p = T.pts[i]
            dv = T.path_dir(i * T.pstep)
            nx, ny = -dv[1], dv[0]
            band.append((p[0] + nx * off, p[1] + ny * off))
        d.line([Tf(p) for p in band], fill=(148, 152, 164), width=5 * SS, joint="curve")
    for off in (-5, 5):
        band = []
        for i in range(len(T.pts)):
            p = T.pts[i]
            dv = T.path_dir(i * T.pstep)
            nx, ny = -dv[1], dv[0]
            band.append((p[0] + nx * off, p[1] + ny * off))
        d.line([Tf(p) for p in band], fill=(120, 100, 38), width=4 * SS, joint="curve")
    s = 0.0
    while s < T.track_len:
        p = T.path_at(s)
        dv = T.path_dir(s)
        nx, ny = -dv[1], dv[0]
        for off in (-62, 62):
            a = (p[0] + nx * off, p[1] + ny * off)
            b = (a[0] + dv[0] * 52, a[1] + dv[1] * 52)
            d.line([Tf(a), Tf(b)], fill=(120, 122, 134), width=4 * SS)
        s += 128
    for cw in crosswalks:
        p = T.path_at(cw)
        dv = T.path_dir(cw)
        nx, ny = -dv[1], dv[0]
        off = -RH + 26
        while off < RH - 26:
            a = (p[0] + nx * off - dv[0] * 15, p[1] + ny * off - dv[1] * 15)
            b = (p[0] + nx * off + dv[0] * 15, p[1] + ny * off + dv[1] * 15)
            d.line([Tf(a), Tf(b)], fill=(150, 154, 166), width=15 * SS)
            off += 42
    for i in sorted(T.arc_idx):
        if (i - 1) in T.arc_idx and (i + 1) in T.arc_idx and i % 3 != 0:
            continue
        p = T.pts[i % len(T.pts)]
        dv = T.path_dir(i * T.pstep)
        nx, ny = -dv[1], dv[0]
        dv2 = T.path_dir((i + 8) * T.pstep)
        cross = dv[0] * dv2[1] - dv[1] * dv2[0]
        sgn = 1 if cross > 0 else -1
        a = (p[0] + nx * sgn * (RH - 12), p[1] + ny * sgn * (RH - 12))
        b = (p[0] + nx * sgn * (RH + 8), p[1] + ny * sgn * (RH + 8))
        col = (150, 44, 34) if (i // 3) % 2 == 0 else (138, 140, 148)
        d.line([Tf(a), Tf(b)], fill=col, width=10 * SS)
    # خط شروع شطرنجی
    st = T.path_at(0)
    sd = T.path_dir(0)
    sn = (-sd[1], sd[0])
    cell = 30.0
    for row in range(2):
        for c in range(8):
            px0 = st[0] + sn[0] * (-RH + c * 32.5 + 4) + sd[0] * row * cell
            py0 = st[1] + sn[1] * (-RH + c * 32.5 + 4) + sd[1] * row * cell
            col = (210, 210, 216) if (row + c) % 2 == 0 else (18, 18, 24)
            poly = [Tf((px0, py0)), Tf((px0 + sn[0] * 30, py0 + sn[1] * 30)),
                    Tf((px0 + sn[0] * 30 + sd[0] * cell, py0 + sn[1] * 30 + sd[1] * cell)),
                    Tf((px0 + sd[0] * cell, py0 + sd[1] * cell))]
            d.polygon(poly, fill=col)

    img = img.convert("RGBA")

    def paste_rot(base, spr, pos, ang_deg):
        r = spr.rotate(-ang_deg + 90, expand=True, resample=Image.BICUBIC)
        px, py = Tf(pos)
        base.paste(r, (int(px - r.size[0] / 2), int(py - r.size[1] / 2)), r)

    # بنای شناسه (زیر درخت‌ها/ساختمان‌ها)
    draw_landmark(d, T, Tf)
    for L in lamps:
        pool = radial_pool(210, pal["lamp"], pal["lamp_a"])
        px, py = Tf(L["pos"])
        img.alpha_composite(pool, (int(px - 105), int(py - 105)))
    for A in alleys:
        paste_rot(img, make_alley_sprite(A["len"]), A["pos"], A["rot"])
    for G in greens:
        gxp, gyp = Tf(G["pos"])
        rr = G["r"] * SS
        d.ellipse([gxp - rr, gyp - rr * 0.8, gxp + rr, gyp + rr * 0.8], fill=tuple(int(v * 0.7) for v in pal["tree"]))
        d.ellipse([gxp - rr * 0.7, gyp - rr * 0.55, gxp + rr * 0.7, gyp + rr * 0.55], fill=pal["tree"])
    for i, P in enumerate(parked):
        paste_rot(img, CAR_SPR[["traf_white", "traf_gray", "traf_taxi"][i % 3]], P["pos"], P["rot"])
    for i, Tr in enumerate(trees):
        paste_rot(img, TREE_SPRITES[T.tid][i], Tr["pos"], 0)
    for i, b in enumerate(buildings):
        paste_rot(img, ROOF_SPRITES[T.tid][i], b["pos"], b["rot"])
    d = ImageDraw.Draw(img)
    for L in lamps:
        px, py = Tf(L["pos"])
        d.ellipse([px - 5 * SS, py - 5 * SS, px + 5 * SS, py + 5 * SS], fill=(255, 232, 170, 255))
        d.ellipse([px - 8 * SS, py - 8 * SS, px + 8 * SS, py + 8 * SS], fill=(255, 220, 140, 90))
    p = T.path_at(0)
    dv = T.path_dir(0)
    nn = (-dv[1], dv[0])
    a = (p[0] + nn[0] * (RH + 16), p[1] + nn[1] * (RH + 16))
    b2 = (p[0] - nn[0] * (RH + 16), p[1] - nn[1] * (RH + 16))
    gl = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(gl).line([Tf(a), Tf(b2)], fill=(90, 210, 255, 46), width=60 * SS)
    gl = gl.filter(ImageFilter.GaussianBlur(16 * SS / 2))
    img = Image.alpha_composite(img, gl)

    img = img.resize((int(img.size[0] * DS / SS), int(img.size[1] * DS / SS)), Image.LANCZOS)
    cw, chh = int(QW * DS), int(QH * DS)
    cx0 = int(round(MARGIN * DS))
    cy0 = int(round(MARGIN * DS))
    tile = img.crop((cx0, cy0, cx0 + cw, cy0 + chh))
    arr = np.asarray(tile, dtype=np.int16)
    g = np.random.RandomState(qx * 3 + qy + 9).randint(-4, 4, (chh, cw, 1), dtype=np.int16)
    arr = np.clip(arr + g, 0, 255).astype(np.uint8)
    tile = Image.fromarray(arr.astype(np.uint8)[:, :, :3], "RGB")
    ln = LEVEL_NUM[T.tid]
    tile.save(os.path.join(OUT, "l%d_map_%d.jpg" % (ln, qy * 2 + qx)), quality=88)
    print("  tile l%d_%d" % (ln, qy * 2 + qx), tile.size, flush=True)


def bake(tid):
    print("== track:", tid, flush=True)
    T = Track(tid)
    buildings, alleys, greens, lamps, trees, parked, crosswalks = place_city(T)
    print("  city:", len(buildings), "bld /", len(trees), "tree / len=", int(T.track_len), flush=True)
    ROOF_SPRITES[tid] = [make_roof_sprite(b, T.pal, T.pal["night"]) for b in buildings]
    TREE_SPRITES[tid] = [make_tree_sprite(x["r"], T.pal["tree"]) for x in trees]
    globals()["ROOF_SPRITES"] = ROOF_SPRITES
    globals()["TREE_SPRITES"] = TREE_SPRITES
    for qx in (0, 1):
        for qy in (0, 1):
            render_quad(T, qx, qy, buildings, alleys, greens, lamps, trees, parked, crosswalks)
    layout = {
        "meta": {
            "rect": list(T.rect), "scale": DS, "road_half": T.road_half, "walk_half": T.walk_half,
            "track_len": T.track_len, "pstep": T.pstep,
            "start": {"pos": [T.path_at(0)[0], T.path_at(0)[1]],
                      "ang": math.degrees(math.atan2(T.path_dir(0)[1], T.path_dir(0)[0]))},
            "world_min": [T.rect[0] + 60, T.rect[1] + 60],
            "world_max": [T.rect[2] - 60, T.rect[3] - 60],
        },
        "centerline": [[round(x, 1), round(y, 1)] for x, y in T.pts],
        "buildings": [[b["pos"][0], b["pos"][1], round(b["rot"], 2), round(b["w"], 1), round(b["h"], 1)] for b in buildings],
        "solids": [[round(x["pos"][0], 1), round(x["pos"][1], 1), 18] for x in trees]
                  + [[round(L["pos"][0], 1), round(L["pos"][1], 1), 7] for L in lamps]
                  + [[round(P["pos"][0], 1), round(P["pos"][1], 1), 46] for P in parked],
        "lamps": [[round(L["pos"][0], 1), round(L["pos"][1], 1)] for L in lamps],
        "parked": [[P["pos"][0], P["pos"][1], round(P["rot"], 2)] for P in parked],
        "crosswalks": [round(c, 1) for c in crosswalks],
        "theme": {"tid": tid, "ambient": list(T.pal["ambient"]), "under": list(T.pal["under"]),
                  "night": T.pal["night"]},
    }
    with open(os.path.join(DATA, "track_%s.json" % tid), "w") as f:
        json.dump(layout, f)
    print("  json saved:", tid, os.path.getsize(os.path.join(DATA, "track_%s.json" % tid)) // 1024, "KB", flush=True)


ROOF_SPRITES = {}
TREE_SPRITES = {}
LEVEL_NUM = {"valiasr": 1, "hemmat": 2, "bazaar": 3, "tajrish": 4, "azadi": 5}
CAR_SPR = {}
for cid in ("traf_white", "traf_gray", "traf_taxi"):
    pth = os.path.join(OUT, cid + "_top.png")
    if os.path.exists(pth):
        CAR_SPR[cid] = Image.open(pth).convert("RGBA")
    else:
        CAR_SPR[cid] = Image.new("RGBA", (180, 90), (90, 90, 96, 255))

if __name__ == "__main__":
    only = sys.argv[1:] if len(sys.argv) > 1 else ["valiasr", "hemmat", "bazaar", "tajrish", "azadi"]
    for tid in only:
        bake(tid)
    print("ALL DONE", flush=True)
