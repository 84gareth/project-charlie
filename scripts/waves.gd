extends RefCounted
## Where each wave of baddies comes from: just off-screen, from both sides
## when there's room, never off the ends of the street.

const SIZE: int = 3
## Half a screen (800 px) plus a bit, so they walk in from out of view.
const OFFSCREEN: float = 950.0
## Up-and-down offsets, so a wave spreads across the street.
const LANES: Array[float] = [-35.0, 0.0, 35.0]
## Seconds between beating a wave and the next one arriving.
const PAUSE: float = 1.5

static func spawn_points(hero_x: float, area: Rect2, count: int = SIZE) -> Array[Vector2]:
	var out: Array[Vector2] = []
	var mid_y: float = area.get_center().y
	for i: int in count:
		var side: float = 1.0 if i % 2 == 0 else -1.0
		var dist: float = OFFSCREEN + i * 60.0
		var x: float = hero_x + side * dist
		if x < area.position.x or x > area.end.x:
			x = hero_x - side * dist
		x = clampf(x, area.position.x, area.end.x)
		out.append(Vector2(x, mid_y + LANES[i % LANES.size()]))
	return out

## The lane a baddie keeps while chasing.
static func lane(i: int) -> float:
	return LANES[i % LANES.size()]
