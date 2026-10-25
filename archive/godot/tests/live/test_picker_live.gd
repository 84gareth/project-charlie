extends "res://tests/framework/live_case.gd"
## The start screen in the real game: it shows first, nothing happens on
## the street until a hero is picked, and keys, controller or a click
## pick one. The picking press doesn't also swing the sword.

const Choice = preload("res://scripts/hero_choice.gd")
const Waves = preload("res://scripts/waves.gd")

var _main: Node
var _hero: Node2D

func before_each() -> void:
	_main = load("res://scenes/main.tscn").instantiate()
	_main.mode = "street"
	add_child(_main)
	await frames(1)
	_hero = _main.get_node("%Hero")

func after_each() -> void:
	Input.action_release("move_right")
	if is_instance_valid(_main):
		_main.queue_free()
	await frames(1)

func _send(e: InputEvent) -> void:
	Input.parse_input_event(e)
	Input.flush_buffered_events()

func _tap_key(code: Key) -> void:
	for down: bool in [true, false]:
		var e := InputEventKey.new()
		e.physical_keycode = code
		e.pressed = down
		_send(e)

func _tap_pad(button: JoyButton) -> void:
	for down: bool in [true, false]:
		var e := InputEventJoypadButton.new()
		e.button_index = button
		e.pressed = down
		_send(e)

func _board() -> Node2D:
	return _main.get_node("HeroPicker/Board")

func test_picker_shows_first_and_nothing_starts() -> void:
	assert_true(_main.picking, "picking")
	assert_not_null(_board(), "cards on screen")
	var x: float = _hero.position.x
	Input.action_press("move_right")
	await seconds(Waves.PAUSE + 0.3)
	Input.action_release("move_right")
	assert_eq(_hero.position.x, x, "hero waits")
	assert_eq(_main.baddies.size(), 0, "no baddies yet")

func test_right_then_sword_key_picks_the_girl() -> void:
	_tap_key(KEY_RIGHT)
	assert_eq(_board().selected, 1, "girl chosen")
	_tap_key(KEY_Z)
	await until(func() -> bool: return not _main.picking, "picked")
	assert_eq(_main.hero_look, "girl")
	assert_eq(_hero.art.look, "girl", "hero has pigtails")
	assert_false(_hero.attack.busy(), "picking didn't swing the sword")
	await until(func() -> bool: return not is_instance_valid(_main.picker), "picker goes away")
	await until(func() -> bool: return _main.baddies.size() == Waves.SIZE, "the fight begins")

func test_controller_picks_the_boy_straight_away() -> void:
	_tap_pad(JOY_BUTTON_A)
	await until(func() -> bool: return not _main.picking, "picked")
	assert_eq(_hero.art.look, "boy")

func test_controller_dpad_moves_the_choice() -> void:
	_tap_pad(JOY_BUTTON_DPAD_RIGHT)
	assert_eq(_board().selected, 1, "to the girl")
	_tap_pad(JOY_BUTTON_DPAD_LEFT)
	assert_eq(_board().selected, 0, "back to the boy")

func test_clicking_the_girl_card_picks_her() -> void:
	var at: Vector2 = get_viewport().get_final_transform() * Choice.CARDS[1].get_center()
	for down: bool in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.position = at
		e.global_position = at
		e.pressed = down
		_send(e)
	await until(func() -> bool: return not _main.picking, "picked by click")
	assert_eq(_hero.art.look, "girl")

func test_a_chosen_hero_skips_the_picker() -> void:
	var other: Node = load("res://scenes/main.tscn").instantiate()
	other.mode = "street"
	other.hero_look = "girl"
	add_child(other)
	await frames(1)
	assert_false(other.picking, "no picker")
	assert_eq(other.get_node("%Hero").art.look, "girl")
	other.queue_free()
