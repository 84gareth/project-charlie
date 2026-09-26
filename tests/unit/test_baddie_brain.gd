extends "res://tests/framework/test_case.gd"
## Baddies walk up beside the hero, are slower than the hero, and take two
## hits.

const Brain = preload("res://scripts/baddie_brain.gd")
const Walk = preload("res://scripts/walk.gd")
const Attacks = preload("res://scripts/attacks.gd")

const AREA: Rect2 = Rect2(80.0, 600.0, 4640.0, 270.0)
const HERO: Vector2 = Vector2(1000, 730)

func test_stops_beside_the_hero_on_its_own_side() -> void:
	var from_right: Vector2 = Brain.chase_target(HERO, Vector2(1500, 700), 0.0, AREA)
	assert_eq(from_right, Vector2(HERO.x + Brain.STOP_X, HERO.y), "right side")
	var from_left: Vector2 = Brain.chase_target(HERO, Vector2(400, 700), 0.0, AREA)
	assert_eq(from_left, Vector2(HERO.x - Brain.STOP_X, HERO.y), "left side")

func test_lane_spreads_them_up_and_down() -> void:
	var t: Vector2 = Brain.chase_target(HERO, Vector2(1500, 700), 35.0, AREA)
	assert_eq(t.y, HERO.y + 35.0)

func test_stopping_spot_stays_on_the_street() -> void:
	var t: Vector2 = Brain.chase_target(Vector2(4700, 865), Vector2(4710, 700), 35.0, AREA)
	assert_true(AREA.has_point(t) or t.x == AREA.end.x or t.y == AREA.end.y, "inside the walk area")
	assert_lt(t.y, AREA.end.y + 0.001, "not below the road")

func test_stands_where_the_sword_and_hammer_reach() -> void:
	var spot: Vector2 = Brain.chase_target(HERO, Vector2(1500, 700), 35.0, AREA)
	assert_true(Attacks.hits(Attacks.SWORD, HERO, 1, spot), "sword reaches")
	assert_true(Attacks.hits(Attacks.HAMMER, HERO, 1, spot), "hammer reaches")

func test_walks_toward_target_without_overshooting() -> void:
	var p: Vector2 = Brain.step(Vector2(1000, 700), Vector2(1010, 700), 1.0)
	assert_eq(p, Vector2(1010, 700), "stops on the spot")
	var q: Vector2 = Brain.step(Vector2(1000, 700), Vector2(2000, 700), 0.1)
	assert_almost_eq(q.x, 1000.0 - 0.0 + Brain.SPEED.x * 0.1, 0.001, "moves at its speed")

func test_slower_than_the_hero() -> void:
	assert_lt(Brain.SPEED.x, Walk.SPEED.x, "along the street")
	assert_lt(Brain.SPEED.y, Walk.SPEED.y, "across the street")

func test_can_punch_from_where_it_stands() -> void:
	for lane: float in [-35.0, 0.0, 35.0]:
		var spot: Vector2 = Brain.chase_target(HERO, Vector2(1500, 700), lane, AREA)
		assert_true(Brain.in_reach(spot, HERO), "lane %s" % lane)

func test_punch_misses_if_the_hero_steps_away() -> void:
	assert_false(Brain.in_reach(Vector2(1110, 730), Vector2(1110 - Brain.PUNCH_REACH.x - 10, 730)), "too far along")
	assert_false(Brain.in_reach(Vector2(1110, 730), Vector2(1000, 730 + Brain.PUNCH_REACH.y + 10)), "too far across")

func test_the_wind_up_gives_time_to_dodge() -> void:
	# From the stopping spot, walking away for the whole wind-up gets
	# comfortably out of reach, with room to spare for slow reactions.
	var needed: float = Brain.PUNCH_REACH.x - Brain.STOP_X
	assert_gt(Walk.SPEED.x * Brain.WINDUP, needed * 3.0, "along the street")
	var needed_y: float = Brain.PUNCH_REACH.y + 35.0
	assert_gt(Walk.SPEED.y * Brain.WINDUP, needed_y, "across the street")

func test_punches_are_spaced_out() -> void:
	assert_gt(Brain.COOLDOWN, Brain.WINDUP, "rests between punches")
	assert_gt(Brain.STAGGER, 0.0, "a wave doesn't punch all at once")

func test_two_hits_from_either_weapon() -> void:
	for kind: String in [Attacks.SWORD, Attacks.HAMMER]:
		var dmg: int = Brain.DAMAGE[kind]
		assert_gt(Brain.HP, dmg, "%s: one hit isn't enough" % kind)
		assert_true(dmg * 2 >= Brain.HP, "%s: two hits are" % kind)
