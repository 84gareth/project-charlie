extends Node2D
## Placeholder baddie: a blocky purple monster with horns, feet at (0, 0),
## facing right. Made only of rectangles so sinking can cut off whatever
## has gone below the street. Real art (and more kinds) comes later.

const BODY: Color = Color(0.55, 0.3, 0.7)
const BELLY: Color = Color(0.72, 0.5, 0.85)
const HORN: Color = Color(0.98, 0.9, 0.6)
const EYE: Color = Color(1, 1, 1)
const PUPIL: Color = Color(0.1, 0.1, 0.1)
const FEET: Color = Color(0.35, 0.18, 0.45)

## The monster as rectangles, standing on y = 0.
const PARTS: Array = [
	[Rect2(-30, -24, 22, 24), FEET],
	[Rect2(8, -24, 22, 24), FEET],
	[Rect2(-40, -130, 80, 110), BODY],
	[Rect2(-24, -95, 48, 60), BELLY],
	[Rect2(-36, -150, 14, 22), HORN],
	[Rect2(22, -150, 14, 22), HORN],
	[Rect2(4, -118, 22, 22), EYE],
	[Rect2(16, -112, 9, 11), PUPIL],
	[Rect2(-20, -118, 18, 18), EYE],
	[Rect2(-8, -112, 8, 10), PUPIL],
]
const HEIGHT: float = 150.0

## 1 is right, -1 is left.
var facing: int = 1:
	set(value):
		facing = value
		scale.x = value
## True while wobbling from a hit.
var hurt: bool = false
## 0 standing, 1 all the way into the ground.
var sink: float = 0.0

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var down: float = sink * HEIGHT
	# Shadow, turning into a hole as it sinks.
	var hole: Color = Color(0, 0, 0, 0.28).lerp(Color(0.1, 0.08, 0.12, 0.9), sink)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, 48.0 + sink * 10.0, hole)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var wobble: float = sin(Time.get_ticks_msec() * 0.06) * 6.0 if hurt else 0.0
	var street: Rect2 = Rect2(-500, -500, 1000, 500)  # everything above y = 0
	for part: Array in PARTS:
		var r: Rect2 = (part[0] as Rect2)
		r.position += Vector2(wobble, down)
		r = r.intersection(street)
		if r.has_area():
			var c: Color = part[1]
			draw_rect(r, c.lerp(Color.WHITE, 0.6) if hurt else c)
