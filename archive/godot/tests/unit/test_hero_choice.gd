extends "res://tests/framework/test_case.gd"
## The start screen's choice: boy on the left, girl on the right.

const Choice = preload("res://scripts/hero_choice.gd")

func test_boy_left_girl_right() -> void:
	assert_eq(Choice.LOOKS, ["boy", "girl"] as Array[String])
	assert_lt(Choice.CARDS[0].position.x, Choice.CARDS[1].position.x)

func test_moving_stops_at_the_ends() -> void:
	assert_eq(Choice.move(0, 1), 1, "right to the girl")
	assert_eq(Choice.move(1, 1), 1, "can't go past the girl")
	assert_eq(Choice.move(1, -1), 0, "left to the boy")
	assert_eq(Choice.move(0, -1), 0, "can't go past the boy")

func test_clicking_finds_the_card() -> void:
	assert_eq(Choice.card_at(Choice.CARDS[0].get_center()), 0, "boy card")
	assert_eq(Choice.card_at(Choice.CARDS[1].get_center()), 1, "girl card")
	assert_eq(Choice.card_at(Vector2(800, 100)), -1, "above the cards")
	assert_eq(Choice.card_at(Vector2(800, 440)), -1, "the gap between them")

func test_cards_are_big_and_fit_on_screen() -> void:
	var screen: Rect2 = Rect2(0, 0, 1600, 900)
	for r: Rect2 in Choice.CARDS:
		assert_true(screen.encloses(r), "on screen: %s" % r)
		assert_gt(r.size.x, 300.0, "big enough to click")
	assert_false(Choice.CARDS[0].intersects(Choice.CARDS[1]), "don't overlap")
