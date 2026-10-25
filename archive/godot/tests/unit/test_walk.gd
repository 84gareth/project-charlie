extends "res://tests/framework/test_case.gd"
## Belt-scroller walking: speeds, diagonals, staying on the street, facing.

const Walk = preload("res://scripts/walk.gd")

const AREA: Rect2 = Rect2(100.0, 600.0, 1000.0, 200.0)

func test_walks_right_at_full_speed() -> void:
	var p: Vector2 = Walk.step(Vector2(500, 700), Vector2.RIGHT, 0.5, AREA)
	assert_almost_eq(p.x, 500.0 + Walk.SPEED.x * 0.5)
	assert_almost_eq(p.y, 700.0)

func test_walks_down_the_street_slower_than_along_it() -> void:
	var along: Vector2 = Walk.step(Vector2(500, 700), Vector2.RIGHT, 0.1, AREA)
	var across: Vector2 = Walk.step(Vector2(500, 700), Vector2.DOWN, 0.1, AREA)
	assert_gt(along.x - 500.0, across.y - 700.0, "along beats across")
	assert_gt(across.y, 700.0, "down means further down the screen")

func test_diagonal_is_not_faster_than_straight() -> void:
	var straight: Vector2 = Walk.step(Vector2(500, 700), Vector2.RIGHT * 3.0, 0.1, AREA)
	assert_almost_eq(straight.x - 500.0, Walk.SPEED.x * 0.1, 0.001, "oversized input is capped")
	var diag: Vector2 = Walk.step(Vector2(500, 700), Vector2(1, 1), 0.1, AREA)
	assert_lt(diag.x - 500.0, Walk.SPEED.x * 0.1, "diagonal x is less than a straight walk")

func test_stays_on_the_street_on_every_side() -> void:
	assert_almost_eq(Walk.step(Vector2(110, 700), Vector2.LEFT, 1.0, AREA).x, AREA.position.x, 0.001, "left edge")
	assert_almost_eq(Walk.step(Vector2(1090, 700), Vector2.RIGHT, 1.0, AREA).x, AREA.end.x, 0.001, "right edge")
	assert_almost_eq(Walk.step(Vector2(500, 610), Vector2.UP, 1.0, AREA).y, AREA.position.y, 0.001, "back of the pavement")
	assert_almost_eq(Walk.step(Vector2(500, 790), Vector2.DOWN, 1.0, AREA).y, AREA.end.y, 0.001, "front of the road")

func test_standing_still_stays_put() -> void:
	assert_eq(Walk.step(Vector2(500, 700), Vector2.ZERO, 1.0, AREA), Vector2(500, 700))

func test_facing_follows_left_and_right_only() -> void:
	assert_eq(Walk.facing(1, -1.0), -1, "walk left, face left")
	assert_eq(Walk.facing(-1, 1.0), 1, "walk right, face right")
	assert_eq(Walk.facing(-1, 0.0), -1, "straight up or down keeps facing")
	assert_eq(Walk.facing(1, 0.05), 1, "a tiny stick wobble keeps facing")
