extends "res://tests/framework/test_case.gd"
## Sword swings in front; the hammer spins all around; one attack at a time.

const Attacks = preload("res://scripts/attacks.gd")

const HERO: Vector2 = Vector2(1000, 700)

func test_sword_hits_in_front() -> void:
	assert_true(Attacks.hits(Attacks.SWORD, HERO, 1, HERO + Vector2(100, 0)), "right in front")
	assert_true(Attacks.hits(Attacks.SWORD, HERO, 1, HERO + Vector2(100, 40)), "a bit down the street")

func test_sword_misses_behind_far_and_off_to_the_side() -> void:
	assert_false(Attacks.hits(Attacks.SWORD, HERO, 1, HERO + Vector2(-100, 0)), "behind")
	assert_false(Attacks.hits(Attacks.SWORD, HERO, 1, HERO + Vector2(Attacks.SWORD_REACH + 10, 0)), "too far")
	assert_false(Attacks.hits(Attacks.SWORD, HERO, 1, HERO + Vector2(100, Attacks.SWORD_DEPTH + 10)), "too far down the street")

func test_sword_faces_the_way_the_hero_faces() -> void:
	assert_true(Attacks.hits(Attacks.SWORD, HERO, -1, HERO + Vector2(-100, 0)), "facing left hits left")
	assert_false(Attacks.hits(Attacks.SWORD, HERO, -1, HERO + Vector2(100, 0)), "facing left misses right")

func test_hammer_spin_hits_all_around() -> void:
	for d: Vector2 in [Vector2(150, 0), Vector2(-150, 0), Vector2(0, 60), Vector2(0, -60)]:
		assert_true(Attacks.hits(Attacks.HAMMER, HERO, 1, HERO + d), "hits at %s" % d)
	assert_false(Attacks.hits(Attacks.HAMMER, HERO, 1, HERO + Vector2(Attacks.HAMMER_REACH + 10, 0)), "too far")

func test_one_attack_at_a_time() -> void:
	var s := Attacks.State.new()
	assert_false(s.busy())
	assert_true(s.start(Attacks.SWORD), "sword starts")
	assert_false(s.start(Attacks.HAMMER), "no hammer mid-swing")
	assert_eq(s.kind, Attacks.SWORD)

func test_attack_finishes_after_its_time() -> void:
	var s := Attacks.State.new()
	s.start(Attacks.HAMMER)
	s.update(Attacks.DURATION[Attacks.HAMMER] - 0.05)
	assert_true(s.busy(), "still spinning")
	s.update(0.1)
	assert_false(s.busy(), "spin over")
	assert_true(s.start(Attacks.SWORD), "free to attack again")

func test_hammer_spin_lasts_longer_than_a_sword_swing() -> void:
	assert_gt(Attacks.DURATION[Attacks.HAMMER], Attacks.DURATION[Attacks.SWORD])

func test_can_only_hit_in_the_middle_of_an_attack() -> void:
	var s := Attacks.State.new()
	assert_false(s.can_hit(), "idle")
	s.start(Attacks.SWORD)
	assert_false(s.can_hit(), "wind-up")
	s.update(0.1)
	assert_true(s.can_hit(), "mid-swing")
	s.update(0.12)
	assert_false(s.can_hit(), "follow-through")

func test_unknown_attack_does_not_start() -> void:
	var s := Attacks.State.new()
	assert_false(s.start("banana"))
	assert_false(s.busy())
