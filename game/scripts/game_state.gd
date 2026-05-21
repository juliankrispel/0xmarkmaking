extends Node
## Single source of truth for the economy + progression. Autoload "GameState".

signal state_changed
signal goal_reached

var wood := 15
var population := 0     # active workers
var housing := 5        # capacity (Town Hall base + Houses)
var goal := 12          # target population to "win"
var won := false

func add_wood(n: int) -> void:
	wood += n
	state_changed.emit()

func can_afford(cost: int) -> bool:
	return wood >= cost

func spend(cost: int) -> bool:
	if wood < cost:
		return false
	wood -= cost
	state_changed.emit()
	return true

func add_housing(n: int) -> void:
	housing += n
	state_changed.emit()

func add_population(n: int) -> void:
	population += n
	state_changed.emit()
	if not won and population >= goal:
		won = true
		goal_reached.emit()

func free_housing() -> int:
	return housing - population

func reset() -> void:
	wood = 15
	population = 0
	housing = 5
	won = false
