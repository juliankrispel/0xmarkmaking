extends Node
## Single source of truth for the economy. Registered as the "GameState" autoload.

signal resources_changed(resources: Dictionary)

var resources := {"wood": 0, "stone": 0}

func add(kind: String, amount: int) -> void:
	resources[kind] = int(resources.get(kind, 0)) + amount
	resources_changed.emit(resources)

func can_afford(cost: Dictionary) -> bool:
	for k in cost:
		if int(resources.get(k, 0)) < int(cost[k]):
			return false
	return true

func spend(cost: Dictionary) -> bool:
	if not can_afford(cost):
		return false
	for k in cost:
		resources[k] = int(resources[k]) - int(cost[k])
	resources_changed.emit(resources)
	return true
