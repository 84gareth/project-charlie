extends "res://tests/framework/test_case.gd"
## Helpers join at 200, 500 and 700 gems (kept, not spent), all come
## along, and keep to their own spots behind the hero.

const Helpers = preload("res://scripts/helpers.gd")
const FightState = preload("res://scripts/fight_state.gd")

const AREA: Rect2 = Rect2(80.0, 600.0, 4640.0, 270.0)
const HERO: Vector2 = Vector2(2000, 730)

func test_charlies_numbers_and_colours() -> void:
	assert_eq(Helpers.KINDS, ["blue", "yellow", "green"] as Array[String], "level 1 to 3")
	assert_eq(Helpers.UNLOCK["blue"], 200)
	assert_eq(Helpers.UNLOCK["yellow"], 500)
	assert_eq(Helpers.UNLOCK["green"], 700)
	assert_eq(Helpers.POWER["blue"], "wave")
	assert_eq(Helpers.POWER["yellow"], "sneaky")
	assert_eq(Helpers.POWER["green"], "flying")

func test_who_has_joined_at_each_total() -> void:
	assert_eq(Helpers.unlocked(0), [] as Array[String])
	assert_eq(Helpers.unlocked(199), [] as Array[String])
	assert_eq(Helpers.unlocked(200), ["blue"] as Array[String])
	assert_eq(Helpers.unlocked(699), ["blue", "yellow"] as Array[String])
	assert_eq(Helpers.unlocked(700), ["blue", "yellow", "green"] as Array[String], "all of them")
	assert_eq(Helpers.unlocked(5000), ["blue", "yellow", "green"] as Array[String])

func test_joining_happens_once_as_the_total_passes() -> void:
	assert_eq(Helpers.newly_unlocked(190, 200), ["blue"] as Array[String], "blue arrives")
	assert_eq(Helpers.newly_unlocked(200, 210), [] as Array[String], "not again")
	assert_eq(Helpers.newly_unlocked(0, 700), ["blue", "yellow", "green"] as Array[String], "all at once")

func test_first_helper_after_about_seven_waves() -> void:
	# Gareth chose gems worth 10 so blue comes within a sitting.
	var baddies: int = ceili(Helpers.UNLOCK["blue"] / float(FightState.GEM_VALUE))
	assert_eq(baddies, 20)
	assert_lt(baddies / 3.0, 8.0, "under 8 waves of 3")

func test_helpers_keep_behind_the_hero() -> void:
	for i: int in 3:
		assert_lt(Helpers.follow_spot(HERO, 1, i, AREA).x, HERO.x, "behind when facing right: %d" % i)
		assert_gt(Helpers.follow_spot(HERO, -1, i, AREA).x, HERO.x, "behind when facing left: %d" % i)

func test_each_helper_has_its_own_spot_on_the_street() -> void:
	var spots: Dictionary = {}
	for i: int in 3:
		var s: Vector2 = Helpers.follow_spot(HERO, 1, i, AREA)
		assert_true(s.x >= AREA.position.x and s.x <= AREA.end.x and s.y >= AREA.position.y and s.y <= AREA.end.y, "on the street")
		spots[s] = true
	assert_eq(spots.size(), 3, "no stacking")

func test_spots_stay_on_the_street_at_the_ends() -> void:
	var s: Vector2 = Helpers.follow_spot(Vector2(AREA.position.x + 10, AREA.end.y), 1, 2, AREA)
	assert_eq(s.x, AREA.position.x, "not off the left end")
	assert_eq(s.y, AREA.end.y, "not off the front")

func test_following_catches_up_without_overshooting() -> void:
	assert_eq(Helpers.follow_step(Vector2(100, 700), Vector2(105, 700), 1.0), Vector2(105, 700), "arrives")
	var near: float = Helpers.follow_step(Vector2(0, 700), Vector2(100, 700), 0.1).x
	var far: float = Helpers.follow_step(Vector2(0, 700), Vector2(1000, 700), 0.1).x
	assert_gt(far, near, "hurries when far behind")
