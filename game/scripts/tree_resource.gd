class_name TreeResource
extends Node3D
## A harvestable tree. Depletes when chopped, then slowly regrows so the loop never stalls.

@export var max_amount := 5

var amount := 5
var _regrow := 0.0
var _foliage: Node3D

func _ready() -> void:
	add_to_group("trees")
	amount = max_amount
	_build()

func _build() -> void:
	var trunk := BuildLib.cyl(0.12, 0.16, 0.7, 7, Color("8a5a32"))
	trunk.position.y = 0.35
	add_child(trunk)
	_foliage = Node3D.new()
	add_child(_foliage)
	var cols := [Color("356a31"), Color("3f7a3a"), Color("4f9147")]
	for i in 3:
		var leaf := BuildLib.cone(0.8 - i * 0.2, 0.9, 7, cols[i])
		leaf.position.y = 0.9 + i * 0.5
		_foliage.add_child(leaf)

func available() -> bool:
	return amount > 0

func harvest() -> void:
	if amount <= 0:
		return
	amount -= 1
	var s := 0.4 + 0.6 * float(amount) / float(max_amount)
	_foliage.scale = Vector3(s, s, s)
	if amount <= 0:
		_regrow = 8.0

func _process(delta: float) -> void:
	if amount <= 0:
		_regrow -= delta
		if _regrow <= 0.0:
			amount = max_amount
			_foliage.scale = Vector3.ONE
