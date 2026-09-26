extends Node2D
## A baddie. Its position is where its feet touch the street. Walks up
## beside the hero; when hit it wobbles and gets pushed back; out of HP it
## sinks into the ground, then says so with `sunk` and goes away.

signal sunk(baddie: Node2D)

const Brain = preload("res://scripts/baddie_brain.gd")
const Layout = preload("res://scripts/street_layout.gd")

enum State { WALK, HURT, SINK }

@onready var art: Node2D = $Art

var state: State = State.WALK
var hp: int = Brain.HP
## Set by whoever spawns it.
var hero: Node2D
var lane: float = 0.0
var walk_area: Rect2 = Layout.WALK_AREA

var _timer: float = 0.0
## One swing or spin hits a baddie once, however long it lasts.
var _last_hit_attack: int = -1

func alive() -> bool:
	return state != State.SINK

## Hit by attack number `attack_id`, from someone standing at `from_x`.
## True if it counted.
func take_hit(damage: int, attack_id: int, from_x: float) -> bool:
	if not alive() or attack_id == _last_hit_attack:
		return false
	_last_hit_attack = attack_id
	hp -= damage
	position.x = clampf(position.x + signf(position.x - from_x) * Brain.KNOCKBACK,
			walk_area.position.x, walk_area.end.x)
	state = State.SINK if hp <= 0 else State.HURT
	_timer = 0.0
	return true

func _process(delta: float) -> void:
	_timer += delta
	match state:
		State.WALK:
			if is_instance_valid(hero):
				var target: Vector2 = Brain.chase_target(hero.position, position, lane, walk_area)
				position = Brain.step(position, target, delta)
		State.HURT:
			if _timer >= Brain.HURT_TIME:
				state = State.WALK
		State.SINK:
			if _timer >= Brain.SINK_TIME:
				sunk.emit(self)
				queue_free()
				return
	if is_instance_valid(hero) and alive():
		art.facing = 1 if hero.position.x >= position.x else -1
	art.hurt = state == State.HURT
	art.sink = clampf(_timer / Brain.SINK_TIME, 0.0, 1.0) if state == State.SINK else 0.0
