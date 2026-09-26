extends Node
## Capture helper: three baddies walk up, two hammer spins sink them, gems
## pop out and the hero walks over them. For a movie-maker run, windowed:
##   Godot --path . --always-on-top --write-movie captures/fight.png \
##     --fixed-fps 30 --quit-after 150 res://tools/fight_capture.tscn

func _ready() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	add_child(main)
	main.waves_enabled = false
	await get_tree().process_frame
	var hero: Node2D = main.get_node("%Hero")
	hero.position = Vector2(800, 735)
	main.spawn_baddie(hero.position + Vector2(330, 0), 0.0)
	main.spawn_baddie(hero.position + Vector2(-300, 0), 35.0)
	main.spawn_baddie(hero.position + Vector2(420, 0), -35.0)
	await get_tree().create_timer(1.8).timeout
	_tap("hammer")
	await get_tree().create_timer(0.9).timeout
	_tap("hammer")
	await get_tree().create_timer(1.3).timeout
	Input.action_press("move_right")

func _tap(action: String) -> void:
	for down: bool in [true, false]:
		var e := InputEventAction.new()
		e.action = action
		e.pressed = down
		Input.parse_input_event(e)
