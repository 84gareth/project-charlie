extends Node2D
## The player's hero. Its position is where its feet touch the street.
## Walks with the keyboard or a controller; no fighting yet.

const Walk = preload("res://scripts/walk.gd")
const Layout = preload("res://scripts/street_layout.gd")

@onready var art: Node2D = $Art

## 1 is right, -1 is left.
var facing: int = 1
var walk_area: Rect2 = Layout.WALK_AREA

func _process(delta: float) -> void:
	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position = Walk.step(position, dir, delta, walk_area)
	facing = Walk.facing(facing, dir.x)
	art.facing = facing
	art.moving = dir.length() > 0.1
