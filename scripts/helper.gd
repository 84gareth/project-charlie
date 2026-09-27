extends Node2D
## One of Charlie's helpers on the street. Its position is where its feet
## touch the ground. Follows the hero, hopping gently, and faces the way
## the hero faces. Pops in with a sparkle when it first joins.

const Helpers = preload("res://scripts/helpers.gd")
const Layout = preload("res://scripts/street_layout.gd")

@onready var sprite: Sprite2D = $Sprite

var kind: String = "blue"
## Its place in the line of helpers (0, 1 or 2).
var index: int = 0
var hero: Node2D
var walk_area: Rect2 = Layout.WALK_AREA

var _time: float = 0.0

func _ready() -> void:
	sprite.texture = load(Helpers.TEXTURE[kind])
	sprite.scale = Vector2.ONE * Helpers.SCALE[kind]
	# Pop in: grow from nothing with a little overshoot.
	scale = Vector2.ZERO
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.45) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	_time += delta
	if is_instance_valid(hero):
		var target: Vector2 = Helpers.follow_spot(hero.position, hero.facing, index, walk_area)
		position = Helpers.follow_step(position, target, delta)
		sprite.flip_h = hero.facing < 0
	# A gentle hop, each helper a little out of step with the others.
	sprite.position.y = -absf(sin(_time * 5.0 + index)) * 10.0
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, 40.0, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
