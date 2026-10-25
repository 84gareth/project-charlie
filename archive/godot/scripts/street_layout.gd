extends RefCounted
## Sizes of the city street, in world pixels. The screen is 1600x900; the
## street is three screens long.

const WORLD_WIDTH: int = 4800
const SCREEN_HEIGHT: int = 900

## Where the buildings stop and the pavement starts.
const PAVEMENT_TOP: float = 560.0
## Where the pavement stops and the road starts.
const ROAD_TOP: float = 720.0

## Where the hero's feet may go: the pavement and the road.
const WALK_AREA: Rect2 = Rect2(80.0, 600.0, WORLD_WIDTH - 160.0, 270.0)

const HERO_START: Vector2 = Vector2(420.0, 730.0)
