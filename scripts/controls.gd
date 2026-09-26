extends RefCounted
## The game's buttons, set up in code so the keyboard and game controllers
## (Xbox and Switch) both work without touching the editor's Input Map.
## Call install() once at startup; calling it again is harmless.
##
## Controllers: the d-pad and the left stick both move. Godot reads Xbox and
## Switch pads through the same standard layout, so one mapping covers both.

## How far the stick must tip before the hero moves.
const DEADZONE: float = 0.3

const MOVES: Dictionary = {
	"move_left": {"keys": [KEY_LEFT, KEY_A], "dpad": JOY_BUTTON_DPAD_LEFT, "axis": JOY_AXIS_LEFT_X, "dir": -1.0},
	"move_right": {"keys": [KEY_RIGHT, KEY_D], "dpad": JOY_BUTTON_DPAD_RIGHT, "axis": JOY_AXIS_LEFT_X, "dir": 1.0},
	"move_up": {"keys": [KEY_UP, KEY_W], "dpad": JOY_BUTTON_DPAD_UP, "axis": JOY_AXIS_LEFT_Y, "dir": -1.0},
	"move_down": {"keys": [KEY_DOWN, KEY_S], "dpad": JOY_BUTTON_DPAD_DOWN, "axis": JOY_AXIS_LEFT_Y, "dir": 1.0},
}

## Any of the four face buttons does something. Godot names them by where
## they sit (A is the bottom one), so on a Switch pad the letters differ
## but the places match: bottom and right swing the sword, left and top
## spin the hammer.
const BUTTONS: Dictionary = {
	"sword": {"keys": [KEY_Z, KEY_J, KEY_SPACE], "pad": [JOY_BUTTON_A, JOY_BUTTON_B]},
	"hammer": {"keys": [KEY_X, KEY_K], "pad": [JOY_BUTTON_X, JOY_BUTTON_Y]},
}

static func install() -> void:
	for action: String in BUTTONS:
		if InputMap.has_action(action):
			InputMap.erase_action(action)
		InputMap.add_action(action)
		var b: Dictionary = BUTTONS[action]
		for keycode: Key in b["keys"]:
			var key := InputEventKey.new()
			key.device = -1
			key.physical_keycode = keycode
			InputMap.action_add_event(action, key)
		for button: JoyButton in b["pad"]:
			var pad := InputEventJoypadButton.new()
			pad.device = -1
			pad.button_index = button
			InputMap.action_add_event(action, pad)
	for action: String in MOVES:
		if InputMap.has_action(action):
			InputMap.erase_action(action)
		InputMap.add_action(action, DEADZONE)
		var m: Dictionary = MOVES[action]
		for keycode: Key in m["keys"]:
			var key := InputEventKey.new()
			key.device = -1
			key.physical_keycode = keycode
			InputMap.action_add_event(action, key)
		var dpad := InputEventJoypadButton.new()
		dpad.device = -1
		dpad.button_index = m["dpad"]
		InputMap.action_add_event(action, dpad)
		var stick := InputEventJoypadMotion.new()
		stick.device = -1
		stick.axis = m["axis"]
		stick.axis_value = m["dir"]
		InputMap.action_add_event(action, stick)
