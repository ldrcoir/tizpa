extends Node
## سامان — هستهٔ تیز پا: مراحل، ماشین‌ها، متن‌ها، ذخیره‌سازی (تک‌منبعِ حقیقت)

const MASIR_ZAKHIRE := "user://tizpa_save.json"

# نسخهٔ بازی — منو/آغاز از همین می‌خوانند (دست‌نویس ممنوع)
const NOSKHE := "1.2"
const SAKHT := 3

# ───────────────── ۵ مرحله — متنوع در فرم/زمان روز/چالش ─────────────────
const MARHALEHA := [
	{
		"shomare": 1, "nam": "ولی‌عصر", "masir": "valiasr",
		"dorha": 3, "raghiban": 3, "maharat": 0.90, "trafik": 0.9,
		"tozih": "بلوار درختی غروب — جای یادگیری دریفت",
		"tasvir": "res://assets/sprites/thumb_valiasr.png",
		"musighi": "moosighi_1",
	},
	{
		"shomare": 2, "nam": "همت", "masir": "hemmat",
		"dorha": 3, "raghiban": 3, "maharat": 0.96, "trafik": 1.4,
		"tozih": "اتوبان پهنی شب — سرعت خالص، مواظب تاکسی‌ها باش",
		"tasvir": "res://assets/sprites/thumb_hemmat.png",
		"musighi": "moosighi_2",
	},
	{
		"shomare": 3, "nam": "بازار", "masir": "bazaar",
		"dorha": 4, "raghiban": 3, "maharat": 1.0, "trafik": 1.1,
		"tozih": "کوچه‌های تنگ روز بازار — پیچ‌ها بیرحماند",
		"tasvir": "res://assets/sprites/thumb_bazaar.png",
		"musighi": "moosighi_3",
	},
	{
		"shomare": 4, "nam": "تجریش", "masir": "tajrish",
		"dorha": 3, "raghiban": 3, "maharat": 1.05, "trafik": 1.2,
		"tozih": "مارپیچ شمال شهر زیر سایهٔ توچال",
		"tasvir": "res://assets/sprites/thumb_tajrish.png",
		"musighi": "moosighi_4",
	},
	{
		"shomare": 5, "nam": "آزادی", "masir": "azadi",
		"dorha": 4, "raghiban": 3, "maharat": 1.10, "trafik": 1.5,
		"tozih": "فینال نیمه‌شب زیر بنای آزادی — فقط شاهین‌ها می‌برند",
		"tasvir": "res://assets/sprites/thumb_azadi.png",
		"musighi": "moosighi_5",
	},
]

# ماشین بازیکن — هلیا
const MASHINHA := [
	{
		"shenase": "helia", "nam": "هلیا", "en": "Helia",
		"tozih": "کوپه فیروزه‌ای هلیا — سبک، تیز و آرم‌بیمرحوم",
		"tasvir": "res://assets/sprites/helia_top.png",
		"chabok": 1.0, "shetab": 1.12, "mohkam": 1.0, "gheymat": 0
	},
]

var mashin_entekhabi: int = 0
var setare_marhale := {}   # شماره → ستاره (۰..۳)
var behtarin_marhale := {} # شماره → بهترین زمان (ثانیه)
var bolandi_moosighi := 0.8
var bolandi_seda := 0.9

const ZABANHA := {
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
	"locked": {"fa": "قفله! قبلی رو ببر", "en": "Locked! Win previous"},
}

func matn(klid: String) -> String:
	if ZABANHA.has(klid):
		return ZABANHA[klid]["fa"]
	return klid

func _ready() -> void:
	bargozari()

func marhale_baz(shomare: int) -> bool:
	if shomare <= 1:
		return true
	return setare_marhale.has(shomare - 1) and int(setare_marhale[shomare - 1]) > 0

func behtarin_zaman(shomare: int) -> float:
	return float(behtarin_marhale.get(shomare, -1.0))

func sabte_natije(shomare: int, rotbe: int, zaman: float) -> int:
	var setare := clampi(4 - rotbe, 0, 3)
	if rotbe <= 3:
		var ghadim := int(setare_marhale.get(shomare, 0))
		setare_marhale[shomare] = maxi(ghadim, setare)
	var ghadim_z := float(behtarin_marhale.get(shomare, -1.0))
	if ghadim_z < 0.0 or zaman < ghadim_z:
		behtarin_marhale[shomare] = zaman
	zakhire()
	return setare

func zakhire() -> void:
	var dade := {
		"stars": setare_marhale,
		"best": behtarin_marhale,
		"music_vol": bolandi_moosighi,
		"sfx_vol": bolandi_seda,
	}
	var f := FileAccess.open(MASIR_ZAKHIRE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(dade))
		f.close()

func bargozari() -> void:
	if not FileAccess.file_exists(MASIR_ZAKHIRE):
		return
	var f := FileAccess.open(MASIR_ZAKHIRE, FileAccess.READ)
	if f == null:
		return
	var dade = JSON.parse_string(f.get_as_text())
	if dade == null:
		return
	var st = dade.get("stars", {})
	setare_marhale.clear()
	for k in st:
		setare_marhale[int(k)] = int(st[k])
	var bz = dade.get("best", {})
	behtarin_marhale.clear()
	for k in bz:
		behtarin_marhale[int(k)] = float(bz[k])
	bolandi_moosighi = clampf(float(dade.get("music_vol", 0.8)), 0.0, 1.0)
	bolandi_seda = clampf(float(dade.get("sfx_vol", 0.9)), 0.0, 1.0)
	f.close()

func amalkard() -> Dictionary:
	var c = MASHINHA[mashin_entekhabi]
	return {
		"chabok": float(c["chabok"]),
		"shetab": float(c["shetab"]),
		"mohkam": float(c["mohkam"]),
		"turbo": 1.25,
	}
