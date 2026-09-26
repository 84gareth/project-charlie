extends Node2D
## Placeholder hero made of simple shapes, feet at (0, 0), facing right.
## Real art comes after Charlie has played the touch test.

const SKIN: Color = Color(0.96, 0.78, 0.62)
const SHIRT: Color = Color(0.15, 0.55, 0.95)
const TROUSERS: Color = Color(0.2, 0.22, 0.35)
const SHOES: Color = Color(0.1, 0.1, 0.12)
const HAIR: Color = Color(0.4, 0.25, 0.12)

## 1 is right, -1 is left.
var facing: int = 1:
	set(value):
		facing = value
		scale.x = value
var moving: bool = false

var _step_time: float = 0.0

func _process(delta: float) -> void:
	_step_time = _step_time + delta * 12.0 if moving else 0.0
	queue_redraw()

func _draw() -> void:
	# Shadow on the street.
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, 44.0, Color(0, 0, 0, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var swing: float = sin(_step_time) * 14.0
	# Back leg, then front leg.
	draw_rect(Rect2(-20.0 - swing, -64.0, 16.0, 58.0), TROUSERS)
	draw_rect(Rect2(-24.0 - swing, -8.0, 24.0, 8.0), SHOES)
	draw_rect(Rect2(4.0 + swing, -64.0, 16.0, 58.0), TROUSERS)
	draw_rect(Rect2(4.0 + swing, -8.0, 24.0, 8.0), SHOES)
	# Body and arm.
	draw_rect(Rect2(-28.0, -138.0, 56.0, 78.0), SHIRT)
	draw_rect(Rect2(-8.0 - swing * 0.6, -130.0, 16.0, 56.0), SHIRT.darkened(0.2))
	draw_circle(Vector2(-swing * 0.6, -72.0), 9.0, SKIN)
	# Head, hair and eye.
	draw_circle(Vector2(0.0, -168.0), 30.0, SKIN)
	draw_rect(Rect2(-32.0, -202.0, 58.0, 20.0), HAIR)
	draw_circle(Vector2(14.0, -172.0), 4.5, Color.BLACK)
