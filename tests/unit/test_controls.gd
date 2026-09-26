extends "res://tests/framework/test_case.gd"
## Keyboard, d-pad and stick all map to the four walk directions.

const Controls = preload("res://scripts/controls.gd")

func before_each() -> void:
	Controls.install()

func _key(code: Key) -> InputEventKey:
	var e := InputEventKey.new()
	e.physical_keycode = code
	e.pressed = true
	return e

func _pad(button: JoyButton) -> InputEventJoypadButton:
	var e := InputEventJoypadButton.new()
	e.button_index = button
	e.pressed = true
	return e

func _stick(axis: JoyAxis, value: float) -> InputEventJoypadMotion:
	var e := InputEventJoypadMotion.new()
	e.axis = axis
	e.axis_value = value
	return e

func test_arrow_keys_and_wasd_walk() -> void:
	assert_true(InputMap.event_is_action(_key(KEY_LEFT), "move_left"), "left arrow")
	assert_true(InputMap.event_is_action(_key(KEY_D), "move_right"), "D")
	assert_true(InputMap.event_is_action(_key(KEY_UP), "move_up"), "up arrow")
	assert_true(InputMap.event_is_action(_key(KEY_S), "move_down"), "S")
	assert_false(InputMap.event_is_action(_key(KEY_LEFT), "move_right"), "left arrow is not right")

func test_controller_dpad_walks() -> void:
	assert_true(InputMap.event_is_action(_pad(JOY_BUTTON_DPAD_LEFT), "move_left"))
	assert_true(InputMap.event_is_action(_pad(JOY_BUTTON_DPAD_RIGHT), "move_right"))
	assert_true(InputMap.event_is_action(_pad(JOY_BUTTON_DPAD_UP), "move_up"))
	assert_true(InputMap.event_is_action(_pad(JOY_BUTTON_DPAD_DOWN), "move_down"))

func test_controller_stick_walks_the_right_way() -> void:
	# is_action_pressed, not event_is_action: Godot says any push on an axis
	# "matches" both directions; only the pressed check looks at the sign.
	assert_true(_stick(JOY_AXIS_LEFT_X, -1.0).is_action_pressed("move_left"), "stick left")
	assert_true(_stick(JOY_AXIS_LEFT_X, 1.0).is_action_pressed("move_right"), "stick right")
	assert_true(_stick(JOY_AXIS_LEFT_Y, -1.0).is_action_pressed("move_up"), "stick up")
	assert_true(_stick(JOY_AXIS_LEFT_Y, 1.0).is_action_pressed("move_down"), "stick down")
	assert_false(_stick(JOY_AXIS_LEFT_X, 1.0).is_action_pressed("move_left"), "stick right is not left")
	assert_false(_stick(JOY_AXIS_LEFT_X, -0.1).is_action_pressed("move_left"), "a tiny wobble is ignored")

func test_installing_twice_does_not_double_up() -> void:
	var before: int = InputMap.action_get_events("move_left").size()
	Controls.install()
	assert_eq(InputMap.action_get_events("move_left").size(), before)
