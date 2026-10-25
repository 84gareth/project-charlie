extends Node2D
## The blue helper's wave: rolls along the street in one direction and
## goes away after WAVE_LENGTH. main.gd checks what it passes over, using
## `prev_x` (where it was last frame) and `attack_id` (so each baddie is
## knocked once per wave).

const Powers = preload("res://scripts/helper_powers.gd")

const WATER: Color = Color(0.2, 0.6, 0.95, 0.9)
const DEEP: Color = Color(0.1, 0.4, 0.8, 0.9)
const FOAM: Color = Color(1, 1, 1, 0.95)

## 1 rolls right, -1 rolls left.
var dir: int = 1
var attack_id: int = 0
var prev_x: float = 0.0

var _travelled: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	prev_x = position.x
	scale.x = dir

func _process(delta: float) -> void:
	_time += delta
	prev_x = position.x
	var step: float = Powers.WAVE_SPEED * delta
	position.x += dir * step
	_travelled += step
	if _travelled >= Powers.WAVE_LENGTH:
		queue_free()
	queue_redraw()

func _draw() -> void:
	# Fades in over the first bit and out over the last bit.
	var fade: float = clampf(minf(_travelled / 80.0, (Powers.WAVE_LENGTH - _travelled) / 150.0), 0.0, 1.0)
	var wobble: float = sin(_time * 14.0) * 5.0
	# A curling wave, drawn facing right: low at the back, a tall curl in front.
	var body := PackedVector2Array([
		Vector2(-110, 0), Vector2(-80, -30), Vector2(-40, -60 + wobble),
		Vector2(10, -95), Vector2(45, -110 + wobble), Vector2(70, -95),
		Vector2(60, -70), Vector2(40, -65), Vector2(55, -40), Vector2(70, 0),
	])
	draw_colored_polygon(body, DEEP * Color(1, 1, 1, fade))
	var front := PackedVector2Array([
		Vector2(-60, 0), Vector2(-30, -35), Vector2(10, -70 + wobble),
		Vector2(40, -80), Vector2(35, -55), Vector2(50, -30), Vector2(60, 0),
	])
	draw_colored_polygon(front, WATER * Color(1, 1, 1, fade))
	for i: int in 5:
		draw_circle(Vector2(20.0 + i * 11.0, -100.0 + absf(i - 2) * 6.0 + wobble), 8.0, FOAM * Color(1, 1, 1, fade))
