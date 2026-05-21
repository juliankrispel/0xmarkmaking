class_name BuildLib
extends RefCounted
## Tiny helpers for building low-poly meshes in code (mirrors the web viewer's primitives).

static func mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.92
	return m

static func _mi(mesh: PrimitiveMesh, c: Color) -> MeshInstance3D:
	mesh.material = mat(c)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	return mi

static func box(w: float, h: float, d: float, c: Color) -> MeshInstance3D:
	var bm := BoxMesh.new()
	bm.size = Vector3(w, h, d)
	return _mi(bm, c)

static func cyl(top_r: float, bot_r: float, h: float, seg: int, c: Color) -> MeshInstance3D:
	var cm := CylinderMesh.new()
	cm.top_radius = top_r
	cm.bottom_radius = bot_r
	cm.height = h
	cm.radial_segments = seg
	return _mi(cm, c)

static func cone(r: float, h: float, seg: int, c: Color) -> MeshInstance3D:
	return cyl(0.0, r, h, seg, c)

static func sphere(r: float, c: Color) -> MeshInstance3D:
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2.0
	sm.radial_segments = 16
	sm.rings = 8
	return _mi(sm, c)
