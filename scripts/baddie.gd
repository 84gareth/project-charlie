extends Node2D
## A baddie. Its position is where its feet touch the street. Walks up
## beside the hero and now and then winds up a punch: `punched` fires if
## the hero is still in reach when it lands. When hit it wobbles, gets
## pushed back and loses its wind-up; out of HP it sinks into the ground,
## then says so with `sunk` and goes away.

signal punched(baddie: Node2D)
signal sunk(baddie: Node2D)

const Brain = preload("res://scripts/baddie_brain.gd")
const Layout = preload("res://scripts/street_layout.gd")

enum State { WALK, WINDUP, PUNCH, HURT, SINK }

@onready var art: Node2D = $Art

var state: State = State.WALK
var hp: int = Brain.HP
## Set by whoever spawns it.
var hero: Node2D
var lane: float = 0.0
var walk_area: Rect2 = Layout.WALK_AREA
## Seconds until it may start its next punch.
var punch_wait: float = Brain.FIRST_PUNCH

var _timer: float = 0.0
## Every attack that has hit it: one swing, spin, wave or bonk hits a
## baddie once, however long it lasts, even if another lands meanwhile.
var _hit_by: Dictionary = {}

func alive() -> bool:
	return state != State.SINK

## Hit by attack number `attack_id`, from someone standing at `from_x`.
## True if it counted.
func take_hit(damage: int, attack_id: int, from_x: float) -> bool:
	if not alive() or _hit_by.has(attack_id):
		return false
	_hit_by[attack_id] = true
	hp -= damage
	position.x = clampf(position.x + signf(position.x - from_x) * Brain.KNOCKBACK,
			walk_area.position.x, walk_area.end.x)
	_enter(State.SINK if hp <= 0 else State.HURT)
	return true

func _enter(new_state: State) -> void:
	state = new_state
	_timer = 0.0

func _process(delta: float) -> void:
	_timer += delta
	match state:
		State.WALK:
			punch_wait -= delta
			if is_instance_valid(hero):
				var target: Vector2 = Brain.chase_target(hero.position, position, lane, walk_area)
				position = Brain.step(position, target, delta)
				if punch_wait <= 0.0 and Brain.in_reach(position, hero.position):
					_enter(State.WINDUP)
		State.WINDUP:
			if _timer >= Brain.WINDUP:
				if is_instance_valid(hero) and Brain.in_reach(position, hero.position):
					punched.emit(self)
				punch_wait = Brain.COOLDOWN
				_enter(State.PUNCH)
		State.PUNCH:
			if _timer >= Brain.PUNCH_SHOW:
				_enter(State.WALK)
		State.HURT:
			if _timer >= Brain.HURT_TIME:
				punch_wait = maxf(punch_wait, Brain.FIRST_PUNCH)
				_enter(State.WALK)
		State.SINK:
			if _timer >= Brain.SINK_TIME:
				sunk.emit(self)
				queue_free()
				return
	if is_instance_valid(hero) and alive():
		art.facing = 1 if hero.position.x >= position.x else -1
	art.hurt = state == State.HURT
	art.pose = ("windup" if state == State.WINDUP else "punch" if state == State.PUNCH else "")
	art.sink = clampf(_timer / Brain.SINK_TIME, 0.0, 1.0) if state == State.SINK else 0.0
