extends RefCounted
## Reads the playtest mode from the command line, as tools/playtest.sh
## passes it after Godot's `--`:  --mode=practice
##   street    the normal game (the default)
##   practice  no baddies: try walking, the sword and the hammer
##   fight     the first wave arrives straight away, close by

const MODES: Array[String] = ["street", "practice", "fight"]
const DEFAULT: String = "street"

static func mode(args: PackedStringArray) -> String:
	for arg: String in args:
		if arg.begins_with("--mode="):
			var m: String = arg.trim_prefix("--mode=")
			return m if MODES.has(m) else DEFAULT
	return DEFAULT
