extends Node3D
## Gameplay scene (built in code): stylized world, isometric camera, HUD,
## build menu with click-to-place, pause, and the grow-your-village goal loop.

var cam_rig: Node3D
var cam: Camera3D
var units_root: Node3D
var buildings_root: Node3D
var home: Node3D

# UI
var hud_root: Control
var wood_label: Label
var pop_label: Label
var goal_label: Label
var banner: Label
var _cards: Array = []

# placement
var _placing := ""
var _ghost: MeshInstance3D
var _ghost_mat: StandardMaterial3D

func _ready() -> void:
	randomize()
	GameState.reset()
	_setup_environment()
	_setup_lights()
	_setup_camera()
	_setup_ground()
	_setup_home()
	_scatter_trees(10)
	units_root = Node3D.new()
	units_root.name = "Units"
	add_child(units_root)
	buildings_root = Node3D.new()
	buildings_root.name = "Buildings"
	add_child(buildings_root)
	for i in 2:
		_spawn_worker(home.global_position + Vector3(randf_range(-2.6, 2.6), 0, randf_range(-2.6, 2.6)))
	_setup_hud()
	_setup_pause()
	GameState.state_changed.connect(_refresh_hud)
	GameState.goal_reached.connect(_on_goal)
	_refresh_hud()

# ---------- world ----------

func _setup_environment() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("26333f")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("3a4658")
	env.ambient_light_energy = 0.55
	env.fog_enabled = true
	env.fog_light_color = Color("223444")
	env.fog_density = 0.012
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.5
	env.glow_bloom = 0.15
	we.environment = env
	add_child(we)

func _setup_lights() -> void:
	var sun := DirectionalLight3D.new()
	sun.light_color = Color("ffe6b0")
	sun.light_energy = 1.4
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-50, -40, 0)
	add_child(sun)
	var fill := DirectionalLight3D.new()
	fill.light_color = Color("7da0ff")
	fill.light_energy = 0.4
	fill.rotation_degrees = Vector3(-20, 130, 0)
	add_child(fill)

func _setup_camera() -> void:
	cam_rig = Node3D.new()
	cam_rig.name = "CameraRig"
	add_child(cam_rig)
	cam = Camera3D.new()
	cam.name = "Camera3D"
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 18.0
	cam.position = Vector3(16, 18, 16)
	cam_rig.add_child(cam)
	cam.look_at(Vector3.ZERO, Vector3.UP)

func _setup_ground() -> void:
	var ground := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(80, 80)
	pm.material = BuildLib.mat(Color("83b056"))
	ground.mesh = pm
	add_child(ground)

func _setup_home() -> void:
	home = Node3D.new()
	home.name = "TownHall"
	add_child(home)
	var base := BuildLib.box(3.4, 0.4, 3.4, Color("70512f"))
	base.position.y = 0.2
	home.add_child(base)
	var grass := BuildLib.box(3.5, 0.16, 3.5, Color("83b056"))
	grass.position.y = 0.46
	home.add_child(grass)
	var walls := BuildLib.box(2.4, 1.5, 2.0, Color("e7dabc"))
	walls.position.y = 1.29
	home.add_child(walls)
	var roof := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(2.9, 1.2, 2.2)
	prism.material = BuildLib.mat(Color("46699a"))
	roof.mesh = prism
	roof.position.y = 2.64
	home.add_child(roof)
	var door := BuildLib.box(0.7, 0.9, 0.12, Color("5e3a22"))
	door.position = Vector3(0, 0.99, 1.01)
	home.add_child(door)
	var pole := BuildLib.cyl(0.04, 0.04, 2.4, 6, Color("4a3320"))
	pole.position = Vector3(1.3, 1.74, -0.8)
	home.add_child(pole)
	var banner_mesh := BuildLib.box(0.7, 0.5, 0.05, Color("2f63b8"))
	banner_mesh.position = Vector3(1.65, 2.6, -0.8)
	home.add_child(banner_mesh)

func _scatter_trees(n: int) -> void:
	var root := Node3D.new()
	root.name = "Resources"
	add_child(root)
	var placed := 0
	var tries := 0
	while placed < n and tries < 300:
		tries += 1
		var ang := randf() * TAU
		var rad := randf_range(6.5, 13.0)
		var tree := TreeResource.new()
		tree.position = Vector3(cos(ang) * rad, 0, sin(ang) * rad)
		root.add_child(tree)
		placed += 1

func _spawn_worker(pos: Vector3) -> void:
	var w := Worker.new()
	w.home = home
	w.position = pos
	units_root.add_child(w)
	GameState.add_population(1)

# ---------- HUD ----------

func _setup_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud_root = Control.new()
	hud_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.theme = UI.make_theme()
	layer.add_child(hud_root)

	# top-left resource bar
	var top := PanelContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	top.position = Vector2(16, 12)
	hud_root.add_child(top)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 14)
	top.add_child(hb)
	hb.add_child(UI.icon(UI.WOOD))
	wood_label = UI.label("0")
	hb.add_child(wood_label)
	hb.add_child(UI.icon(UI.POP))
	pop_label = UI.label("0 / 0")
	hb.add_child(pop_label)

	# goal text, top-center
	goal_label = UI.label("", 14, UI.MUTED)
	goal_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	goal_label.offset_top = 14
	goal_label.offset_bottom = 40
	goal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	goal_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_child(goal_label)

	# bottom-center build bar
	var holder := HBoxContainer.new()
	holder.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	holder.offset_top = -88
	holder.offset_bottom = -16
	holder.alignment = BoxContainer.ALIGNMENT_CENTER
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_child(holder)
	var build := PanelContainer.new()
	holder.add_child(build)
	var bb := HBoxContainer.new()
	bb.add_theme_constant_override("separation", 10)
	build.add_child(bb)
	for type in Building.order():
		var cfg: Dictionary = Building.TYPES[type]
		var card := UI.button("%s\n%d wood" % [type, int(cfg.cost)])
		card.custom_minimum_size = Vector2(150, 50)
		card.tooltip_text = String(cfg.desc)
		card.pressed.connect(_start_placing.bind(type))
		bb.add_child(card)
		_cards.append({"type": type, "button": card})

	# win banner
	banner = UI.label("", 26, UI.ACCENT2)
	banner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.visible = false
	hud_root.add_child(banner)

func _setup_pause() -> void:
	var pl := CanvasLayer.new()
	pl.set_script(load("res://scripts/pause.gd"))
	add_child(pl)

func _refresh_hud() -> void:
	if wood_label != null:
		wood_label.text = "%d" % GameState.wood
	if pop_label != null:
		pop_label.text = "%d / %d" % [GameState.population, GameState.housing]
	if goal_label != null:
		goal_label.text = "Goal: grow your village to %d villagers   (%d/%d)" % [GameState.goal, GameState.population, GameState.goal]
	_update_cards()

func _on_goal() -> void:
	if banner != null:
		banner.text = "Your village is thriving!"
		banner.visible = true

func _update_cards() -> void:
	for c in _cards:
		var cfg: Dictionary = Building.TYPES[c.type]
		var afford := GameState.can_afford(int(cfg.cost))
		var house_ok := int(cfg.get("needs_housing", 0)) <= GameState.free_housing()
		c.button.disabled = not (afford and house_ok)
		c.button.modulate = UI.ACCENT2.lightened(0.2) if c.type == _placing else Color(1, 1, 1)

# ---------- placement ----------

func _start_placing(type: String) -> void:
	if _placing == type:
		_cancel_placing()
		return
	_placing = type
	if _ghost == null:
		_ghost_mat = StandardMaterial3D.new()
		_ghost_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_ghost_mat.albedo_color = Color(0.3, 1.0, 0.4, 0.4)
		var bm := BoxMesh.new()
		bm.size = Vector3(3, 0.25, 3)
		bm.material = _ghost_mat
		_ghost = MeshInstance3D.new()
		_ghost.mesh = bm
		add_child(_ghost)
	_ghost.visible = true
	_update_cards()

func _cancel_placing() -> void:
	_placing = ""
	if _ghost != null:
		_ghost.visible = false
	_update_cards()

func _ground_point() -> Vector3:
	var m := get_viewport().get_mouse_position()
	var o := cam.project_ray_origin(m)
	var d := cam.project_ray_normal(m)
	if absf(d.y) < 0.00001:
		return Vector3.ZERO
	var t := -o.y / d.y
	var p := o + d * t
	p.x = round(p.x / 2.0) * 2.0
	p.z = round(p.z / 2.0) * 2.0
	p.y = 0.0
	return p

func _can_place(type: String, pos: Vector3) -> bool:
	var cfg: Dictionary = Building.TYPES[type]
	if not GameState.can_afford(int(cfg.cost)):
		return false
	if int(cfg.get("needs_housing", 0)) > GameState.free_housing():
		return false
	if pos.distance_to(home.global_position) < 3.5:
		return false
	for b in buildings_root.get_children():
		if pos.distance_to(b.global_position) < 2.5:
			return false
	return true

func _try_place() -> void:
	var p := _ground_point()
	if not _can_place(_placing, p):
		return
	var cfg: Dictionary = Building.TYPES[_placing]
	GameState.spend(int(cfg.cost))
	var b := Building.make(_placing)
	b.position = p
	buildings_root.add_child(b)
	if int(cfg.get("housing", 0)) > 0:
		GameState.add_housing(int(cfg.housing))
	if bool(cfg.get("worker", false)):
		_spawn_worker(p + Vector3(0, 0, 1.6))
	_cancel_placing()

# ---------- input / camera ----------

func _process(delta: float) -> void:
	if cam_rig == null:
		return
	var v := Vector3.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		v.z -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		v.z += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		v.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		v.x += 1.0
	if v != Vector3.ZERO:
		var dir := v.normalized().rotated(Vector3.UP, cam_rig.rotation.y)
		cam_rig.global_position += dir * 14.0 * delta
	if Input.is_key_pressed(KEY_Q):
		cam_rig.rotation.y += delta * 1.2
	if Input.is_key_pressed(KEY_E):
		cam_rig.rotation.y -= delta * 1.2
	if _placing != "" and _ghost != null:
		var p := _ground_point()
		_ghost.position = p
		_ghost_mat.albedo_color = Color(0.3, 1.0, 0.4, 0.4) if _can_place(_placing, p) else Color(1.0, 0.35, 0.35, 0.45)

func _unhandled_input(event: InputEvent) -> void:
	if _placing != "" and event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_place()
			get_viewport().set_input_as_handled()
			return
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_placing()
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseButton and event.pressed and cam != null:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			cam.size = maxf(8.0, cam.size - 2.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cam.size = minf(42.0, cam.size + 2.0)
	elif event is InputEventMouseMotion and cam_rig != null:
		if (event.button_mask & MOUSE_BUTTON_MASK_RIGHT) != 0:
			var pan := Vector3(-event.relative.x, 0, -event.relative.y).rotated(Vector3.UP, cam_rig.rotation.y)
			cam_rig.global_position += pan * 0.03
