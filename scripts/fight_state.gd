extends RefCounted
## The hero's side of the fight, as pure logic: hearts and gems.
## Charlie chose 12 hearts. Running out restarts the fight, and you keep
## your gems (Gareth's decision).

const MAX_HEARTS: int = 12
## Seconds after a hit when nothing can hurt you again, so a crowd can't
## take several hearts at once.
const SAFE_TIME: float = 1.0

var hearts: int = MAX_HEARTS
var gems: int = 0

var _safe: float = 0.0

## A baddie's punch landed. True if it cost a heart.
func take_hit() -> bool:
	if _safe > 0.0 or hearts <= 0:
		return false
	hearts -= 1
	_safe = SAFE_TIME
	return true

func update(delta: float) -> void:
	_safe = maxf(0.0, _safe - delta)

func is_safe() -> bool:
	return _safe > 0.0

func out_of_hearts() -> bool:
	return hearts <= 0

func add_gem() -> void:
	gems += 1

## Hearts back to full; gems kept.
func restart_fight() -> void:
	hearts = MAX_HEARTS
	_safe = SAFE_TIME
