extends Node2D
## Placeholder hero made of simple shapes, feet at (0, 0), facing right.
## Holds a sword; the hammer rides on the back until the spin attack.
## Real art comes after Charlie has played the touch test.

const Attacks = preload("res://scripts/attacks.gd")

const SKIN: Color = Color(0.96, 0.78, 0.62)
const SHIRT: Color = Color(0.15, 0.55, 0.95)
const TROUSERS: Color = Color(0.2, 0.22, 0.35)
const SHOES: Color = Color(0.1, 0.1, 0.12)
const HAIR: Color = Color(0.4, 0.25, 0.12)
const BLADE: Color = Color(0.85, 0.9, 0.95)
const GRIP: Color = Color(0.45, 0.28, 0.12)
const GOLD: Color = Color(0.95, 0.75, 0.2)
const HAMMER_HEAD: Color = Color(0.45, 0.47, 0.52)
const SWOOSH: Color = Color(1, 1, 1, 0.55)

## Where the spinning hammer circles, around the hero's middle.
const SPIN_CENTRE: Vector2 = Vector2(0.0, -95.0)
const SPIN_RADIUS: Vector2 = Vector2(150.0, 45.0)
const SPIN_TURNS: float = 2.0

## 1 is right, -1 is left.
var facing: int = 1:
	set(value):
		facing = value
		scale.x = value
var moving: bool = false
## Which attack is happening ("" for none), and how far through it (0 to 1).
var attack_kind: String = ""
var attack_progress: float = 0.0
## Knocked down: lying on the street with stars going round.
var down: bool = false

var _step_time: float = 0.0

func _process(delta: float) -> void:
	_step_time = _step_time + delta * 12.0 if moving else 0.0
	queue_redraw()

func _draw() -> void:
	# Shadow on the street.
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, 44.0 if not down else 110.0, Color(0, 0, 0, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if down:
		_draw_lying_down()
		return

	var spinning: bool = attack_kind == Attacks.HAMMER
	var spin_angle: float = attack_progress * SPIN_TURNS * TAU
	if spinning:
		_draw_spin_ring()
		if sin(spin_angle) < 0.0:
			_draw_spinning_hammer(spin_angle)
	else:
		_draw_hammer_on_back()

	var swing: float = sin(_step_time) * 14.0
	# Back leg, then front leg.
	draw_rect(Rect2(-20.0 - swing, -64.0, 16.0, 58.0), TROUSERS)
	draw_rect(Rect2(-24.0 - swing, -8.0, 24.0, 8.0), SHOES)
	draw_rect(Rect2(4.0 + swing, -64.0, 16.0, 58.0), TROUSERS)
	draw_rect(Rect2(4.0 + swing, -8.0, 24.0, 8.0), SHOES)
	# Body.
	draw_rect(Rect2(-28.0, -138.0, 56.0, 78.0), SHIRT)
	# Head, hair and eye.
	draw_circle(Vector2(0.0, -168.0), 30.0, SKIN)
	draw_rect(Rect2(-32.0, -202.0, 58.0, 20.0), HAIR)
	draw_circle(Vector2(14.0, -172.0), 4.5, Color.BLACK)

	if spinning:
		if sin(spin_angle) >= 0.0:
			_draw_spinning_hammer(spin_angle)
	else:
		_draw_sword_arm(swing)

## The arm holding the sword. Idle, the sword points up and forward; a
## sword attack sweeps it from over the shoulder down to the front.
func _draw_sword_arm(walk_swing: float) -> void:
	var shoulder: Vector2 = Vector2(0.0, -126.0)
	var hand: Vector2
	var blade_angle: float
	if attack_kind == Attacks.SWORD:
		var t: float = ease(attack_progress, 0.4)
		blade_angle = lerpf(deg_to_rad(-120.0), deg_to_rad(25.0), t)
		hand = shoulder + Vector2(cos(blade_angle), sin(blade_angle)) * 46.0
		# The swoosh the blade leaves behind it.
		draw_arc(shoulder, 150.0, deg_to_rad(-120.0), blade_angle, 24, SWOOSH, 18.0)
	else:
		blade_angle = deg_to_rad(-60.0)
		hand = Vector2(10.0 - walk_swing * 0.6, -72.0)
	draw_line(shoulder, hand, SHIRT.darkened(0.2), 16.0)
	var dir: Vector2 = Vector2(cos(blade_angle), sin(blade_angle))
	var side: Vector2 = Vector2(-dir.y, dir.x)
	# Grip, gold guard, then the blade.
	draw_line(hand - dir * 16.0, hand + dir * 8.0, GRIP, 9.0)
	draw_line(hand + dir * 8.0 - side * 16.0, hand + dir * 8.0 + side * 16.0, GOLD, 7.0)
	draw_line(hand + dir * 10.0, hand + dir * 100.0, BLADE, 12.0)
	draw_circle(hand, 9.0, SKIN)

## Flat on the street, head to the back, with dizzy stars circling.
func _draw_lying_down() -> void:
	# Turned a quarter: feet to the front, head to the back, centred.
	draw_set_transform(Vector2(100.0, -30.0), -PI / 2.0, Vector2.ONE)
	draw_rect(Rect2(-20.0, -64.0, 16.0, 58.0), TROUSERS)
	draw_rect(Rect2(4.0, -64.0, 16.0, 58.0), TROUSERS)
	draw_rect(Rect2(-28.0, -138.0, 56.0, 78.0), SHIRT)
	draw_circle(Vector2(0.0, -168.0), 30.0, SKIN)
	draw_rect(Rect2(-32.0, -202.0, 58.0, 20.0), HAIR)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var t: float = Time.get_ticks_msec() * 0.004
	for i: int in 3:
		var a: float = t + i * TAU / 3.0
		draw_circle(Vector2(-68.0 + cos(a) * 40.0, -80.0 + sin(a) * 12.0), 8.0, GOLD)

func _draw_hammer_on_back() -> void:
	draw_line(Vector2(-20.0, -70.0), Vector2(-44.0, -170.0), GRIP, 9.0)
	draw_rect(Rect2(-72.0, -196.0, 56.0, 34.0), HAMMER_HEAD)

## A faint ring on the street where the hammer is sweeping.
func _draw_spin_ring() -> void:
	draw_set_transform(SPIN_CENTRE, 0.0, Vector2(1.0, SPIN_RADIUS.y / SPIN_RADIUS.x))
	draw_arc(Vector2.ZERO, SPIN_RADIUS.x, 0.0, TAU, 48, SWOOSH, 14.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_spinning_hammer(angle: float) -> void:
	var head: Vector2 = SPIN_CENTRE + Vector2(cos(angle) * SPIN_RADIUS.x, sin(angle) * SPIN_RADIUS.y)
	draw_line(SPIN_CENTRE, head, GRIP, 10.0)
	draw_circle(SPIN_CENTRE, 10.0, SKIN)
	draw_rect(Rect2(head - Vector2(34.0, 24.0), Vector2(68.0, 48.0)), HAMMER_HEAD)
