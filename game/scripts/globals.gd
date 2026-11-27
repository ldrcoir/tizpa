extends Node
## Globals — تیز پا (Caspian Studio)
## سطوح/پیشرفت/تنظیمات/متن — تنها منبع حقیقت نسخه

const SAVE_PATH := "user://tizpa_save.json"

# نسخه بازی — منو/بوت از همین می‌خوانند (دست‌نویس ممنوع)
const VERSION := "1.1"
const BUILD := 2

# ─────────────── ۵ مرحله — متنوع در فرم/زمان روز/چالش ───────────────
const LEVELS := [
        {
                "id": 1, "name": "ولیعصر", "track": "valiasr",
                "laps": 3, "rivals": 3, "skill": 0.90, "traffic": 0.9,
                "desc": "بلوار درختی غروب — جای یادگیری دریفت",
                "thumb": "res://assets/sprites/thumb_valiasr.png",
        },
        {
                "id": 2, "name": "همت", "track": "hemmat",
                "laps": 3, "rivals": 3, "skill": 0.96, "traffic": 1.4,
                "desc": "اتوبان پهنِ شب — سرعت خالص، مواظب تاکسی‌ها باش",
                "thumb": "res://assets/sprites/thumb_hemmat.png",
        },
        {
                "id": 3, "name": "بازار", "track": "bazaar",
                "laps": 4, "rivals": 3, "skill": 1.0, "traffic": 1.1,
                "desc": "کوچه‌های تنگ روز بازار — پیچ‌ها بیرحم‌اند",
                "thumb": "res://assets/sprites/thumb_bazaar.png",
        },
        {
                "id": 4, "name": "تجریش", "track": "tajrish",
                "laps": 3, "rivals": 3, "skill": 1.05, "traffic": 1.2,
                "desc": "مارپیچ شمال شهر زیر سایه‌ی توچال",
                "thumb": "res://assets/sprites/thumb_tajrish.png",
        },
        {
                "id": 5, "name": "آزادی", "track": "azadi",
                "laps": 4, "rivals": 3, "skill": 1.10, "traffic": 1.5,
                "desc": "فینال نیمه‌شب زیر بنای آزادی — فقط شاهین‌ها می‌برند",
                "thumb": "res://assets/sprites/thumb_azadi.png",
        },
]

# ماشین بازیکن — هلیا
const CARS := [
        {
                "id": "helia", "name": "هلیا", "en": "Helia",
                "desc": "کوپه فیروزه‌ای هلیا — سبک، تیز و آرام‌بی‌رحم",
                "tex": "res://assets/sprites/helia_top.png",
                "jump": 1.0, "accel": 1.12, "tough": 1.0, "price": 0
        },
]

var selected_car: int = 0
var level_stars := {}   # id -> ستاره (۰..۳)
var level_best := {}    # id -> بهترین زمان (ثانیه)
var music_vol := 0.8
var sfx_vol := 0.9

const I18N := {
        "go": {"fa": "برو!", "en": "GO!"},
        "pos": {"fa": "جایگاه", "en": "POS"},
        "paused": {"fa": "توقف", "en": "Paused"},
        "win": {"fa": "پیروزی!", "en": "Victory!"},
        "lose": {"fa": "باختی! دوباره", "en": "Defeat! Retry"},
        "next": {"fa": "مرحله بعد", "en": "Next"},
        "retry": {"fa": "دوباره", "en": "Retry"},
        "menu": {"fa": "منو", "en": "Menu"},
        "nitro": {"fa": "نیترو", "en": "NITRO"},
        "mission": {"fa": "مرحله", "en": "Stage"},
        "level": {"fa": "مرحله", "en": "Stage"},
        "locked": {"fa": "قفله! قبلی را ببر", "en": "Locked! Win previous"},
}

func L(key: String) -> String:
        if I18N.has(key):
                return I18N[key]["fa"]
        return key

func _ready() -> void:
        load_save()

func level_unlocked(id: int) -> bool:
        if id <= 1:
                return true
        return level_stars.has(id - 1) and int(level_stars[id - 1]) > 0

func best_time(id: int) -> float:
        return float(level_best.get(id, -1.0))

func set_result(id: int, rank: int, race_time: float) -> int:
        var stars := clampi(4 - rank, 0, 3)
        if rank <= 3:
                var old := int(level_stars.get(id, 0))
                level_stars[id] = maxi(old, stars)
        var oldb := float(level_best.get(id, -1.0))
        if oldb < 0.0 or race_time < oldb:
                level_best[id] = race_time
        save_game()
        return stars

func save_game() -> void:
        var data := {
                "stars": level_stars,
                "best": level_best,
                "music_vol": music_vol,
                "sfx_vol": sfx_vol,
        }
        var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
        if f:
                f.store_string(JSON.stringify(data))
                f.close()

func load_save() -> void:
        if not FileAccess.file_exists(SAVE_PATH):
                return
        var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
        if f == null:
                return
        var data = JSON.parse_string(f.get_as_text())
        if data == null:
                return
        var ls = data.get("stars", {})
        level_stars.clear()
        for k in ls:
                level_stars[int(k)] = int(ls[k])
        var lb = data.get("best", {})
        level_best.clear()
        for k in lb:
                level_best[int(k)] = float(lb[k])
        music_vol = clampf(float(data.get("music_vol", 0.8)), 0.0, 1.0)
        sfx_vol = clampf(float(data.get("sfx_vol", 0.9)), 0.0, 1.0)
        f.close()

func car_stats() -> Dictionary:
        var c = CARS[selected_car]
        return {
                "jump": float(c["jump"]),
                "accel": float(c["accel"]),
                "tough": float(c["tough"]),
                "turbo": 1.25,
        }
