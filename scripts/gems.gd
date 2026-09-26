extends RefCounted
## Picking up gems: walk onto one and it's yours.

## How close the hero's feet must be, along and across the street.
const PICKUP: Vector2 = Vector2(70.0, 45.0)

static func touching(hero: Vector2, gem: Vector2) -> bool:
	return absf(gem.x - hero.x) <= PICKUP.x and absf(gem.y - hero.y) <= PICKUP.y
