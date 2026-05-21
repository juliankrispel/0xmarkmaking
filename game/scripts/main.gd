extends Node3D
## Builds the world in code: stylized environment, isometric camera, ground,
## a starting Town Hall (the hub), trees, and the first workers. Wires the UI.

const TRAIN_COST := {"wood": 5}

var cam_rig: Node3D
var cam: Camera3D
var units_root: Node3D
var home: Node3D
var wood_label: Label

func _ready() -> void:
	randomize()
	_setup_environment()
	_setup_lights()
	_setup_camera()
	_setup_ground()
	_setup_home()
	_scatter_trees(9)
	units_root = Node3D.new()
	units_root.name = "Units"
	add_child(units_root)
	for i in 3:
		_spawn_worker()
	_setup_ui()

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
	var banner := BuildLib.box(0.7, 0.5, 0.05, Color("2f63b8"))
	banner.position = Vector3(1.65, 2.6, -0.8)
	home.add_child(banner)

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

func _spawn_worker() -> void:
	var w := Worker.new()
	w.home = home
	var ang := randf() * TAU
	w.position = home.global_position + Vector3(cos(ang) * 2.6, 0, sin(ang) * 2.6)
	units_root.add_child(w)

func _setup_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := VBoxContainer.new()
	panel.position = Vector2(18, 16)
	panel.add_theme_constant_override("separation", 8)
	layer.add_child(panel)
	var title := Label.new()
	title.text = "Low-Poly Village"
	panel.add_child(title)
	wood_label = Label.new()
	panel.add_child(wood_label)
	var btn := Button.new()
	btn.text = "Train Lumberjack (5 wood)"
	btn.pressed.connect(_on_train_pressed)
	panel.add_child(btn)
	var hint := Label.new()
	hint.modulate = Color(1, 1, 1, 0.7)
	hint.text = "WASD / right-drag: pan   ·   wheel: zoom   ·   Q/E: rotate"
	panel.add_child(hint)
	GameState.resources_changed.connect(_on_resources_changed)
	_refresh_wood()

func _on_train_pressed() -> void:
	if GameState.spend(TRAIN_COST):
		_spawn_worker()

func _on_resources_changed(_r: Dictionary) -> void:
	_refresh_wood()

func _refresh_wood() -> void:
	if wood_label != null:
		wood_label.text = "Wood: %d" % int(GameState.resources.get("wood", 0))

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

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and cam != null:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			cam.size = maxf(8.0, cam.size - 2.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cam.size = minf(42.0, cam.size + 2.0)
	elif event is InputEventMouseMotion and cam_rig != null:
		if (event.button_mask & MOUSE_BUTTON_MASK_RIGHT) != 0:
			var pan := Vector3(-event.relative.x, 0, -event.relative.y).rotated(Vector3.UP, cam_rig.rotation.y)
			cam_rig.global_position += pan * 0.03
