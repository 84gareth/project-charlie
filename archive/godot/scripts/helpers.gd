extends RefCounted
## Charlie's helpers, as pure data and maths. Three of them, level 1 to 3:
## blue (waves), yellow (sneaky) and green (flying). Each joins when your
## gem total reaches its number, you keep your gems, and every helper you
## have comes along, following close behind you.

const KINDS: Array[String] = ["blue", "yellow", "green"]
const UNLOCK: Dictionary = {"blue": 200, "yellow": 500, "green": 700}
const POWER: Dictionary = {"blue": "wave", "yellow": "sneaky", "green": "flying"}
const TEXTURE: Dictionary = {
	"blue": "res://assets/helpers/helper1_blue.png",
	"yellow": "res://assets/helpers/helper2_yellow.png",
	"green": "res://assets/helpers/helper3_green.png",
}
## Sprite scale (the renders are 512 px): each level a little bigger.
const SCALE: Dictionary = {"blue": 0.3, "yellow": 0.36, "green": 0.4}

## Where each helper keeps to, relative to the hero facing right: behind
## the hero, spread along and across the street so they don't stack.
const SPOTS: Array[Vector2] = [Vector2(-150, -55), Vector2(-150, 75), Vector2(-290, 10)]
## Following speed: never slower than this, faster the further behind.
const FOLLOW_SPEED: float = 300.0
const CATCH_UP: float = 3.0

## Every helper your gem total has earned, in level order.
static func unlocked(gems: int) -> Array[String]:
	var out: Array[String] = []
	for k: String in KINDS:
		if gems >= UNLOCK[k]:
			out.append(k)
	return out

## Helpers that join as the gem total goes from `before` to `after`.
static func newly_unlocked(before: int, after: int) -> Array[String]:
	var out: Array[String] = []
	for k: String in KINDS:
		if before < UNLOCK[k] and after >= UNLOCK[k]:
			out.append(k)
	return out

## Where helper number `index` wants to be, kept on the street.
static func follow_spot(hero: Vector2, facing: int, index: int, area: Rect2) -> Vector2:
	var s: Vector2 = SPOTS[index % SPOTS.size()]
	var p: Vector2 = hero + Vector2(s.x * facing, s.y)
	return Vector2(clampf(p.x, area.position.x, area.end.x), clampf(p.y, area.position.y, area.end.y))

## One frame of following, never overshooting.
static func follow_step(me: Vector2, target: Vector2, delta: float) -> Vector2:
	var speed: float = maxf(FOLLOW_SPEED, me.distance_to(target) * CATCH_UP)
	return me.move_toward(target, speed * delta)
