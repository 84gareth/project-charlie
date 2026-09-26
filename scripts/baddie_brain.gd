extends RefCounted
## How a baddie behaves, as pure numbers and maths: walk up beside the
## hero, now and then wind up a punch (step away in time and it misses);
## two hits and it sinks into the ground.

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

## A punch lands if the hero is this close, along and across the street.
const PUNCH_REACH: Vector2 = Vector2(140.0, 45.0)
## Seconds of wind-up before a punch: long enough to see it and step away.
const WINDUP: float = 0.7
## Seconds the punch pose shows after it's thrown.
const PUNCH_SHOW: float = 0.2
## Seconds between one baddie's punches.
const COOLDOWN: float = 2.5
## Before its first punch: this long, plus STAGGER per place in the wave,
## so a whole wave doesn't punch together.
const FIRST_PUNCH: float = 1.0
const STAGGER: float = 0.8

static func in_reach(me: Vector2, hero: Vector2) -> bool:
	return absf(hero.x - me.x) <= PUNCH_REACH.x and absf(hero.y - me.y) <= PUNCH_REACH.y

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
