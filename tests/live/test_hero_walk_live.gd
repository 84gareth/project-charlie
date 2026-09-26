extends "res://tests/framework/live_case.gd"
## The hero walks in the real game when a key, d-pad or stick is pushed,
## and never walks off the street.

const Layout = preload("res://scripts/street_layout.gd")

var _main: Node
var _hero: Node2D

func before_each() -> void:
	_main = load("res://scenes/main.tscn").instantiate()
	add_child(_main)
	await frames(1)
	_hero = _main.get_node("%Hero")

func after_each() -> void:
	_release_everything()
	if is_instance_valid(_main):
		_main.queue_free()
	await frames(1)

func _release_everything() -> void:
	for action: String in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(action)
	_send(_stick(JOY_AXIS_LEFT_X, 0.0))
	_send(_stick(JOY_AXIS_LEFT_Y, 0.0))

func _send(e: InputEvent) -> void:
	Input.parse_input_event(e)
	Input.flush_buffered_events()

func _key(code: Key, down: bool) -> InputEventKey:
	var e := InputEventKey.new()
	e.physical_keycode = code
	e.pressed = down
	return e

func _pad(button: JoyButton, down: bool) -> InputEventJoypadButton:
	var e := InputEventJoypadButton.new()
	e.button_index = button
	e.pressed = down
	return e

func _stick(axis: JoyAxis, value: float) -> InputEventJoypadMotion:
	var e := InputEventJoypadMotion.new()
	e.axis = axis
	e.axis_value = value
	return e

func test_right_arrow_walks_right_and_faces_right() -> void:
	var start_x: float = _hero.position.x
	_send(_key(KEY_RIGHT, true))
	await until(func() -> bool: return _hero.position.x > start_x + 20.0, "hero walks right")
	_send(_key(KEY_RIGHT, false))
	assert_eq(_hero.facing, 1)

func test_controller_stick_walks_left_and_turns_around() -> void:
	var start_x: float = _hero.position.x
	_send(_stick(JOY_AXIS_LEFT_X, -1.0))
	await until(func() -> bool: return _hero.position.x < start_x - 20.0, "hero walks left")
	assert_eq(_hero.facing, -1, "faces left")

func test_controller_dpad_walks_up_the_street() -> void:
	var start_y: float = _hero.position.y
	_send(_pad(JOY_BUTTON_DPAD_UP, true))
	await until(func() -> bool: return _hero.position.y < start_y - 20.0, "hero walks up")
	_send(_pad(JOY_BUTTON_DPAD_UP, false))

func test_cannot_walk_off_the_left_end() -> void:
	_hero.position = Vector2(Layout.WALK_AREA.position.x + 5.0, 700.0)
	_send(_key(KEY_LEFT, true))
	await seconds(0.3)
	_send(_key(KEY_LEFT, false))
	assert_eq(_hero.position.x, Layout.WALK_AREA.position.x, "stopped at the end of the street")
