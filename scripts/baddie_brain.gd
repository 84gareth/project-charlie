extends RefCounted
## How a baddie behaves, as pure numbers and maths: walk up beside the
## hero and wait there; two hits and it sinks into the ground.
## (Hitting back comes in Phase 2, step 4.)

## Pixels per second; slower than the hero so Charlie can get away.
const SPEED: Vector2 = Vector2(150.0, 110.0)
## How far in front of the hero a baddie stops: inside sword reach.
const STOP_X: float = 110.0
const HP: int = 2
const DAMAGE: Dictionary = {"sword": 1, "hammer": 1}
## Seconds of wobble after being hit.
const HURT_TIME: float = 0.25
## Seconds to sink into the ground.
const SINK_TIME: float = 0.8
## How far a hit pushes a baddie away.
const KNOCKBACK: float = 40.0

## Where a baddie wants to stand: beside the hero on the side it's already
## on, shifted by its `lane` so a crowd doesn't stack in one spot.
static func chase_target(hero: Vector2, me: Vector2, lane: float, area: Rect2) -> Vector2:
	var side: float = 1.0 if me.x >= hero.x else -1.0
	var t: Vector2 = Vector2(hero.x + side * STOP_X, hero.y + lane)
	return Vector2(clampf(t.x, area.position.x, area.end.x), clampf(t.y, area.position.y, area.end.y))

## One frame of walking toward `target`, never overshooting it.
static func step(me: Vector2, target: Vector2, delta: float) -> Vector2:
	return Vector2(
		move_toward(me.x, target.x, SPEED.x * delta),
		move_toward(me.y, target.y, SPEED.y * delta))
