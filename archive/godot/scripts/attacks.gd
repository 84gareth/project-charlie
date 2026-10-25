extends RefCounted
## Sword and hammer, as pure data and maths.
##   Sword: a quick swing in front of the hero.
##   Hammer: Charlie's "spin hammer attack", hitting all around.
## Positions are feet-on-the-street positions, like the hero's.

const SWORD: String = "sword"
const HAMMER: String = "hammer"

## How long each attack lasts, in seconds. The hero stands still meanwhile.
const DURATION: Dictionary = {SWORD: 0.25, HAMMER: 0.7}
## When during the attack it can hit something: (from, to) in seconds.
const HIT_WINDOW: Dictionary = {SWORD: Vector2(0.05, 0.2), HAMMER: Vector2(0.1, 0.6)}

## The sword reaches this far in front, and this far up or down the street.
const SWORD_REACH: float = 170.0
const SWORD_DEPTH: float = 50.0
## The hammer spin reaches this far all around.
const HAMMER_REACH: float = 190.0
const HAMMER_DEPTH: float = 70.0

## Would this attack hit something standing at `target`?
static func hits(kind: String, hero: Vector2, facing: int, target: Vector2) -> bool:
	var d: Vector2 = target - hero
	match kind:
		SWORD:
			var ahead: float = d.x * facing
			return ahead >= -20.0 and ahead <= SWORD_REACH and absf(d.y) <= SWORD_DEPTH
		HAMMER:
			return absf(d.x) <= HAMMER_REACH and absf(d.y) <= HAMMER_DEPTH
	return false

## One hero's attack in progress: which one, and how far through it is.
class State:
	extends RefCounted

	var kind: String = ""
	var time: float = 0.0

	func busy() -> bool:
		return kind != ""

	## Starts an attack unless one is already going. True if it started.
	func start(new_kind: String) -> bool:
		if busy() or not DURATION.has(new_kind):
			return false
		kind = new_kind
		time = 0.0
		return true

	func update(delta: float) -> void:
		if not busy():
			return
		time += delta
		if time >= DURATION[kind]:
			kind = ""
			time = 0.0

	func can_hit() -> bool:
		if not busy():
			return false
		var w: Vector2 = HIT_WINDOW[kind]
		return time >= w.x and time <= w.y

	## 0 at the start of the attack, nearly 1 at the end; 0 when idle.
	func progress() -> float:
		return time / DURATION[kind] if busy() else 0.0
