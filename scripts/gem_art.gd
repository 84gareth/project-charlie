extends Node2D
## A shiny gem: a pink diamond with a sparkle. Bobs gently when lying on
## the street; sits still when used as the gem counter's picture.

const FACE: Color = Color(0.98, 0.35, 0.65)
const LIGHT: Color = Color(1.0, 0.7, 0.85)
const SHINE: Color = Color(1, 1, 1, 0.9)

@export var bob: bool = true
@export var size: float = 1.0

func _process(_delta: float) -> void:
	if bob:
		queue_redraw()

func _draw() -> void:
	var lift: float = 0.0
	if bob:
		lift = 30.0 + sin(Time.get_ticks_msec() * 0.005) * 8.0
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.3))
		draw_circle(Vector2.ZERO, 22.0, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2(0, -lift), 0.0, Vector2.ONE * size)
	var top := Vector2(0, -26)
	var left := Vector2(-22, -6)
	var right := Vector2(22, -6)
	var bottom := Vector2(0, 26)
	draw_colored_polygon(PackedVector2Array([top, right, bottom, left]), FACE)
	draw_colored_polygon(PackedVector2Array([top, right, Vector2(0, -6), left]), LIGHT)
	draw_circle(Vector2(-7, -14), 4.0, SHINE)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
