extends Node
## Capture helper: loads the game, then holds right-and-down so a movie-maker
## run shows the hero walking and the camera following. Run windowed:
##   Godot --path . --always-on-top --write-movie captures/walk.png \
##     --fixed-fps 30 --quit-after 90 res://tools/walk_capture.tscn

func _ready() -> void:
	add_child(load("res://scenes/main.tscn").instantiate())
	await get_tree().create_timer(0.5).timeout
	Input.action_press("move_right")
	Input.action_press("move_down")
