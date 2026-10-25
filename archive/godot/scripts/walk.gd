extends RefCounted
## Belt-scroller walking, as pure maths: left and right along the street,
## up and down across it (slower, like Rita's Rewind and Streets of Rage),
## never leaving the walkable part of the street.

## Pixels per second. Across the street is slower than along it.
const SPEED: Vector2 = Vector2(420.0, 260.0)

## Where the hero's feet end up after walking `dir` (a stick or d-pad
## vector, length 0 to 1) for `delta` seconds, kept inside `area`.
static func step(pos: Vector2, dir: Vector2, delta: float, area: Rect2) -> Vector2:
	var next: Vector2 = pos + dir.limit_length(1.0) * SPEED * delta
	return Vector2(
		clampf(next.x, area.position.x, area.end.x),
		clampf(next.y, area.position.y, area.end.y))

## Which way the hero faces: 1 is right, -1 is left. Walking straight up or
## down keeps the old facing.
static func facing(current: int, dir_x: float) -> int:
	if dir_x > 0.1:
		return 1
	if dir_x < -0.1:
		return -1
	return current
