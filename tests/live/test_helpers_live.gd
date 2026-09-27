extends "res://tests/framework/live_case.gd"
## Helpers in the real game: picking up the gem that reaches 200 brings
## the blue helper, you keep your gems, helpers follow you, stay through a
## fight restart, and the helpers playtest mode brings all three.

const Helpers = preload("res://scripts/helpers.gd")
const FightState = preload("res://scripts/fight_state.gd")

var _main: Node
var _hero: Node2D

func _start(mode: String = "practice") -> void:
	_main = load("res://scenes/main.tscn").instantiate()
	_main.hero_look = "boy"
	_main.mode = mode
	add_child(_main)
	await frames(1)
	_hero = _main.get_node("%Hero")

func after_each() -> void:
	Input.action_release("move_right")
	if is_instance_valid(_main):
		_main.queue_free()
	await frames(1)

func _drop_gem_on_hero() -> void:
	var gem: Node2D = _main.GEM_SCENE.instantiate()
	gem.position = _hero.position
	_main.world.add_child(gem)
	_main.loose_gems.append(gem)

func test_the_gem_that_reaches_200_brings_blue() -> void:
	await _start()
	_main.set_gems(190)
	assert_eq(_main.helpers.size(), 0, "not yet at 190")
	_drop_gem_on_hero()
	await until(func() -> bool: return _main.helpers.size() == 1, "blue joins")
	assert_eq(_main.helpers[0].kind, "blue")
	assert_eq(_main.fight.gems, 200, "gems kept, not spent")
	assert_eq(_main.get_node("%GemLabel").text, "200")

func test_helpers_follow_the_hero() -> void:
	await _start()
	_main.set_gems(200)
	var h: Node2D = _main.helpers[0]
	var start_x: float = h.position.x
	Input.action_press("move_right")
	await seconds(0.8)
	Input.action_release("move_right")
	await until(func() -> bool: return h.position.x > start_x + 150.0, "helper keeps up")
	assert_lt(h.position.x, _hero.position.x, "stays behind the hero")

func test_helpers_mode_brings_all_three() -> void:
	await _start("helpers")
	assert_eq(_main.helpers.size(), 3)
	var kinds: Array[String] = []
	for h: Node2D in _main.helpers:
		kinds.append(h.kind)
	assert_eq(kinds, Helpers.KINDS, "blue, yellow, green")
	assert_gt(_main.baddies.size(), 0, "and a fight")

func test_helpers_stay_when_the_fight_restarts() -> void:
	await _start("street")
	_main.set_gems(500)
	_main.fight.hearts = 1
	var b: Node2D = _main.spawn_baddie(_hero.position + Vector2(110, 0))
	b.punch_wait = 0.0
	await until(func() -> bool: return _hero.down, "hero falls down")
	await until(func() -> bool: return not _hero.down, "back up")
	assert_eq(_main.helpers.size(), 2, "blue and yellow still here")
	for h: Node2D in _main.helpers:
		assert_true(is_instance_valid(h), "not freed")
