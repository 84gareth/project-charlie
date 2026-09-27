extends "res://tests/framework/test_case.gd"
## tools/playtest.sh passes --mode=<name>; anything odd means the normal game.

const PlaytestArgs = preload("res://scripts/playtest_args.gd")

func test_no_arguments_is_the_normal_game() -> void:
	assert_eq(PlaytestArgs.mode(PackedStringArray()), "street")

func test_each_mode_is_read() -> void:
	for m: String in ["street", "practice", "fight"]:
		assert_eq(PlaytestArgs.mode(PackedStringArray(["--mode=" + m])), m)

func test_unknown_mode_falls_back_to_the_normal_game() -> void:
	assert_eq(PlaytestArgs.mode(PackedStringArray(["--mode=banana"])), "street")

func test_hero_is_read_when_given() -> void:
	assert_eq(PlaytestArgs.hero(PackedStringArray(["--mode=fight", "--hero=girl"])), "girl")
	assert_eq(PlaytestArgs.hero(PackedStringArray(["--hero=boy"])), "boy")

func test_no_hero_or_an_odd_one_means_ask() -> void:
	assert_eq(PlaytestArgs.hero(PackedStringArray()), "")
	assert_eq(PlaytestArgs.hero(PackedStringArray(["--hero=dragon"])), "")

func test_other_arguments_are_ignored() -> void:
	assert_eq(PlaytestArgs.mode(PackedStringArray(["--verbose", "--mode=fight"])), "fight")
