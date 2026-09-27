extends RefCounted
## Reads playtest options from the command line, as tools/playtest.sh
## passes them after Godot's `--`:  --mode=fight --hero=girl
##   street    the normal game (the default), starting at the hero picker
##   practice  no baddies: try walking, the sword and the hammer
##   fight     the first wave arrives straight away, close by
##   helpers   start with 700 gems (all three helpers), then a close wave
## --hero=boy|girl skips the picker (every mode but street skips it
## anyway, as the boy unless told otherwise).

const MODES: Array[String] = ["street", "practice", "fight", "helpers"]
const DEFAULT: String = "street"
const LOOKS: Array[String] = ["boy", "girl"]

static func mode(args: PackedStringArray) -> String:
	var m: String = _value(args, "--mode=")
	return m if MODES.has(m) else DEFAULT

## "boy" or "girl" if asked for, otherwise "".
static func hero(args: PackedStringArray) -> String:
	var h: String = _value(args, "--hero=")
	return h if LOOKS.has(h) else ""

static func _value(args: PackedStringArray, prefix: String) -> String:
	for arg: String in args:
		if arg.begins_with(prefix):
			return arg.trim_prefix(prefix)
	return ""
