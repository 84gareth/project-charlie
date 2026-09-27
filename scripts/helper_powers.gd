extends RefCounted
## Charlie's helper powers, as pure numbers and maths.
##   blue   "has waves": sends a wave rolling along the street that knocks
##          every baddie in its path.
##   yellow "has sneaky powers": vanishes, pops up behind a baddie (on the
##          far side from you) and bonks it.
##   green  "has flying powers": flies up and swoops down on a baddie. The
##          level 3 helper, so the strongest: one swoop sinks a baddie.
## And every helper "gives you hearts": one now and then when you've lost
## some.

const COOLDOWN: Dictionary = {"blue": 5.0, "yellow": 4.0, "green": 4.5}
const DAMAGE: Dictionary = {"blue": 1, "yellow": 1, "green": 2}
## Before a helper's first power: this long, plus STAGGER per place in line,
## so they don't all go at once.
const FIRST_WAIT: float = 1.0
const STAGGER: float = 0.8
## Helpers only go for baddies this close to the hero (about on screen).
const RANGE: float = 700.0

const WAVE_SPEED: float = 650.0
const WAVE_LENGTH: float = 900.0
## A wave knocks baddies this far up or down the street from its line.
const WAVE_DEPTH: float = 70.0

## How far behind a baddie the sneaky helper pops up.
const SNEAK_GAP: float = 75.0
## How high the flying helper goes on its way to a baddie.
const FLY_HEIGHT: float = 220.0

## Seconds between one helper's hearts.
const HEAL_EVERY: float = 15.0

## The nearest target (by street distance to the hero) within RANGE, as an
## index into `targets`, or -1 if none.
static func pick_target(hero: Vector2, targets: Array[Vector2]) -> int:
	var best: int = -1
	var best_d: float = INF
	for i: int in targets.size():
		var d: float = absf(targets[i].x - hero.x)
		if d <= RANGE and d < best_d:
			best = i
			best_d = d
	return best

## Did a wave that just moved from `prev_x` to `now_x` along the line
## `wave_y` pass over something standing at `target`?
static func wave_hits(prev_x: float, now_x: float, wave_y: float, target: Vector2) -> bool:
	var lo: float = minf(prev_x, now_x)
	var hi: float = maxf(prev_x, now_x)
	return target.x >= lo and target.x <= hi and absf(target.y - wave_y) <= WAVE_DEPTH

## Where the sneaky helper pops up: just behind the baddie, on the side
## away from the hero, kept on the street.
static func sneak_spot(target: Vector2, hero: Vector2, area: Rect2) -> Vector2:
	var away: float = 1.0 if target.x >= hero.x else -1.0
	var p: Vector2 = target + Vector2(away * SNEAK_GAP, 0.0)
	return Vector2(clampf(p.x, area.position.x, area.end.x), clampf(p.y, area.position.y, area.end.y))

## The flying helper's path from `from` to `to`: t runs 0 to 1, rising to
## FLY_HEIGHT above the higher end halfway.
static func fly_arc(from: Vector2, to: Vector2, t: float) -> Vector2:
	var p: Vector2 = from.lerp(to, t)
	p.y -= sin(t * PI) * FLY_HEIGHT
	return p
