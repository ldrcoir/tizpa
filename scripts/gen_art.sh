#!/bin/bash
# تولید هنر تیز پا — هلیا (پوشیده و محترمانه) + تهران + ۵ مرحله
# خروجی: /home/z/my-project/tizpa/art_raw/
set -u
O=/home/z/my-project/tizpa/art_raw
mkdir -p "$O"
cd "$O"

gen() { # $1=name $2=size $3=prompt
  if [ -s "$1.png" ]; then echo "SKIP $1"; return; fi
  echo "== $1 =="
  z-ai image -p "$3" -o "$1.png" -s "$2" 2>&1 | tail -1
}

STYLE="stylized realistic game key art, cinematic lighting, vibrant colors, high quality, detailed, no text, no letters, no watermark, no logo"

# ۱) پس‌زمینه منو — تهران شب + هلیا کنار ماشین
gen menu_bg 1344x768 "Night Tehran street racing scene, glowing Milad Tower in background skyline, wet asphalt with neon reflections, a sleek teal sports coupe parked on the right side, a young Iranian woman wearing modest dark hijab headscarf and loose long racing jacket standing proudly beside the car with arms crossed, purple and orange neon signs on buildings, atmospheric haze, $STYLE"

# ۲) پرتره هلیا — راننده
gen helia 864x1152 "Portrait of a young Iranian female street racer wearing a modest dark hijab headscarf and a loose long teal racing jacket fully covering her body, confident warm smile, standing in a neon-lit Tehran garage at night, sports car blurred behind, $STYLE"

# ۳) ماشین قهرمان — سه‌رخ
gen hero_car 1344x768 "Sleek teal cyan sports coupe, three-quarter front view, parked on wet night street in Tehran, glowing headlights, neon city reflections on paint, Milad Tower far in background, $STYLE"

# ۴) آیکون بازی
gen icon 1024x1024 "Bold racing game icon, stylized top view of a teal sports car drifting with tire smoke and speed lines, dark blue background with gold racing stripe accents, $STYLE"

# ۵-۹) پنج مرحله
gen thumb_valiasr 1152x864 "Golden dusk on Valiasr street Tehran, long avenue lined with tall plane trees, warm sunset light through leaves, classic Persian buildings, a sports car speeding down the avenue, $STYLE"
gen thumb_hemmat 1152x864 "Midnight highway racing in Tehran, wide elevated freeway with light trails, highway lights stretching to horizon, city glow, sports car at high speed, $STYLE"
gen thumb_bazaar 1152x864 "Daytime narrow street near Tehran Grand Bazaar, dense shops with colorful awnings, brick walls, arched doorways, warm sunlight, a compact car weaving through, $STYLE"
gen thumb_tajrish 1152x864 "Sunset in northern Tehran Tajrish district, pink and orange sky over snowy Tochal mountain range, upscale streets below with lights turning on, sports car on curvy road, $STYLE"
gen thumb_azadi 1152x864 "Midnight at Azadi Tower Tehran, glowing monument with Persian geometric patterns, night street racing with neon lights, dramatic sky, sports car drifting in foreground, $STYLE"

echo "=== DONE ==="
ls -la "$O"
