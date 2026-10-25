extends "res://tests/framework/live_case.gd"
## Baddies punch back in the real game: a punch costs a heart and shows on
## the hearts row; stepping away or hitting first stops it; out of hearts
## the hero falls down, the fight restarts with full hearts and the gems
## are kept.

const Brain = preload("res://scripts/baddie_brain.gd")
const FightState = preload("res://scripts/fight_state.gd")
const Waves = preload("res://scripts/waves.gd")

var _main: Node
var _hero: Node2D

func before_each() -> void:
	_main = load("res://scenes/main.tscn").instantiate()
	_main.hero_look = "boy"
	add_child(_main)
	await frames(1)
	_main.waves_enabled = false
	_hero = _main.get_node("%Hero")

func after_each() -> void:
	if is_instance_valid(_main):
		_main.queue_free()
	await frames(1)

func _winding_up(b: Node2D) -> bool:
	return is_instance_valid(b) and b.state == b.State.WINDUP

func test_a_punch_costs_a_heart() -> void:
	var b: Node2D = _main.spawn_baddie(_hero.position + Vector2(Brain.STOP_X, 0))
	b.punch_wait = 0.0
	await until(func() -> bool: return _main.fight.hearts == FightState.MAX_HEARTS - 1, "punch lands")
	assert_eq(_main.get_node("%Hearts").hearts, FightState.MAX_HEARTS - 1, "hearts row shows it")
	assert_true(_hero.blinking, "hero blinks")

func test_stepping_away_dodges_the_punch() -> void:
	var b: Node2D = _main.spawn_baddie(_hero.position + Vector2(Brain.STOP_X, 0))
	b.punch_wait = 0.0
	await until(func() -> bool: return _winding_up(b), "wind-up starts")
	_hero.position.x -= 300.0
	b.hero = null  # stay put, so it can't follow into reach
	await seconds(Brain.WINDUP + 0.2)
	assert_eq(_main.fight.hearts, FightState.MAX_HEARTS, "missed")

func test_hitting_it_first_stops_the_punch() -> void:
	var b: Node2D = _main.spawn_baddie(_hero.position + Vector2(Brain.STOP_X, 0))
	b.punch_wait = 0.0
	await until(func() -> bool: return _winding_up(b), "wind-up starts")
	b.take_hit(1, 999, _hero.position.x)
	await seconds(Brain.WINDUP + 0.2)
	assert_eq(_main.fight.hearts, FightState.MAX_HEARTS, "punch cancelled")

func test_out_of_hearts_restarts_the_fight_and_keeps_gems() -> void:
	for i: int in 7:
		_main.fight.add_gem()
	_main.fight.hearts = 1
	_main.waves_enabled = true
	var b: Node2D = _main.spawn_baddie(_hero.position + Vector2(Brain.STOP_X, 0))
	b.punch_wait = 0.0
	await until(func() -> bool: return _hero.down, "hero falls down")
	assert_eq(_main.baddies.size(), 0, "this fight's baddies go away")
	await until(func() -> bool: return not _hero.down, "hero gets back up")
	assert_eq(_main.fight.hearts, FightState.MAX_HEARTS, "full hearts")
	assert_eq(_main.fight.gems, 7 * FightState.GEM_VALUE, "gems kept")
	assert_eq(_main.get_node("%GemLabel").text, str(7 * FightState.GEM_VALUE), "counter still shows them")
	await until(func() -> bool: return _main.baddies.size() == Waves.SIZE, "the fight starts again")

func test_no_walking_or_attacking_while_down() -> void:
	_main.fight.hearts = 1
	var b: Node2D = _main.spawn_baddie(_hero.position + Vector2(Brain.STOP_X, 0))
	b.punch_wait = 0.0
	await until(func() -> bool: return _hero.down, "hero falls down")
	var x: float = _hero.position.x
	Input.action_press("move_right")
	var e := InputEventAction.new()
	e.action = "sword"
	e.pressed = true
	Input.parse_input_event(e)
	Input.flush_buffered_events()
	await frames(5)
	Input.action_release("move_right")
	assert_eq(_hero.position.x, x, "didn't walk")
	assert_false(_hero.attack.busy(), "didn't swing")
