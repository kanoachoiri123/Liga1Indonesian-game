class_name UIStyle
extends RefCounted

const GAME_TITLE := "BRI SUPER LEAGUE INDONESIA"
const UI_SCALE := 0.5
const FONT_HEADING_PATH := "res://assets/fonts/Daydream.ttf"
const FONT_BODY_PATH := "res://assets/fonts/Pixeled.ttf"
const MENU_DIR := "res://assets/art/ui/mainmenu/"
const TEAMSEL_DIR := "res://assets/art/ui/teamselection/"
const FLAGS_DIR := "res://assets/art/ui/flags/"
const GOAL_IMAGE := "res://assets/art/ui/goal.png"
const TIMES_UP_IMAGE := "res://assets/art/ui/times-up.png"

const COLOR_TEXT := Color("ffffff")
const COLOR_ACCENT := Color("ffd23f")
const COLOR_PANEL := Color(0, 0, 0, 0.65)
const COLOR_GOLD := Color(0.8, 0.6, 0.1, 0.85)
const COLOR_BG := Color("1d4d2b")

static func px(value: float) -> int:
	return maxi(1, roundi(value * UI_SCALE))

static func fs(size: int) -> int:
	return maxi(5, roundi(size * UI_SCALE))

static func load_texture(path: String) -> Texture2D:
	if path != "" and ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null

static func find_asset(dir: String, prefix: String) -> String:
	for f in DirAccess.get_files_at(dir):
		var n := f.trim_suffix(".import").trim_suffix(".remap")
		if n.begins_with(prefix) and n.ends_with(".png"):
			return dir.path_join(n)
	return ""

static func find_texture(dir: String, prefix: String) -> Texture2D:
	return load_texture(find_asset(dir, prefix))

static var _flag_cache: Dictionary = {}
const FLAG_HEIGHT := 12

static func flag_for(team: String) -> Texture2D:
	if _flag_cache.has(team):
		return _flag_cache[team]
	var found: Texture2D = null
	var slug := team.to_lower()
	for n in [slug, slug.replace(" ", "-"), slug.replace(" ", "_"), slug.replace(" ", "")]:
		for prefix in ["flag-", "", "logo-"]:
			found = load_texture(FLAGS_DIR + prefix + n + ".png")
			if found != null:
				break
		if found != null:
			break
	# Shrink to a small fixed height so a big logo can't blow up the layout
	if found != null:
		var img := found.get_image()
		if img != null:
			if img.is_compressed():
				img.decompress()
			var w := maxi(1, roundi(img.get_width() * float(FLAG_HEIGHT) / img.get_height()))
			img.resize(w, FLAG_HEIGHT, Image.INTERPOLATE_LANCZOS)
			found = ImageTexture.create_from_image(img)
	_flag_cache[team] = found
	return found

static func _font(heading: bool) -> Font:
	var path := FONT_HEADING_PATH if heading else FONT_BODY_PATH
	if ResourceLoader.exists(path):
		return load(path) as Font
	return null

static func label(text: String, size: int = 16, color: Color = COLOR_TEXT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", fs(size))
	l.add_theme_color_override("font_color", color)
	var f := _font(size >= 20)
	if f != null:
		l.add_theme_font_override("font", f)
	return l

static func panel_style(color: Color = COLOR_PANEL) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(px(3))
	sb.set_content_margin_all(px(6))
	return sb

static func button(text: String, callback: Callable, size: int = 16) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(px(150), px(26))
	b.add_theme_font_size_override("font_size", fs(size))
	var f := _font(false)
	if f != null:
		b.add_theme_font_override("font", f)
	for state in ["normal", "hover", "pressed", "focus"]:
		var col := Color("2e7d32")
		if state == "hover" or state == "focus":
			col = Color("43a047")
		b.add_theme_stylebox_override(state, panel_style(col))
	b.pressed.connect(callback)
	return b

static func add_background(parent: Control, path: String = "") -> void:
	var tex := load_texture(path)
	if tex != null:
		var tr := TextureRect.new()
		tr.texture = tex
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		parent.add_child(tr)
	else:
		var cr := ColorRect.new()
		cr.color = COLOR_BG
		cr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		parent.add_child(cr)

static func image_node(tex: Texture2D) -> TextureRect:
	var r := TextureRect.new()
	r.texture = tex
	r.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	return r
