extends RefCounted
## The start screen's choice, as pure data: two big cards, boy on the left
## and girl on the right, on the 1600x900 screen.

const LOOKS: Array[String] = ["boy", "girl"]
const CARDS: Array[Rect2] = [Rect2(370, 170, 380, 540), Rect2(850, 170, 380, 540)]
## Where each card's hero stands.
const FEET_Y: float = 640.0

## Moving the choice left (-1) or right (+1), stopping at the ends.
static func move(selected: int, dir: int) -> int:
	return clampi(selected + dir, 0, LOOKS.size() - 1)

## Which card is under a screen point, or -1 for none.
static func card_at(point: Vector2) -> int:
	for i: int in CARDS.size():
		if CARDS[i].has_point(point):
			return i
	return -1
