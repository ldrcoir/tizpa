extends Control
## صحنهٔ آغاز — لایهٔ دفاعی و تشخیصی تیز پا (بدون هیچ تصویری؛ فقط متن)

var nesh_vaz: Label
var nesh_tafsil: Label

func _ready() -> void:
	var pas_zamine := ColorRect.new()
	pas_zamine.color = Color(0.075, 0.06, 0.075)
	pas_zamine.set_anchors_preset(Control.PRESET_FULL_RECT)
	pas_zamine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(pas_zamine)

	nesh_vaz = _nesh_label("تیز پا", 44)
	nesh_vaz.set_anchors_preset(Control.PRESET_CENTER)
	nesh_vaz.anchor_top = 0.52
	nesh_vaz.anchor_bottom = 0.60
	nesh_vaz.offset_left = -300
	nesh_vaz.offset_right = 300
	add_child(nesh_vaz)

	nesh_tafsil = _nesh_label("", 15)
	nesh_tafsil.set_anchors_preset(Control.PRESET_CENTER)
	nesh_tafsil.anchor_top = 0.62
	nesh_tafsil.anchor_bottom = 0.95
	nesh_tafsil.offset_left = -420
	nesh_tafsil.offset_right = 420
	nesh_tafsil.add_theme_color_override("font_color", Color(1, 1, 1, 0.65))
	add_child(nesh_tafsil)

	var model := OS.get_model_name()
	var ver := Engine.get_version_info()
	var ver_str := "%d.%d.%d" % [ver["major"], ver["minor"], ver["patch"]]
	nesh_tafsil.text = "در حال باز کردن منو…\n" + model + " — Godot " + ver_str
	var fa_b := ""
	for ch in str(Saman.SAKHT):
		fa_b += "۰۱۲۳۴۵۶۷۸۹"[int(ch)] if ch >= "0" and ch <= "9" else ch
	var nesh_noskhe := _nesh_label("تیز پا v" + Saman.NOSKHE + " — بیلد " + fa_b, 34)
	nesh_noskhe.set_anchors_preset(Control.PRESET_TOP_WIDE)
	nesh_noskhe.anchor_top = 0.02
	nesh_noskhe.anchor_bottom = 0.11
	nesh_noskhe.offset_left = 16
	nesh_noskhe.offset_right = -16
	nesh_noskhe.add_theme_color_override("font_color", Color(0.96, 0.76, 0.25))
	add_child(nesh_noskhe)
	_be_roh_menu()

func _nesh_label(matn_nesh: String, andaze: int) -> Label:
	var l := Label.new()
	l.text = matn_nesh
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", andaze)
	var f := load("res://assets/fonts/Vazirmatn-Bold.ttf")
	if f != null:
		l.add_theme_font_override("font", f)
	return l

func _be_roh_menu() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var uargs := OS.get_cmdline_user_args()
	for ua in uargs:
		if ua.begins_with("--level="):
			Saman.set_meta("marhale_shoroo", int(ua.split("=")[1]))
	var masir_sahne := "res://scenes/menu.tscn"
	if uargs.has("--autotest-full") or uargs.has("--shots") or uargs.has("--playtest"):
		masir_sahne = "res://scenes/mosabeghe_3d.tscn"
	var bast: PackedScene = load(masir_sahne)
	if bast == null:
		_shekast("صحنه پیدا نشد: " + masir_sahne)
		return
	var nemoone = bast.instantiate()
	if nemoone == null:
		_shekast("ساخت صحنه شکست خورد (instantiate = null)")
		return
	nemoone.set("layout_direction", Control.LAYOUT_DIRECTION_LTR)
	get_tree().root.add_child.call_deferred(nemoone)
	await get_tree().create_timer(1.0).timeout
	if not is_instance_valid(self):
		return
	if masir_sahne.ends_with("menu.tscn") and nemoone.get("panjare_aset") == null:
		_shekast("منو نیمه‌کاره ماند (پنجرهٔ اصلی ساخته نشد — جزئیات از لاگ پایین صفحه)")
		return
	get_tree().current_scene = nemoone
	print("[tizpa][aghaz] current_scene -> ", masir_sahne.get_file(), " OK")
	var ganjine = load("res://scripts/ganjine.gd")
	if ganjine != null and not ganjine.azmoon_khod():
		print("[tizpa][aghaz] BVAULT SELF-TEST FAILED — محتوای رمزی سالم باز نمی‌شود!")
	nesh_tafsil.text = "منو آماده شد — نسخهٔ درست نصب شده"
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.35)
	tw.tween_callback(queue_free)
	get_tree().create_timer(3.0).timeout.connect(func():
		if is_instance_valid(self) and is_inside_tree():
			queue_free())

func _shekast(payam: String) -> void:
	nesh_vaz.text = "خطای راه‌اندازی"
	var dom := _domb_log()
	nesh_tafsil.text += "\n\n" + payam
	if dom != "":
		nesh_tafsil.text += "\n\n— آخری لاگ —\n" + dom
	nesh_tafsil.text += "\nلطفاً از این صفحه عکس بگیر و برایم بفرست"
	nesh_tafsil.add_theme_color_override("font_color", Color(1.0, 0.45, 0.4))

func _domb_log() -> String:
	for p in ["user://logs/godot.log", "user://logs/godot.log.1"]:
		if not FileAccess.file_exists(p):
			continue
		var f := FileAccess.open(p, FileAccess.READ)
		if f == null:
			continue
		var khat_ha: Array[String] = []
		while not f.eof_reached():
			var k := f.get_line()
			if k.strip_edges() != "":
				khat_ha.append(k)
		f.close()
		var khata: Array[String] = []
		for k in khat_ha:
			if k.contains("ERROR") or k.contains("Failed") or k.contains("error"):
				khata.append(k)
		var entekhab: Array[String] = khata if not khata.is_empty() else khat_ha
		var khoruji := ""
		for i in range(max(0, entekhab.size() - 7), entekhab.size()):
			khoruji += entekhab[i].substr(0, 110) + "\n"
		if khoruji != "":
			return khoruji
	return ""
