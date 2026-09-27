extends "res://tests/framework/test_case.gd"
## Helper powers: who they go for, what a wave knocks, where the sneaky
## one pops up, the flying one's path, green the strongest, and hearts.

const Powers = preload("res://scripts/helper_powers.gd")
const Brain = preload("res://scripts/baddie_brain.gd")
const FightState = preload("res://scripts/fight_state.gd")

const AREA: Rect2 = Rect2(80.0, 600.0, 4640.0, 270.0)
const HERO: Vector2 = Vector2(2000, 730)

func test_goes_for_the_nearest_baddie() -> void:
	var spots: Array[Vector2] = [Vector2(2400, 730), Vector2(1850, 700), Vector2(2600, 760)]
	assert_eq(Powers.pick_target(HERO, spots), 1, "the one 150 away")

func test_ignores_baddies_far_away() -> void:
	var spots: Array[Vector2] = [Vector2(HERO.x + Powers.RANGE + 10.0, 730)]
	assert_eq(Powers.pick_target(HERO, spots), -1)
	assert_eq(Powers.pick_target(HERO, [] as Array[Vector2]), -1, "none at all")

func test_a_wave_knocks_what_it_rolls_over() -> void:
	assert_true(Powers.wave_hits(1000.0, 1012.0, 730.0, Vector2(1005, 730)), "rolled over it")
	assert_true(Powers.wave_hits(1012.0, 1000.0, 730.0, Vector2(1005, 760)), "rolling left, a bit down the street")
	assert_false(Powers.wave_hits(1000.0, 1012.0, 730.0, Vector2(1020, 730)), "not reached yet")
	assert_false(Powers.wave_hits(1000.0, 1012.0, 730.0, Vector2(1005, 730 + Powers.WAVE_DEPTH + 5)), "too far across")

func test_sneaky_pops_up_on_the_far_side() -> void:
	var right: Vector2 = Powers.sneak_spot(Vector2(2200, 730), HERO, AREA)
	assert_gt(right.x, 2200.0, "baddie to the right: pops up further right")
	var left: Vector2 = Powers.sneak_spot(Vector2(1800, 730), HERO, AREA)
	assert_lt(left.x, 1800.0, "baddie to the left: pops up further left")
	var edge: Vector2 = Powers.sneak_spot(Vector2(AREA.end.x - 10, 730), HERO, AREA)
	assert_eq(edge.x, AREA.end.x, "never off the street")

func test_flying_goes_up_and_lands_on_the_spot() -> void:
	var from: Vector2 = Vector2(1000, 730)
	var to: Vector2 = Vector2(1400, 700)
	assert_eq(Powers.fly_arc(from, to, 0.0), from, "starts at home")
	assert_true(Powers.fly_arc(from, to, 1.0).is_equal_approx(to), "lands on the baddie")
	assert_lt(Powers.fly_arc(from, to, 0.5).y, 700.0 - Powers.FLY_HEIGHT + 20.0, "high up halfway")

func test_green_is_the_strongest() -> void:
	assert_gt(Powers.DAMAGE["green"], Powers.DAMAGE["blue"])
	assert_true(Powers.DAMAGE["green"] >= Brain.HP, "one swoop sinks a baddie")

func test_helpers_take_turns() -> void:
	for k: String in ["blue", "yellow", "green"]:
		assert_gt(Powers.COOLDOWN[k], 1.5, "%s rests between powers" % k)
	assert_gt(Powers.STAGGER, 0.0)

func test_a_heart_from_a_helper() -> void:
	var f := FightState.new()
	assert_false(f.heal(), "already full")
	f.take_hit()
	assert_true(f.heal(), "one back")
	assert_eq(f.hearts, FightState.MAX_HEARTS)
	f.hearts = 0
	assert_false(f.heal(), "not while knocked out")
