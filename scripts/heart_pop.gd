extends Node2D
## A heart that pops up over a helper when it gives you one, floats up
## and fades away.

const RED: Color = Color(0.95, 0.2, 0.3)
const LIFE: float = 1.0

var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	if _time >= LIFE:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var t: float = _time / LIFE
	var c: Color = RED * Color(1, 1, 1, 1.0 - t * t)
	var at: Vector2 = Vector2(0, -60.0 * t)
	var s: float = 1.2 + 0.4 * sin(minf(t * 3.0, 1.0) * PI)
	draw_circle(at + Vector2(-9, -6) * s, 11.0 * s, c)
	draw_circle(at + Vector2(9, -6) * s, 11.0 * s, c)
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-19.5, -2) * s, at + Vector2(19.5, -2) * s, at + Vector2(0, 20) * s,
	]), c)
