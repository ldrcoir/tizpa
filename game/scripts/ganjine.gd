extends RefCounted
## Ganjine — کانتینر کدگذاری‌شده BVAULT (نسخه ۱)
## فرمت: "BVAULT1" + نسخه(1B) + noun(12B) + payload(ChaCha20)
## کلید = SHA256(partA ‖ partB) — partA ماسک‌شده در کد، partB سهم سرور (فعلاً fallback آفلاین)
## هیچ محتوای رمزگشایی‌شده روی دیسک نوشته نمی‌شود؛ فقط در حافظه پارس می‌شود.
## اصل پروژه: در نسخه ریلیز (غیر debug) فقط .bvault پذیرفته می‌شود.

const MAGIC := "BVAULT1"

# جدول partA با ماسک حسابی (0x37 + i*0x9D) — بازسازی در زمان اجرا
const _KAL_A := [39, 243, 42, 42, 212, 142, 238, 168, 57, 181, 107, 0, 114, 76, 237, 229,
                222, 229, 138, 120, 126, 24, 58, 100, 28, 86, 7, 167, 201, 71, 121, 243]
const _KAL_B := [106, 251, 97, 223, 47, 160, 177, 141, 240, 111, 25, 150, 236, 135, 93, 70]

static var _kashid_anbar: PackedByteArray = PackedByteArray()

static func _posh(i: int) -> int:
        return (0x37 + i * 0x9D) & 0xFF

## سهم سرور: اگر res://dadeh/online.json کلید بدهد از آنجا می‌آید؛ وگرنه fallback
static func _bakhsh_b() -> PackedByteArray:
        var khoruji := PackedByteArray()
        for i in 16:
                khoruji.append(_KAL_B[i] ^ _posh(i))
        return khoruji

static func _begir_kalid() -> PackedByteArray:
        if _kashid_anbar.size() == 32:
                return _kashid_anbar
        var bakhsh_a := PackedByteArray()
        for i in 32:
                bakhsh_a.append(_KAL_A[i] ^ _posh(i))
        var baft_hash := HashingContext.new()
        baft_hash.start(HashingContext.HASH_SHA256)
        baft_hash.update(bakhsh_a)
        baft_hash.update(_bakhsh_b())
        _kashid_anbar = baft_hash.finish()
        return _kashid_anbar

# ---------- ChaCha20 (RFC 8439) خالص GDScript ----------
static func _le32(b: PackedByteArray, off: int) -> int:
        return (b[off] | (b[off + 1] << 8) | (b[off + 2] << 16) | (b[off + 3] << 24)) & 0xFFFFFFFF

static func _charkh_chap(v: int, c: int) -> int:
        # ⛔ فیکس باگ BVAULT: PackedInt32Array مقادیر بالای bit31 را منفی ذخیره می‌کند
        # و شیفت راستِ GDScript روی منفی «حسابی» است — بدون ماسک، بیت‌های علامت
        # به نتیجه می‌ریزند و کلید-استریم خراب می‌شود (سناریو روی گوشی باز نمی‌شد)
        return ((v << c) & 0xFFFFFFFF) | ((v & 0xFFFFFFFF) >> (32 - c))

static func _charkh_raqami(s: PackedInt32Array, a: int, b: int, c: int, d: int) -> void:
        s[a] = (s[a] + s[b]) & 0xFFFFFFFF; s[d] = _charkh_chap(s[d] ^ s[a], 16)
        s[c] = (s[c] + s[d]) & 0xFFFFFFFF; s[b] = _charkh_chap(s[b] ^ s[c], 12)
        s[a] = (s[a] + s[b]) & 0xFFFFFFFF; s[d] = _charkh_chap(s[d] ^ s[a], 8)
        s[c] = (s[c] + s[d]) & 0xFFFFFFFF; s[b] = _charkh_chap(s[b] ^ s[c], 7)

static func _chacha20_yai(key: PackedByteArray, noun: PackedByteArray, dadeh: PackedByteArray, counter0: int = 0) -> PackedByteArray:
        var khoruji := PackedByteArray()
        khoruji.resize(dadeh.size())
        var tedad_blok := (dadeh.size() + 63) / 64
        for blok in tedad_blok:
                var vaziat := PackedInt32Array([0x61707865, 0x3320646E, 0x79622D32, 0x6B206574,
                        _le32(key, 0), _le32(key, 4), _le32(key, 8), _le32(key, 12),
                        _le32(key, 16), _le32(key, 20), _le32(key, 24), _le32(key, 28),
                        (counter0 + blok) & 0xFFFFFFFF,
                        _le32(noun, 0), _le32(noun, 4), _le32(noun, 8)])
                var kar := PackedInt32Array(vaziat)
                for gamm_r in 10:
                        _charkh_raqami(kar, 0, 4, 8, 12); _charkh_raqami(kar, 1, 5, 9, 13); _charkh_raqami(kar, 2, 6, 10, 14); _charkh_raqami(kar, 3, 7, 11, 15)
                        _charkh_raqami(kar, 0, 5, 10, 15); _charkh_raqami(kar, 1, 6, 11, 12); _charkh_raqami(kar, 2, 7, 8, 13); _charkh_raqami(kar, 3, 4, 9, 14)
                var paye := blok * 64
                for j in 16:
                        var vazhe := (kar[j] + vaziat[j]) & 0xFFFFFFFF
                        for k in 4:
                                var neshane := paye + j * 4 + k
                                if neshane < dadeh.size():
                                        khoruji[neshane] = dadeh[neshane] ^ ((vazhe >> (8 * k)) & 0xFF)
        return khoruji

# ---------- API عمومی ----------
## باز کردن .bvault → بایت‌های اصلی؛ خرابی = PackedByteArray خالی
static func baz_kon_bvault(masir: String) -> PackedByteArray:
        if not FileAccess.file_exists(masir):
                return PackedByteArray()
        var f := FileAccess.open(masir, FileAccess.READ)
        if f == null:
                return PackedByteArray()
        var gologle := f.get_buffer(f.get_length())
        f.close()
        if gologle.size() < 21 or gologle.slice(0, 7).get_string_from_ascii() != MAGIC:
                return PackedByteArray()
        var noun := gologle.slice(8, 20)
        return _chacha20_yai(_begir_kalid(), noun, gologle.slice(20))

## لود JSON: ریلیز فقط vault؛ حالت توسعه fallback هم‌نام .json
static func khandan_json(masir: String) -> Dictionary:
        var paye := masir.get_basename()
        var dadeh := baz_kon_bvault(paye + ".bvault")
        var tajzie_shode = null
        if not dadeh.is_empty():
                tajzie_shode = JSON.parse_string(dadeh.get_string_from_utf8())
                if tajzie_shode is Dictionary:
                        return tajzie_shode
                push_warning("BVAULT parse failed: " + paye + ".bvault")
        if OS.is_debug_build():
                # fallback توسعه: خزانه نبود یا خراب بود → پلین JSON کنارش
                var masir_json := paye + ".json"
                if FileAccess.file_exists(masir_json):
                        var f := FileAccess.open(masir_json, FileAccess.READ)
                        if f != null:
                                var t2 = JSON.parse_string(f.get_as_text())
                                if t2 is Dictionary:
                                        return t2
        return {}

## تست سلامت: خودِ لودر باید بتواند یک فایل تست رمزشده را بخواند
static func azmoon_khod() -> bool:
        # ۱) بردار استاندارد RFC 8439 §2.4.2 — جواب درست از بیرون آمده،
        # پس اگر پیاده‌سازی خراب شود (مثل باگ rotl منفی) این تست می‌گیردش؛
        # راند‌تریپ متقارنِ ساده این باگ را پنهان می‌کرد!
        var kalid_rfc := PackedByteArray()
        for i in 32:
                kalid_rfc.append(i)
        var noun_rfc := PackedByteArray()
        for b in PackedByteArray([0, 0, 0, 0, 0, 0, 0, 0x4a, 0, 0, 0, 0]):
                noun_rfc.append(b)
        var matn_rfc := "Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it.".to_utf8_buffer()
        var hex_entezar := "6e2e359a2568f98041ba0728dd0d6981e97e7aec1d4360c20a27afccfd9fae0bf91b65c5524733ab8f593dabcd62b3571639d624e65152ab8f530c359f0861d807ca0dbf500d6a6156a38e088a22b65e52bc514d16ccf806818ce91ab77937365af90bbf74a35be6b40b8eedf2785e42874d"
        var deedeh := _chacha20_yai(kalid_rfc, noun_rfc, matn_rfc, 1)
        if deedeh.hex_encode() != hex_entezar:
                push_error("BVAULT azmoon_khod: RFC 8439 vector FAILED")
                return false
        # ۲) راند‌تریپ UTF-8
        var matn := "سلام از ناخدای vault — بوقی!"
        var pegham := matn.to_utf8_buffer()
        var noun := PackedByteArray()
        noun.resize(12)
        for i in 12:
                noun[i] = (i * 7 + 3) & 0xFF
        var ramz_shode := _chacha20_yai(_begir_kalid(), noun, pegham)
        var baz_ramz := _chacha20_yai(_begir_kalid(), noun, ramz_shode)
        return baz_ramz == pegham and baz_ramz.get_string_from_utf8() == matn
