extends Control
## Title / main menu, styled with the shared theme.

var _settings: Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UI.make_theme()

	var bg := ColorRect.new()
	bg.color = Color("1d2733")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(panel)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(300, 0)
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)

	var title := UI.label("Low-Poly Village", 30)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var sub := UI.label("a tiny settlers-like", 14, UI.MUTED)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	box.add_child(spacer)

	var play := UI.button("New Game")
	play.pressed.connect(func(): get_tree().change_scene_to_file("res://Main.tscn"))
	box.add_child(play)
	var settings := UI.button("Settings")
	settings.pressed.connect(_open_settings)
	box.add_child(settings)
	var quit := UI.button("Quit")
	quit.pressed.connect(func(): get_tree().quit())
	box.add_child(quit)

func _open_settings() -> void:
	if _settings != null:
		return
	_settings = UI.settings_panel(_close_settings)
	add_child(_settings)

func _close_settings() -> void:
	if _settings != null:
		_settings.queue_free()
		_settings = null
