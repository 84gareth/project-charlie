extends Node2D
## One of Charlie's helpers on the street. Its position is where its feet
## touch the ground. Follows the hero, hopping gently, and faces the way
## the hero faces. Pops in with a sparkle when it first joins.
##
## main.gd decides WHEN to use a power (ready_for_power, then use_power
## with a baddie); the helper does the move and says what happened:
##   made_wave      blue: a wave should roll from `at` in `dir`
##   bonked         yellow and green: the power landed on `target`
##   wants_to_heal  its heart timer is up; main gives a heart if you need one

signal made_wave(helper: Node2D, at: Vector2, dir: int)
signal bonked(helper: Node2D, target: Node2D, damage: int)
signal wants_to_heal(helper: Node2D)

const Helpers = preload("res://scripts/helpers.gd")
const Powers = preload("res://scripts/helper_powers.gd")
const Layout = preload("res://scripts/street_layout.gd")

enum State { FOLLOW, SNEAK, FLY }

## Sneaky timings, in seconds from the start of the power.
const SNEAK_GONE: float = 0.25
const SNEAK_BACK: float = 0.4
const SNEAK_BONK: float = 0.45
const SNEAK_LEAVE: float = 0.8
const SNEAK_END: float = 1.0
## Flying timings.
const FLY_OUT: float = 0.6
const FLY_HOME: float = 0.5

@onready var sprite: Sprite2D = $Sprite

var kind: String = "blue"
## Its place in the line of helpers (0, 1 or 2).
var index: int = 0
var hero: Node2D
var walk_area: Rect2 = Layout.WALK_AREA
var state: State = State.FOLLOW
## Seconds until it may use its power again.
var power_wait: float = 0.0
## Seconds until it may give another heart.
var heal_wait: float = Powers.HEAL_EVERY

var _time: float = 0.0
var _power_time: float = 0.0
var _target: Node2D
var _target_spot: Vector2
var _from: Vector2
var _bonked: bool = false
## How far above the street it is while flying (the shadow stays down).
var _lift: float = 0.0

func _ready() -> void:
	sprite.texture = load(Helpers.TEXTURE[kind])
	sprite.scale = Vector2.ONE * Helpers.SCALE[kind]
	power_wait = Powers.FIRST_WAIT + index * Powers.STAGGER
	heal_wait = Powers.HEAL_EVERY * 0.5 + index * 2.0
	# Pop in: grow from nothing with a little overshoot.
	scale = Vector2.ZERO
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.45) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func ready_for_power() -> bool:
	return state == State.FOLLOW and power_wait <= 0.0

func use_power(target: Node2D) -> void:
	power_wait = Powers.COOLDOWN[kind]
	_target = target
	_target_spot = target.position
	_power_time = 0.0
	_bonked = false
	match Helpers.POWER[kind]:
		"wave":
			var dir: int = 1 if target.position.x >= position.x else -1
			made_wave.emit(self, Vector2(position.x, target.position.y), dir)
		"sneaky":
			state = State.SNEAK
		"flying":
			state = State.FLY
			_from = position

func _process(delta: float) -> void:
	_time += delta
	power_wait -= delta
	heal_wait -= delta
	if heal_wait <= 0.0:
		wants_to_heal.emit(self)
	if is_instance_valid(_target):
		_target_spot = _target.position
	match state:
		State.FOLLOW:
			_follow(delta)
		State.SNEAK:
			_sneak(delta)
		State.FLY:
			_fly(delta)
	queue_redraw()

func _home() -> Vector2:
	if not is_instance_valid(hero):
		return position
	return Helpers.follow_spot(hero.position, hero.facing, index, walk_area)

func _follow(delta: float) -> void:
	_lift = 0.0
	modulate.a = move_toward(modulate.a, 1.0, delta * 4.0)
	if is_instance_valid(hero):
		position = Helpers.follow_step(position, _home(), delta)
		sprite.flip_h = hero.facing < 0
	# A gentle hop, each helper a little out of step with the others.
	sprite.position.y = -absf(sin(_time * 5.0 + index)) * 10.0

## Vanish, pop up behind the baddie, bonk, vanish, come home.
func _sneak(delta: float) -> void:
	var before: float = _power_time
	_power_time += delta
	var t: float = _power_time
	if t < SNEAK_GONE:
		modulate.a = 1.0 - t / SNEAK_GONE
	elif before < SNEAK_GONE:
		position = Powers.sneak_spot(_target_spot, hero.position if is_instance_valid(hero) else _target_spot, walk_area)
		sprite.flip_h = _target_spot.x < position.x
	if t >= SNEAK_GONE and t < SNEAK_LEAVE:
		modulate.a = clampf((t - SNEAK_GONE) / (SNEAK_BACK - SNEAK_GONE), 0.0, 1.0)
	if t >= SNEAK_BONK and not _bonked:
		_bonked = true
		sprite.position.x = -20.0 if sprite.flip_h else 20.0
		if is_instance_valid(_target):
			bonked.emit(self, _target, Powers.DAMAGE[kind])
	sprite.position.x = move_toward(sprite.position.x, 0.0, delta * 80.0)
	if t >= SNEAK_LEAVE:
		modulate.a = 1.0 - clampf((t - SNEAK_LEAVE) / (SNEAK_END - SNEAK_LEAVE), 0.0, 1.0)
	if t >= SNEAK_END:
		position = _home()
		modulate.a = 0.0
		state = State.FOLLOW

## Up in an arc, down onto the baddie, then an arc back home.
func _fly(delta: float) -> void:
	_power_time += delta
	var t: float = _power_time
	if t < FLY_OUT:
		var k: float = t / FLY_OUT
		position = Powers.fly_arc(_from, _target_spot, k)
		_lift = sin(k * PI) * Powers.FLY_HEIGHT
		sprite.flip_h = _target_spot.x < _from.x
		return
	if not _bonked:
		_bonked = true
		position = _target_spot
		_from = position
		if is_instance_valid(_target):
			bonked.emit(self, _target, Powers.DAMAGE[kind])
	var k2: float = clampf((t - FLY_OUT) / FLY_HOME, 0.0, 1.0)
	var home: Vector2 = _home()
	position = Powers.fly_arc(_from, home, k2)
	_lift = sin(k2 * PI) * Powers.FLY_HEIGHT
	if k2 >= 1.0:
		_lift = 0.0
		state = State.FOLLOW

func _draw() -> void:
	# The shadow stays on the street while flying.
	var fade: float = 1.0 - clampf(_lift / (Powers.FLY_HEIGHT * 1.5), 0.0, 0.6)
	draw_set_transform(Vector2(0.0, _lift), 0.0, Vector2(fade, 0.3 * fade))
	draw_circle(Vector2.ZERO, 40.0, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
