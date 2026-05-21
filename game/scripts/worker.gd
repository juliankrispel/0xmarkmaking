class_name Worker
extends Node3D
## A lumberjack: walk to nearest tree, chop, carry a log back to home, deliver wood, repeat.
## The pose() logic mirrors the web viewer's animateUnit (Idle / Walk / Chop / Carry).

enum St { SEEK, TO_TREE, CHOP, RETURN, DELIVER }

var home: Node3D
var cloak := Color("b14730")
var speed := 2.6

var _state := St.SEEK
var _target: TreeResource
var _carrying := false
var _chop_t := 0.0
var _deliver_t := 0.0
var _t := 0.0

# rig
var _core: Node3D
var _hand_l: Node3D
var _hand_r: Node3D
var _log: MeshInstance3D
const BASE_L := Vector3(-0.5, 0.55, 0.12)
const BASE_R := Vector3(0.5, 0.55, 0.12)

func _ready() -> void:
	_t = randf() * 6.28
	_build()

func _build() -> void:
	_core = Node3D.new()
	add_child(_core)
	var body := BuildLib.cone(0.46, 1.0, 14, cloak)
	body.position.y = 0.5
	_core.add_child(body)
	var head := BuildLib.sphere(0.27, Color("d9a273"))
	head.position.y = 1.05
	_core.add_child(head)
	var hat := BuildLib.cone(0.28, 0.46, 14, Color("7a3b28"))
	hat.position.y = 1.16
	_core.add_child(hat)
	var eye_l := BuildLib.sphere(0.05, Color("2b2b33"))
	eye_l.position = Vector3(-0.1, 1.08, 0.25)
	_core.add_child(eye_l)
	var eye_r := BuildLib.sphere(0.05, Color("2b2b33"))
	eye_r.position = Vector3(0.1, 1.08, 0.25)
	_core.add_child(eye_r)
	_hand_l = _make_hand()
	_hand_l.position = BASE_L
	_core.add_child(_hand_l)
	_hand_r = _make_hand()
	_hand_r.position = BASE_R
	_core.add_child(_hand_r)
	# axe in the right hand
	var axe_handle := BuildLib.cyl(0.035, 0.035, 0.5, 6, Color("8a5a32"))
	axe_handle.position = Vector3(0, -0.08, 0.06)
	axe_handle.rotation.x = 0.35
	_hand_r.add_child(axe_handle)
	var axe_blade := BuildLib.box(0.05, 0.2, 0.24, Color("6e757c"))
	axe_blade.position = Vector3(0.02, 0.16, 0.24)
	axe_blade.rotation.x = 0.35
	_hand_r.add_child(axe_blade)
	# carried log (shown only while returning)
	_log = BuildLib.cyl(0.12, 0.12, 0.7, 8, Color("9a6336"))
	_log.rotation.z = PI / 2.0
	_log.position = Vector3(0, 0.7, 0.42)
	_log.visible = false
	_core.add_child(_log)

func _make_hand() -> Node3D:
	var h := Node3D.new()
	h.add_child(BuildLib.sphere(0.1, Color("d9a273")))
	return h

func _physics_process(delta: float) -> void:
	_t += delta
	match _state:
		St.SEEK:
			_target = _nearest_tree()
			if _target != null:
				_state = St.TO_TREE
		St.TO_TREE:
			if _target == null or not _target.available():
				_state = St.SEEK
			elif _move_to(_target.global_position, delta) < 1.2:
				_state = St.CHOP
				_chop_t = 1.6
		St.CHOP:
			_chop_t -= delta
			if _chop_t <= 0.0:
				if _target != null and _target.available():
					_target.harvest()
				_carrying = true
				_state = St.RETURN
		St.RETURN:
			if home != null and _move_to(home.global_position, delta) < 1.7:
				_state = St.DELIVER
				_deliver_t = 0.3
		St.DELIVER:
			_deliver_t -= delta
			if _deliver_t <= 0.0:
				if _carrying:
					GameState.add("wood", 1)
					_carrying = false
				_state = St.SEEK
	_pose()

func _move_to(p: Vector3, delta: float) -> float:
	var cur := global_position
	var to := Vector3(p.x, cur.y, p.z)
	var diff := to - cur
	var dist := diff.length()
	if dist > 0.05:
		var dir := diff / dist
		global_position += dir * minf(speed * delta, dist)
		rotation.y = atan2(dir.x, dir.z)
	return dist

func _nearest_tree() -> TreeResource:
	var best: TreeResource = null
	var best_d := 1.0e9
	for n in get_tree().get_nodes_in_group("trees"):
		var tr := n as TreeResource
		if tr != null and tr.available():
			var d := global_position.distance_to(tr.global_position)
			if d < best_d:
				best_d = d
				best = tr
	return best

func _pose() -> void:
	_log.visible = _carrying and _state != St.CHOP
	_core.rotation = Vector3.ZERO
	_hand_l.rotation = Vector3.ZERO
	_hand_r.rotation = Vector3.ZERO
	_hand_l.position = BASE_L
	_hand_r.position = BASE_R
	var fy := sin(_t * 1.6) * 0.06
	match _state:
		St.TO_TREE, St.RETURN:
			var a := _t * 7.0
			fy = abs(sin(a)) * 0.08
			_core.rotation.x = sin(a) * 0.08
			if _carrying:
				_hand_l.position = Vector3(-0.24, 0.7, 0.42)
				_hand_r.position = Vector3(0.24, 0.7, 0.42)
				_core.rotation.x = -0.1
			else:
				_hand_l.position.z += sin(a) * 0.2
				_hand_r.position.z -= sin(a) * 0.2
		St.CHOP:
			var s := sin(_t * 8.0) * 0.5 + 0.5
			_hand_r.position = Vector3(0.2, 0.5 + s * 0.6, 0.2)
			_hand_l.position = Vector3(-0.02, 0.5 + s * 0.6, 0.25)
			_hand_r.rotation.x = -2.0 * s + 0.5
			_hand_l.rotation.x = _hand_r.rotation.x
			_core.rotation.x = s * 0.4
		_:
			_core.rotation.z = sin(_t * 1.2) * 0.02
			_hand_l.position.y += sin(_t * 3.0) * 0.05
			_hand_r.position.y += sin(_t * 3.0 + PI) * 0.05
	_core.position.y = fy
