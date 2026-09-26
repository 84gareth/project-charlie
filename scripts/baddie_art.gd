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

## The fist: resting at its side, pulled back while winding up (so Charlie
## can see a punch coming), and thrown forward for the punch.
const FIST_REST: Rect2 = Rect2(34, -78, 22, 22)
const FIST_BACK: Rect2 = Rect2(-66, -112, 26, 26)
const FIST_OUT: Rect2 = Rect2(38, -96, 36, 26)
const WINDUP_TINT: Color = Color(1.0, 0.45, 0.3)

## 1 is right, -1 is left.
var facing: int = 1:
	set(value):
		facing = value
		scale.x = value
## True while wobbling from a hit.
var hurt: bool = false
## "" normally, "windup" before a punch, "punch" as it's thrown.
var pose: String = ""
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

	var wobble: float = 0.0
	if hurt:
		wobble = sin(Time.get_ticks_msec() * 0.06) * 6.0
	elif pose == "windup":
		wobble = sin(Time.get_ticks_msec() * 0.04) * 3.0 - 6.0
	var fist: Rect2 = FIST_REST
	if pose == "windup":
		fist = FIST_BACK
	elif pose == "punch":
		fist = FIST_OUT
	var street: Rect2 = Rect2(-500, -500, 1000, 500)  # everything above y = 0
	for part: Array in PARTS + [[fist, BODY.darkened(0.15)]]:
		var r: Rect2 = (part[0] as Rect2)
		r.position += Vector2(wobble, down)
		r = r.intersection(street)
		if r.has_area():
			var c: Color = part[1]
			if hurt:
				c = c.lerp(Color.WHITE, 0.6)
			elif pose == "windup":
				c = c.lerp(WINDUP_TINT, 0.35)
			draw_rect(r, c)
