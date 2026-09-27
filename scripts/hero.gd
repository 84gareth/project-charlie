extends Node2D
## The player's hero. Its position is where its feet touch the street.
## Walks with the keyboard or a controller; one button swings the sword,
## another does the spin hammer attack. Stands still while attacking.
## A punch bumps it back and makes it blink; out of hearts it falls down
## for a moment (main.gd decides when).

signal attack_started(kind: String)

const Walk = preload("res://scripts/walk.gd")
const Layout = preload("res://scripts/street_layout.gd")
const Attacks = preload("res://scripts/attacks.gd")

## How far a punch pushes the hero.
const BUMP: float = 50.0

@onready var art: Node2D = $Art

## 1 is right, -1 is left.
var facing: int = 1
var walk_area: Rect2 = Layout.WALK_AREA
var attack := Attacks.State.new()
## Counts up with every attack, so a baddie is hit once per swing or spin.
var attack_id: int = 0
## True while blinking after a punch (set by main.gd).
var blinking: bool = false
## True while knocked down: no walking or attacking.
var down: bool = false
## False while the start screen is up: no walking or attacking.
var controls_on: bool = true

func _unhandled_input(event: InputEvent) -> void:
	if down or not controls_on:
		return
	if event.is_action_pressed("sword"):
		_start_attack(Attacks.SWORD)
	elif event.is_action_pressed("hammer"):
		_start_attack(Attacks.HAMMER)

func _start_attack(kind: String) -> void:
	if attack.start(kind):
		attack_id += 1
		attack_started.emit(kind)

## Pushed away from a punch thrown by someone at `from_x`.
func bumped(from_x: float) -> void:
	var away: float = signf(position.x - from_x)
	if away == 0.0:
		away = -facing
	position.x = clampf(position.x + away * BUMP, walk_area.position.x, walk_area.end.x)

func _process(delta: float) -> void:
	attack.update(delta)
	var dir: Vector2 = Vector2.ZERO
	if not attack.busy() and not down and controls_on:
		dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position = Walk.step(position, dir, delta, walk_area)
	facing = Walk.facing(facing, dir.x)
	art.facing = facing
	art.moving = dir.length() > 0.1
	art.attack_kind = attack.kind
	art.attack_progress = attack.progress()
	art.down = down
	var blink_off: bool = blinking and int(Time.get_ticks_msec() / 100.0) % 2 == 0
	art.modulate.a = 0.35 if blink_off else 1.0
