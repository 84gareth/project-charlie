extends "res://tests/framework/test_case.gd"
## Twelve hearts; a short safe time after each hit; running out restarts
## the fight with full hearts and every gem kept.

const FightState = preload("res://scripts/fight_state.gd")

func test_starts_with_twelve_hearts_and_no_gems() -> void:
	var f := FightState.new()
	assert_eq(FightState.MAX_HEARTS, 12, "Charlie's number")
	assert_eq(f.hearts, 12)
	assert_eq(f.gems, 0)

func test_each_gem_is_worth_ten() -> void:
	var f := FightState.new()
	f.add_gem()
	assert_eq(f.gems, 10, "Gareth's number")
	f.add_gem()
	assert_eq(f.gems, 20)

func test_a_punch_costs_one_heart() -> void:
	var f := FightState.new()
	assert_true(f.take_hit())
	assert_eq(f.hearts, 11)

func test_safe_for_a_moment_after_a_hit() -> void:
	var f := FightState.new()
	f.take_hit()
	assert_true(f.is_safe())
	assert_false(f.take_hit(), "second punch straight after doesn't count")
	assert_eq(f.hearts, 11)
	f.update(FightState.SAFE_TIME + 0.01)
	assert_false(f.is_safe())
	assert_true(f.take_hit(), "counts again once safe time is over")
	assert_eq(f.hearts, 10)

func test_twelve_punches_run_out() -> void:
	var f := FightState.new()
	for i: int in 12:
		assert_false(f.out_of_hearts(), "still going after %d" % i)
		f.take_hit()
		f.update(FightState.SAFE_TIME + 0.01)
	assert_true(f.out_of_hearts())
	assert_false(f.take_hit(), "can't go below zero")
	assert_eq(f.hearts, 0)

func test_restart_fills_hearts_and_keeps_gems() -> void:
	var f := FightState.new()
	for i: int in 5:
		f.add_gem()
	for i: int in 12:
		f.take_hit()
		f.update(FightState.SAFE_TIME + 0.01)
	f.restart_fight()
	assert_eq(f.hearts, FightState.MAX_HEARTS, "full hearts")
	assert_eq(f.gems, 5 * FightState.GEM_VALUE, "gems kept")
	assert_true(f.is_safe(), "a moment to get ready")
