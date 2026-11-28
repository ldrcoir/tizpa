extends Control
## منوی تیز پا — مسابقه خیابانی تهران، سبک NFS
## درس‌های نسخه‌های قبل:
##  ۱) layout_direction صریحاً LTR — روی گوشی فارسی اِریب می‌شد
##  ۲) پنل‌ها اندازه ثابت وسط — روی هر عرضی سالم
##  ۳) ناحیه امن بالا
##  ۴) تیتر متنی — همیشه رندر می‌شود
##  ۵) کلیک/هاور صدا — حس حرفه‌ای
##  ۶) تست خودکار واقعی: منو → مراحل → مرحله ۱ → بازی

var khatt: FontFile
var khatt_bold: FontFile
var panjare_aset: PanelContainer
var poste_marahel: PanelContainer
var poste_rahnama: PanelContainer
var poste_tanzimat: PanelContainer
var poste_darbare: PanelContainer
var tust: Label
var _entezar_taghir_sahne := false

const RANG_TALA := Color(0.96, 0.76, 0.25)
const RANG_TALA_KAMRANG := Color(0.72, 0.55, 0.2)
const RANG_FIROZE := Color(0.20, 0.72, 0.78)
const RANG_SHISHEH := Color(0.055, 0.065, 0.10, 0.93)
const RANG_KERM := Color(0.95, 0.93, 0.88)
const ERTEFA_AMAN := 46.0

func _ready() -> void:
	layout_direction = Control.LAYOUT_DIRECTION_LTR
	khatt = load("res://assets/fonts/Lalezar-Regular.ttf")
	khatt_bold = load("res://assets/fonts/Vazirmatn-Bold.ttf")
	_saz_paszamine()
	_saz_onvan()
	_saz_khane()
	_saz_marahel()
	_saz_rahnama()
	_saz_tanzimat()
	_saz_darbare()
	_saz_noskhe()
	Sedasan.ejra_moosighi("moosighi_menu")
	_chalesh_khodkar()

# ─────────────────────────── پس‌زمینه ───────────────────────────
func _saz_paszamine() -> void:
	var pas_zamine := TextureRect.new()
	pas_zamine.texture = load("res://assets/sprites/menu_bg.png")
	pas_zamine.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pas_zamine.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	pas_zamine.set_anchors_preset(Control.PRESET_FULL_RECT)
	pas_zamine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(pas_zamine)
	var gerad := Gradient.new()
	gerad.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	gerad.colors = PackedColorArray([Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.25), Color(0.02, 0.02, 0.05, 0.85)])
	var baft := GradientTexture2D.new()
	baft.gradient = gerad
	baft.fill_from = Vector2(0.5, 0.0)
	baft.fill_to = Vector2(0.5, 1.0)
	baft.width = 64
	baft.height = 256
	var ro_push := TextureRect.new()
	ro_push.texture = baft
	ro_push.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ro_push.set_anchors_preset(Control.PRESET_FULL_RECT)
	ro_push.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ro_push)

func _saz_onvan() -> void:
	var t := Label.new()
	t.text = "تیز پا"
	t.add_theme_font_override("font", khatt)
	t.add_theme_font_size_override("font_size", 132)
	t.add_theme_color_override("font_color", RANG_TALA)
	t.add_theme_color_override("font_outline_color", Color(0.10, 0.04, 0.02))
	t.add_theme_constant_override("outline_size", 20)
	t.add_theme_color_override("font_shadow_color", Color(0.9, 0.5, 0.1, 0.45))
	t.add_theme_constant_override("shadow_offset_x", 0)
	t.add_theme_constant_override("shadow_offset_y", 6)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	t.anchor_left = 0.02
	t.anchor_right = 0.98
	t.anchor_top = 0.0
	t.offset_top = ERTEFA_AMAN + 6
	t.offset_bottom = ERTEFA_AMAN + 160
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(t)
	var zir := Label.new()
	zir.text = "مسابقه‌ی خیابانی تهران"
	zir.add_theme_font_override("font", khatt_bold)
	zir.add_theme_font_size_override("font_size", 30)
	zir.add_theme_color_override("font_color", Color(0.92, 0.88, 0.80, 0.95))
	zir.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	zir.add_theme_constant_override("outline_size", 8)
	zir.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	zir.anchor_left = 0.02
	zir.anchor_right = 0.98
	zir.anchor_top = 0.0
	zir.offset_top = ERTEFA_AMAN + 168
	zir.offset_bottom = ERTEFA_AMAN + 210
	zir.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(zir)

# ─────────────────────────── دکمه‌های اصلی ───────────────────────────
func _saz_khane() -> void:
	panjare_aset = PanelContainer.new()
	panjare_aset.add_theme_stylebox_override("panel", _shisheh())
	panjare_aset.anchor_left = 1.0
	panjare_aset.anchor_right = 1.0
	panjare_aset.anchor_top = 1.0
	panjare_aset.anchor_bottom = 1.0
	panjare_aset.offset_left = -400
	panjare_aset.offset_right = -36
	panjare_aset.offset_top = -332 - 30
	panjare_aset.offset_bottom = -36
	add_child(panjare_aset)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	panjare_aset.add_child(vb)
	var d1 := _dokme_menu("شروع مسابقه", true)
	d1.pressed.connect(func(): _kilik(); _neshan(poste_marahel))
	vb.add_child(d1)
	var d2 := _dokme_menu("راهنمای بازی", false)
	d2.pressed.connect(func(): _kilik(); _neshan(poste_rahnama))
	vb.add_child(d2)
	var d3 := _dokme_menu("تنظیمات", false)
	d3.pressed.connect(func(): _kilik(); _neshan(poste_tanzimat))
	vb.add_child(d3)
	var d4 := _dokme_menu("درباره ما", false)
	d4.pressed.connect(func(): _kilik(); _neshan(poste_darbare))
	vb.add_child(d4)

func _dokme_menu(matn: String, asli: bool) -> Button:
	var d := Button.new()
	d.text = matn
	d.add_theme_font_override("font", khatt)
	d.add_theme_font_size_override("font_size", 38)
	d.custom_minimum_size = Vector2(0, 62)
	d.mouse_entered.connect(func(): Sedasan.ejra_seda("ui", -18.0))
	d.pressed.connect(_kilik)
	if asli:
		d.add_theme_stylebox_override("normal", _dokme(Color(0.72, 0.16, 0.12), Color(0.94, 0.62, 0.18), 3))
		d.add_theme_stylebox_override("hover", _dokme(Color(0.84, 0.22, 0.15), Color(1.0, 0.74, 0.30), 3))
		d.add_theme_stylebox_override("pressed", _dokme(Color(0.55, 0.11, 0.08), Color(0.94, 0.62, 0.18), 3))
	else:
		d.add_theme_stylebox_override("normal", _dokme(Color(0.10, 0.13, 0.20), Color(0.30, 0.42, 0.55), 2))
		d.add_theme_stylebox_override("hover", _dokme(Color(0.14, 0.19, 0.29), Color(0.45, 0.62, 0.78), 2))
		d.add_theme_stylebox_override("pressed", _dokme(Color(0.07, 0.09, 0.15), Color(0.30, 0.42, 0.55), 2))
	d.add_theme_color_override("font_color", RANG_KERM)
	d.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	d.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
	return d

func _kilik() -> void:
	Sedasan.ejra_seda("done", -6.0)

# ─────────────────────────── انتخاب مرحله ───────────────────────────
func _saz_marahel() -> void:
	poste_marahel = _poste_panel()
	var vb: VBoxContainer = poste_marahel.get_child(0)
	vb.add_child(_onvan_panel("مراحل مسابقه"))
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 10)
	vb.add_child(list)
	for M in Saman.MARHALEHA:
		list.add_child(_kart_marhale(M))
	vb.add_child(_saf_pusht(poste_marahel))

func _kart_marhale(M: Dictionary) -> Button:
	var baz := Saman.marhale_baz(int(M["shomare"]))
	var d := Button.new()
	d.custom_minimum_size = Vector2(720, 104)
	d.add_theme_stylebox_override("normal", _ghalti_kart(baz))
	d.add_theme_stylebox_override("hover", _ghalti_kart(true))
	d.add_theme_stylebox_override("pressed", _ghalti_kart(true))
	d.add_theme_stylebox_override("disabled", _ghalti_kart(false))
	d.mouse_entered.connect(func(): if baz: Sedasan.ejra_seda("ui", -18.0))
	d.pressed.connect(func():
		if not baz:
			_neshan_tust(Saman.matn("locked"))
			return
		_kilik()
		Saman.set_meta("marhale_shoroo", int(M["shomare"]))
		_entezar_taghir_sahne = true
		get_tree().change_scene_to_file("res://scenes/mosabeghe_3d.tscn"))
	var hb := HBoxContainer.new()
	hb.set_anchors_preset(Control.PRESET_FULL_RECT)
	hb.offset_left = 10
	hb.offset_right = -10
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	d.add_child(hb)
	var aks := TextureRect.new()
	aks.texture = load(str(M["tasvir"]))
	aks.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	aks.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	aks.custom_minimum_size = Vector2(150, 84)
	aks.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	aks.modulate = Color(1, 1, 1, 1.0 if baz else 0.35)
	aks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(aks)
	var vasat := VBoxContainer.new()
	vasat.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vasat.alignment = BoxContainer.ALIGNMENT_CENTER
	vasat.add_theme_constant_override("separation", 2)
	vasat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(vasat)
	var nam := Label.new()
	nam.text = (raqam_fa(int(M["shomare"])) + ". " + str(M["nam"])) if baz else (str(M["nam"]))
	nam.add_theme_font_override("font", khatt)
	nam.add_theme_font_size_override("font_size", 34)
	nam.add_theme_color_override("font_color", RANG_TALA if baz else Color(0.6, 0.6, 0.62))
	nam.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	nam.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vasat.add_child(nam)
	var tozih := Label.new()
	tozih.text = (str(M["tozih"]) if baz else (Saman.matn("locked") + " — " + str(M["tozih"])))
	tozih.add_theme_font_override("font", khatt_bold)
	tozih.add_theme_font_size_override("font_size", 19)
	tozih.add_theme_color_override("font_color", Color(0.85, 0.85, 0.88, 0.8 if baz else 0.35))
	tozih.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	tozih.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	tozih.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vasat.add_child(tozih)
	var rast := VBoxContainer.new()
	rast.alignment = BoxContainer.ALIGNMENT_CENTER
	rast.add_theme_constant_override("separation", 4)
	rast.custom_minimum_size = Vector2(110, 0)
	rast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(rast)
	var setareha := Label.new()
	var s := int(Saman.setare_marhale.get(int(M["shomare"]), 0))
	setareha.text = ("★".repeat(s) + "·".repeat(3 - s)) if baz else ""
	setareha.add_theme_font_size_override("font_size", 30)
	setareha.add_theme_color_override("font_color", Color(0.98, 0.82, 0.25))
	setareha.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	setareha.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rast.add_child(setareha)
	var behtarin := Saman.behtarin_zaman(int(M["shomare"]))
	var zaman := Label.new()
	zaman.text = ("بهترین: " + _shekl(behtarin)) if behtarin > 0.0 else ("دور ×" + raqam_fa(int(M["dorha"])))
	zaman.add_theme_font_override("font", khatt_bold)
	zaman.add_theme_font_size_override("font_size", 18)
	zaman.add_theme_color_override("font_color", Color(0.75, 0.85, 0.95, 0.8))
	zaman.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zaman.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rast.add_child(zaman)
	return d

# ─────────────────────────── راهنمای بازی ───────────────────────────
func _saz_rahnama() -> void:
	poste_rahnama = _poste_panel()
	var vb: VBoxContainer = poste_rahnama.get_child(0)
	vb.add_child(_onvan_panel("راهنمای بازی"))
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 18)
	vb.add_child(hb)
	var matn_ha := VBoxContainer.new()
	matn_ha.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	matn_ha.add_theme_constant_override("separation", 10)
	hb.add_child(matn_ha)
	matn_ha.add_child(_rahnama_sar("هدف"))
	matn_ha.add_child(_rahnama_matn("در هر مرحله چند دور می‌چرخی. اول شو تا ۳ ستاره بگیری؛ دوم یا سوم هم مرحله‌ی بعد را باز می‌کند. زمنت رکورد می‌شود."))
	matn_ha.add_child(_rahnama_sar("کنترل"))
	matn_ha.add_child(_saf_klidha([["نیمه چپ/راست صفحه", "فرمان"], ["دکمه ترمز", "ترمز"], ["دکمه نیترو", "شتاب ویژه"]]))
	matn_ha.add_child(_rahnama_matn("صفحه‌کلید: ◄ ► یا A D فرمان — S ترمز — SPACE نیترو"))
	matn_ha.add_child(_rahnama_sar("نیترو و دریفت"))
	matn_ha.add_child(_rahnama_matn("با دریفت‌کردن نوار نیترو پر می‌شود. ترمز + فرمان در سرعت = دریفت؛ وسط پیچ رها کن و با نیترو ببرون."))
	matn_ha.add_child(_rahnama_sar("نکات حرفه‌ای"))
	matn_ha.add_child(_rahnama_matn("قبل از پیچ ترمز بزن، داخل پیچ دریفت بگیر، از تاکسی‌های زرد دوری کن و رقیب را در مستقیم سبقت بگیر."))
	vb.add_child(_saf_pusht(poste_rahnama))

func _rahnama_sar(t: String) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_override("font", khatt)
	l.add_theme_font_size_override("font_size", 28)
	l.add_theme_color_override("font_color", RANG_TALA)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	return l

func _rahnama_matn(t: String) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_override("font", khatt_bold)
	l.add_theme_font_size_override("font_size", 19)
	l.add_theme_color_override("font_color", Color(0.88, 0.88, 0.92, 0.92))
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l.custom_minimum_size = Vector2(0, 0)
	return l

func _saf_klidha(saf_ha: Array) -> Control:
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 8)
	hb.alignment = BoxContainer.ALIGNMENT_END
	for r in saf_ha:
		var klid := PanelContainer.new()
		var g := StyleBoxFlat.new()
		g.bg_color = Color(0.14, 0.17, 0.24)
		g.set_corner_radius_all(8)
		g.border_color = Color(0.4, 0.5, 0.62)
		g.border_width_bottom = 3
		g.content_margin_left = 10
		g.content_margin_right = 10
		g.content_margin_top = 4
		g.content_margin_bottom = 4
		klid.add_theme_stylebox_override("panel", g)
		var kl := Label.new()
		kl.text = str(r[0])
		kl.add_theme_font_override("font", khatt_bold)
		kl.add_theme_font_size_override("font_size", 17)
		kl.add_theme_color_override("font_color", RANG_KERM)
		klid.add_child(kl)
		hb.add_child(klid)
		var arzesh := Label.new()
		arzesh.text = str(r[1])
		arzesh.add_theme_font_override("font", khatt_bold)
		arzesh.add_theme_font_size_override("font_size", 18)
		arzesh.add_theme_color_override("font_color", Color(0.7, 0.85, 0.95))
		hb.add_child(arzesh)
	return hb

# ─────────────────────────── تنظیمات ───────────────────────────
func _saz_tanzimat() -> void:
	poste_tanzimat = _poste_panel()
	var vb: VBoxContainer = poste_tanzimat.get_child(0)
	vb.add_child(_onvan_panel("تنظیمات"))
	vb.add_child(_saf_liz("موسیقی", Saman.bolandi_moosighi, func(v: float):
		Saman.bolandi_moosighi = v
		Sedasan.tanzim_moosighi(v)))
	vb.add_child(_saf_liz("افکت‌ها", Saman.bolandi_seda, func(v: float):
		Saman.bolandi_seda = v
		Sedasan.tanzim_seda(v)))
	var rahnama := Label.new()
	rahnama.text = "تنظیمات خودکار ذخیره می‌شود."
	rahnama.add_theme_font_override("font", khatt_bold)
	rahnama.add_theme_font_size_override("font_size", 17)
	rahnama.add_theme_color_override("font_color", Color(0.7, 0.7, 0.76, 0.7))
	rahnama.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vb.add_child(rahnama)
	vb.add_child(_saf_pusht(poste_tanzimat))

func _saf_liz(matn: String, meghdar: float, taghir: Callable) -> Control:
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 14)
	var l := Label.new()
	l.text = matn
	l.add_theme_font_override("font", khatt)
	l.add_theme_font_size_override("font_size", 30)
	l.custom_minimum_size = Vector2(150, 0)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hb.add_child(l)
	var liz := HSlider.new()
	liz.min_value = 0.0
	liz.max_value = 1.0
	liz.step = 0.05
	liz.value = meghdar
	liz.custom_minimum_size = Vector2(320, 40)
	liz.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	liz.value_changed.connect(taghir)
	liz.drag_ended.connect(func(_c: bool): Saman.zakhire(); Sedasan.ejra_seda("ui", -10.0))
	hb.add_child(liz)
	return hb

# ─────────────────────────── درباره ما ───────────────────────────
func _saz_darbare() -> void:
	poste_darbare = _poste_panel()
	var vb: VBoxContainer = poste_darbare.get_child(0)
	vb.add_child(_onvan_panel("درباره ما"))
	var pooyesh := Label.new()
	pooyesh.text = "پژوهش سرای امام هادی (ع)\n\nهلیا موزونی\n\nاستاد راهنما: مهندس احسان مراد"
	pooyesh.add_theme_font_override("font", khatt)
	pooyesh.add_theme_font_size_override("font_size", 32)
	pooyesh.add_theme_color_override("font_color", Color(0.94, 0.92, 0.88))
	pooyesh.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pooyesh.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pooyesh.custom_minimum_size = Vector2(0, 240)
	vb.add_child(pooyesh)
	vb.add_child(_saf_pusht(poste_darbare))

# ─────────────────────────── اجزای مشترک ───────────────────────────
func _poste_panel() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _shisheh())
	p.anchor_left = 0.5
	p.anchor_right = 0.5
	p.anchor_top = 0.5
	p.anchor_bottom = 0.5
	p.offset_left = -430
	p.offset_right = 430
	p.offset_top = -322
	p.offset_bottom = 322
	p.visible = false
	add_child(p)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	p.add_child(vb)
	return p

func _onvan_panel(t: String) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_override("font", khatt)
	l.add_theme_font_size_override("font_size", 44)
	l.add_theme_color_override("font_color", RANG_TALA)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func _saf_pusht(az: PanelContainer) -> Control:
	var hb := HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	var d := Button.new()
	d.text = "برگشت"
	d.add_theme_font_override("font", khatt)
	d.add_theme_font_size_override("font_size", 30)
	d.custom_minimum_size = Vector2(220, 54)
	d.add_theme_stylebox_override("normal", _dokme(Color(0.10, 0.13, 0.20), Color(0.30, 0.42, 0.55), 2))
	d.add_theme_stylebox_override("hover", _dokme(Color(0.14, 0.19, 0.29), Color(0.45, 0.62, 0.78), 2))
	d.add_theme_stylebox_override("pressed", _dokme(Color(0.07, 0.09, 0.15), Color(0.30, 0.42, 0.55), 2))
	d.add_theme_color_override("font_color", RANG_KERM)
	d.pressed.connect(func(): _kilik(); _neshan(panjare_aset))
	hb.add_child(d)
	return hb

func _neshan(p: PanelContainer) -> void:
	for q in [panjare_aset, poste_marahel, poste_rahnama, poste_tanzimat, poste_darbare]:
		if q != null:
			q.visible = (q == p)
	if p != panjare_aset:
		p.pivot_offset = p.size * 0.5
		p.scale = Vector2(0.92, 0.92)
		var tw := create_tween()
		tw.tween_property(p, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _shisheh() -> StyleBoxFlat:
	var g := StyleBoxFlat.new()
	g.bg_color = RANG_SHISHEH
	g.set_corner_radius_all(20)
	g.border_color = Color(0.85, 0.68, 0.28, 0.45)
	g.border_width_top = 2
	g.border_width_bottom = 3
	g.border_width_left = 2
	g.border_width_right = 2
	g.shadow_color = Color(0, 0, 0, 0.5)
	g.shadow_size = 14
	g.content_margin_left = 22
	g.content_margin_right = 22
	g.content_margin_top = 16
	g.content_margin_bottom = 16
	return g

func _dokme(paye: Color, tir: Color, tivaz: int) -> StyleBoxFlat:
	var g := StyleBoxFlat.new()
	g.bg_color = paye
	g.set_corner_radius_all(16)
	g.border_color = tir
	g.border_width_top = tivaz
	g.border_width_bottom = tivaz + 2
	g.border_width_left = tivaz
	g.border_width_right = tivaz
	g.shadow_color = Color(0, 0, 0, 0.35)
	g.shadow_size = 5
	return g

func _ghalti_kart(roshan: bool) -> StyleBoxFlat:
	var g := StyleBoxFlat.new()
	g.bg_color = Color(0.09, 0.11, 0.17, 0.92) if roshan else Color(0.07, 0.08, 0.12, 0.8)
	g.set_corner_radius_all(14)
	g.border_color = Color(0.85, 0.68, 0.28, 0.55) if roshan else Color(0.3, 0.3, 0.36, 0.4)
	g.border_width_left = 2
	g.border_width_right = 2
	g.border_width_top = 2
	g.border_width_bottom = 3
	g.content_margin_left = 10
	g.content_margin_right = 10
	g.content_margin_top = 8
	g.content_margin_bottom = 8
	return g

func _saz_noskhe() -> void:
	var v := Label.new()
	v.text = "تیز پا — نسخه " + Saman.NOSKHE + " — بیلد " + raqam_fa(Saman.SAKHT)
	v.add_theme_font_override("font", khatt_bold)
	v.add_theme_font_size_override("font_size", 17)
	v.add_theme_color_override("font_color", Color(0.85, 0.75, 0.5, 0.75))
	v.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	v.add_theme_constant_override("outline_size", 6)
	v.anchor_top = 1.0
	v.anchor_bottom = 1.0
	v.anchor_left = 0.0
	v.anchor_right = 1.0
	v.offset_left = 16
	v.offset_right = -16
	v.offset_top = -34
	v.offset_bottom = -8
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(v)
	tust = Label.new()
	tust.add_theme_font_override("font", khatt)
	tust.add_theme_font_size_override("font_size", 30)
	tust.add_theme_color_override("font_color", Color(1, 0.85, 0.4))
	tust.add_theme_color_override("font_outline_color", Color(0.1, 0.03, 0.02))
	tust.add_theme_constant_override("outline_size", 8)
	tust.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tust.anchor_left = 0.0
	tust.anchor_right = 1.0
	tust.anchor_top = 0.62
	tust.anchor_bottom = 0.68
	tust.modulate.a = 0.0
	tust.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tust)

func _neshan_tust(matn: String) -> void:
	if tust == null:
		return
	tust.text = matn
	tust.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(1.4)
	tw.tween_property(tust, "modulate:a", 0.0, 0.5)

func _shekl(t: float) -> String:
	var d := int(t) / 60
	var s := int(t) % 60
	return raqam_fa(d) + ":" + ("۰" if s < 10 else "") + raqam_fa(s)

func raqam_fa(n: int) -> String:
	var s := str(n)
	var khoruji := ""
	for ch in s:
		if ch >= "0" and ch <= "9":
			khoruji += "۰۱۲۳۴۵۶۷۸۹"[int(ch)]
		else:
			khoruji += ch
	return khoruji

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and e.keycode == KEY_ESCAPE:
		_neshan(panjare_aset)

# ─────────────────────────── تست خودکار ───────────────────────────
func _chalesh_khodkar() -> void:
	var dasturha := OS.get_cmdline_user_args()
	if dasturha.has("--autotest"):
		_ejra_khodkar()
	if dasturha.has("--shot-menu"):
		_aks_menu()

func _ejra_khodkar() -> void:
	print("[tizpa][menu] HOME OK — buttons=", panjare_aset.get_child(0).get_child_count())
	await get_tree().create_timer(1.2).timeout
	_neshan(poste_marahel)
	await get_tree().create_timer(0.8).timeout
	var list: VBoxContainer = poste_marahel.get_child(0).get_child(1)
	var kart: Button = list.get_child(0)
	var vasat: Vector2 = kart.get_global_rect().get_center()
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = true
	e.position = vasat
	e.global_position = vasat
	Input.parse_input_event(e)
	var e2 := e.duplicate()
	e2.pressed = false
	Input.parse_input_event(e2)
	await get_tree().create_timer(2.0).timeout
	print("[tizpa][menu] LEVEL-1 LAUNCH ", "OK" if _entezar_taghir_sahne else "FAIL")
	if not _entezar_taghir_sahne:
		get_tree().quit(1)

func _aks_menu() -> void:
	DirAccess.make_dir_recursive_absolute("user://aks")
	await get_tree().create_timer(0.6).timeout
	var aks := get_viewport().get_texture().get_image()
	if aks != null:
		aks.save_png("user://aks/aks_menu.png")
	_neshan(poste_marahel)
	await get_tree().create_timer(0.5).timeout
	var aks2 := get_viewport().get_texture().get_image()
	if aks2 != null:
		aks2.save_png("user://aks/aks_marahel.png")
	_neshan(poste_rahnama)
	await get_tree().create_timer(0.5).timeout
	var aks3 := get_viewport().get_texture().get_image()
	if aks3 != null:
		aks3.save_png("user://aks/aks_rahnama.png")
	_neshan(poste_darbare)
	await get_tree().create_timer(0.5).timeout
	var aks4 := get_viewport().get_texture().get_image()
	if aks4 != null:
		aks4.save_png("user://aks/aks_darbare.png")
	_neshan(poste_tanzimat)
	await get_tree().create_timer(0.5).timeout
	var aks5 := get_viewport().get_texture().get_image()
	if aks5 != null:
		aks5.save_png("user://aks/aks_tanzimat.png")
	print("[tizpa][menu] SHOTS OK")
	get_tree().quit()
