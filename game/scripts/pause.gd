extends CanvasLayer
## Pause overlay + settings. Runs while the tree is paused (PROCESS_MODE_ALWAYS).
## Esc toggles pause; the game scene's nodes are PAUSABLE so they freeze.

var _root: Control
var _menu: PanelContainer
var _settings: Control
var _paused := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.theme = UI.make_theme()
	_root.visible = false
	add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(dim)

	_menu = PanelContainer.new()
	_menu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_root.add_child(_menu)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(260, 0)
	box.add_theme_constant_override("separation", 12)
	_menu.add_child(box)
	box.add_child(UI.label("Paused", 24))
	var resume := UI.button("Resume")
	resume.pressed.connect(_resume)
	box.add_child(resume)
	var settings := UI.button("Settings")
	settings.pressed.connect(_open_settings)
	box.add_child(settings)
	var quit := UI.button("Quit to Title")
	quit.pressed.connect(_quit_title)
	box.add_child(quit)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _paused:
			_resume()
		else:
			_pause()
		get_viewport().set_input_as_handled()

func _pause() -> void:
	_paused = true
	get_tree().paused = true
	_root.visible = true

func _resume() -> void:
	_close_settings()
	_paused = false
	get_tree().paused = false
	_root.visible = false

func _open_settings() -> void:
	if _settings != null:
		return
	_settings = UI.settings_panel(_close_settings)
	_root.add_child(_settings)
	_menu.visible = false

func _close_settings() -> void:
	if _settings != null:
		_settings.queue_free()
		_settings = null
	_menu.visible = true

func _quit_title() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Title.tscn")
