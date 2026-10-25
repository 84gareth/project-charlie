extends Node2D
## A row of hearts for the HUD: full ones red, lost ones grey. Two rows
## of six so twelve fit comfortably in the corner.

const FULL: Color = Color(0.95, 0.2, 0.3)
const EMPTY: Color = Color(0.82, 0.82, 0.86)
const OUTLINE: Color = Color(0.15, 0.1, 0.25)
const PER_ROW: int = 6
const GAP: float = 46.0

var max_hearts: int = 12:
	set(value):
		max_hearts = value
		queue_redraw()
var hearts: int = 12:
	set(value):
		hearts = value
		queue_redraw()

func _draw() -> void:
	for i: int in max_hearts:
		var at: Vector2 = Vector2((i % PER_ROW) * GAP, floorf(i / float(PER_ROW)) * GAP)
		_heart(at, 1.08, OUTLINE)
		_heart(at, 1.0, FULL if i < hearts else EMPTY)

## A heart centred on `at`: two bumps on top of a point.
func _heart(at: Vector2, s: float, colour: Color) -> void:
	draw_circle(at + Vector2(-9, -6) * s, 11.0 * s, colour)
	draw_circle(at + Vector2(9, -6) * s, 11.0 * s, colour)
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-19.5, -2) * s, at + Vector2(19.5, -2) * s, at + Vector2(0, 20) * s,
	]), colour)
