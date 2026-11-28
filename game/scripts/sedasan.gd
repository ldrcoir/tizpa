extends Node
## سداسان — مدیریت صدا: موسیقی هر مرحله، موتور، لاستیک، باد، افکت‌ها

var seda_ha := {}
var bolandi_moosighi := 0.8
var bolandi_seda := 0.9
var pakhsh_moosighi: AudioStreamPlayer
var pakhsh_moharrek: AudioStreamPlayer
var pakhsh_lastik: AudioStreamPlayer
var pakhsh_bad: AudioStreamPlayer
var pakhsh_ui: AudioStreamPlayer
var moosighi_konuni := ""

func _ready() -> void:
	for n in ["horn", "coin", "jump", "boost", "crash", "win", "fail", "clank", "nitro", "lap", "beep", "shift", "ui", "done"]:
		var masir := "res://assets/audio/%s.wav" % n
		if ResourceLoader.exists(masir):
			seda_ha[n] = load(masir)
	pakhsh_moosighi = AudioStreamPlayer.new()
	bolandi_moosighi = Saman.bolandi_moosighi
	bolandi_seda = Saman.bolandi_seda
	pakhsh_moosighi.volume_db = -6.0 + linear_to_db(maxf(0.001, bolandi_moosighi)) - linear_to_db(1.0)
	add_child(pakhsh_moosighi)
	pakhsh_moharrek = AudioStreamPlayer.new()
	pakhsh_moharrek.stream = load("res://assets/audio/engine.wav")
	var es := pakhsh_moharrek.stream as AudioStreamWAV
	if es != null:
		_loop_besaz(es)
	pakhsh_moharrek.volume_db = -60.0
	pakhsh_moharrek.finished.connect(func(): if pakhsh_moharrek.volume_db > -50.0: pakhsh_moharrek.play())
	add_child(pakhsh_moharrek)
	pakhsh_lastik = AudioStreamPlayer.new()
	var masir_l := "res://assets/audio/skid.wav"
	if ResourceLoader.exists(masir_l):
		pakhsh_lastik.stream = load(masir_l)
		var sl := pakhsh_lastik.stream as AudioStreamWAV
		if sl != null:
			_loop_besaz(sl)
		pakhsh_lastik.volume_db = -60.0
		pakhsh_lastik.finished.connect(func(): if pakhsh_lastik.volume_db > -50.0: pakhsh_lastik.play())
		add_child(pakhsh_lastik)
	pakhsh_bad = AudioStreamPlayer.new()
	var masir_b := "res://assets/audio/wind.wav"
	if ResourceLoader.exists(masir_b):
		pakhsh_bad.stream = load(masir_b)
		var wb := pakhsh_bad.stream as AudioStreamWAV
		if wb != null:
			_loop_besaz(wb)
		pakhsh_bad.volume_db = -60.0
		pakhsh_bad.finished.connect(func(): if pakhsh_bad.volume_db > -50.0: pakhsh_bad.play())
		add_child(pakhsh_bad)
	pakhsh_ui = AudioStreamPlayer.new()
	add_child(pakhsh_ui)

## لوپ بی‌درز برای هر جریان WAV (با فشرده‌سازی هم کار می‌کند)
func _loop_besaz(jaryan: AudioStreamWAV) -> void:
	jaryan.loop_mode = AudioStreamWAV.LOOP_FORWARD
	jaryan.loop_begin = 0
	var bpfr := 2
	if jaryan.stereo:
		bpfr = 4
	jaryan.loop_end = jaryan.data.size() / bpfr

## موسیقی هر صحنه — نام فایل بدون پسوند؛ لوپ بی‌درز خودکار
func ejra_moosighi(nam: String) -> void:
	if moosighi_konuni == nam and pakhsh_moosighi.playing:
		return
	moosighi_konuni = nam
	var masir := "res://assets/audio/%s.wav" % nam
	if not ResourceLoader.exists(masir):
		return
	var jaryan = load(masir)
	if jaryan == null:
		return
	var wav := jaryan as AudioStreamWAV
	if wav != null and wav.loop_mode == AudioStreamWAV.LOOP_DISABLED:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(wav.get_length() * wav.mix_rate)
	pakhsh_moosighi.stream = jaryan
	pakhsh_moosighi.play()

func tavagof_moosighi() -> void:
	moosighi_konuni = ""
	pakhsh_moosighi.stop()

func ejra_seda(nam: String, bolandi_db: float = -2.0) -> void:
	if seda_ha.has(nam):
		var p := AudioStreamPlayer.new()
		p.stream = seda_ha[nam]
		p.volume_db = bolandi_db + linear_to_db(maxf(0.001, bolandi_seda)) - linear_to_db(0.9)
		add_child(p)
		p.play()
		p.finished.connect(p.queue_free)

## کلیک منو — کوتاه و گرم؛ روی هر دکمه صدا زده می‌شود
func klik_menu() -> void:
	if seda_ha.has("ui"):
		pakhsh_ui.stream = seda_ha["ui"]
		pakhsh_ui.volume_db = -8.0
		pakhsh_ui.play()

func seda_anjam(nam: String) -> void:
	ejra_seda(nam, -10.0)

## موتور با دور موتور واقعی — گیربکس در صحنهٔ مسابقه حساب می‌شود
## dord: ۰=درجا، ۱=خط قرمز | ghas: ۰=بی‌گاز، ۱=گاز کامل
func moharrek_kamel(faal: bool, dord: float, ghas: float = 1.0, nitro: bool = false) -> void:
	if not faal:
		if pakhsh_moharrek.playing:
			pakhsh_moharrek.stop()
		return
	if not pakhsh_moharrek.playing:
		pakhsh_moharrek.play()
	var r := clampf(dord, 0.0, 1.0)
	var th := clampf(ghas, 0.0, 1.0)
	var pitch := 0.62 + r * 1.0 + (0.1 if nitro else 0.0)
	if r < 0.22:
		pitch += sin(Time.get_ticks_msec() * 0.02) * 0.012
	pakhsh_moharrek.pitch_scale = pitch
	var bol := clampf(0.18 + r * 0.72 + th * 0.18, 0.0, 1.0)
	pakhsh_moharrek.volume_db = lerp(-30.0, -7.5, bol)

## سازگاری با صحنه‌های ساده (منو/توقف)
func moharrek(faal: bool, shaded: float = 0.5) -> void:
	moharrek_kamel(faal, clampf(shaded, 0.0, 1.0), shaded)

func lastik(faal: bool, shaded: float = 0.6) -> void:
	if pakhsh_lastik == null or pakhsh_lastik.stream == null:
		return
	if faal:
		if not pakhsh_lastik.playing:
			pakhsh_lastik.play()
		pakhsh_lastik.volume_db = lerp(-24.0, -6.0, clamp(shaded, 0.0, 1.0))
		pakhsh_lastik.pitch_scale = 0.92 + 0.16 * clamp(shaded, 0.0, 1.0)
	else:
		pakhsh_lastik.stop()

## باد و غلتش جاده — با سرعت؛ meghdar ۰..۱
func bad(miqdar: float) -> void:
	if pakhsh_bad == null or pakhsh_bad.stream == null:
		return
	var n := clampf(miqdar, 0.0, 1.0)
	if n <= 0.02:
		if pakhsh_bad.playing:
			pakhsh_bad.stop()
		return
	if not pakhsh_bad.playing:
		pakhsh_bad.play()
	pakhsh_bad.volume_db = lerp(-34.0, -8.0, n * n)
	pakhsh_bad.pitch_scale = 0.85 + n * 0.5

func tavagof_ranandegi() -> void:
	moharrek(false)
	lastik(false)
	bad(0.0)

func tanzim_moosighi(v: float) -> void:
	bolandi_moosighi = clampf(v, 0.0, 1.0)
	pakhsh_moosighi.volume_db = -6.0 + linear_to_db(maxf(0.001, bolandi_moosighi)) - linear_to_db(1.0)

func tanzim_seda(v: float) -> void:
	bolandi_seda = clampf(v, 0.0, 1.0)
