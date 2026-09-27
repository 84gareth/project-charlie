extends "res://tests/framework/live_case.gd"
## In the real game, the sword and hammer buttons start attacks, the hero
## stands still while attacking, and walks again afterwards.

const Attacks = preload("res://scripts/attacks.gd")

var _main: Node
var _hero: Node2D
var _started: Array[String] = []

func before_each() -> void:
	_main = load("res://scenes/main.tscn").instantiate()
	_main.hero_look = "boy"
	add_child(_main)
	await frames(1)
	_hero = _main.get_node("%Hero")
	_hero.attack_started.connect(func(kind: String) -> void: _started.append(kind))

func after_each() -> void:
	for action: String in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(action)
	if is_instance_valid(_main):
		_main.queue_free()
	await frames(1)

func _send(e: InputEvent) -> void:
	Input.parse_input_event(e)
	Input.flush_buffered_events()

func _tap_key(code: Key) -> void:
	var down := InputEventKey.new()
	down.physical_keycode = code
	down.pressed = true
	_send(down)
	var up := InputEventKey.new()
	up.physical_keycode = code
	_send(up)

func _tap_pad(button: JoyButton) -> void:
	var down := InputEventJoypadButton.new()
	down.button_index = button
	down.pressed = true
	_send(down)
	var up := InputEventJoypadButton.new()
	up.button_index = button
	_send(up)

func test_z_swings_the_sword() -> void:
	_tap_key(KEY_Z)
	await until(func() -> bool: return _hero.attack.kind == Attacks.SWORD, "sword swing")
	assert_eq(_started, [Attacks.SWORD] as Array[String])
	await until(func() -> bool: return not _hero.attack.busy(), "swing ends")

func test_controller_left_button_spins_the_hammer() -> void:
	_tap_pad(JOY_BUTTON_X)
	await until(func() -> bool: return _hero.attack.kind == Attacks.HAMMER, "hammer spin")
	assert_eq(_started, [Attacks.HAMMER] as Array[String])

func test_hero_stands_still_while_spinning_then_walks_again() -> void:
	Input.action_press("move_right")
	_tap_key(KEY_X)
	await until(func() -> bool: return _hero.attack.busy(), "spin starts")
	var x: float = _hero.position.x
	await seconds(0.3)
	assert_eq(_hero.position.x, x, "no walking mid-spin")
	await until(func() -> bool: return not _hero.attack.busy(), "spin ends")
	await until(func() -> bool: return _hero.position.x > x + 20.0, "walks again after")

func test_mashing_during_a_spin_does_not_restart_it() -> void:
	_tap_key(KEY_X)
	await until(func() -> bool: return _hero.attack.busy(), "spin starts")
	_tap_key(KEY_Z)
	_tap_key(KEY_X)
	await frames(2)
	assert_eq(_started.size(), 1, "only the first press counts")
	assert_eq(_hero.attack.kind, Attacks.HAMMER, "still the hammer")
