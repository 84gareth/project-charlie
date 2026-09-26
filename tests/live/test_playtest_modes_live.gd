extends "res://tests/framework/live_case.gd"
## The playtest modes do what tools/playtest.sh promises.

const Waves = preload("res://scripts/waves.gd")

var _main: Node

func after_each() -> void:
	if is_instance_valid(_main):
		_main.queue_free()
	await frames(1)

func _start(mode: String) -> void:
	_main = load("res://scenes/main.tscn").instantiate()
	_main.mode = mode
	add_child(_main)
	await frames(1)

func test_practice_has_no_baddies() -> void:
	await _start("practice")
	await seconds(Waves.PAUSE + 0.5)
	assert_eq(_main.baddies.size(), 0, "still no baddies after the wave pause")

func test_fight_brings_baddies_straight_away_and_on_screen() -> void:
	await _start("fight")
	assert_eq(_main.baddies.size(), Waves.SIZE, "a wave at once")
	var hero: Node2D = _main.get_node("%Hero")
	for b: Node2D in _main.baddies:
		assert_lt(absf(b.position.x - hero.position.x), 800.0, "on screen: %s" % b.position)

func test_street_waits_for_the_first_wave() -> void:
	await _start("street")
	assert_eq(_main.baddies.size(), 0, "none yet")
	await until(func() -> bool: return _main.baddies.size() == Waves.SIZE, "first wave comes")
