class_name UI
extends RefCounted
## Shared, palette-matched UI: a Theme builder plus a few widget helpers.

const INK := Color("eef2f6")
const MUTED := Color("9fb0c0")
const PANEL := Color(0.094, 0.114, 0.145, 0.92)
const ACCENT := Color("4d7fd6")
const ACCENT2 := Color("5aa469")
const WOOD := Color("9a6336")
const POP := Color("4d7fd6")

static func _sb(bg: Color, radius: int, border: Color, bw: int, margin: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	sb.set_border_width_all(bw)
	sb.border_color = border
	sb.set_content_margin_all(margin)
	return sb

static func make_theme() -> Theme:
	var t := Theme.new()
	t.set_color("font_color", "Label", INK)
	t.set_font_size("font_size", "Label", 16)

	t.set_stylebox("normal", "Button", _sb(PANEL, 10, Color(1, 1, 1, 0.12), 1, 10))
	t.set_stylebox("hover", "Button", _sb(Color("223044"), 10, Color(1, 1, 1, 0.30), 1, 10))
	t.set_stylebox("pressed", "Button", _sb(ACCENT, 10, ACCENT, 1, 10))
	t.set_stylebox("disabled", "Button", _sb(Color(0.094, 0.114, 0.145, 0.5), 10, Color(1, 1, 1, 0.06), 1, 10))
	t.set_stylebox("focus", "Button", _sb(Color(0, 0, 0, 0), 10, Color(0, 0, 0, 0), 0, 10))
	t.set_color("font_color", "Button", INK)
	t.set_color("font_hover_color", "Button", Color(1, 1, 1))
	t.set_color("font_pressed_color", "Button", Color(1, 1, 1))
	t.set_color("font_disabled_color", "Button", Color(1, 1, 1, 0.32))
	t.set_font_size("font_size", "Button", 15)

	var panel_sb := _sb(PANEL, 14, Color(1, 1, 1, 0.10), 1, 12)
	panel_sb.shadow_size = 8
	panel_sb.shadow_color = Color(0, 0, 0, 0.45)
	t.set_stylebox("panel", "PanelContainer", panel_sb)
	t.set_stylebox("panel", "Panel", panel_sb)
	return t

static func label(text: String, size := 16, color := INK) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

static func button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	return b

static func icon(color: Color, size := 16.0) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.custom_minimum_size = Vector2(size, size)
	r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return r

## A self-contained settings panel. `on_back` is called when Back is pressed.
static func settings_panel(on_back: Callable) -> Control:
	var wrap := PanelContainer.new()
	wrap.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(320, 0)
	box.add_theme_constant_override("separation", 12)
	wrap.add_child(box)

	box.add_child(label("Settings", 22))

	box.add_child(label("Master volume", 14, MUTED))
	var vol := HSlider.new()
	vol.min_value = 0.0
	vol.max_value = 1.0
	vol.step = 0.01
	vol.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	vol.value_changed.connect(func(v): AudioServer.set_bus_volume_db(0, linear_to_db(maxf(0.0001, v))))
	box.add_child(vol)

	var full := CheckButton.new()
	full.text = "Fullscreen"
	full.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	full.toggled.connect(func(on): DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED))
	box.add_child(full)

	var back := button("Back")
	back.pressed.connect(on_back)
	box.add_child(back)
	return wrap
