class_name Building
extends RefCounted
## Placeable building defs (cost in wood) + their low-poly visuals.

const TYPES := {
	"House": {
		"cost": 8, "housing": 4, "worker": false, "footprint": 3.0,
		"desc": "+4 housing",
	},
	"Lumberjack Hut": {
		"cost": 12, "housing": 0, "worker": true, "needs_housing": 1, "footprint": 3.0,
		"desc": "+1 lumberjack (needs housing)",
	},
}

static func order() -> Array:
	return ["House", "Lumberjack Hut"]

static func make(type: String) -> Node3D:
	match type:
		"House":
			return _house()
		"Lumberjack Hut":
			return _hut()
	return Node3D.new()

static func _plot(g: Node3D) -> void:
	var base := BuildLib.box(2.6, 0.35, 2.6, Color("70512f"))
	base.position.y = 0.175
	g.add_child(base)
	var grass := BuildLib.box(2.7, 0.14, 2.7, Color("83b056"))
	grass.position.y = 0.4
	g.add_child(grass)

static func _house() -> Node3D:
	var g := Node3D.new()
	_plot(g)
	var walls := BuildLib.box(1.7, 1.1, 1.4, Color("e7dabc"))
	walls.position.y = 1.02
	g.add_child(walls)
	var roof := MeshInstance3D.new()
	var pr := PrismMesh.new()
	pr.size = Vector3(2.0, 0.9, 1.6)
	pr.material = BuildLib.mat(Color("46699a"))
	roof.mesh = pr
	roof.position.y = 2.02
	g.add_child(roof)
	var door := BuildLib.box(0.5, 0.7, 0.1, Color("5e3a22"))
	door.position = Vector3(0, 0.82, 0.71)
	g.add_child(door)
	return g

static func _hut() -> Node3D:
	var g := Node3D.new()
	_plot(g)
	for sx in [-1, 1]:
		for sz in [-1, 1]:
			var post := BuildLib.box(0.18, 1.3, 0.18, Color("5e3a22"))
			post.position = Vector3(sx * 0.7, 1.05, sz * 0.6)
			g.add_child(post)
	var roof := MeshInstance3D.new()
	var pr := PrismMesh.new()
	pr.size = Vector3(1.95, 0.7, 1.75)
	pr.material = BuildLib.mat(Color("46699a"))
	roof.mesh = pr
	roof.position.y = 1.85
	g.add_child(roof)
	for i in 2:
		var logm := BuildLib.cyl(0.12, 0.12, 1.0, 8, Color("9a6336"))
		logm.rotation.z = PI / 2.0
		logm.position = Vector3(-0.5, 0.62 + i * 0.26, 0.0)
		g.add_child(logm)
	return g
