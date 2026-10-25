extends "res://tests/framework/test_case.gd"
## Waves arrive from just off-screen, spread out, and never off the street.

const Waves = preload("res://scripts/waves.gd")

const AREA: Rect2 = Rect2(80.0, 600.0, 4640.0, 270.0)
const HALF_SCREEN: float = 800.0

func test_a_wave_is_three_baddies() -> void:
	assert_eq(Waves.spawn_points(2400.0, AREA).size(), Waves.SIZE)
	assert_eq(Waves.SIZE, 3)

func test_mid_street_they_come_from_both_sides_out_of_view() -> void:
	var pts: Array[Vector2] = Waves.spawn_points(2400.0, AREA)
	var left: int = 0
	var right: int = 0
	for p: Vector2 in pts:
		assert_gt(absf(p.x - 2400.0), HALF_SCREEN, "out of view: %s" % p)
		if p.x < 2400.0:
			left += 1
		else:
			right += 1
	assert_gt(left, 0, "some from the left")
	assert_gt(right, 0, "some from the right")

func test_at_the_start_of_the_street_they_all_come_from_the_right() -> void:
	for p: Vector2 in Waves.spawn_points(300.0, AREA):
		assert_gt(p.x, 300.0 + HALF_SCREEN, "from the right and out of view: %s" % p)

func test_at_the_end_of_the_street_they_all_come_from_the_left() -> void:
	for p: Vector2 in Waves.spawn_points(4600.0, AREA):
		assert_lt(p.x, 4600.0 - HALF_SCREEN, "from the left and out of view: %s" % p)

func test_always_on_the_street_and_spread_up_and_down() -> void:
	var ys: Dictionary = {}
	for p: Vector2 in Waves.spawn_points(2400.0, AREA):
		assert_true(p.x >= AREA.position.x and p.x <= AREA.end.x, "along: %s" % p)
		assert_true(p.y >= AREA.position.y and p.y <= AREA.end.y, "across: %s" % p)
		ys[p.y] = true
	assert_eq(ys.size(), Waves.SIZE, "each on its own lane")
