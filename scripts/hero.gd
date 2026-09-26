extends Node2D
## The player's hero. Its position is where its feet touch the street.
## Walks with the keyboard or a controller; one button swings the sword,
## another does the spin hammer attack. Stands still while attacking.

signal attack_started(kind: String)

const Walk = preload("res://scripts/walk.gd")
const Layout = preload("res://scripts/street_layout.gd")
const Attacks = preload("res://scripts/attacks.gd")

@onready var art: Node2D = $Art

## 1 is right, -1 is left.
var facing: int = 1
var walk_area: Rect2 = Layout.WALK_AREA
var attack := Attacks.State.new()
## Counts up with every attack, so a baddie is hit once per swing or spin.
var attack_id: int = 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("sword"):
		_start_attack(Attacks.SWORD)
	elif event.is_action_pressed("hammer"):
		_start_attack(Attacks.HAMMER)

func _start_attack(kind: String) -> void:
	if attack.start(kind):
		attack_id += 1
		attack_started.emit(kind)

func _process(delta: float) -> void:
	attack.update(delta)
	var dir: Vector2 = Vector2.ZERO
	if not attack.busy():
		dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position = Walk.step(position, dir, delta, walk_area)
	facing = Walk.facing(facing, dir.x)
	art.facing = facing
	art.moving = dir.length() > 0.1
	art.attack_kind = attack.kind
	art.attack_progress = attack.progress()
