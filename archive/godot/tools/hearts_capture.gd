extends Node
## Capture helper: two baddies beside a hero with 2 hearts left. They wind
## up and punch; the second punch knocks the hero down, then the fight
## restarts. For a movie-maker run, windowed:
##   Godot --path . --always-on-top --write-movie captures/hearts.png \
##     --fixed-fps 30 --quit-after 150 res://tools/hearts_capture.tscn

func _ready() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	main.mode = "practice"
	add_child(main)
	await get_tree().process_frame
	var hero: Node2D = main.get_node("%Hero")
	hero.position = Vector2(800, 735)
	main.fight.hearts = 2
	main._show_score()
	var a: Node2D = main.spawn_baddie(hero.position + Vector2(110, 0))
	a.punch_wait = 0.4
	var b: Node2D = main.spawn_baddie(hero.position + Vector2(-110, 30), 30.0)
	b.punch_wait = 1.8
