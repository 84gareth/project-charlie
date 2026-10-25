extends Node2D
## The start screen: pick a boy or a girl. No reading needed: two big
## cards with the heroes on them; the chosen one has a yellow frame and
## bounces. Left/right (arrows, d-pad or stick) moves the choice; the
## sword or hammer button, Enter, or a click on a card picks.

signal picked(look: String)

const Choice = preload("res://scripts/hero_choice.gd")

const CARD: Color = Color(0.98, 0.96, 0.9)
const CARD_EDGE: Color = Color(0.35, 0.3, 0.5)
const CHOSEN: Color = Color(1.0, 0.82, 0.15)

var selected: int = 0

var _time: float = 0.0
@onready var _arts: Array[Node2D] = [$BoyArt, $GirlArt]

func _process(delta: float) -> void:
	_time += delta
	for i: int in _arts.size():
		var bounce: float = absf(sin(_time * 6.0)) * 24.0 if i == selected else 0.0
		_arts[i].position = Vector2(Choice.CARDS[i].get_center().x, Choice.FEET_Y - bounce)
	queue_redraw()

func _draw() -> void:
	for i: int in Choice.CARDS.size():
		var r: Rect2 = Choice.CARDS[i]
		if i == selected:
			draw_rect(r.grow(14.0), CHOSEN)
		draw_rect(r, CARD)
		draw_rect(r, CARD_EDGE, false, 6.0)
		# A little floor for the hero to stand on.
		draw_rect(Rect2(r.position.x + 40.0, Choice.FEET_Y, r.size.x - 80.0, 12.0), CARD_EDGE.lightened(0.5))

func _unhandled_input(event: InputEvent) -> void:
	var handled: bool = true
	if event.is_action_pressed("move_left"):
		selected = Choice.move(selected, -1)
	elif event.is_action_pressed("move_right"):
		selected = Choice.move(selected, 1)
	elif event.is_action_pressed("sword") or event.is_action_pressed("hammer") \
			or event.is_action_pressed("ui_accept"):
		picked.emit(Choice.LOOKS[selected])
	elif event is InputEventMouseMotion:
		var over: int = Choice.card_at(make_input_local(event).position)
		if over >= 0:
			selected = over
	elif event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		var hit: int = Choice.card_at(make_input_local(event).position)
		if hit >= 0:
			selected = hit
			picked.emit(Choice.LOOKS[hit])
	else:
		handled = false
	# Nothing reaches the hero while the picker is up.
	if handled:
		get_viewport().set_input_as_handled()
