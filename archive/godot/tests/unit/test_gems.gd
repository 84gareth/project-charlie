extends "res://tests/framework/test_case.gd"
## Walk onto a gem to pick it up; walking near isn't enough.

const Gems = preload("res://scripts/gems.gd")

func test_standing_on_a_gem_picks_it_up() -> void:
	assert_true(Gems.touching(Vector2(500, 700), Vector2(500, 700)))
	assert_true(Gems.touching(Vector2(500, 700), Vector2(560, 730)), "close enough")

func test_walking_past_nearby_does_not() -> void:
	assert_false(Gems.touching(Vector2(500, 700), Vector2(600, 700)), "too far along")
	assert_false(Gems.touching(Vector2(500, 700), Vector2(500, 760)), "too far across")
