extends Node
## Capture helper: loads the game, swings the sword, then spins the hammer,
## for a movie-maker run. Run windowed:
##   Godot --path . --always-on-top --write-movie captures/attack.png \
##     --fixed-fps 30 --quit-after 75 res://tools/attack_capture.tscn
## Sword frames are about 16-23, hammer frames about 36-57.

func _ready() -> void:
	add_child(load("res://scenes/main.tscn").instantiate())
	await get_tree().create_timer(0.5).timeout
	Input.parse_input_event(_action("sword", true))
	Input.parse_input_event(_action("sword", false))
	await get_tree().create_timer(0.6).timeout
	Input.parse_input_event(_action("hammer", true))
	Input.parse_input_event(_action("hammer", false))

func _action(action: String, down: bool) -> InputEventAction:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = down
	return e
