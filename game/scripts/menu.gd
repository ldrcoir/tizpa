extends Control
## منوی تیز پا — حرفه‌ای، شبانه، سبک NFS
## درس‌های نسخه‌های قبل:
##  ۱) layout_direction صریحاً LTR — روی گوشی فارسی اِریب می‌شد
##  ۲) پنل‌ها اندازه ثابت وسط — روی هر عرضی سالم
##  ۳) ناحیه امن بالا (SAFE_TOP=46)
##  ۴) تیتر متنی — همیشه رندر می‌شود
##  ۵) کلیک/هاور صدا — حس حرفه‌ای
##  ۶) autotest واقعی: منو → مراحل → مرحله ۱ → بازی

var font: FontFile
var font_bold: FontFile
var panel_home: PanelContainer
var panel_levels: PanelContainer
var panel_guide: PanelContainer
var panel_settings: PanelContainer
var panel_about: PanelContainer
var toast: Label
var _drive_car: Node2D = null
var _drive_spd := 260.0
var _expect_scene_change := false

const COL_GOLD := Color(0.96, 0.76, 0.25)
const COL_GOLD_DIM := Color(0.72, 0.55, 0.2)
const COL_TEAL := Color(0.20, 0.72, 0.78)
const COL_GLASS := Color(0.055, 0.065, 0.10, 0.93)
const COL_CREAM := Color(0.95, 0.93, 0.88)
const SAFE_TOP := 46.0

func _ready() -> void:
        layout_direction = Control.LAYOUT_DIRECTION_LTR
        font = load("res://assets/fonts/Lalezar-Regular.ttf")
        font_bold = load("res://assets/fonts/Vazirmatn-Bold.ttf")
        _build_bg()
        _build_title()
        _build_home()
        _build_levels()
        _build_guide()
        _build_settings()
        _build_about()
        _build_driveby()
        _build_version()
        _autotest_hooks()

# ─────────────────────────── پس‌زمینه ───────────────────────────
func _build_bg() -> void:
        var bg := TextureRect.new()
        bg.texture = load("res://assets/sprites/menu_bg.png")
        bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
        bg.set_anchors_preset(Control.PRESET_FULL_RECT)
        bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(bg)
        # گرادیان تیره پایین برای خوانایی
        var grad := Gradient.new()
        grad.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
        grad.colors = PackedColorArray([Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.25), Color(0.02, 0.02, 0.05, 0.85)])
        var gt := GradientTexture2D.new()
        gt.gradient = grad
        gt.fill_from = Vector2(0.5, 0.0)
        gt.fill_to = Vector2(0.5, 1.0)
        gt.width = 64
        gt.height = 256
        var ov := TextureRect.new()
        ov.texture = gt
        ov.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        ov.set_anchors_preset(Control.PRESET_FULL_RECT)
        ov.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(ov)

func _build_title() -> void:
        var t := Label.new()
        t.text = "تیز پا"
        t.add_theme_font_override("font", font)
        t.add_theme_font_size_override("font_size", 132)
        t.add_theme_color_override("font_color", COL_GOLD)
        t.add_theme_color_override("font_outline_color", Color(0.10, 0.04, 0.02))
        t.add_theme_constant_override("outline_size", 20)
        t.add_theme_color_override("font_shadow_color", Color(0.9, 0.5, 0.1, 0.45))
        t.add_theme_constant_override("shadow_offset_x", 0)
        t.add_theme_constant_override("shadow_offset_y", 6)
        t.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        t.anchor_left = 0.02
        t.anchor_right = 0.98
        t.anchor_top = 0.0
        t.offset_top = SAFE_TOP + 6
        t.offset_bottom = SAFE_TOP + 160
        t.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(t)
        var st := Label.new()
        st.text = "مسابقه‌ی خیابانی تهران"
        st.add_theme_font_override("font", font_bold)
        st.add_theme_font_size_override("font_size", 30)
        st.add_theme_color_override("font_color", Color(0.92, 0.88, 0.80, 0.95))
        st.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
        st.add_theme_constant_override("outline_size", 8)
        st.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        st.anchor_left = 0.02
        st.anchor_right = 0.98
        st.anchor_top = 0.0
        st.offset_top = SAFE_TOP + 168
        st.offset_bottom = SAFE_TOP + 210
        st.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(st)

# ─────────────────────────── دکمه‌های اصلی ───────────────────────────
func _build_home() -> void:
        panel_home = PanelContainer.new()
        panel_home.add_theme_stylebox_override("panel", _glass())
        panel_home.anchor_left = 1.0
        panel_home.anchor_right = 1.0
        panel_home.anchor_top = 1.0
        panel_home.anchor_bottom = 1.0
        panel_home.offset_left = -400
        panel_home.offset_right = -36
        panel_home.offset_top = -332 - 30
        panel_home.offset_bottom = -36
        add_child(panel_home)
        var vb := VBoxContainer.new()
        vb.add_theme_constant_override("separation", 12)
        panel_home.add_child(vb)
        var b1 := _menu_btn("شروع مسابقه", true)
        b1.pressed.connect(func(): _click(); _show(panel_levels))
        vb.add_child(b1)
        var b2 := _menu_btn("راهنمای بازی", false)
        b2.pressed.connect(func(): _click(); _show(panel_guide))
        vb.add_child(b2)
        var b3 := _menu_btn("تنظیمات", false)
        b3.pressed.connect(func(): _click(); _show(panel_settings))
        vb.add_child(b3)
        var b4 := _menu_btn("درباره ما", false)
        b4.pressed.connect(func(): _click(); _show(panel_about))
        vb.add_child(b4)

func _menu_btn(txt: String, primary: bool) -> Button:
        var b := Button.new()
        b.text = txt
        b.add_theme_font_override("font", font)
        b.add_theme_font_size_override("font_size", 38)
        b.custom_minimum_size = Vector2(0, 62)
        b.mouse_entered.connect(func(): AudioMgr.play_sfx("ui", -18.0))
        b.pressed.connect(_click)
        if primary:
                b.add_theme_stylebox_override("normal", _btn(Color(0.72, 0.16, 0.12), Color(0.94, 0.62, 0.18), 3))
                b.add_theme_stylebox_override("hover", _btn(Color(0.84, 0.22, 0.15), Color(1.0, 0.74, 0.30), 3))
                b.add_theme_stylebox_override("pressed", _btn(Color(0.55, 0.11, 0.08), Color(0.94, 0.62, 0.18), 3))
        else:
                b.add_theme_stylebox_override("normal", _btn(Color(0.10, 0.13, 0.20), Color(0.30, 0.42, 0.55), 2))
                b.add_theme_stylebox_override("hover", _btn(Color(0.14, 0.19, 0.29), Color(0.45, 0.62, 0.78), 2))
                b.add_theme_stylebox_override("pressed", _btn(Color(0.07, 0.09, 0.15), Color(0.30, 0.42, 0.55), 2))
        b.add_theme_color_override("font_color", COL_CREAM)
        b.add_theme_color_override("font_hover_color", Color(1, 1, 1))
        b.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
        return b

func _click() -> void:
        AudioMgr.play_sfx("done", -6.0)

# ─────────────────────────── انتخاب مرحله ───────────────────────────
func _build_levels() -> void:
        panel_levels = _panel_shell()
        var vb: VBoxContainer = panel_levels.get_child(0)
        vb.add_child(_panel_title("مراحل مسابقه"))
        var list := VBoxContainer.new()
        list.add_theme_constant_override("separation", 10)
        vb.add_child(list)
        for lv in Globals.LEVELS:
                list.add_child(_level_card(lv))
        vb.add_child(_back_row(panel_levels))

func _level_card(lv: Dictionary) -> Button:
        var unlocked := Globals.level_unlocked(int(lv["id"]))
        var b := Button.new()
        b.custom_minimum_size = Vector2(720, 104)
        b.add_theme_stylebox_override("normal", _card_sb(unlocked))
        b.add_theme_stylebox_override("hover", _card_sb(true))
        b.add_theme_stylebox_override("pressed", _card_sb(true))
        b.add_theme_stylebox_override("disabled", _card_sb(false))
        b.mouse_entered.connect(func(): if unlocked: AudioMgr.play_sfx("ui", -18.0))
        b.pressed.connect(func():
                if not unlocked:
                        _show_toast(Globals.L("locked"))
                        return
                _click()
                Globals.set_meta("start_level", int(lv["id"]))
                _expect_scene_change = true
                get_tree().change_scene_to_file("res://scenes/game.tscn"))
        # چیدمان: تصویر | متن‌ها | ستاره/رکورد
        var hb := HBoxContainer.new()
        hb.set_anchors_preset(Control.PRESET_FULL_RECT)
        hb.offset_left = 10
        hb.offset_right = -10
        hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
        b.add_child(hb)
        var thumb := TextureRect.new()
        thumb.texture = load(str(lv["thumb"]))
        thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
        thumb.custom_minimum_size = Vector2(150, 84)
        thumb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        thumb.modulate = Color(1, 1, 1, 1.0 if unlocked else 0.35)
        thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
        hb.add_child(thumb)
        var mid := VBoxContainer.new()
        mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        mid.alignment = BoxContainer.ALIGNMENT_CENTER
        mid.add_theme_constant_override("separation", 2)
        mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
        hb.add_child(mid)
        var nm := Label.new()
        nm.text = (fa_num(int(lv["id"])) + ". " + str(lv["name"])) if unlocked else (str(lv["name"]))
        nm.add_theme_font_override("font", font)
        nm.add_theme_font_size_override("font_size", 34)
        nm.add_theme_color_override("font_color", COL_GOLD if unlocked else Color(0.6, 0.6, 0.62))
        nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
        mid.add_child(nm)
        var ds := Label.new()
        ds.text = (str(lv["desc"]) if unlocked else (Globals.L("locked") + " — " + str(lv["desc"])))
        ds.add_theme_font_override("font", font_bold)
        ds.add_theme_font_size_override("font_size", 19)
        ds.add_theme_color_override("font_color", Color(0.85, 0.85, 0.88, 0.8 if unlocked else 0.35))
        ds.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        ds.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
        ds.mouse_filter = Control.MOUSE_FILTER_IGNORE
        mid.add_child(ds)
        var right := VBoxContainer.new()
        right.alignment = BoxContainer.ALIGNMENT_CENTER
        right.add_theme_constant_override("separation", 4)
        right.custom_minimum_size = Vector2(110, 0)
        right.mouse_filter = Control.MOUSE_FILTER_IGNORE
        hb.add_child(right)
        var stars := Label.new()
        var s := int(Globals.level_stars.get(int(lv["id"]), 0))
        stars.text = ("٭".repeat(s) + "·".repeat(3 - s)) if unlocked else ""
        stars.add_theme_font_size_override("font_size", 30)
        stars.add_theme_color_override("font_color", Color(0.98, 0.82, 0.25))
        stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        stars.mouse_filter = Control.MOUSE_FILTER_IGNORE
        right.add_child(stars)
        var bt := Globals.best_time(int(lv["id"]))
        var tm := Label.new()
        tm.text = ("بهترین: " + _fmt(bt)) if bt > 0.0 else ("دور ×" + fa_num(int(lv["laps"])))
        tm.add_theme_font_override("font", font_bold)
        tm.add_theme_font_size_override("font_size", 18)
        tm.add_theme_color_override("font_color", Color(0.75, 0.85, 0.95, 0.8))
        tm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        tm.mouse_filter = Control.MOUSE_FILTER_IGNORE
        right.add_child(tm)
        return b

# ─────────────────────────── راهنمای بازی ───────────────────────────
func _build_guide() -> void:
        panel_guide = _panel_shell()
        var vb: VBoxContainer = panel_guide.get_child(0)
        vb.add_child(_panel_title("راهنمای بازی"))
        var hb := HBoxContainer.new()
        hb.add_theme_constant_override("separation", 18)
        vb.add_child(hb)
        # ستون متن
        var txt := VBoxContainer.new()
        txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        txt.add_theme_constant_override("separation", 10)
        hb.add_child(txt)
        txt.add_child(_guide_h("هدف"))
        txt.add_child(_guide_p("در هر مرحله چند دور می‌چرخی. اول شو تا ۳ ستاره بگیری؛ دوم یا سوم هم مرحله‌ی بعد را باز می‌کند. زمانت رکورد می‌شود."))
        txt.add_child(_guide_h("کنترل"))
        txt.add_child(_guide_keys_row([["نیمه چپ/راست صفحه", "فرمان"], ["دکمه ترمز", "ترمز + دریفت"], ["دکمه نیترو", "شتاب ویژه"]]))
        txt.add_child(_guide_p("صفحه‌کلید: ◄ ► فرمان — S ترمز — SPACE نیترو"))
        txt.add_child(_guide_h("نیترو و دریفت"))
        txt.add_child(_guide_p("با دریفت‌کردن نوار نیترو پر می‌شود. ترمز + فرمان در سرعت = دریفت؛ وسط پیچ رها کن و با نیترو بیرون بزن."))
        txt.add_child(_guide_h("نکات حرفه‌ای"))
        txt.add_child(_guide_p("قبل از پیچ ترمز بزن، داخل پیچ دریفت بگیر، از تاکسی‌های زرد دوری کن و رقیب را در مستقیم سبقت بگیر."))
        # پرتره هلیا
        var right := VBoxContainer.new()
        right.alignment = BoxContainer.ALIGNMENT_CENTER
        hb.add_child(right)
        var pr := TextureRect.new()
        pr.texture = load("res://assets/sprites/helia.png")
        pr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        pr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
        pr.custom_minimum_size = Vector2(150, 200)
        right.add_child(pr)
        var hlbl := Label.new()
        hlbl.text = "هلیا"
        hlbl.add_theme_font_override("font", font)
        hlbl.add_theme_font_size_override("font_size", 28)
        hlbl.add_theme_color_override("font_color", COL_TEAL)
        hlbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        right.add_child(hlbl)
        vb.add_child(_back_row(panel_guide))

func _guide_h(t: String) -> Label:
        var l := Label.new()
        l.text = t
        l.add_theme_font_override("font", font)
        l.add_theme_font_size_override("font_size", 28)
        l.add_theme_color_override("font_color", COL_GOLD)
        l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        return l

func _guide_p(t: String) -> Label:
        var l := Label.new()
        l.text = t
        l.add_theme_font_override("font", font_bold)
        l.add_theme_font_size_override("font_size", 19)
        l.add_theme_color_override("font_color", Color(0.88, 0.88, 0.92, 0.92))
        l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        l.custom_minimum_size = Vector2(0, 0)
        return l

func _guide_keys_row(rows: Array) -> Control:
        var hb := HBoxContainer.new()
        hb.add_theme_constant_override("separation", 8)
        hb.alignment = BoxContainer.ALIGNMENT_END
        for r in rows:
                var key := PanelContainer.new()
                var sb := StyleBoxFlat.new()
                sb.bg_color = Color(0.14, 0.17, 0.24)
                sb.set_corner_radius_all(8)
                sb.border_color = Color(0.4, 0.5, 0.62)
                sb.border_width_bottom = 3
                sb.content_margin_left = 10
                sb.content_margin_right = 10
                sb.content_margin_top = 4
                sb.content_margin_bottom = 4
                key.add_theme_stylebox_override("panel", sb)
                var kl := Label.new()
                kl.text = str(r[0])
                kl.add_theme_font_override("font", font_bold)
                kl.add_theme_font_size_override("font_size", 17)
                kl.add_theme_color_override("font_color", COL_CREAM)
                key.add_child(kl)
                hb.add_child(key)
                var vl := Label.new()
                vl.text = str(r[1])
                vl.add_theme_font_override("font", font_bold)
                vl.add_theme_font_size_override("font_size", 18)
                vl.add_theme_color_override("font_color", Color(0.7, 0.85, 0.95))
                hb.add_child(vl)
        return hb

# ─────────────────────────── تنظیمات ───────────────────────────
func _build_settings() -> void:
        panel_settings = _panel_shell()
        var vb: VBoxContainer = panel_settings.get_child(0)
        vb.add_child(_panel_title("تنظیمات"))
        vb.add_child(_slider_row("موسیقی", Globals.music_vol, func(v: float):
                Globals.music_vol = v
                AudioMgr.set_music_vol(v)))
        vb.add_child(_slider_row("افکت‌ها", Globals.sfx_vol, func(v: float):
                Globals.sfx_vol = v
                AudioMgr.set_sfx_vol(v)))
        var hint := Label.new()
        hint.text = "تنظیمات خودکار ذخیره می‌شود."
        hint.add_theme_font_override("font", font_bold)
        hint.add_theme_font_size_override("font_size", 17)
        hint.add_theme_color_override("font_color", Color(0.7, 0.7, 0.76, 0.7))
        hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        vb.add_child(hint)
        vb.add_child(_back_row(panel_settings))

func _slider_row(txt: String, val: float, onchange: Callable) -> Control:
        var hb := HBoxContainer.new()
        hb.add_theme_constant_override("separation", 14)
        var l := Label.new()
        l.text = txt
        l.add_theme_font_override("font", font)
        l.add_theme_font_size_override("font_size", 30)
        l.custom_minimum_size = Vector2(150, 0)
        l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        hb.add_child(l)
        var sl := HSlider.new()
        sl.min_value = 0.0
        sl.max_value = 1.0
        sl.step = 0.05
        sl.value = val
        sl.custom_minimum_size = Vector2(320, 40)
        sl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        sl.value_changed.connect(onchange)
        sl.drag_ended.connect(func(_c: bool): Globals.save_game(); AudioMgr.play_sfx("ui", -10.0))
        hb.add_child(sl)
        return hb

# ─────────────────────────── درباره ما ───────────────────────────
func _build_about() -> void:
        panel_about = _panel_shell()
        var vb: VBoxContainer = panel_about.get_child(0)
        vb.add_child(_panel_title("درباره ما"))
        var nm := Label.new()
        nm.text = "استودیو کسپین"
        nm.add_theme_font_override("font", font)
        nm.add_theme_font_size_override("font_size", 52)
        nm.add_theme_color_override("font_color", COL_TEAL)
        nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        vb.add_child(nm)
        var p1 := Label.new()
        p1.text = "ما یک استودیوی مستقل ایرانی هستیم؛ عاشق ماشین، شب‌های تهران و بازی‌های مسابقه‌ای.\nتیز پا را با تمام وجود ساختیم تا حس خیابان‌های این شهر را بیاوریم:"
        p1.add_theme_font_override("font", font_bold)
        p1.add_theme_font_size_override("font_size", 21)
        p1.add_theme_color_override("font_color", Color(0.9, 0.9, 0.94))
        p1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        p1.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        vb.add_child(p1)
        var p2 := Label.new()
        p2.text = "«از ولیعصر تا آزادی، از غروب تا نیمه‌شب — تیز بران، اما با احترام.»"
        p2.add_theme_font_override("font", font)
        p2.add_theme_font_size_override("font_size", 26)
        p2.add_theme_color_override("font_color", COL_GOLD)
        p2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        p2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        vb.add_child(p2)
        var vlbl := Label.new()
        vlbl.text = "نسخه " + "۱٫۰" + " — بیلد " + fa_num(Globals.BUILD)
        vlbl.add_theme_font_override("font", font_bold)
        vlbl.add_theme_font_size_override("font_size", 18)
        vlbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.72))
        vlbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        vb.add_child(vlbl)
        vb.add_child(_back_row(panel_about))

# ─────────────────────────── اجزای مشترک ───────────────────────────
func _panel_shell() -> PanelContainer:
        var p := PanelContainer.new()
        p.add_theme_stylebox_override("panel", _glass())
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

func _panel_title(t: String) -> Label:
        var l := Label.new()
        l.text = t
        l.add_theme_font_override("font", font)
        l.add_theme_font_size_override("font_size", 44)
        l.add_theme_color_override("font_color", COL_GOLD)
        l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        return l

func _back_row(of: PanelContainer) -> Control:
        var hb := HBoxContainer.new()
        hb.alignment = BoxContainer.ALIGNMENT_CENTER
        var b := Button.new()
        b.text = "برگشت"
        b.add_theme_font_override("font", font)
        b.add_theme_font_size_override("font_size", 30)
        b.custom_minimum_size = Vector2(220, 54)
        b.add_theme_stylebox_override("normal", _btn(Color(0.10, 0.13, 0.20), Color(0.30, 0.42, 0.55), 2))
        b.add_theme_stylebox_override("hover", _btn(Color(0.14, 0.19, 0.29), Color(0.45, 0.62, 0.78), 2))
        b.add_theme_stylebox_override("pressed", _btn(Color(0.07, 0.09, 0.15), Color(0.30, 0.42, 0.55), 2))
        b.add_theme_color_override("font_color", COL_CREAM)
        b.pressed.connect(func(): _click(); _show(panel_home))
        hb.add_child(b)
        return hb

func _show(p: PanelContainer) -> void:
        for q in [panel_home, panel_levels, panel_guide, panel_settings, panel_about]:
                if q != null:
                        q.visible = (q == p)
        if p != panel_home:
                p.pivot_offset = p.size * 0.5
                p.scale = Vector2(0.92, 0.92)
                var tw := create_tween()
                tw.tween_property(p, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _glass() -> StyleBoxFlat:
        var sb := StyleBoxFlat.new()
        sb.bg_color = COL_GLASS
        sb.set_corner_radius_all(20)
        sb.border_color = Color(0.85, 0.68, 0.28, 0.45)
        sb.border_width_top = 2
        sb.border_width_bottom = 3
        sb.border_width_left = 2
        sb.border_width_right = 2
        sb.shadow_color = Color(0, 0, 0, 0.5)
        sb.shadow_size = 14
        sb.content_margin_left = 22
        sb.content_margin_right = 22
        sb.content_margin_top = 16
        sb.content_margin_bottom = 16
        return sb

func _btn(base: Color, border: Color, bw: int) -> StyleBoxFlat:
        var sb := StyleBoxFlat.new()
        sb.bg_color = base
        sb.set_corner_radius_all(16)
        sb.border_color = border
        sb.border_width_top = bw
        sb.border_width_bottom = bw + 2
        sb.border_width_left = bw
        sb.border_width_right = bw
        sb.shadow_color = Color(0, 0, 0, 0.35)
        sb.shadow_size = 5
        return sb

func _card_sb(on: bool) -> StyleBoxFlat:
        var sb := StyleBoxFlat.new()
        sb.bg_color = Color(0.09, 0.11, 0.17, 0.92) if on else Color(0.07, 0.08, 0.12, 0.8)
        sb.set_corner_radius_all(14)
        sb.border_color = Color(0.85, 0.68, 0.28, 0.55) if on else Color(0.3, 0.3, 0.36, 0.4)
        sb.border_width_left = 2
        sb.border_width_right = 2
        sb.border_width_top = 2
        sb.border_width_bottom = 3
        sb.content_margin_left = 10
        sb.content_margin_right = 10
        sb.content_margin_top = 8
        sb.content_margin_bottom = 8
        return sb

# ماشین ردشونده — نفس منو
func _build_driveby() -> void:
        _drive_car = Node2D.new()
        var spr := Sprite2D.new()
        spr.texture = load("res://assets/sprites/helia_top.png")
        spr.scale = Vector2(0.72, 0.72)
        spr.rotation = PI / 2.0
        _drive_car.add_child(spr)
        _drive_car.position = Vector2(-120, 692)
        _drive_car.z_index = 5
        add_child(_drive_car)

func _process(delta: float) -> void:
        if _drive_car != null:
                _drive_car.position.x += _drive_spd * delta
                if _drive_car.position.x > 1400:
                        _drive_car.position.x = -140.0 - randf() * 900.0
                        _drive_car.position.y = 640.0 + randf() * 60.0

func _build_version() -> void:
        var v := Label.new()
        var fb := ""
        for ch in str(Globals.BUILD):
                fb += ch
        v.text = "تیز پا — نسخه " + "۱٫۰" + " — بیلد " + fa_num(Globals.BUILD) + " — استودیو کسپین"
        v.add_theme_font_override("font", font_bold)
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
        toast = Label.new()
        toast.add_theme_font_override("font", font)
        toast.add_theme_font_size_override("font_size", 30)
        toast.add_theme_color_override("font_color", Color(1, 0.85, 0.4))
        toast.add_theme_color_override("font_outline_color", Color(0.1, 0.03, 0.02))
        toast.add_theme_constant_override("outline_size", 8)
        toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        toast.anchor_left = 0.0
        toast.anchor_right = 1.0
        toast.anchor_top = 0.62
        toast.anchor_bottom = 0.68
        toast.modulate.a = 0.0
        toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(toast)

func _show_toast(t: String) -> void:
        if toast == null:
                return
        toast.text = t
        toast.modulate.a = 1.0
        var tw := create_tween()
        tw.tween_interval(1.4)
        tw.tween_property(toast, "modulate:a", 0.0, 0.5)

func _fmt(t: float) -> String:
        var m := int(t) / 60
        var s := int(t) % 60
        return fa_num(m) + ":" + ("۰" if s < 10 else "") + fa_num(s)

func fa_num(n: int) -> String:
        var s := str(n)
        var out := ""
        for ch in s:
                if ch >= "0" and ch <= "9":
                        out += "۰۱۲۳۴۵۶۷۸۹"[int(ch)]
                else:
                        out += ch
        return out

func _unhandled_input(e: InputEvent) -> void:
        if e is InputEventKey and e.pressed and e.keycode == KEY_ESCAPE:
                _show(panel_home)

# ─────────────────────────── تست خودکار ───────────────────────────
func _autotest_hooks() -> void:
        var uargs := OS.get_cmdline_user_args()
        if uargs.has("--autotest"):
                _run_autotest()
        if uargs.has("--shot-menu"):
                _shot_menu()

func _run_autotest() -> void:
        print("[tizpa][menu] HOME OK — buttons=", panel_home.get_child(0).get_child_count())
        await get_tree().create_timer(1.2).timeout
        _show(panel_levels)
        await get_tree().create_timer(0.8).timeout
        # اولین کارت آزاد را بزن → بازی
        var list: VBoxContainer = panel_levels.get_child(0).get_child(1)
        var card: Button = list.get_child(0)
        var center: Vector2 = card.get_global_rect().get_center()
        var ev := InputEventMouseButton.new()
        ev.button_index = MOUSE_BUTTON_LEFT
        ev.pressed = true
        ev.position = center
        ev.global_position = center
        Input.parse_input_event(ev)
        var ev2 := ev.duplicate()
        ev2.pressed = false
        Input.parse_input_event(ev2)
        await get_tree().create_timer(2.0).timeout
        print("[tizpa][menu] LEVEL-1 LAUNCH ", "OK" if _expect_scene_change else "FAIL")
        if not _expect_scene_change:
                get_tree().quit(1)

func _shot_menu() -> void:
        await get_tree().create_timer(0.6).timeout
        var img := get_viewport().get_texture().get_image()
        if img != null:
                img.save_png("/home/z/my-project/scripts/shot_menu.png")
        _show(panel_levels)
        await get_tree().create_timer(0.5).timeout
        var img2 := get_viewport().get_texture().get_image()
        if img2 != null:
                img2.save_png("/home/z/my-project/scripts/shot_levels.png")
        _show(panel_guide)
        await get_tree().create_timer(0.5).timeout
        var img3 := get_viewport().get_texture().get_image()
        if img3 != null:
                img3.save_png("/home/z/my-project/scripts/shot_guide.png")
        _show(panel_about)
        await get_tree().create_timer(0.5).timeout
        var img4 := get_viewport().get_texture().get_image()
        if img4 != null:
                img4.save_png("/home/z/my-project/scripts/shot_about.png")
        _show(panel_settings)
        await get_tree().create_timer(0.5).timeout
        var img5 := get_viewport().get_texture().get_image()
        if img5 != null:
                img5.save_png("/home/z/my-project/scripts/shot_settings.png")
        print("[tizpa][menu] SHOTS OK")
        get_tree().quit()
