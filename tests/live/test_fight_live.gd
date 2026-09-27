extends "res://tests/framework/live_case.gd"
## The real fight: baddies arrive, walk up, take two hits, sink into the
## ground, leave a gem; walking onto the gem counts it; the next wave comes.

const Attacks = preload("res://scripts/attacks.gd")
const Brain = preload("res://scripts/baddie_brain.gd")
const Waves = preload("res://scripts/waves.gd")

var _main: Node
var _hero: Node2D

func before_each() -> void:
	_main = load("res://scenes/main.tscn").instantiate()
	_main.hero_look = "boy"
	add_child(_main)
	await frames(1)
	_hero = _main.get_node("%Hero")

func after_each() -> void:
	for action: String in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(action)
	if is_instance_valid(_main):
		_main.queue_free()
	await frames(1)

func _press(action: String) -> void:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = true
	Input.parse_input_event(e)
	e = InputEventAction.new()
	e.action = action
	Input.parse_input_event(e)
	Input.flush_buffered_events()

## Swing and wait for the swing to finish.
func _swing(action: String) -> void:
	_press(action)
	await until(func() -> bool: return _hero.attack.busy(), "attack starts")
	await until(func() -> bool: return not _hero.attack.busy(), "attack ends")

func test_first_wave_arrives_and_walks_up_to_the_hero() -> void:
	await until(func() -> bool: return _main.baddies.size() == Waves.SIZE, "a wave arrives")
	var b: Node2D = _main.baddies[0]
	var gap: float = absf(b.position.x - _hero.position.x)
	await until(func() -> bool: return absf(b.position.x - _hero.position.x) < gap - 30.0, "baddie walks closer")

func test_one_sword_swing_hits_once() -> void:
	_main.waves_enabled = false
	var b: Node2D = _main.spawn_baddie(_hero.position + Vector2(100, 0))
	await _swing("sword")
	assert_eq(b.hp, Brain.HP - 1, "hit exactly once")

func test_sword_misses_a_baddie_behind() -> void:
	_main.waves_enabled = false
	var b: Node2D = _main.spawn_baddie(_hero.position + Vector2(-100, 0))
	await _swing("sword")
	assert_eq(b.hp, Brain.HP, "not hit")

func test_hammer_spin_hits_both_sides() -> void:
	_main.waves_enabled = false
	var front: Node2D = _main.spawn_baddie(_hero.position + Vector2(120, 0))
	var back: Node2D = _main.spawn_baddie(_hero.position + Vector2(-120, 0))
	await _swing("hammer")
	assert_eq(front.hp, Brain.HP - 1, "front hit")
	assert_eq(back.hp, Brain.HP - 1, "back hit")

func test_two_hits_sink_it_and_leave_a_gem_to_pick_up() -> void:
	_main.waves_enabled = false
	var b: Node2D = _main.spawn_baddie(_hero.position + Vector2(100, 0))
	await _swing("sword")
	await _swing("sword")
	assert_false(b.alive(), "sinking")
	await until(func() -> bool: return _main.loose_gems.size() == 1, "a gem pops out")
	assert_eq(_main.baddies.size(), 0, "baddie gone")
	assert_eq(_main.fight.gems, 0, "not picked up yet")
	var gem: Node2D = _main.loose_gems[0]
	_hero.position = gem.position
	await until(func() -> bool: return _main.fight.gems == 10, "gem counted, worth 10")
	assert_eq(_main.get_node("%GemLabel").text, "10", "counter shows it")
	assert_eq(_main.loose_gems.size(), 0, "gem gone from the street")

func test_beating_a_wave_brings_the_next() -> void:
	await until(func() -> bool: return _main.baddies.size() == Waves.SIZE, "first wave")
	var first: Array[Node2D] = _main.baddies.duplicate()
	for b: Node2D in first:
		b.take_hit(Brain.HP, 999, b.position.x)
	await until(func() -> bool: return _main.baddies.size() == Waves.SIZE and not first.has(_main.baddies[0]), "second wave", 6.0)
