extends "res://tests/framework/live_case.gd"
## Each helper's power in the real game: blue's wave knocks a baddie,
## yellow sneaks round and bonks one, green swoops and sinks one, and
## helpers give a heart back when you've lost one.

const Brain = preload("res://scripts/baddie_brain.gd")
const Powers = preload("res://scripts/helper_powers.gd")
const FightState = preload("res://scripts/fight_state.gd")

var _main: Node
var _hero: Node2D

func before_each() -> void:
	_main = load("res://scenes/main.tscn").instantiate()
	_main.hero_look = "boy"
	_main.mode = "practice"
	add_child(_main)
	await frames(1)
	_hero = _main.get_node("%Hero")

func after_each() -> void:
	if is_instance_valid(_main):
		_main.queue_free()
	await frames(1)

## A baddie that stands still (no chasing, no punching) at `offset`.
func _dummy(offset: Vector2) -> Node2D:
	var b: Node2D = _main.spawn_baddie(_hero.position + offset)
	b.hero = null
	b.punch_wait = 999.0
	return b

## Only `kind` may use its power; the others wait.
func _only(kind: String) -> Node2D:
	var mine: Node2D = null
	for h: Node2D in _main.helpers:
		if h.kind == kind:
			mine = h
			h.power_wait = 0.0
		else:
			h.power_wait = 999.0
		h.heal_wait = 999.0
	return mine

func test_blue_wave_knocks_a_baddie() -> void:
	_main.set_gems(200)
	await frames(1)
	var b: Node2D = _dummy(Vector2(400, 30))
	_only("blue")
	await until(func() -> bool: return _main.waves.size() > 0, "a wave rolls")
	await until(func() -> bool: return b.hp < Brain.HP, "the wave knocks it")
	assert_gt(b.position.x, _hero.position.x + 400.0, "pushed along the way the wave rolls")

func test_one_wave_knocks_a_baddie_only_once() -> void:
	_main.set_gems(200)
	await frames(1)
	var b: Node2D = _dummy(Vector2(300, 0))
	b.hp = 5
	var blue: Node2D = _only("blue")
	await until(func() -> bool: return _main.waves.size() > 0, "a wave rolls")
	blue.power_wait = 999.0
	await until(func() -> bool: return _main.waves.is_empty(), "the wave is gone", 4.0)
	assert_eq(b.hp, 4, "knocked once")

func test_yellow_sneaks_round_and_bonks() -> void:
	_main.set_gems(500)
	await frames(1)
	var b: Node2D = _dummy(Vector2(300, 0))
	var yellow: Node2D = _only("yellow")
	await until(func() -> bool: return yellow.state == yellow.State.SNEAK, "sneaks")
	await until(func() -> bool: return yellow.position.x > b.position.x, "pops up behind it")
	await until(func() -> bool: return b.hp < Brain.HP, "bonk")
	await until(func() -> bool: return yellow.state == yellow.State.FOLLOW, "comes home")

func test_green_swoops_and_sinks_a_baddie_in_one_go() -> void:
	_main.set_gems(700)
	await frames(1)
	var b: Node2D = _dummy(Vector2(350, 0))
	var green: Node2D = _only("green")
	await until(func() -> bool: return green.state == green.State.FLY, "flies")
	await until(func() -> bool: return not b.alive(), "swoops down and sinks it")
	await until(func() -> bool: return _main.loose_gems.size() == 1, "and a gem pops out")

func test_helpers_leave_far_away_baddies_alone() -> void:
	_main.set_gems(700)
	await frames(1)
	var b: Node2D = _dummy(Vector2(Powers.RANGE + 200.0, 0))
	for h: Node2D in _main.helpers:
		h.power_wait = 0.0
	await seconds(0.5)
	for h: Node2D in _main.helpers:
		assert_eq(h.state, h.State.FOLLOW, "%s stays with you" % h.kind)
	assert_eq(_main.waves.size(), 0, "no wave")
	assert_eq(b.hp, Brain.HP)

func test_a_helper_gives_a_heart_back() -> void:
	_main.set_gems(200)
	await frames(1)
	var blue: Node2D = _main.helpers[0]
	blue.power_wait = 999.0
	_main.fight.hearts = FightState.MAX_HEARTS - 2
	blue.heal_wait = 0.0
	await until(func() -> bool: return _main.fight.hearts == FightState.MAX_HEARTS - 1, "one heart back")
	assert_eq(_main.get_node("%Hearts").hearts, FightState.MAX_HEARTS - 1, "shows on the hearts row")
	await seconds(0.3)
	assert_eq(_main.fight.hearts, FightState.MAX_HEARTS - 1, "then waits before the next")
	assert_gt(blue.heal_wait, Powers.HEAL_EVERY - 1.0, "timer reset")
