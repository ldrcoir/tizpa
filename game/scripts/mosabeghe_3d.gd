extends Node3D
## تیز پا — مسابقهٔ خیابانی سه‌بعدی تهران؛ دوربین تعقیبی پشت ماشین (سبک ان‌اف‌اس)
## فیزیک همان موتور قبلی است (دریفت، گریپ، نیترو، ترافیک، رقیب) — فقط رندر سه‌بعدی شده.

const SHETAB := 350.0
const TORMOZ := 800.0
const NERKH_CHARKHESH := 2.55
const CHASB := 9.0
const CHASB_DERIFT := 2.25
const TAVAN_NITRO := 1.40
const DANDAHA := [0.0, 0.15, 0.31, 0.50, 0.72, 1.02]

const FA_D := "۰۱۲۳۴۵۶۷۸۹"
const RAGHIBAN := ["pride_blue", "pejo_green", "shahin", "shahin_white", "samand", "dena", "dena_race", "quick", "tiba", "formula_blue", "formula_red", "formula_black"]

# رنگ بدنهٔ ماشین‌ها — از پالت واقعی‌گرایانهٔ اسپرایت‌ها
const RANG_MASHINHA := {
	"helia": Color(26, 138, 148), "pride_blue": Color(42, 94, 192),
	"pejo_green": Color(38, 142, 90), "shahin": Color(46, 116, 126),
	"samand": Color(98, 106, 120), "dena": Color(138, 42, 46),
	"quick": Color(162, 202, 64), "tiba": Color(148, 164, 178),
	"formula_red": Color(216, 48, 38), "formula_blue": Color(38, 96, 208),
	"formula_black": Color(34, 34, 42), "traf_white": Color(200, 202, 206),
	"traf_gray": Color(116, 122, 132), "traf_taxi": Color(222, 174, 36),
	"traf_van": Color(192, 194, 200),
}

# سبک بدنه — اندازه‌ها بر حسب واحد دنیا
const SABK_MASHINHA := {
	"helia": {"sabk": "koupe", "tool": 96, "pahna": 44, "bala": 27, "sagh": 8},
	"pride_blue": {"sabk": "sadegan", "tool": 92, "pahna": 42, "bala": 29, "sagh": 9},
	"pejo_green": {"sabk": "sadegan", "tool": 94, "pahna": 43, "bala": 29, "sagh": 9},
	"shahin": {"sabk": "koupe", "tool": 98, "pahna": 44, "bala": 28, "sagh": 8},
	"shahin_white": {"sabk": "koupe", "tool": 98, "pahna": 44, "bala": 28, "sagh": 8},
	"samand": {"sabk": "sadegan", "tool": 96, "pahna": 43, "bala": 30, "sagh": 9},
	"dena": {"sabk": "sadegan", "tool": 94, "pahna": 44, "bala": 30, "sagh": 9},
	"dena_race": {"sabk": "mosuli", "tool": 98, "pahna": 46, "bala": 28, "sagh": 8},
	"dena_red": {"sabk": "sadegan", "tool": 94, "pahna": 44, "bala": 30, "sagh": 9},
	"quick": {"sabk": "hachbek", "tool": 84, "pahna": 42, "bala": 31, "sagh": 9},
	"tiba": {"sabk": "hachbek", "tool": 82, "pahna": 41, "bala": 31, "sagh": 9},
	"formula_red": {"sabk": "formula", "tool": 100, "pahna": 40, "bala": 22, "sagh": 5},
	"formula_blue": {"sabk": "formula", "tool": 100, "pahna": 40, "bala": 22, "sagh": 5},
	"formula_black": {"sabk": "formula", "tool": 100, "pahna": 40, "bala": 22, "sagh": 5},
	"boghi": {"sabk": "hachbek", "tool": 82, "pahna": 41, "bala": 31, "sagh": 9},
	"boghi_yellow": {"sabk": "hachbek", "tool": 82, "pahna": 41, "bala": 31, "sagh": 9},
	"nissan": {"sabk": "mosuli", "tool": 102, "pahna": 46, "bala": 28, "sagh": 8},
	"nissan_blue": {"sabk": "mosuli", "tool": 102, "pahna": 46, "bala": 28, "sagh": 8},
	"pejo": {"sabk": "sadegan", "tool": 94, "pahna": 43, "bala": 29, "sagh": 9},
	"pejo_race": {"sabk": "mosuli", "tool": 96, "pahna": 45, "bala": 28, "sagh": 8},
	"pride": {"sabk": "sadegan", "tool": 90, "pahna": 42, "bala": 29, "sagh": 9},
	"traf_white": {"sabk": "sadegan", "tool": 94, "pahna": 42, "bala": 30, "sagh": 9},
	"traf_gray": {"sabk": "sadegan", "tool": 94, "pahna": 42, "bala": 30, "sagh": 9},
	"traf_taxi": {"sabk": "sadegan", "tool": 94, "pahna": 42, "bala": 30, "sagh": 9, "alama": true},
	"traf_van": {"sabk": "van", "tool": 100, "pahna": 44, "bala": 36, "sagh": 10},
}

const MAGHZ_SCRIPT := preload("res://scripts/shakhsiat.gd")

var shomare_marhale := 1
var marhale: Dictionary
var pazhoye := {}          # پالت زمان‌روز پیست (ambient/under)
var zaman_gozashte := 0.0
var tamam := false
var masabeghe_tamam := false
var autotest := false
var autotest_kamel := false
var aks := false

# مسیر
var gheteh_a: Array = []   # نقطهٔ شروع هر قطعه
var gheteh_jahat: Array = []
var gheteh_tool: Array = []
var jam_tool: Array = []
var tool_masir := 0.0
var sakhtemanha: Array = []  # {ja, charkh, andaze}
var mavaneh: Array = []      # {ja, shoa}
var mostatil_nagsheh := Rect2(240, 240, 5920, 4920)
var had_paein := Vector2(260, 260)
var had_bala := Vector2(5740, 4540)
var shoroo_ja := Vector2.ZERO
var shoroo_zaviye := 0.0
var pahna_rah := 260.0

# بازیکن
var ja_mashin := Vector2.ZERO
var sorat := Vector2.ZERO
var zaviye := 0.0
var s_ro_masir := 0.0
var dor := 0
var tedad_dor := 2
var bishtarin_sorat := 620.0
var chasb_asli := CHASB
var derift := false
var nitro_baz := false
var anbar_nitro := 1.0
var nerkh_takhlive := 0.30
var _nitro_pish := false
var dandeh := 1
var dord_moharrek := 0.16
var _zaman_dandeh := 0.0
var ferman_chap := false
var ferman_rast := false
var tormoz_pa := false
var nitro_pa := false
var engesht_ha := {}       # شناسهٔ لمس → -۱ چپ / +۱ راست
var klid_chap := false
var klid_rast := false
var birahne := false
var shomar_tanasob := 0.0
var zaman_bezarav := 0.0
var zaman_tanesh := 0.0
var larzesh := 0.0

# رقیب‌ها و ترافیک
var raghibha: Array = []   # {grh, s, tord, ritm, khat, khat_konuni, pich, kund, t, chamaghe, kund_nesh}
var trafikha: Array = []   # {grh, s, jahat, tord, khat}
var rotbe_payan := 1

# نودها
var jahan: Node3D
var laye_namayesh: CanvasLayer
var eshare_chap: AlamatFerman
var eshare_rast: AlamatFerman
var shuale_p: CPUParticles3D
var dud_p: CPUParticles3D
var dud_ravan_p: CPUParticles3D
var chragh_tormoz_p: StandardMaterial3D
var charkhha_p: Array = []
var mashin: Node3D
var badaneh: Node3D
var dorbine: Camera3D
var mat_sakheman: Array = []
var mat_panjere: Array = []
var rad_ha: RadLastik
var khat_shoroo: Node3D
var darvaze: Node3D
var yaz_rekord: Label
var yaz_zaman: Label
var yaz_mamuriat: Label
var yaz_makan: Label
var yaz_dor: Label
var yaz_km: Label
var nitro_navar: ProgressBar
var pishraft: ProgressBar
var soratsanj: Control
var khat_sorat: Control
var shomar: Label
var dokme_toghof: Button
var posh_toghof: Control
var panel_payan: PanelContainer
var dokme_dobare: Button
var dokme_menu: Button
var shakhsiat = null
var langar_mashin: Control
var _marhale_moad := -1
var shoro := 2.6
var _timer_khodkar := 0.0
var _marhale_khodkar := 0
var _zaviye_aval := 0.0
var _zaman_trafik := 0.4
var _zaman_lastik := 0.0
var _derift_did := false

func _ready() -> void:
	autotest = OS.get_cmdline_user_args().has("--autotest")
	autotest_kamel = OS.get_cmdline_user_args().has("--autotest-full")
	aks = OS.get_cmdline_user_args().has("--shots")
	if autotest_kamel and Saman.has_meta("az_dobare"):
		print("[tizpa][autotest] TAP-RETRY OK — بازی دوباره لود شد")
	var sh: int = Saman.get_meta("marhale_shoroo", 1)
	for M in Saman.MARHALEHA:
		if int(M["shomare"]) == sh:
			marhale = M
			break
	if marhale.is_empty():
		marhale = Saman.MARHALEHA[0]
	tedad_dor = int(marhale.get("dorha", 2))
	var karkard: Dictionary = Saman.amalkard()
	bishtarin_sorat = 620.0 * clampf(float(karkard["shetab"]), 0.85, 1.45)
	chasb_asli = CHASB * clampf(float(karkard["chabok"]), 0.8, 1.3)
	nerkh_takhlive = 0.34 / maxf(0.8, float(karkard["turbo"]))
	_khandan_masir()
	_saz_jahan()
	_saz_mashin()
	_saz_hud()
	_parrandeh_raghiban()
	Sedasan.ejra_moosighi(str(marhale.get("musighi", "moosighi_1")))
	shakhsiat = MAGHZ_SCRIPT.new()
	add_child(shakhsiat)
	langar_mashin = Control.new()
	langar_mashin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	langar_mashin.size = Vector2.ZERO
	laye_namayesh.add_child(langar_mashin)
	yaz_mamuriat.text = Saman.matn("mission") + " " + raqam_fa(int(marhale["shomare"])) + " — " + str(marhale["nam"])
	var mtw := create_tween()
	mtw.tween_interval(5.0)
	mtw.tween_property(yaz_mamuriat, "modulate:a", 0.0, 0.8)
	if autotest_kamel:
		_khodkar_kamel()
	if aks:
		_ejra_aks()
	if OS.get_cmdline_user_args().has("--playtest"):
		_ejra_pleitest()

# ───────────────── ریاضی مسیر ─────────────────
func _khandan_masir() -> void:
	var masir := "res://data/track_%s.json" % str(marhale["masir"])
	var txt := FileAccess.get_file_as_string(masir)
	var j: Dictionary = JSON.parse_string(txt) if txt != "" else {}
	if j.is_empty() or j.get("centerline", []).size() < 8:
		push_error("track json missing: " + masir)
		get_tree().quit(1)
		return
	var meta: Dictionary = j["meta"]
	var r: Array = meta["rect"]
	mostatil_nagsheh = Rect2(r[0], r[1], r[2] - r[0], r[3] - r[1])
	var wm: Array = meta.get("world_min", [r[0], r[1]])
	var wx: Array = meta.get("world_max", [r[2], r[3]])
	had_paein = Vector2(wm[0], wm[1])
	had_bala = Vector2(wx[0], wx[1])
	var sh: Dictionary = meta.get("start", {})
	var sp: Array = sh.get("pos", [mostatil_nagsheh.position.x, mostatil_nagsheh.position.y])
	shoroo_ja = Vector2(sp[0], sp[1])
	shoroo_zaviye = deg_to_rad(float(sh.get("ang", 0.0)))
	pahna_rah = float(meta.get("road_half", 130.0)) * 2.0
	pazhoye = j.get("theme", {})
	var pts: Array = j["centerline"]
	var n := pts.size()
	jam_tool = [0.0]
	for i in n:
		var a := Vector2(pts[i][0], pts[i][1])
		var b := Vector2(pts[(i + 1) % n][0], pts[(i + 1) % n][1])
		var d := (b - a)
		var l := maxf(d.length(), 0.001)
		gheteh_a.append(a)
		gheteh_jahat.append(d / l)
		gheteh_tool.append(l)
		jam_tool.append(jam_tool[i] + l)
	tool_masir = jam_tool[n]
	for b in j.get("buildings", []):
		sakhtemanha.append({
			"ja": Vector2(b[0], b[1]),
			"charkh": deg_to_rad(float(b[2])),
			"andaze": Vector2(b[3], b[4]),
		})
	for s in j.get("solids", []):
		mavaneh.append({"ja": Vector2(s[0], s[1]), "shoa": float(s[2])})

func _masir_ja(s: float) -> Vector2:
	var ss := fposmod(s, tool_masir)
	for i in gheteh_a.size():
		if ss <= jam_tool[i + 1] + 0.001:
			return gheteh_a[i] + gheteh_jahat[i] * (ss - jam_tool[i])
	return gheteh_a[0]

func _masir_jahat(s: float) -> Vector2:
	var ss := fposmod(s, tool_masir)
	for i in gheteh_a.size():
		if ss <= jam_tool[i + 1] + 0.001:
			return gheteh_jahat[i]
	return gheteh_jahat[0]

## نزدیک‌ترین نقطهٔ پیست + فاصله از آن (برای آفساید)
func _nazdiktarin(p: Vector2) -> Dictionary:
	var behtar_s := 0.0
	var behtar_d := INF
	for i in gheteh_a.size():
		var nesbi: Vector2 = p - gheteh_a[i]
		var t: float = clampf(nesbi.dot(gheteh_jahat[i]), 0.0, gheteh_tool[i])
		var q: Vector2 = gheteh_a[i] + gheteh_jahat[i] * t
		var d := p.distance_to(q)
		if d < behtar_d:
			behtar_d = d
			behtar_s = jam_tool[i] + t
	return {"s": behtar_s, "dist": behtar_d}

# ───────────────── تبدیل مختصات ۲بعدی شبیه‌ساز → سه‌بعدی ─────────────────
func _j3(p: Vector2, y := 0.0) -> Vector3:
	return Vector3(p.x, y, p.y)

func _charkh3(tha: float) -> float:
	return -tha

# ───────────────── ساخت دنیا ─────────────────
func _saz_jahan() -> void:
	jahan = Node3D.new()
	add_child(jahan)
	var shab: bool = bool(pazhoye.get("night", false))
	var amb: Array = pazhoye.get("ambient", [1.0, 0.93, 0.83])
	var zir: Array = pazhoye.get("under", [0.027, 0.031, 0.055])

	var mahit := Environment.new()
	var asman := ProceduralSkyMaterial.new()
	if shab:
		asman.sky_top_color = Color(0.02, 0.03, 0.08)
		asman.sky_horizon_color = Color(0.10, 0.09, 0.14)
		asman.ground_bottom_color = Color(0.015, 0.015, 0.03)
		asman.ground_horizon_color = Color(0.08, 0.07, 0.11)
		asman.sun_angle_max = 8.0
	else:
		asman.sky_top_color = Color(0.30, 0.42, 0.62).lerp(Color(amb[0], amb[1], amb[2]), 0.25)
		asman.sky_horizon_color = Color(amb[0] * 0.95, amb[1] * 0.85, amb[2] * 0.72)
		asman.ground_bottom_color = Color(0.10, 0.09, 0.08)
		asman.ground_horizon_color = Color(amb[0] * 0.7, amb[1] * 0.62, amb[2] * 0.5)
	var asman_jadval := Sky.new()
	asman_jadval.sky_material = asman
	mahit.sky = asman_jadval
	mahit.background_mode = Environment.BG_SKY
	mahit.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	mahit.ambient_light_color = Color(amb[0], amb[1], amb[2])
	mahit.ambient_light_energy = 1.0 if not shab else 0.45
	mahit.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	mahit.fog_enabled = true
	if shab:
		mahit.fog_light_color = Color(0.05, 0.06, 0.10)
		mahit.fog_density = 0.0016
		mahit.glow_enabled = true
		mahit.glow_intensity = 0.7
		mahit.glow_bloom = 0.12
	else:
		mahit.fog_light_color = Color(amb[0] * 0.9, amb[1] * 0.85, amb[2] * 0.78)
		mahit.fog_density = 0.0009
	mahit.fog_sky_affect = 0.0
	var mahit_greh := WorldEnvironment.new()
	mahit_greh.environment = mahit
	jahan.add_child(mahit_greh)

	var khorshid := DirectionalLight3D.new()
	if shab:
		khorshid.rotation_degrees = Vector3(-38, 210, 0)
		khorshid.light_color = Color(0.55, 0.66, 1.0)
		khorshid.light_energy = 0.22
	else:
		khorshid.rotation_degrees = Vector3(-52, 148, 0)
		khorshid.light_color = Color(1.0, 0.94, 0.82)
		khorshid.light_energy = 1.25
	khorshid.shadow_enabled = true
	khorshid.directional_shadow_max_distance = 2600.0
	jahan.add_child(khorshid)

	# زمین تاریک بی‌نهایت — بیرون نقشه هم همان هوای پیست است
	var zamin_greh := MeshInstance3D.new()
	var zamin_mesh := PlaneMesh.new()
	zamin_mesh.size = Vector2(42000, 42000)
	zamin_greh.mesh = zamin_mesh
	var zamin_mat := StandardMaterial3D.new()
	zamin_mat.albedo_color = Color(zir[0], zir[1], zir[2])
	zamin_mat.roughness = 1.0
	zamin_greh.material_override = zamin_mat
	zamin_greh.position = _j3(mostatil_nagsheh.get_center(), -0.4)
	jahan.add_child(zamin_greh)

	# نقشهٔ شهر — ۴ تایل بافته‌شده؛ یووی صریح تا جاده دقیقاً زیر ساختمان‌ها بیفتد
	var tw := mostatil_nagsheh.size.x * 0.5
	var th := mostatil_nagsheh.size.y * 0.5
	for i in 4:
		var gunjeh := "res://assets/sprites/l%d_map_%d.jpg" % [int(marhale["shomare"]), i]
		var tile := MeshInstance3D.new()
		tile.mesh = _mosatil_mesh(mostatil_nagsheh.position + Vector2(float(i % 2) * tw, float(i / 2) * th), Vector2(tw, th), load(gunjeh))
		jahan.add_child(tile)

	# رد لاستیک — روی آسفالت می‌ماند
	rad_ha = RadLastik.new()
	jahan.add_child(rad_ha)

	_saz_sakhtemanha(shab)
	_saz_mavaneh(shab)
	_saz_khat_shoroo()

# ───────────────────────── ساختمان‌ها و اشیاء شهر ─────────────────────────

func _saz_sakhtemanha(shab: bool) -> void:
	var amb: Array = pazhoye.get("ambient", [1.0, 0.93, 0.83])
	var asas := Color(amb[0], amb[1], amb[2]).clamp(Color(0.4, 0.4, 0.4), Color(1.2, 1.2, 1.2))
	var tonha := [Color(0.60, 0.56, 0.52), Color(0.50, 0.47, 0.44), Color(0.68, 0.63, 0.57)]
	var baft := _baft_divar(shab)
	for k in 3:
		var m := StandardMaterial3D.new()
		m.albedo_texture = baft
		m.albedo_color = tonha[k] * asas
		m.roughness = 0.92
		m.uv1_scale = Vector3(2 + k, 3 + k, 1)
		mat_sakheman.append(m)
	if shab:
		var roshan := _baft_panjare()
		var tavano := [1.7, 1.1, 0.7]
		for k in 3:
			var mp := StandardMaterial3D.new()
			mp.albedo_texture = baft
			mp.albedo_color = tonha[k] * asas
			mp.emission_enabled = true
			mp.emission_texture = roshan
			mp.emission = Color(1.0, 0.82, 0.5)
			mp.emission_energy_multiplier = tavano[k]
			mp.uv1_scale = Vector3(2 + k, 3 + k, 1)
			mat_panjere.append(mp)
	var tas := RandomNumberGenerator.new()
	for b in sakhtemanha:
		var ja: Vector2 = b["ja"]
		var andaze: Vector2 = b["andaze"]
		tas.seed = hash(Vector2i(int(ja.x), int(ja.y)))
		var ertefa := tas.randf_range(90.0, 430.0)
		var greh := MeshInstance3D.new()
		var jadval := BoxMesh.new()
		jadval.size = Vector3(andaze.x, ertefa, andaze.y)
		greh.mesh = jadval
		var nomre := tas.randi_range(0, 2)
		greh.material_override = mat_panjere[nomre] if (shab and mat_panjere.size() > 0) else mat_sakheman[nomre]
		greh.position = _j3(ja, ertefa * 0.5)
		greh.rotation.y = -float(b["charkh"])
		jahan.add_child(greh)

## بافت دیوار — بتن با شبکه پنجره (روز: شیشه تیره / شب: سیاه برای نور emission)
func _baft_divar(shab: bool) -> ImageTexture:
	var px := 64
	var py := 96
	var img := Image.create(px, py, false, Image.FORMAT_RGBA8)
	for y in py:
		for x in px:
			var khane := (x % 8 < 6) and (y % 12 < 8)
			if khane:
				img.set_pixel(x, y, Color(0.12, 0.16, 0.20) if not shab else Color(0.03, 0.03, 0.05))
			else:
				img.set_pixel(x, y, Color(1, 1, 1))
	return ImageTexture.create_from_image(img)

## بافت پنجره‌های روشن — فقط خانه‌های روشن؛ بقیه سیاه (برای emission شب)
func _baft_panjare() -> ImageTexture:
	var px := 64
	var py := 96
	var img := Image.create(px, py, false, Image.FORMAT_RGBA8)
	var tas := RandomNumberGenerator.new()
	tas.seed = 90210
	for y in py:
		for x in px:
			var khane := (x % 8 < 6) and (y % 12 < 8)
			var kami := tas.randf()
			if khane and kami > 0.42:
				img.set_pixel(x, y, Color(1, 1, 1) if kami > 0.8 else Color(0.75, 0.75, 0.9))
			else:
				img.set_pixel(x, y, Color(0, 0, 0))
	return ImageTexture.create_from_image(img)

## موانع شهری — درخت / تیر چراغ / ماشین پارک‌شده
func _saz_mavaneh(shab: bool) -> void:
	var chub := StandardMaterial3D.new()
	chub.albedo_color = Color(0.36, 0.26, 0.18)
	chub.roughness = 1.0
	var barg := StandardMaterial3D.new()
	barg.albedo_color = Color(0.16, 0.38, 0.16)
	barg.roughness = 1.0
	var feliz := StandardMaterial3D.new()
	feliz.albedo_color = Color(0.55, 0.57, 0.60)
	feliz.metallic = 0.7
	feliz.roughness = 0.4
	var sar_cheragh := StandardMaterial3D.new()
	sar_cheragh.albedo_color = Color(1.0, 0.95, 0.75)
	sar_cheragh.emission_enabled = true
	sar_cheragh.emission = Color(1.0, 0.9, 0.6)
	sar_cheragh.emission_energy_multiplier = 2.4 if shab else 0.0
	var mat_park := StandardMaterial3D.new()
	mat_park.albedo_color = RANG_MASHINHA["traf_gray"]
	mat_park.metallic = 0.55
	mat_park.roughness = 0.35
	var mat_park_saghf := StandardMaterial3D.new()
	mat_park_saghf.albedo_color = RANG_MASHINHA["traf_gray"] * 0.8
	for so in mavaneh:
		var ja: Vector2 = so["ja"]
		var nou: int = absi(int(ja.x)) % 3
		var greh := Node3D.new()
		greh.position = _j3(ja, 0.0)
		jahan.add_child(greh)
		if nou == 0:
			var tan := MeshInstance3D.new()
			var tan_m := CylinderMesh.new()
			tan_m.top_radius = so["shoa"] * 0.15
			tan_m.bottom_radius = so["shoa"] * 0.22
			tan_m.height = so["shoa"] * 2.6
			tan.mesh = tan_m
			tan.material_override = chub
			tan.position.y = so["shoa"] * 1.3
			greh.add_child(tan)
			var sar := MeshInstance3D.new()
			var sar_m := SphereMesh.new()
			sar_m.radius = so["shoa"] * 0.95
			sar_m.height = so["shoa"] * 1.7
			sar.mesh = sar_m
			sar.material_override = barg
			sar.position.y = so["shoa"] * 3.1
			greh.add_child(sar)
		elif nou == 1:
			var mil := MeshInstance3D.new()
			var mil_m := CylinderMesh.new()
			mil_m.top_radius = 4.0
			mil_m.bottom_radius = 6.0
			mil_m.height = 190.0
			mil.mesh = mil_m
			mil.material_override = feliz
			mil.position.y = 95.0
			greh.add_child(mil)
			var sar := MeshInstance3D.new()
			var sar_m := BoxMesh.new()
			sar_m.size = Vector3(34, 8, 14)
			sar.mesh = sar_m
			sar.material_override = sar_cheragh
			sar.position.y = 192.0
			greh.add_child(sar)
		else:
			var shasi := MeshInstance3D.new()
			var jm := BoxMesh.new()
			jm.size = Vector3(96, 24, 42)
			shasi.mesh = jm
			shasi.material_override = mat_park
			shasi.position.y = 13.0
			greh.add_child(shasi)
			var saghf := MeshInstance3D.new()
			var sm := BoxMesh.new()
			sm.size = Vector3(52, 18, 38)
			saghf.mesh = sm
			saghf.material_override = mat_park_saghf
			saghf.position = Vector3(-2, 33, 0)
			greh.add_child(saghf)

## خط شروع شطرنجی + دروازه
func _saz_khat_shoroo() -> void:
	var jahat := _masir_jahat(0.0)
	var tha := jahat.angle()
	khat_shoroo = Node3D.new()
	khat_shoroo.position = _j3(shoroo_ja, 0.06)
	khat_shoroo.rotation.y = _charkh3(tha)
	jahan.add_child(khat_shoroo)
	var img := Image.create(16, 4, false, Image.FORMAT_RGBA8)
	for y in 4:
		for x in 16:
			var sefid := (x + y) % 2 == 0
			img.set_pixel(x, y, Color(0.95, 0.95, 0.95) if sefid else Color(0.07, 0.07, 0.07))
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = ImageTexture.create_from_image(img)
	mat.roughness = 0.75
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := Vector3.UP
	var q0 := Vector3(-30.0, 0.0, -pahna_rah * 0.5)
	var q1 := Vector3(30.0, 0.0, -pahna_rah * 0.5)
	var q2 := Vector3(30.0, 0.0, pahna_rah * 0.5)
	var q3 := Vector3(-30.0, 0.0, pahna_rah * 0.5)
	for jorf in [[q0, Vector2(0, 0)], [q1, Vector2(4, 0)], [q2, Vector2(4, 16)], [q3, Vector2(0, 16)]]:
		st.set_normal(n)
		st.set_uv(jorf[1])
		st.add_vertex(jorf[0])
	st.add_index(0); st.add_index(2); st.add_index(1)
	st.add_index(0); st.add_index(3); st.add_index(2)
	st.set_material(mat)
	var ghal := MeshInstance3D.new()
	ghal.mesh = st.commit()
	khat_shoroo.add_child(ghal)
	darvaze = Node3D.new()
	khat_shoroo.add_child(darvaze)
	var mil_mat := StandardMaterial3D.new()
	mil_mat.albedo_color = Color(0.75, 0.12, 0.10)
	mil_mat.metallic = 0.5
	mil_mat.roughness = 0.4
	for tarafe in [-1.0, 1.0]:
		var mil := MeshInstance3D.new()
		var mil_m := CylinderMesh.new()
		mil_m.top_radius = 8.0
		mil_m.bottom_radius = 10.0
		mil_m.height = 200.0
		mil.mesh = mil_m
		mil.material_override = mil_mat
		mil.position = Vector3(0.0, 100.0, tarafe * (pahna_rah * 0.5 + 26.0))
		darvaze.add_child(mil)
	var tigh := MeshInstance3D.new()
	var tigh_m := BoxMesh.new()
	tigh_m.size = Vector3(14, 12, pahna_rah + 52.0)
	tigh.mesh = tigh_m
	var tigh_mat := StandardMaterial3D.new()
	tigh_mat.albedo_color = Color(1.0, 0.85, 0.3)
	tigh_mat.emission_enabled = true
	tigh_mat.emission = Color(1.0, 0.8, 0.25)
	tigh_mat.emission_energy_multiplier = 2.0
	tigh.material_override = tigh_mat
	tigh.position = Vector3(0.0, 202.0, 0.0)
	darvaze.add_child(tigh)

## چهارضلعی افقی با یووی صریح — تایل بافت نقشه
func _mosatil_mesh(gosheh: Vector2, andaze: Vector2, tex: Texture2D) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var v0 := Vector3(gosheh.x, 0.0, gosheh.y)
	var v1 := Vector3(gosheh.x + andaze.x, 0.0, gosheh.y)
	var v2 := Vector3(gosheh.x + andaze.x, 0.0, gosheh.y + andaze.y)
	var v3 := Vector3(gosheh.x, 0.0, gosheh.y + andaze.y)
	st.set_normal(Vector3.UP)
	st.set_uv(Vector2(0, 0)); st.add_vertex(v0)
	st.set_uv(Vector2(1, 0)); st.add_vertex(v1)
	st.set_uv(Vector2(1, 1)); st.add_vertex(v2)
	st.set_uv(Vector2(0, 1)); st.add_vertex(v3)
	st.add_index(0); st.add_index(2); st.add_index(1)
	st.add_index(0); st.add_index(3); st.add_index(2)
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = tex
	mat.roughness = 0.96
	st.set_material(mat)
	return st.commit()

# ───────────────────────── ماشین‌ها ─────────────────────────

func _saz_mashin() -> void:
	var shab: bool = bool(pazhoye.get("night", false))
	var id: String = str(Saman.MASHINHA[Saman.mashin_entekhabi]["shenase"])
	var fx := _greh_mashin(id, true, shab)
	mashin = fx["greh"]
	add_child(mashin)
	badaneh = fx["badaneh"]
	shuale_p = fx["shuale"]
	dud_p = fx["dud"]
	dud_ravan_p = fx["dud_ravan"]
	chragh_tormoz_p = fx["chragh_tormoz"]
	charkhha_p = fx["charkhha"]
	ja_mashin = _masir_ja(0.0)
	zaviye = _masir_jahat(0.0).angle()
	s_ro_masir = 0.0
	mashin.position = _j3(ja_mashin)
	mashin.rotation.y = _charkh3(zaviye)
	_zaviye_aval = zaviye
	dorbine = Camera3D.new()
	dorbine.fov = 72.0
	dorbine.near = 1.0
	dorbine.far = 30000.0
	add_child(dorbine)
	var f3 := _j3(Vector2.RIGHT.rotated(zaviye))
	dorbine.position = _j3(ja_mashin) - f3 * 360.0 + Vector3.UP * 150.0
	dorbine.look_at(_j3(ja_mashin) + Vector3.UP * 60.0)
	dorbine.make_current()

## ساخت گره کامل یک ماشین — بدنه، شیشه، چرخ، چراغ‌ها، نئون
func _greh_mashin(id: String, ba_jazab: bool, shab: bool) -> Dictionary:
	var sb: Dictionary = SABK_MASHINHA.get(id, SABK_MASHINHA["helia"])
	var rang: Color = RANG_MASHINHA.get(id, RANG_MASHINHA["traf_gray"])
	var sabk: String = str(sb["sabk"])
	var tool_f := float(sb["tool"])
	var pahna_f := float(sb["pahna"])
	var bala_f := float(sb["bala"])
	var sagh_f := float(sb["sagh"])
	var greh := Node3D.new()
	var badaneh_greh := Node3D.new()
	greh.add_child(badaneh_greh)
	var mat_badaneh := StandardMaterial3D.new()
	mat_badaneh.albedo_color = rang
	mat_badaneh.metallic = 0.55
	mat_badaneh.roughness = 0.34
	mat_badaneh.cull_mode = BaseMaterial3D.CULL_DISABLED
	var mat_shishe := StandardMaterial3D.new()
	mat_shishe.albedo_color = Color(0.05, 0.07, 0.10)
	mat_shishe.metallic = 0.4
	mat_shishe.roughness = 0.06
	mat_shishe.cull_mode = BaseMaterial3D.CULL_DISABLED
	var ghal := MeshInstance3D.new()
	ghal.mesh = _badaneh_mesh(sabk, tool_f, pahna_f, bala_f, sagh_f)
	ghal.set_surface_override_material(0, mat_badaneh)
	ghal.set_surface_override_material(1, mat_shishe)
	badaneh_greh.add_child(ghal)
	var mat_lastik := StandardMaterial3D.new()
	mat_lastik.albedo_color = Color(0.07, 0.07, 0.08)
	mat_lastik.roughness = 0.9
	var mat_taze := StandardMaterial3D.new()
	mat_taze.albedo_color = Color(0.75, 0.76, 0.80)
	mat_taze.metallic = 0.9
	mat_taze.roughness = 0.3
	var charkhha: Array = []
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var ch := MeshInstance3D.new()
			var cm := CylinderMesh.new()
			cm.top_radius = sagh_f
			cm.bottom_radius = sagh_f
			cm.height = pahna_f * 0.26
			cm.radial_segments = 14
			ch.mesh = cm
			ch.material_override = mat_lastik
			ch.rotation.x = PI / 2.0
			ch.position = Vector3(sx * tool_f * 0.33, sagh_f, sz * pahna_f * 0.44)
			greh.add_child(ch)
			var taze := MeshInstance3D.new()
			var tm := CylinderMesh.new()
			tm.top_radius = sagh_f * 0.55
			tm.bottom_radius = sagh_f * 0.55
			tm.height = pahna_f * 0.28
			tm.radial_segments = 12
			taze.mesh = tm
			taze.material_override = mat_taze
			taze.rotation.x = PI / 2.0
			taze.position = ch.position
			greh.add_child(taze)
			charkhha.append(ch)
	var mat_jelo := StandardMaterial3D.new()
	mat_jelo.albedo_color = Color(1.0, 0.97, 0.85)
	mat_jelo.emission_enabled = true
	mat_jelo.emission = Color(1.0, 0.95, 0.8)
	mat_jelo.emission_energy_multiplier = 2.5 if shab else 0.4
	var mat_tormoz_chragh := StandardMaterial3D.new()
	mat_tormoz_chragh.albedo_color = Color(0.55, 0.08, 0.06)
	mat_tormoz_chragh.emission_enabled = true
	mat_tormoz_chragh.emission = Color(1.0, 0.12, 0.06)
	mat_tormoz_chragh.emission_energy_multiplier = 1.0
	for sz in [-1.0, 1.0]:
		var cj := MeshInstance3D.new()
		var cjm := BoxMesh.new()
		cjm.size = Vector3(6.0, 7.0, 12.0)
		cj.mesh = cjm
		cj.material_override = mat_jelo
		cj.position = Vector3(tool_f * 0.5, sagh_f + bala_f * 0.42, sz * pahna_f * 0.32)
		badaneh_greh.add_child(cj)
		var ct := MeshInstance3D.new()
		ct.mesh = cjm
		ct.material_override = mat_tormoz_chragh
		ct.position = Vector3(-tool_f * 0.5, sagh_f + bala_f * 0.42, sz * pahna_f * 0.32)
		badaneh_greh.add_child(ct)
	var u := 0.0
	for hr in id:
		u = fmod(u + float(hr.unicode_at(0)) * 0.113, 1.0)
	var mat_neon := StandardMaterial3D.new()
	mat_neon.albedo_color = Color.from_hsv(u, 0.85, 1.0, 0.35)
	mat_neon.emission_enabled = true
	mat_neon.emission = Color.from_hsv(u, 0.85, 1.0)
	mat_neon.emission_energy_multiplier = 1.4
	mat_neon.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var neon := MeshInstance3D.new()
	var nm := PlaneMesh.new()
	nm.size = Vector2(tool_f * 0.85, pahna_f * 1.25)
	neon.mesh = nm
	neon.material_override = mat_neon
	neon.position.y = 1.5
	greh.add_child(neon)
	if sabk == "mosuli" or sabk == "formula":
		var parvaz := MeshInstance3D.new()
		var pm := BoxMesh.new()
		pm.size = Vector3(16.0, 5.0, pahna_f * 0.95)
		parvaz.mesh = pm
		parvaz.material_override = mat_badaneh
		parvaz.position = Vector3(-tool_f * 0.46, sagh_f + bala_f * 0.72, 0.0)
		badaneh_greh.add_child(parvaz)
	if sb.get("alama", false):
		var alama := MeshInstance3D.new()
		var am := BoxMesh.new()
		am.size = Vector3(12.0, 10.0, 28.0)
		alama.mesh = am
		var mat_alama := StandardMaterial3D.new()
		mat_alama.albedo_color = Color(1.0, 0.85, 0.2)
		mat_alama.emission_enabled = true
		mat_alama.emission = Color(1.0, 0.8, 0.2)
		mat_alama.emission_energy_multiplier = 1.6
		alama.material_override = mat_alama
		alama.position = Vector3(-tool_f * 0.05, sagh_f + bala_f + 6.0, 0.0)
		badaneh_greh.add_child(alama)
	var cheragh_jelo: SpotLight3D = null
	var shuale: CPUParticles3D = null
	var dud: CPUParticles3D = null
	var dud_ravan: CPUParticles3D = null
	if ba_jazab:
		cheragh_jelo = SpotLight3D.new()
		cheragh_jelo.spot_range = 980.0
		cheragh_jelo.spot_angle = 34.0
		cheragh_jelo.light_color = Color(1.0, 0.95, 0.85)
		cheragh_jelo.light_energy = 3.2 if shab else 0.6
		cheragh_jelo.position = Vector3(tool_f * 0.4, sagh_f + bala_f * 0.5, 0.0)
		cheragh_jelo.rotation.y = -PI / 2.0
		badaneh_greh.add_child(cheragh_jelo)
		shuale = _part_saz(Color(0.85, 0.92, 1.0), 26, 0.30, Vector3(-1, 0, 0), 420.0, 0.75)
		shuale.position = Vector3(-tool_f * 0.5, sagh_f + bala_f * 0.28, 0.0)
		greh.add_child(shuale)
		dud = _part_saz(Color(0.75, 0.75, 0.78, 0.5), 22, 0.9, Vector3.ZERO, 90.0, 1.6)
		dud.position = Vector3(-tool_f * 0.42, sagh_f + 6.0, 0.0)
		greh.add_child(dud)
		dud_ravan = _part_saz(Color(0.7, 0.7, 0.74, 0.25), 8, 1.2, Vector3(-1, 0, 0), 50.0, 0.7)
		dud_ravan.position = Vector3(-tool_f * 0.52, sagh_f + 8.0, 0.0)
		greh.add_child(dud_ravan)
	return {
		"greh": greh, "badaneh": badaneh_greh,
		"chragh_tormoz": mat_tormoz_chragh, "cheragh_jelo": cheragh_jelo,
		"shuale": shuale, "dud": dud, "dud_ravan": dud_ravan,
		"charkhha": charkhha,
	}

func _part_saz(rang: Color, tedad: int, omr: float, jahat: Vector3, sorat: float, andaze: float) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.emitting = false
	p.amount = tedad
	p.lifetime = omr
	p.direction = jahat
	p.spread = 14.0 if jahat != Vector3.ZERO else 180.0
	p.initial_velocity_min = sorat * 0.5
	p.initial_velocity_max = sorat
	p.gravity = Vector3.ZERO
	p.scale_amount_min = andaze * 0.5
	p.scale_amount_max = andaze
	var ghal := QuadMesh.new()
	ghal.size = Vector2(14.0, 14.0)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	m.vertex_color_use_as_albedo = true
	ghal.material = m
	p.mesh = ghal
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 0.9), Color(rang.r, rang.g, rang.b, rang.a * 0.6), Color(rang.r, rang.g, rang.b, 0.0)])
	p.color_ramp = g
	return p

## بدنهٔ شیارشده — دو سطح: ۰ بدنه رنگی، ۱ کابین شیشه‌ای
func _badaneh_mesh(sabk: String, tool: float, pahna: float, bala: float, sagh: float) -> ArrayMesh:
	var profil: Array
	var kabin: Array
	match sabk:
		"koupe":
			profil = [[-0.50, 0.86, 0.10, 0.50], [-0.30, 1.00, 0.06, 0.60], [-0.06, 1.00, 0.05, 0.64], [0.20, 0.97, 0.06, 0.60], [0.40, 0.88, 0.14, 0.48], [0.50, 0.72, 0.26, 0.40]]
			kabin = [[-0.34, 0.80, 0.58, 0.68], [-0.10, 0.87, 0.56, 0.98], [0.10, 0.85, 0.56, 0.98], [0.30, 0.72, 0.55, 0.64]]
		"hachbek":
			profil = [[-0.50, 0.88, 0.12, 0.52], [-0.28, 1.00, 0.07, 0.62], [-0.04, 1.00, 0.06, 0.66], [0.22, 0.96, 0.07, 0.60], [0.40, 0.90, 0.14, 0.52], [0.50, 0.80, 0.22, 0.46]]
			kabin = [[-0.36, 0.82, 0.60, 0.70], [-0.12, 0.88, 0.58, 1.00], [0.08, 0.86, 0.58, 1.00], [0.26, 0.80, 0.56, 0.74], [0.36, 0.72, 0.50, 0.58]]
		"van":
			profil = [[-0.50, 0.88, 0.10, 0.88], [-0.30, 0.96, 0.05, 0.96], [-0.05, 0.96, 0.05, 0.98], [0.20, 0.94, 0.05, 0.96], [0.40, 0.86, 0.10, 0.82], [0.50, 0.74, 0.20, 0.62]]
			kabin = [[0.18, 0.86, 0.72, 0.90], [0.30, 0.86, 0.70, 0.98], [0.42, 0.78, 0.68, 0.92], [0.50, 0.70, 0.62, 0.66]]
		"formula":
			profil = [[-0.50, 0.72, 0.18, 0.44], [-0.28, 0.95, 0.10, 0.54], [0.00, 1.00, 0.08, 0.60], [0.26, 0.92, 0.10, 0.52], [0.46, 0.62, 0.16, 0.38], [0.50, 0.36, 0.24, 0.34]]
			kabin = [[-0.08, 0.42, 0.56, 0.70], [0.04, 0.38, 0.56, 0.96], [0.16, 0.36, 0.56, 0.90], [0.26, 0.32, 0.52, 0.60]]
		_:
			profil = [[-0.50, 0.86, 0.12, 0.48], [-0.30, 1.00, 0.07, 0.58], [-0.05, 1.00, 0.06, 0.62], [0.20, 0.98, 0.06, 0.60], [0.40, 0.90, 0.14, 0.50], [0.50, 0.76, 0.24, 0.42]]
			kabin = [[-0.32, 0.82, 0.56, 0.66], [-0.08, 0.88, 0.54, 0.96], [0.12, 0.86, 0.54, 0.94], [0.32, 0.74, 0.52, 0.62]]
	var st1 := SurfaceTool.new()
	st1.begin(Mesh.PRIMITIVE_TRIANGLES)
	var halgheha: Array = []
	var x_ha: Array = []
	for pr in profil:
		var w := float(pr[1]) * pahna * 0.5
		var paeen := sagh + float(pr[2]) * bala
		var bala_p := sagh + float(pr[3]) * bala
		halgheha.append(_halghe_badaneh(w, paeen, bala_p))
		x_ha.append(float(pr[0]) * tool)
	_dooz(st1, halgheha, x_ha)
	_sar_dooz(st1, halgheha[halgheha.size() - 1], float(x_ha[x_ha.size() - 1]), true)
	_sar_dooz(st1, halgheha[0], float(x_ha[0]), false)
	st1.generate_normals()
	var mesh := st1.commit()
	if kabin.size() >= 2:
		var st2 := SurfaceTool.new()
		st2.begin(Mesh.PRIMITIVE_TRIANGLES)
		var kh: Array = []
		var kx: Array = []
		for pr in kabin:
			var w2 := float(pr[1]) * pahna * 0.5
			var paeen2 := sagh + float(pr[2]) * bala
			var bala_k := sagh + float(pr[3]) * bala
			kh.append(_halghe_kabin(w2, paeen2, bala_k))
			kx.append(float(pr[0]) * tool)
		_dooz(st2, kh, kx)
		_sar_dooz(st2, kh[kh.size() - 1], float(kx[kx.size() - 1]), true)
		_sar_dooz(st2, kh[0], float(kx[0]), false)
		st2.generate_normals()
		st2.commit(mesh)
	return mesh

## حلقهٔ مقطع بدنه — ۹ نقطه از sill چپ تا sill راست با پوش سقف
func _halghe_badaneh(w: float, paeen: float, bala: float) -> PackedVector3Array:
	var nokat := PackedVector3Array()
	for k in 9:
		var za := PI * float(k) / 8.0
		nokat.append(Vector3(0.0, paeen + (bala - paeen) * pow(sin(za), 0.85), -w * cos(za)))
	return nokat

## حلقهٔ مقطع کابین — سقف تخت‌تر، ۷ نقطه
func _halghe_kabin(w: float, paeen: float, bala: float) -> PackedVector3Array:
	var nokat := PackedVector3Array()
	for k in 7:
		var za := PI * float(k) / 6.0
		nokat.append(Vector3(0.0, paeen + (bala - paeen) * pow(sin(za), 0.6), -w * cos(za)))
	return nokat

## دوختن مقاطع کنار هم — مثلث‌بندی رو به بیرون
func _dooz(st: SurfaceTool, halgheha: Array, x_ha: Array) -> void:
	for i in halgheha.size() - 1:
		var A: PackedVector3Array = halgheha[i]
		var B: PackedVector3Array = halgheha[i + 1]
		var x_a := float(x_ha[i])
		var x_b := float(x_ha[i + 1])
		for k in A.size() - 1:
			var v0 := Vector3(x_a, A[k].y, A[k].z)
			var v1 := Vector3(x_a, A[k + 1].y, A[k + 1].z)
			var v2 := Vector3(x_b, B[k + 1].y, B[k + 1].z)
			var v3 := Vector3(x_b, B[k].y, B[k].z)
			st.add_vertex(v0)
			st.add_vertex(v1)
			st.add_vertex(v2)
			st.add_vertex(v0)
			st.add_vertex(v2)
			st.add_vertex(v3)

## درپوش دو سر بدنه — بادبزن
func _sar_dooz(st: SurfaceTool, halghe: PackedVector3Array, x: float, jelo: bool) -> void:
	var my := 0.0
	for p in halghe:
		my += p.y
	my /= float(halghe.size())
	st.add_vertex(Vector3(x, my, 0.0))
	for k in halghe.size():
		st.add_vertex(Vector3(x, halghe[k].y, halghe[k].z))
	var n := halghe.size()
	for k in n - 1:
		if jelo:
			st.add_index(0)
			st.add_index(1 + k)
			st.add_index(2 + k)
		else:
			st.add_index(0)
			st.add_index(2 + k)
			st.add_index(1 + k)

# ───────────────────────── رقیب‌ها و ترافیک ─────────────────────────

func _parrandeh_raghiban() -> void:
	var shab: bool = bool(pazhoye.get("night", false))
	var mahal := RAGHIBAN.duplicate()
	mahal.shuffle()
	var shorouha := [90.0, 180.0, 270.0, 360.0]
	var khatha := [-58.0, 58.0, -58.0, 58.0]
	var maharat := float(marhale.get("maharat", 0.95))
	for i in int(marhale.get("raghiban", 3)):
		var id: String = mahal[i % mahal.size()]
		var fx := _greh_mashin(id, false, shab)
		add_child(fx["greh"])
		raghibha.append({
			"greh": fx["greh"], "badaneh": fx["badaneh"],
			"s": float(shorouha[i % 4]), "sorat": 0.0,
			"ritm": maharat * randf_range(0.975, 1.025),
			"khat": float(khatha[i % 4]), "khat_konuni": float(khatha[i % 4]),
			"pich": false, "kund": false, "t": 0.0,
			"chragh_tormoz": fx["chragh_tormoz"],
		})

func _avari_trafik(s_abs: float) -> void:
	var shab: bool = bool(pazhoye.get("night", false))
	var noskheha := ["traf_white", "traf_gray", "traf_taxi", "traf_van"]
	var id: String = noskheha[randi_range(0, noskheha.size() - 1)]
	var fx := _greh_mashin(id, false, shab)
	add_child(fx["greh"])
	var jahat := 1.0
	if randf() < 0.22:
		jahat = -1.0
	trafikha.append({
		"greh": fx["greh"], "badaneh": fx["badaneh"],
		"s": s_abs, "jahat": jahat, "sorat": randf_range(150.0, 250.0),
		"khat": 58.0 * jahat,
	})

# ───────────────────────── رد لاستیک ─────────────────────────

class RadLastik extends MultiMeshInstance3D:
	const TEDAD := 520
	var shomare := 0

	func _init() -> void:
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		var ghal := QuadMesh.new()
		ghal.size = Vector2(22.0, 7.0)
		ghal.orientation = PlaneMesh.FACE_Y
		var m := StandardMaterial3D.new()
		m.albedo_color = Color(0.05, 0.05, 0.06, 0.55)
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
		ghal.material = m
		mm.mesh = ghal
		mm.instance_count = TEDAD
		for i in TEDAD:
			mm.set_instance_transform(i, Transform3D(Basis.IDENTITY, Vector3(0, -50, 0)))
		multimesh = mm

	func ezafe(p: Vector2, tha: float) -> void:
		var b := Basis(Vector3.UP, -tha)
		multimesh.set_instance_transform(shomare, Transform3D(b, Vector3(p.x, 0.10, p.y)))
		shomare = (shomare + 1) % TEDAD

# ───────────────────────── HUD ─────────────────────────

func _saz_hud() -> void:
	laye_namayesh = CanvasLayer.new()
	laye_namayesh.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(laye_namayesh)
	var khatt: FontFile = load("res://assets/fonts/Lalezar-Regular.ttf")
	var bold: FontFile = load("res://assets/fonts/Vazirmatn-Bold.ttf")

	eshare_chap = AlamatFerman.new()
	eshare_chap.bazi = self
	eshare_chap.jahat = -1
	eshare_chap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ja_gozar(eshare_chap, 0.0, 1.0, 0.0, 1.0, 36, -150, 156, -30)
	laye_namayesh.add_child(eshare_chap)
	eshare_rast = AlamatFerman.new()
	eshare_rast.bazi = self
	eshare_rast.jahat = 1
	eshare_rast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ja_gozar(eshare_rast, 1.0, 1.0, 1.0, 1.0, -156, -150, -36, -30)
	laye_namayesh.add_child(eshare_rast)

	yaz_makan = _yaz_ha(khatt, 58, Color(0.98, 0.8, 0.2))
	yaz_makan.add_theme_constant_override("outline_size", 12)
	_ja_gozar(yaz_makan, 0.5, 0.0, 0.5, 0.0, -160, 44, 160, 116)
	yaz_makan.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	yaz_dor = _yaz_ha(khatt, 30, Color(0.95, 0.95, 0.98, 0.9))
	_ja_gozar(yaz_dor, 0.5, 0.0, 0.5, 0.0, -160, 112, 160, 152)
	yaz_dor.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	pishraft = ProgressBar.new()
	pishraft.min_value = 0
	pishraft.max_value = 100
	pishraft.value = 0
	pishraft.show_percentage = false
	pishraft.add_theme_stylebox_override("background", _ghalti(Color(0.08, 0.08, 0.12, 0.8), Color(0.5, 0.45, 0.3, 0.6), 6, 1, false))
	pishraft.add_theme_stylebox_override("fill", _ghalti(Color(0.95, 0.62, 0.12), Color(0.7, 0.4, 0.05), 6, 0, false))
	pishraft.mouse_filter = Control.MOUSE_FILTER_IGNORE
	laye_namayesh.add_child(pishraft)
	_ja_gozar(pishraft, 0.5, 0.0, 0.5, 0.0, -140, 154, 140, 170)

	yaz_rekord = _yaz_ha(khatt, 34, Color(0.95, 0.75, 0.1))
	_ja_gozar(yaz_rekord, 1.0, 0.0, 1.0, 0.0, -280, 46, -70, 96)
	yaz_zaman = _yaz_ha(khatt, 32, Color(0.95, 0.95, 0.98, 0.95))
	_ja_gozar(yaz_zaman, 1.0, 0.0, 1.0, 0.0, -280, 100, -70, 144)
	yaz_mamuriat = _yaz_ha(khatt, 24, Color(0.9, 0.9, 0.95, 0.85))
	_ja_gozar(yaz_mamuriat, 0.0, 0.0, 1.0, 0.0, 240, 176, -240, 214)
	yaz_mamuriat.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	dokme_toghof = Button.new()
	dokme_toghof.text = "II"
	dokme_toghof.add_theme_font_override("font", khatt)
	dokme_toghof.add_theme_font_size_override("font_size", 34)
	_dokme_araeste(dokme_toghof, false)
	laye_namayesh.add_child(dokme_toghof)
	_ja_gozar(dokme_toghof, 0.0, 0.0, 0.0, 0.0, 24, 46, 116, 122)
	dokme_toghof.pressed.connect(_toghof)

	var nagsheh := NagshehKuchak.new()
	nagsheh.bazi = self
	nagsheh.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ja_gozar(nagsheh, 1.0, 0.0, 1.0, 0.0, -252, 158, -28, 350)
	laye_namayesh.add_child(nagsheh)

	var dokme_nitro := Button.new()
	dokme_nitro.text = Saman.matn("nitro")
	dokme_nitro.add_theme_font_override("font", khatt)
	dokme_nitro.add_theme_font_size_override("font_size", 44)
	var nfs := _ghalti(Color(0.09, 0.20, 0.38, 0.78), Color(0.45, 0.72, 1.0, 0.75), 22, 2)
	dokme_nitro.add_theme_stylebox_override("normal", nfs)
	dokme_nitro.add_theme_stylebox_override("hover", _ghalti(Color(0.13, 0.27, 0.48, 0.85), Color(0.6, 0.82, 1.0, 0.9), 22, 2))
	dokme_nitro.add_theme_stylebox_override("pressed", _ghalti(Color(0.06, 0.14, 0.28, 0.9), Color(0.45, 0.72, 1.0, 0.9), 22, 2))
	dokme_nitro.add_theme_stylebox_override("disabled", nfs)
	dokme_nitro.add_theme_color_override("font_color", Color(0.88, 0.95, 1.0))
	dokme_nitro.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
	dokme_nitro.button_down.connect(func(): nitro_pa = true)
	dokme_nitro.button_up.connect(func(): nitro_pa = false)
	laye_namayesh.add_child(dokme_nitro)
	_ja_gozar(dokme_nitro, 1.0, 1.0, 1.0, 1.0, -500, -190, -260, -50)

	var dokme_tormoz := Button.new()
	dokme_tormoz.text = "ترمز"
	dokme_tormoz.add_theme_font_override("font", khatt)
	dokme_tormoz.add_theme_font_size_override("font_size", 38)
	dokme_tormoz.add_theme_stylebox_override("normal", _ghalti(Color(0.34, 0.10, 0.10, 0.78), Color(0.9, 0.42, 0.35, 0.65), 22, 2))
	dokme_tormoz.add_theme_stylebox_override("hover", _ghalti(Color(0.42, 0.14, 0.13, 0.85), Color(1.0, 0.5, 0.42, 0.8), 22, 2))
	dokme_tormoz.add_theme_stylebox_override("pressed", _ghalti(Color(0.24, 0.07, 0.07, 0.9), Color(0.9, 0.42, 0.35, 0.9), 22, 2))
	dokme_tormoz.add_theme_stylebox_override("disabled", _ghalti(Color(0.34, 0.10, 0.10, 0.78), Color(0.9, 0.42, 0.35, 0.65), 22, 2))
	dokme_tormoz.add_theme_color_override("font_color", Color(1.0, 0.92, 0.88))
	dokme_tormoz.button_down.connect(func(): tormoz_pa = true)
	dokme_tormoz.button_up.connect(func(): tormoz_pa = false)
	laye_namayesh.add_child(dokme_tormoz)
	_ja_gozar(dokme_tormoz, 0.0, 1.0, 0.0, 1.0, 260, -190, 500, -50)

	nitro_navar = ProgressBar.new()
	nitro_navar.min_value = 0
	nitro_navar.max_value = 100
	nitro_navar.value = 100
	nitro_navar.show_percentage = false
	nitro_navar.add_theme_stylebox_override("background", _ghalti(Color(0.07, 0.08, 0.14, 0.85), Color(0.3, 0.5, 0.9, 0.7), 6, 1, false))
	nitro_navar.add_theme_stylebox_override("fill", _ghalti(Color(0.25, 0.65, 1.0), Color(0.15, 0.4, 0.9), 6, 0, false))
	nitro_navar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	laye_namayesh.add_child(nitro_navar)
	_ja_gozar(nitro_navar, 0.5, 1.0, 0.5, 1.0, -110, -192, 110, -170)

	soratsanj = Soratsanj.new()
	soratsanj.bazi = self
	soratsanj.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ja_gozar(soratsanj, 0.5, 1.0, 0.5, 1.0, -125, -185, 125, -35)
	laye_namayesh.add_child(soratsanj)
	yaz_km = _yaz_ha(khatt, 56, Color(0.98, 0.98, 1.0))
	yaz_km.add_theme_constant_override("outline_size", 10)
	yaz_km.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ja_gozar(yaz_km, 0.5, 1.0, 0.5, 1.0, -90, -134, 90, -74)

	khat_sorat = KhatSorat.new()
	khat_sorat.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	khat_sorat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	khat_sorat.visible = false
	laye_namayesh.add_child(khat_sorat)

	shomar = Label.new()
	shomar.add_theme_font_override("font", khatt)
	shomar.add_theme_font_size_override("font_size", 130)
	shomar.add_theme_color_override("font_color", Color(0.98, 0.8, 0.2))
	shomar.add_theme_color_override("font_outline_color", Color(0.12, 0.05, 0.02))
	shomar.add_theme_constant_override("outline_size", 24)
	shomar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shomar.anchor_left = 0.0
	shomar.anchor_right = 1.0
	shomar.anchor_top = 0.335
	shomar.anchor_bottom = 0.335
	shomar.offset_top = -90.0
	shomar.offset_bottom = 100.0
	shomar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shomar.z_index = 30
	laye_namayesh.add_child(shomar)

	posh_toghof = Control.new()
	posh_toghof.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	posh_toghof.mouse_filter = Control.MOUSE_FILTER_IGNORE
	posh_toghof.visible = false
	var posh := ColorRect.new()
	posh.color = Color(0, 0, 0, 0.6)
	posh.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	posh.mouse_filter = Control.MOUSE_FILTER_IGNORE
	posh_toghof.add_child(posh)
	var yaz_toghof := Label.new()
	yaz_toghof.text = Saman.matn("paused")
	yaz_toghof.add_theme_font_override("font", bold)
	yaz_toghof.add_theme_font_size_override("font_size", 46)
	yaz_toghof.add_theme_color_override("font_color", Color(0.95, 0.93, 0.85))
	yaz_toghof.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	yaz_toghof.anchor_left = 0.0
	yaz_toghof.anchor_right = 1.0
	yaz_toghof.anchor_top = 0.28
	yaz_toghof.anchor_bottom = 0.38
	yaz_toghof.mouse_filter = Control.MOUSE_FILTER_IGNORE
	posh_toghof.add_child(yaz_toghof)
	var jabe := VBoxContainer.new()
	jabe.anchor_left = 0.5
	jabe.anchor_right = 0.5
	jabe.anchor_top = 0.42
	jabe.anchor_bottom = 0.42
	jabe.offset_left = -150
	jabe.offset_right = 150
	jabe.offset_top = 0
	jabe.offset_bottom = 240
	jabe.add_theme_constant_override("separation", 12)
	posh_toghof.add_child(jabe)
	var b_edame := Button.new()
	b_edame.text = "ادامه"
	b_edame.add_theme_font_override("font", bold)
	b_edame.add_theme_font_size_override("font_size", 30)
	_dokme_araeste(b_edame, true)
	b_edame.pressed.connect(_toghof)
	jabe.add_child(b_edame)
	var b_dobare := Button.new()
	b_dobare.text = Saman.matn("retry")
	b_dobare.add_theme_font_override("font", bold)
	b_dobare.add_theme_font_size_override("font_size", 30)
	_dokme_araeste(b_dobare, false)
	b_dobare.pressed.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/mosabeghe_3d.tscn"))
	jabe.add_child(b_dobare)
	var b_bargasht := Button.new()
	b_bargasht.text = Saman.matn("menu")
	b_bargasht.add_theme_font_override("font", bold)
	b_bargasht.add_theme_font_size_override("font_size", 30)
	_dokme_araeste(b_bargasht, false)
	b_bargasht.pressed.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/menu.tscn"))
	jabe.add_child(b_bargasht)
	laye_namayesh.add_child(posh_toghof)

func _yaz_ha(khatt: FontFile, andaze: int, rang: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", khatt)
	l.add_theme_font_size_override("font_size", andaze)
	l.add_theme_color_override("font_color", rang)
	l.add_theme_color_override("font_outline_color", Color(0.06, 0.05, 0.1))
	l.add_theme_constant_override("outline_size", 8)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	laye_namayesh.add_child(l)
	return l

func _ja_gozar(c: Control, al: float, at: float, ar: float, ab: float, ol: float, ot: float, orr: float, ob: float) -> void:
	c.anchor_left = al
	c.anchor_top = at
	c.anchor_right = ar
	c.anchor_bottom = ab
	c.offset_left = ol
	c.offset_top = ot
	c.offset_right = orr
	c.offset_bottom = ob

func _ghalti(bg: Color, border: Color, radius: int, bw: int = 0, saye := true) -> StyleBoxFlat:
	var g := StyleBoxFlat.new()
	g.bg_color = bg
	g.set_corner_radius_all(radius)
	g.border_color = border
	g.border_width_left = bw
	g.border_width_right = bw
	g.border_width_top = bw
	g.border_width_bottom = bw + (4 if bw > 0 else 0)
	if saye:
		g.shadow_color = Color(0, 0, 0, 0.35)
		g.shadow_size = 6
	return g

func _dokme_araeste(b: Button, asli := true) -> void:
	var paye := Color(0.16, 0.42, 0.60) if asli else Color(0.16, 0.17, 0.24)
	var tir := Color(0.10, 0.28, 0.42) if asli else Color(0.35, 0.38, 0.5)
	b.add_theme_stylebox_override("normal", _ghalti(paye, tir, 16, 2))
	b.add_theme_stylebox_override("hover", _ghalti(paye.lightened(0.08), tir, 16, 2))
	b.add_theme_stylebox_override("pressed", _ghalti(tir, tir, 16, 2))
	b.add_theme_stylebox_override("disabled", _ghalti(Color(0.2, 0.2, 0.26), Color(0.4, 0.4, 0.5), 16, 2))
	var roshan := Color(0.96, 0.97, 1.0)
	b.add_theme_color_override("font_color", roshan)
	b.add_theme_color_override("font_hover_color", roshan)
	b.add_theme_color_override("font_focus_color", roshan)
	b.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
	b.add_theme_color_override("font_disabled_color", Color(0.55, 0.55, 0.62))

# ───────────────────────── ورودی ─────────────────────────

func _konar_e(pos: Vector2) -> int:
	var andaze := get_viewport().get_visible_rect().size
	return -1 if pos.x < andaze.x * 0.5 else 1

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventScreenTouch:
		var andaze := get_viewport().get_visible_rect().size
		if e.pressed and e.position.y > andaze.y * 0.24:
			engesht_ha[e.index] = _konar_e(e.position)
		elif not e.pressed:
			engesht_ha.erase(e.index)
	elif e is InputEventScreenDrag:
		if engesht_ha.has(e.index):
			engesht_ha[e.index] = _konar_e(e.position)
	elif e is InputEventMouseButton:
		if e.button_index == MOUSE_BUTTON_LEFT:
			var andaze2 := get_viewport().get_visible_rect().size
			if e.pressed and e.position.y > andaze2.y * 0.24:
				engesht_ha[2001] = _konar_e(e.position)
			elif not e.pressed:
				engesht_ha.erase(2001)
	if e is InputEventKey and e.pressed:
		if e.keycode == KEY_LEFT or e.keycode == KEY_A:
			klid_chap = true
		elif e.keycode == KEY_RIGHT or e.keycode == KEY_D:
			klid_rast = true
		elif e.keycode == KEY_DOWN or e.keycode == KEY_S:
			tormoz_pa = true
		elif e.keycode == KEY_SPACE or e.keycode == KEY_X or e.keycode == KEY_UP:
			nitro_pa = true
	if e is InputEventKey and not e.pressed:
		if e.keycode == KEY_LEFT or e.keycode == KEY_A:
			klid_chap = false
		elif e.keycode == KEY_RIGHT or e.keycode == KEY_D:
			klid_rast = false
		elif e.keycode == KEY_DOWN or e.keycode == KEY_S:
			tormoz_pa = false
		elif e.keycode == KEY_SPACE or e.keycode == KEY_X or e.keycode == KEY_UP:
			nitro_pa = false

## مشتق نهایی فرمان — هر فریم پیش از فیزیک
func _ferman_yakja() -> void:
	var ch := klid_chap
	var ra := klid_rast
	for v in engesht_ha.values():
		if int(v) < 0:
			ch = true
		else:
			ra = true
	ferman_chap = ch
	ferman_rast = ra
	if eshare_chap != null:
		eshare_chap.miqdar = lerpf(eshare_chap.miqdar, 1.0 if ferman_chap else 0.0, 0.25)
		eshare_chap.queue_redraw()
	if eshare_rast != null:
		eshare_rast.miqdar = lerpf(eshare_rast.miqdar, 1.0 if ferman_rast else 0.0, 0.25)
		eshare_rast.queue_redraw()

func _toghof() -> void:
	if masabeghe_tamam and not tamam:
		return
	var derakht := get_tree()
	derakht.paused = not derakht.paused
	if posh_toghof != null:
		posh_toghof.visible = derakht.paused
	Sedasan.moharrek(not derakht.paused, 0.3)
	Sedasan.lastik(not derakht.paused, 0.0)
	Sedasan.bad(0.0 if derakht.paused else 0.2)

# ───────────────────────── اجزای HUD ─────────────────────────

## گیج سرعت — قوس + عقربه
class Soratsanj extends Control:
	var bazi: Node
	var pishrafte := 0.0

	func _process(_delta: float) -> void:
		if bazi == null:
			return
		var hadaf: float = clampf(bazi.sorat.length() / (bazi.bishtarin_sorat * 1.45), 0.0, 1.0)
		pishrafte = lerpf(pishrafte, hadaf, _delta * 8.0)
		queue_redraw()

	func _draw() -> void:
		var c := size * 0.5
		c.y = size.y * 0.86
		var r := minf(size.x * 0.46, size.y * 0.8)
		var a0 := PI * 0.78
		var a1 := PI * 2.22
		draw_arc(c, r, a0 + (a1 - a0) * 0.78, a1, 40, Color(0.75, 0.16, 0.12, 0.55), 11.0, true)
		draw_arc(c, r, a0, a1, 40, Color(0.08, 0.09, 0.14, 0.8), 11.0, true)
		for k in 11:
			var ta := a0 + (a1 - a0) * k / 10.0
			var p1 := c + Vector2(cos(ta), sin(ta)) * (r - 12.0)
			var p2 := c + Vector2(cos(ta), sin(ta)) * (r - 22.0)
			draw_line(p1, p2, Color(0.75, 0.78, 0.86, 0.5), 2.0, true)
		var rang := Color(0.55, 0.85, 1.0).lerp(Color(1.0, 0.32, 0.12), pishrafte)
		if pishrafte > 0.02:
			draw_arc(c, r, a0, a0 + (a1 - a0) * pishrafte, 40, rang, 7.0, true)
		var na := a0 + (a1 - a0) * pishrafte
		var novak := c + Vector2(cos(na), sin(na)) * (r - 20.0)
		draw_line(c, novak, Color(0.97, 0.97, 1.0, 0.95), 4.0, true)
		draw_circle(c, 7.0, Color(0.88, 0.88, 0.96, 0.95))

## خطوط سرعت نیترو
class KhatSorat extends Control:
	var t := 0.0

	func _process(delta: float) -> void:
		t += delta
		if visible:
			queue_redraw()

	func _draw() -> void:
		var tas := RandomNumberGenerator.new()
		tas.seed = int(t * 30.0)
		var c := size * 0.5
		for i in 22:
			var za := tas.randf_range(0.0, TAU)
			var r0 := tas.randf_range(430.0, 760.0)
			var tool_khat := tas.randf_range(90.0, 260.0)
			var jahat := Vector2(cos(za), sin(za))
			var p0 := c + jahat * r0
			var p1 := c + jahat * (r0 + tool_khat)
			draw_line(p0, p1, Color(0.8, 0.9, 1.0, tas.randf_range(0.05, 0.14)), 2.5)

## مینی‌مپ — مسیر + جای ماشین‌ها
class NagshehKuchak extends Control:
	var bazi: Node
	var jam := 0.0

	func _process(delta: float) -> void:
		jam += delta
		if jam > 0.08:
			jam = 0.0
			queue_redraw()

	func _draw() -> void:
		if bazi == null or bazi.gheteh_a.is_empty():
			return
		var g := bazi
		var pad := 10.0
		var sw := size.x - pad * 2.0
		var sh := size.y - pad * 2.0
		var m: Rect2 = g.mostatil_nagsheh
		var meq: float = minf(sw / m.size.x, sh / m.size.y)
		var of := (size - Vector2(m.size.x, m.size.y) * meq) * 0.5
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.06, 0.10, 0.72))
		draw_rect(Rect2(Vector2(2, 2), size - Vector2(4, 4)), Color(0.85, 0.68, 0.28, 0.35), false, 1.5)
		var nokat := PackedVector2Array()
		for i in range(0, g.gheteh_a.size(), 4):
			nokat.append((g.gheteh_a[i] - m.position) * meq + of)
		if nokat.size() > 2:
			nokat.append(nokat[0])
			draw_polyline(nokat, Color(0.55, 0.60, 0.72, 0.9), 3.0, true)
		var st: Vector2 = (g.gheteh_a[0] - m.position) * meq + of
		draw_circle(st, 3.5, Color(0.95, 0.95, 1.0, 0.9))
		for R in g.raghibha:
			var grh: Node3D = R["greh"]
			var rp: Vector2 = Vector2(grh.position.x - m.position.x, grh.position.z - m.position.y) * meq + of
			draw_circle(rp, 4.0, Color(0.95, 0.35, 0.30, 0.95))
		if g.mashin != null:
			var pp: Vector2 = Vector2(g.ja_mashin.x - m.position.x, g.ja_mashin.y - m.position.y) * meq + of
			draw_circle(pp, 5.0, Color(1.0, 0.82, 0.2, 1.0))
			draw_circle(pp, 7.5, Color(1.0, 0.82, 0.2, 0.35))

## فلش گوشه — جای متن «چپ/راست»، بدون یک کلمه
class AlamatFerman extends Control:
	var bazi: Node
	var jahat := -1
	var miqdar := 0.0

	func _draw() -> void:
		if miqdar < 0.02:
			return
		var c := size * 0.5
		var rang := Color(1.0, 0.95, 0.75, 0.30 * miqdar)
		for k in 3:
			var x := c.x + float(jahat) * (k - 1) * 26.0
			draw_polyline(PackedVector2Array([
				Vector2(x + float(jahat) * 14.0, c.y - 22.0),
				Vector2(x - float(jahat) * 14.0, c.y),
				Vector2(x + float(jahat) * 14.0, c.y + 22.0),
			]), rang, 7.0, true)

# ───────────────────────── حلقهٔ اصلی ─────────────────────────

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	zaman_gozashte += delta

	if shoro > 0.0 and not masabeghe_tamam:
		shoro -= delta
		var payamaki := int((2.6 - maxf(shoro, 0.0)) / 0.65)
		if payamaki != _marhale_moad and payamaki <= 4:
			_marhale_moad = payamaki
			if payamaki < 3:
				shomar.text = raqam_fa(3 - payamaki)
				Sedasan.ejra_seda("beep")
			else:
				shomar.text = Saman.matn("go")
				Sedasan.ejra_seda("horn")
				shomar.add_theme_color_override("font_color", Color(0.3, 0.95, 0.5))
			shomar.pivot_offset = Vector2(get_viewport().get_visible_rect().size.x * 0.5, 95.0)
			shomar.scale = Vector2(1.6, 1.6)
			shomar.modulate.a = 1.0
			var itw := create_tween()
			itw.tween_property(shomar, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			itw.parallel().tween_property(shomar, "modulate:a", 0.0, 0.4).set_delay(0.25)
		if shoro <= 0.0:
			shomar.visible = false
		Sedasan.moharrek_kamel(true, clampf(0.85 - shoro * 0.3, 0.15, 0.85), 0.55, false)
		_ranandegi_raghibha(delta)
		_dorbin_bezan(delta, true)
		return

	if autotest:
		_run_autotest(delta)

	_ferman_yakja()
	_roz_sani_bazigar(delta)
	_ranandegi_raghibha(delta)
	_ranandegi_trafik(delta)
	_hud_tazeh(delta)
	_dorbin_bezan(delta, false)
	_langar_shakhsiat()

	if larzesh > 0.0:
		larzesh = maxf(0.0, larzesh - delta * 26.0)
		dorbine.h_offset = randf_range(-larzesh, larzesh)
	else:
		dorbine.h_offset = 0.0

# ───────────────────────── فیزیک بازیکن ─────────────────────────

func _roz_sani_bazigar(delta: float) -> void:
	if masabeghe_tamam:
		sorat *= exp(-1.6 * delta)
		ja_mashin += sorat * delta
		mashin.position = _j3(ja_mashin)
		Sedasan.tavagof_ranandegi()
		return

	var jolo := Vector2.RIGHT.rotated(zaviye)
	var vf := sorat.dot(jolo)
	var janbi := sorat - jolo * vf

	var ferman := 0.0
	if ferman_chap:
		ferman -= 1.0
	if ferman_rast:
		ferman += 1.0
	var sn := clampf(vf / bishtarin_sorat, -1.0, 1.0)

	var mayel_derift := (tormoz_pa and absf(vf) > 250.0 and absf(ferman) > 0.2) \
		or (absf(ferman) > 0.85 and absf(vf) > 0.78 * bishtarin_sorat)
	if mayel_derift != derift:
		derift = mayel_derift
		if derift:
			Sedasan.lastik(true, 0.7)

	nitro_baz = nitro_pa and anbar_nitro > 0.02 and not tormoz_pa
	if nitro_baz and not _nitro_pish:
		sorat += jolo * 135.0
		larzesh = maxf(larzesh, 1.4)
	_nitro_pish = nitro_baz
	if nitro_baz:
		anbar_nitro = maxf(0.0, anbar_nitro - nerkh_takhlive * delta)
		if not khat_sorat.visible:
			Sedasan.ejra_seda("nitro")
	else:
		anbar_nitro = minf(1.0, anbar_nitro + delta * (0.10 if derift else 0.012))

	var hadaf := bishtarin_sorat * (TAVAN_NITRO if nitro_baz else 1.0)
	if tormoz_pa and not derift:
		vf = move_toward(vf, 0.0, TORMOZ * delta)
	else:
		var shetab := SHETAB * (2.2 if nitro_baz else 1.0)
		vf = move_toward(vf, hadaf, shetab * delta)

	var nr := _nazdiktarin(ja_mashin)
	birahne = nr["dist"] > pahna_rah * 0.5 - 6.0
	var nazdik_rah: bool = nr["dist"] < pahna_rah * 0.5 + 60.0
	if birahne:
		vf *= exp(-1.9 * delta)
		larzesh = maxf(larzesh, 1.6)

	var charkhesh := NERKH_CHARKHESH * sn * (1.35 if derift else 1.0)
	zaviye += ferman * charkhesh * delta

	var chasb := CHASB_DERIFT if derift else chasb_asli
	janbi *= exp(-chasb * delta)
	sorat = jolo * vf + janbi
	ja_mashin += sorat * delta

	_vashkanie_sakhtemanha()

	var mahdud := Vector2(
		clampf(ja_mashin.x, had_paein.x, had_bala.x),
		clampf(ja_mashin.y, had_paein.y, had_bala.y))
	if mahdud != ja_mashin:
		ja_mashin = mahdud
		sorat *= 0.5

	_temas_mashinha()

	var s_jadid: float = nr["s"]
	var pishin := s_ro_masir
	s_ro_masir = s_jadid
	if nazdik_rah:
		if pishin > tool_masir * 0.85 and s_ro_masir < tool_masir * 0.15 and vf > 0.0:
			dor += 1
			if dor < tedad_dor:
				Sedasan.ejra_seda("lap")
			else:
				_gozar_az_khat()
		elif pishin < tool_masir * 0.15 and s_ro_masir > tool_masir * 0.85 and vf < 0.0:
			dor -= 1

	if derift and absf(vf) > 120.0:
		shomar_tanasob -= delta
		if shomar_tanasob <= 0.0:
			shomar_tanasob = 0.024
			var aghab := ja_mashin - jolo * 80.0
			var amudi := Vector2(-jolo.y, jolo.x)
			rad_ha.ezafe(aghab + amudi * 26.0, zaviye)
			rad_ha.ezafe(aghab - amudi * 26.0, zaviye)
	if dud_p != null:
		dud_p.emitting = derift and absf(vf) > 140.0
	var chasb_nesbi := CHASB_DERIFT if derift else chasb_asli
	var sargardah := clampf(1.0 - (chasb_nesbi / chasb_asli) + (janbi.length() / 240.0), 0.0, 1.0)
	Sedasan.lastik(derift and absf(vf) > 100.0, sargardah)

	var sn2 := clampf(absf(vf) / bishtarin_sorat, 0.0, 1.04)
	var g := 1
	while g < DANDAHA.size() and sn2 > float(DANDAHA[g]):
		g += 1
	g = mini(g, DANDAHA.size() - 1)
	var dandeh_pa := float(DANDAHA[g - 1])
	var dandeh_bala := float(DANDAHA[g])
	var rt := clampf((sn2 - dandeh_pa) / maxf(0.02, dandeh_bala - dandeh_pa), 0.0, 1.0)
	rt = 0.16 + 0.84 * rt
	if nitro_baz:
		rt = minf(1.0, rt + 0.12)
	dord_moharrek = lerpf(dord_moharrek, rt, minf(1.0, delta * 11.0))
	if g != dandeh:
		if g > dandeh and sn2 > 0.06 and _zaman_dandeh <= 0.0:
			Sedasan.ejra_seda("shift", -11.0)
			_zaman_dandeh = 0.22
		dandeh = g
	_zaman_dandeh = maxf(0.0, _zaman_dandeh - delta)
	Sedasan.moharrek_kamel(true, dord_moharrek, 0.25 if tormoz_pa else 1.0, nitro_baz)
	Sedasan.bad(clampf(sn2 * 1.08, 0.0, 1.0))
	if shuale_p != null:
		shuale_p.emitting = nitro_baz
	if khat_sorat != null:
		khat_sorat.visible = nitro_baz
	if dud_ravan_p != null:
		dud_ravan_p.emitting = absf(vf) < 95.0
	if chragh_tormoz_p != null:
		var hadafe_chragh := 3.4 if (tormoz_pa or (derift and absf(vf) > 190.0)) else 1.0
		chragh_tormoz_p.emission_energy_multiplier = lerpf(chragh_tormoz_p.emission_energy_multiplier, hadafe_chragh, minf(1.0, delta * 10.0))

	mashin.position = _j3(ja_mashin)
	mashin.rotation.y = _charkh3(zaviye)
	var janbi_mahalli := janbi.rotated(-zaviye).y
	var ghalt_janbi := clampf(janbi_mahalli * 0.0011, -0.16, 0.16)
	var ghalt_bala := clampf(-0.03 * (absf(vf) / maxf(1.0, bishtarin_sorat)), -0.05, 0.05)
	badaneh.rotation.z = lerpf(badaneh.rotation.z, ghalt_bala, minf(1.0, delta * 7.0))
	badaneh.rotation.x = lerpf(badaneh.rotation.x, ghalt_janbi, minf(1.0, delta * 7.0))
	for ch in charkhha_p:
		ch.rotate_object_local(Vector3.UP, -vf * delta * 0.02)

func _vashkanie_sakhtemanha() -> void:
	for b in sakhtemanha:
		var andaze: Vector2 = b["andaze"]
		var mahalli: Vector2 = (ja_mashin - b["ja"]).rotated(-float(b["charkh"]))
		var hx := andaze.x * 0.5 + 20.0
		var hy := andaze.y * 0.5 + 20.0
		if absf(mahalli.x) < hx and absf(mahalli.y) < hy:
			var px := hx - absf(mahalli.x)
			var py := hy - absf(mahalli.y)
			var tel := Vector2.ZERO
			if px < py:
				tel = Vector2(signf(mahalli.x) * px, 0)
			else:
				tel = Vector2(0, signf(mahalli.y) * py)
			ja_mashin += tel.rotated(float(b["charkh"]))
			if zaman_gozashte > zaman_tanesh:
				zaman_tanesh = zaman_gozashte + 0.5
				sorat *= 0.42
				larzesh = 7.0
				Sedasan.ejra_seda("crash")
				_gheriq(_j3(ja_mashin, 20.0), 16)
	for so in mavaneh:
		var dv: Vector2 = ja_mashin - so["ja"]
		var d := dv.length()
		var rr: float = float(so["shoa"]) + 24.0
		if d < rr and d > 0.01:
			ja_mashin += dv.normalized() * (rr - d)
			if zaman_gozashte > zaman_tanesh:
				zaman_tanesh = zaman_gozashte + 0.5
				sorat *= 0.55
				larzesh = maxf(larzesh, 4.0)
				Sedasan.ejra_seda("clank")
				_gheriq(_j3(so["ja"], 15.0), 8)

func _temas_mashinha() -> void:
	for R in raghibha:
		var grh: Node3D = R["greh"]
		var rp := Vector2(grh.position.x, grh.position.z)
		var d := ja_mashin.distance_to(rp)
		if d < 76.0 and d > 0.01:
			var tel := (ja_mashin - rp).normalized() * (76.0 - d) * 0.6
			ja_mashin += tel
			sorat *= 0.985
	for T in trafikha:
		var grh2: Node3D = T["greh"]
		var tp := Vector2(grh2.position.x, grh2.position.z)
		if ja_mashin.distance_to(tp) < 74.0 and zaman_gozashte > zaman_bezarav:
			zaman_bezarav = zaman_gozashte + 1.1
			sorat *= 0.34
			larzesh = 10.0
			Sedasan.ejra_seda("crash")
			_gheriq(_j3((ja_mashin + tp) * 0.5, 20.0), 18)
			T["sorat"] *= 0.4
			T["khat"] += (30.0 if T["khat"] > 0 else -30.0)

func _gheriq(ja: Vector3, tedad: int) -> void:
	var gheriq := CPUParticles3D.new()
	gheriq.position = ja
	gheriq.amount = tedad
	gheriq.lifetime = 0.5
	gheriq.one_shot = true
	gheriq.explosiveness = 1.0
	gheriq.direction = Vector3.UP
	gheriq.spread = 85.0
	gheriq.initial_velocity_min = 170.0
	gheriq.initial_velocity_max = 430.0
	gheriq.gravity = Vector3(0, -950, 0)
	gheriq.scale_amount_min = 1.6
	gheriq.scale_amount_max = 3.4
	var ghal := QuadMesh.new()
	ghal.size = Vector2(9.0, 9.0)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	m.vertex_color_use_as_albedo = true
	ghal.material = m
	gheriq.mesh = ghal
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.7, 1.0])
	g.colors = PackedColorArray([Color(1.0, 0.92, 0.6), Color(1.0, 0.55, 0.2), Color(0.8, 0.2, 0.05, 0.0)])
	gheriq.color_ramp = g
	jahan.add_child(gheriq)
	gheriq.emitting = true
	get_tree().create_timer(1.3).timeout.connect(gheriq.queue_free)

# ───────────────────────── رقیب‌ها و ترافیک ─────────────────────────

func _ranandegi_raghibha(delta: float) -> void:
	var dar_rahandegi := not masabeghe_tamam and shoro <= 0.0
	for R in raghibha:
		var s: float = R["s"]
		if dar_rahandegi:
			var paye := bishtarin_sorat * float(R["ritm"])
			var pishraft_man := float(dor) * tool_masir + s_ro_masir
			var shekad := pishraft_man - s
			if shekad > 600.0:
				paye *= 1.15
			elif shekad < -500.0:
				paye *= 0.9
			var d1 := _masir_jahat(s + 90.0)
			var d2 := _masir_jahat(s + 300.0)
			var za := absf(d1.angle_to(d2))
			var meghias := 1.0 - clampf(za * 0.62, 0.0, 0.44)
			R["pich"] = za > 0.3
			R["kund"] = meghias < 0.82
			R["sorat"] = lerpf(float(R["sorat"]), paye * meghias, delta * 2.0)
			s += float(R["sorat"]) * delta
			R["s"] = s
			R["khat_konuni"] = lerpf(float(R["khat_konuni"]), float(R["khat"]), delta * 1.2)
		var dd := _masir_jahat(s)
		var nn := Vector2(-dd.y, dd.x)
		var ja := _masir_ja(s) + nn * float(R["khat_konuni"])
		var grh: Node3D = R["greh"]
		grh.position = _j3(ja)
		var tha := dd.angle()
		grh.rotation.y = lerp_angle(float(grh.rotation.y), _charkh3(tha), delta * 6.0)
		var mat_t: StandardMaterial3D = R["chragh_tormoz"]
		var hadafe_chragh := 3.2 if (dar_rahandegi and bool(R["kund"])) else 1.0
		mat_t.emission_energy_multiplier = lerpf(mat_t.emission_energy_multiplier, hadafe_chragh, minf(1.0, delta * 9.0))
		if dar_rahandegi and bool(R["pich"]) and float(R["sorat"]) > 300.0:
			R["t"] = float(R["t"]) - delta * 0.5
			if float(R["t"]) <= 0.0:
				R["t"] = 0.024
				var aghab := ja - dd * 74.0
				rad_ha.ezafe(aghab + nn * 24.0, tha)
				rad_ha.ezafe(aghab - nn * 24.0, tha)
	if yaz_makan != null:
		var rk := _rotbe_hesab() if not masabeghe_tamam else rotbe_payan
		yaz_makan.text = raqam_fa(rk) + "/" + raqam_fa(raghibha.size() + 1)
	if yaz_dor != null:
		var namayeshi := mini(dor + 1, tedad_dor)
		yaz_dor.text = "دور " + raqam_fa(namayeshi) + "/" + raqam_fa(tedad_dor)

func _ranandegi_trafik(delta: float) -> void:
	var dar_rahandegi := not masabeghe_tamam and shoro <= 0.0
	var hadd := int(4.0 + float(marhale.get("trafik", 1.0)) * 3.0)
	_zaman_trafik -= delta
	if dar_rahandegi and _zaman_trafik <= 0.0 and trafikha.size() < hadd:
		_zaman_trafik = randf_range(1.1, 1.9) / maxf(0.5, float(marhale.get("trafik", 1.0)))
		var pishraft_man := float(dor) * tool_masir + s_ro_masir
		_avari_trafik(pishraft_man + randf_range(1100.0, 2400.0))
	for i in range(trafikha.size() - 1, -1, -1):
		var T = trafikha[i]
		if dar_rahandegi:
			T["s"] += float(T["jahat"]) * float(T["sorat"]) * delta
		var pishraft_man2 := float(dor) * tool_masir + s_ro_masir
		if absf(float(T["s"]) - pishraft_man2) > 2800.0:
			T["greh"].queue_free()
			trafikha.remove_at(i)
			continue
		var ss := fposmod(float(T["s"]), tool_masir)
		var dd := _masir_jahat(ss) * float(T["jahat"])
		var nn := Vector2(-dd.y, dd.x)
		var ja := _masir_ja(ss) + nn * float(T["khat"])
		T["greh"].position = _j3(ja)
		T["greh"].rotation.y = _charkh3(dd.angle())

# ───────────────────────── HUD و دوربین ─────────────────────────

func _hud_tazeh(_delta: float) -> void:
	if Saman.behtarin_zaman(int(marhale["shomare"])) > 0.0:
		yaz_rekord.text = "رکورد " + zaman_fa(Saman.behtarin_zaman(int(marhale["shomare"])))
	else:
		yaz_rekord.text = ""
	yaz_zaman.text = "زمان " + zaman_fa(maxf(0.0, zaman_gozashte - 2.6))
	var kol := float(dor) * tool_masir + s_ro_masir
	pishraft.value = 100.0 * clampf(kol / (float(tedad_dor) * tool_masir), 0.0, 1.0)
	nitro_navar.value = anbar_nitro * 100.0
	var vf := absf(sorat.dot(Vector2.RIGHT.rotated(zaviye)))
	yaz_km.text = raqam_fa(int(vf * 0.21))

## دوربین تعقیبی — پشت ماشین، پایین، با حس سرعت
func _dorbin_bezan(delta: float, sinemayi: bool) -> void:
	var jolo := Vector2.RIGHT.rotated(zaviye)
	var jolo3 := _j3(jolo)
	var nerkh := clampf(sorat.length() / bishtarin_sorat, 0.0, 1.35)
	var fasele := 360.0 + 200.0 * nerkh
	var bolandi := 150.0 + 46.0 * nerkh
	var hadafe_fov := 72.0 + 8.0 * clampf(nerkh, 0.0, 1.0)
	if nitro_baz:
		hadafe_fov += 9.0
	if masabeghe_tamam:
		fasele = 210.0
		bolandi = 120.0
	if sinemayi:
		var pishrafti := 1.0 - clampf(shoro / 2.6, 0.0, 1.0)
		fasele = 300.0 + 170.0 * pishrafti
		bolandi = 210.0 - 60.0 * pishrafti
		hadafe_fov = 66.0
		var za := 2.4 * (1.0 - pishrafti)
		dorbine.position = _j3(ja_mashin) + Basis(Vector3.UP, za) * (-jolo3 * fasele) + Vector3.UP * bolandi
		dorbine.look_at(_j3(ja_mashin) + Vector3.UP * 60.0)
		dorbine.fov = hadafe_fov
		return
	var hadaf := _j3(ja_mashin) - jolo3 * fasele + Vector3.UP * bolandi
	dorbine.position = dorbine.position.lerp(hadaf, minf(1.0, delta * 4.6))
	if dorbine.position.distance_to(hadaf) > 620.0:
		dorbine.position = hadaf
	var negah := _j3(ja_mashin) + jolo3 * (240.0 + 190.0 * nerkh) + Vector3.UP * 36.0
	if dorbine.position.distance_to(negah) > 0.01:
		dorbine.look_at(negah)
	dorbine.fov = lerpf(dorbine.fov, hadafe_fov, minf(1.0, delta * 3.2))
	if dorbine.position.y < 60.0:
		dorbine.position.y = 60.0

func _langar_shakhsiat() -> void:
	if langar_mashin == null or dorbine == null:
		return
	var andaze := get_viewport().get_visible_rect().size
	var ja_did := Vector2(andaze.x * 0.5, andaze.y * 0.5)
	if dorbine.is_position_in_frustum(_j3(ja_mashin, 92.0)):
		ja_did = dorbine.unproject_position(_j3(ja_mashin, 92.0))
	langar_mashin.position = ja_did + Vector2(0, -46)

# ───────────────────────── پایان و جشن ─────────────────────────

func _gozar_az_khat() -> void:
	if masabeghe_tamam:
		return
	masabeghe_tamam = true
	rotbe_payan = _rotbe_hesab()
	if not tamam:
		tamam = true
		var zaman_mosabeghe := maxf(0.0, zaman_gozashte - 2.6)
		var setare := Saman.sabte_natije(int(marhale["shomare"]), rotbe_payan, zaman_mosabeghe)
		var bord := rotbe_payan <= 3
		if bord:
			Sedasan.ejra_seda("win")
		else:
			Sedasan.ejra_seda("fail")
		_jashn(bord)
		var w := bord
		var s := setare
		get_tree().create_timer(2.6).timeout.connect(func(): _namayesh_payam(w, s))

func _rotbe_hesab() -> int:
	var pishraft_man := float(dor) * tool_masir + s_ro_masir
	var rotbe := 1
	for R in raghibha:
		if float(R["s"]) > pishraft_man:
			rotbe += 1
	return rotbe

func _jashn(bord: bool) -> void:
	Sedasan.lastik(false)
	for i in 3:
		var c := CPUParticles3D.new()
		c.position = _j3(ja_mashin, 120.0) + Vector3(float(i - 1) * 200.0, 0, 0)
		c.emitting = false
		c.amount = 40
		c.lifetime = 3.0
		c.direction = Vector3(0, -1, 0)
		c.spread = 30.0
		c.gravity = Vector3(0, -260, 0)
		c.initial_velocity_min = 60.0
		c.initial_velocity_max = 160.0
		c.scale_amount_min = 5.0
		c.scale_amount_max = 9.0
		var ghal := QuadMesh.new()
		ghal.size = Vector2(16, 16)
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		m.vertex_color_use_as_albedo = true
		ghal.material = m
		c.mesh = ghal
		var g := Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
		var rangha: Array = [Color(1.0, 0.42, 0.16), Color(1.0, 0.85, 0.2), Color(0.25, 0.75, 0.95)]
		g.colors = PackedColorArray([rangha[i], rangha[(i + 1) % 3], rangha[(i + 2) % 3]])
		c.color_ramp = g
		jahan.add_child(c)
		c.emitting = bord
	if shakhsiat != null and langar_mashin != null:
		var id_e_man := str(Saman.MASHINHA[Saman.mashin_entekhabi]["shenase"])
		shakhsiat.begu(langar_mashin, id_e_man, "win" if bord else "lose")
		await get_tree().process_frame
		if shakhsiat.hobab != null and is_instance_valid(shakhsiat.hobab):
			var andaze := get_viewport().get_visible_rect().size
			shakhsiat.hobab.position = Vector2((andaze.x - shakhsiat.hobab.size.x) * 0.5, 92.0)
			get_tree().create_timer(2.1).timeout.connect(func():
				if shakhsiat.hobab != null and is_instance_valid(shakhsiat.hobab):
					shakhsiat.hobab.queue_free()
					shakhsiat.hobab = null)

func _namayesh_payam(bord: bool, setare: int) -> void:
	panel_payan = PanelContainer.new()
	panel_payan.add_theme_stylebox_override("panel", _ghalti(Color(0.11, 0.12, 0.17), Color(0.85, 0.68, 0.28, 0.6), 24, 3))
	var jabe := VBoxContainer.new()
	jabe.add_theme_constant_override("separation", 10)
	panel_payan.add_child(jabe)
	var onvan := Label.new()
	var tarjoman := ["قهرمان خیابان!", "دوم شدی!", "سوم شدی!", "باختی!"]
	onvan.text = str(tarjoman[clampi(rotbe_payan - 1, 0, 3)])
	onvan.add_theme_font_override("font", load("res://assets/fonts/Vazirmatn-Bold.ttf"))
	onvan.add_theme_color_override("font_color", Color(0.98, 0.85, 0.3) if bord else Color(0.95, 0.45, 0.35))
	onvan.add_theme_font_size_override("font_size", 42)
	onvan.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	jabe.add_child(onvan)
	var setare_yaz := Label.new()
	setare_yaz.text = ("★★★".substr(0, setare) + "···".substr(0, 3 - setare)) if setare > 0 else "---"
	setare_yaz.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	setare_yaz.add_theme_font_size_override("font_size", 44)
	setare_yaz.add_theme_color_override("font_color", Color(0.95, 0.78, 0.2))
	jabe.add_child(setare_yaz)
	var jayze := Label.new()
	var rt := maxf(0.0, zaman_gozashte - 2.6)
	var bt := Saman.behtarin_zaman(int(marhale["shomare"]))
	jayze.text = "جایگاه " + raqam_fa(rotbe_payan) + "/" + raqam_fa(raghibha.size() + 1) + "  •  زمان " + zaman_fa(rt)
	if bt > 0.0:
		jayze.text += "  •  رکورد " + zaman_fa(bt)
	jayze.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	jayze.add_theme_font_size_override("font_size", 26)
	jayze.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	jabe.add_child(jayze)
	var saf := HBoxContainer.new()
	saf.alignment = BoxContainer.ALIGNMENT_CENTER
	saf.add_theme_constant_override("separation", 14)
	dokme_dobare = Button.new()
	dokme_dobare.text = Saman.matn("retry")
	dokme_dobare.add_theme_font_override("font", load("res://assets/fonts/Vazirmatn-Bold.ttf"))
	dokme_dobare.pressed.connect(func():
		Saman.set_meta("marhale_shoroo", int(marhale["shomare"]))
		get_tree().change_scene_to_file("res://scenes/mosabeghe_3d.tscn"))
	_dokme_araeste(dokme_dobare, true)
	saf.add_child(dokme_dobare)
	if bord and int(marhale["shomare"]) < Saman.MARHALEHA.size():
		var b_badi := Button.new()
		b_badi.text = Saman.matn("next")
		b_badi.add_theme_font_override("font", load("res://assets/fonts/Vazirmatn-Bold.ttf"))
		b_badi.pressed.connect(func():
			Saman.set_meta("marhale_shoroo", int(marhale["shomare"]) + 1)
			get_tree().change_scene_to_file("res://scenes/mosabeghe_3d.tscn"))
		_dokme_araeste(b_badi, true)
		saf.add_child(b_badi)
	dokme_menu = Button.new()
	dokme_menu.text = Saman.matn("menu")
	dokme_menu.add_theme_font_override("font", load("res://assets/fonts/Vazirmatn-Bold.ttf"))
	dokme_menu.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menu.tscn"))
	_dokme_araeste(dokme_menu, false)
	saf.add_child(dokme_menu)
	jabe.add_child(saf)
	laye_namayesh.add_child(panel_payan)
	_ja_gozar(panel_payan, 0.5, 0.5, 0.5, 0.5, -290, -175, 290, 135)
	panel_payan.custom_minimum_size = Vector2(580, 310)
	panel_payan.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel_payan.grow_vertical = Control.GROW_DIRECTION_BOTH

func _exit_tree() -> void:
	Sedasan.moharrek(false)
	Sedasan.lastik(false)

# ───────────────────────── آزمون خودکار ─────────────────────────

func _run_autotest(delta: float) -> void:
	_timer_khodkar += delta
	match _marhale_khodkar:
		0:
			if _timer_khodkar > 0.6:
				_marhale_khodkar = 1
				_zaviye_aval = zaviye
				_pish_at(get_viewport().get_visible_rect().size * Vector2(0.85, 0.72))
		1:
			if _timer_khodkar > 0.75:
				_marhale_khodkar = 2
				_rah_at(get_viewport().get_visible_rect().size * Vector2(0.85, 0.72))
				_pish_at(get_viewport().get_visible_rect().size * Vector2(0.15, 0.72))
				var gardesh := absf(angle_difference(_zaviye_aval, zaviye))
				print("[tizpa][autotest] STEER-RIGHT ", "OK" if gardesh > 0.08 else "FAIL turned=" + str(gardesh))
				var rs := s_ro_masir + 60.0
				ja_mashin = _masir_ja(rs)
				zaviye = _masir_jahat(rs).angle()
				sorat = _masir_jahat(rs) * bishtarin_sorat * 0.85
				s_ro_masir = rs
				if gardesh <= 0.08:
					get_tree().quit(1)
		2:
			if _timer_khodkar > 0.9:
				_marhale_khodkar = 3
				_rah_at(get_viewport().get_visible_rect().size * Vector2(0.15, 0.72))
				_pish_at(Vector2(get_viewport().get_visible_rect().size.x - 380.0, get_viewport().get_visible_rect().size.y - 120.0))
		3:
			if _timer_khodkar > 1.9:
				_marhale_khodkar = 4
				_rah_at(Vector2(get_viewport().get_visible_rect().size.x - 380.0, get_viewport().get_visible_rect().size.y - 120.0))
				print("[tizpa][autotest] NITRO ", "OK" if anbar_nitro < 0.98 else "FAIL")
				if anbar_nitro >= 0.98:
					get_tree().quit(1)
		4:
			if _timer_khodkar > 2.4 and _marhale_khodkar == 4:
				_marhale_khodkar = 7
				var rs2 := s_ro_masir + 40.0
				ja_mashin = _masir_ja(rs2)
				zaviye = _masir_jahat(rs2).angle()
				sorat = _masir_jahat(rs2) * bishtarin_sorat * 0.95
				s_ro_masir = rs2
				_pish_at(Vector2(380.0, get_viewport().get_visible_rect().size.y - 120.0))
				_pish_at(get_viewport().get_visible_rect().size * Vector2(0.85, 0.72))
				_derift_did = false
		7:
			if derift:
				_derift_did = true
			if _timer_khodkar > 3.4:
				_marhale_khodkar = 8
				_rah_at(Vector2(380.0, get_viewport().get_visible_rect().size.y - 120.0))
				_rah_at(get_viewport().get_visible_rect().size * Vector2(0.85, 0.72))
				print("[tizpa][autotest] DRIFT ", "OK" if _derift_did else "FAIL")
		8:
			if _timer_khodkar > 6.0:
				var nr: Dictionary = _nazdiktarin(ja_mashin)
				_zakhire_aks("shot_bazi.png")
				print("[tizpa][autotest] AUTOTEST OK dor=", dor, " ja=", ja_mashin.round(), " spd=", int(sorat.length()), " birahne=", nr["dist"] < pahna_rah * 0.5, " rotbe=", _rotbe_hesab(), " raghib=", raghibha.size(), " trafik=", trafikha.size(), " bld=", sakhtemanha.size(), " nazdik=", int(nr["dist"]))
				get_tree().quit()

func _pish_at(pos: Vector2) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	ev.button_mask = MOUSE_BUTTON_MASK_LEFT
	ev.position = pos
	ev.global_position = pos
	Input.parse_input_event(ev)

func _rah_at(pos: Vector2) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = false
	ev.position = pos
	ev.global_position = pos
	Input.parse_input_event(ev)

func _tap(dokme: Button) -> void:
	_pish_at(dokme.get_global_rect().get_center())
	_rah_at(dokme.get_global_rect().get_center())

## تست چرخه کامل: توقف → ادامه → خط پایان سریع → پنل → دوباره → منو
func _khodkar_kamel() -> void:
	await get_tree().create_timer(2.8).timeout
	_tap(dokme_toghof)
	await get_tree().create_timer(0.3).timeout
	var m1: bool = get_tree().paused
	_tap(dokme_toghof)
	await get_tree().create_timer(0.3).timeout
	var m2: bool = get_tree().paused
	print("[tizpa][autotest] TAP-PAUSE ", "OK" if (m1 and not m2) else "FAIL")
	if not (m1 and not m2):
		get_tree().quit(1)
		return
	dor = tedad_dor - 1
	s_ro_masir = tool_masir - 900.0
	ja_mashin = _masir_ja(s_ro_masir)
	zaviye = _masir_jahat(s_ro_masir).angle()
	sorat = _masir_jahat(s_ro_masir) * bishtarin_sorat * 0.8
	var guard := 0.0
	while not masabeghe_tamam and guard < 9.0:
		await get_tree().process_frame
		guard += get_process_delta_time()
		var jolo_taraf := 320.0 + sorat.length() * 0.5
		var hadaf2 := _masir_ja(s_ro_masir + jolo_taraf)
		var bayad := (hadaf2 - ja_mashin).angle()
		var ekhtelaf := angle_difference(zaviye, bayad)
		klid_chap = ekhtelaf < -0.03
		klid_rast = ekhtelaf > 0.03
	klid_chap = false
	klid_rast = false
	await get_tree().create_timer(1.6).timeout
	await get_tree().create_timer(3.8).timeout
	if panel_payan == null or dokme_dobare == null or dokme_menu == null:
		print("[tizpa][autotest] END-PANEL FAIL")
		get_tree().quit(1)
		return
	print("[tizpa][autotest] END-PANEL OK")
	_zakhire_aks("shot_panel_payan.png")
	if not Saman.has_meta("at_dobare"):
		Saman.set_meta("at_dobare", 1)
		dokme_dobare.pressed.emit()
		return
	var derakht := get_tree()
	dokme_menu.pressed.emit()
	derakht.create_timer(3.5).timeout.connect(func():
		if derakht.current_scene != null and derakht.current_scene.scene_file_path.ends_with("menu.tscn"):
			print("[tizpa][autotest] ENDMENU-RETURN OK")
		else:
			print("[tizpa][autotest] ENDMENU-RETURN FAIL")
		derakht.quit())

## پلی‌تست کامل — اتوپایلوت مسیر
func _ejra_pleitest() -> void:
	await get_tree().create_timer(0.4).timeout
	_zakhire_aks("pt_1_shomar.png")
	await get_tree().create_timer(2.7).timeout
	print("[tizpa][pleitest] GO — رانندگی شروع")
	var t0 := Time.get_ticks_msec()
	var bala_tarin := 0.0
	var aks_ha := {}
	var barname := {6.0: "pt_2_shoroo.png", 14.0: "pt_3_mostaghim.png", 22.0: "pt_4_pich.png",
		34.0: "pt_5_mian_mosabeghe.png", 46.0: "pt_6_trafik.png", 58.0: "pt_7_payan.png"}
	while not masabeghe_tamam and tamam == false:
		await get_tree().process_frame
		var el := (Time.get_ticks_msec() - t0) / 1000.0
		var jolo_taraf := 300.0 + sorat.length() * 0.45
		var hadaf := _masir_ja(s_ro_masir + jolo_taraf)
		var d := _masir_jahat(s_ro_masir + jolo_taraf)
		var nn := Vector2(-d.y, d.x)
		hadaf += nn * 30.0
		var bayad := (hadaf - ja_mashin).angle()
		var ekhtelaf := angle_difference(zaviye, bayad)
		klid_chap = ekhtelaf < -0.03
		klid_rast = ekhtelaf > 0.03
		var d2 := _masir_jahat(s_ro_masir + 700.0)
		var pich := absf(d.angle_to(d2))
		nitro_pa = pich < 0.06 and anbar_nitro > 0.5
		tormoz_pa = pich > 0.5 and sorat.length() > bishtarin_sorat * 0.75
		bala_tarin = maxf(bala_tarin, sorat.length())
		for k in barname:
			if el > float(k) and not aks_ha.has(k):
				aks_ha[k] = true
				_zakhire_aks(barname[k])
	_zakhire_aks("pt_8_payan.png")
	var nr: Dictionary = _nazdiktarin(ja_mashin)
	print("[tizpa][pleitest] DONE zaman=", (Time.get_ticks_msec() - t0) / 1000.0, " bala_tarin=", int(bala_tarin), " spd=", int(sorat.length()), " dor=", dor, " birahne=", nr["dist"] < pahna_rah * 0.5)
	get_tree().quit()

func _ejra_aks() -> void:
	var maqaleha := {0.6: "aks_1_shomar.png", 3.4: "aks_2_shoroo.png", 9.0: "aks_3_ranandegi.png", 16.0: "aks_4_mian.png"}
	for k in maqaleha:
		get_tree().create_timer(float(k)).timeout.connect(func(): _zakhire_aks(maqaleha[k]))
	get_tree().create_timer(18.0).timeout.connect(func(): get_tree().quit())

func _zakhire_aks(nam: String) -> void:
	var tasvir := get_viewport().get_texture().get_image()
	if tasvir == null:
		return
	var puch := DirAccess.open("user://")
	if puch != null and not puch.dir_exists("aks"):
		puch.make_dir_recursive("aks")
	tasvir.save_png("user://aks/" + nam)
	print("[tizpa][aks] ذخیره شد: user://aks/" + nam)

# ───────────────────────── کمکی ─────────────────────────

func raqam_fa(n: int) -> String:
	var s := str(n)
	for i in 10:
		s = s.replace(str(i), FA_D[i])
	return s

func zaman_fa(t: float) -> String:
	var d := int(t / 60.0)
	var s := int(t) % 60
	var y := int(fmod(t, 1.0) * 10.0)
	return raqam_fa(d) + ":" + ("۰" if s < 10 else "") + raqam_fa(s) + "٫" + raqam_fa(y)
