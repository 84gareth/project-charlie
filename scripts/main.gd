extends Node2D
## The game: one city street, the hero, and waves of baddies that each
## leave a gem behind (Phase 2, step 3). Beat a wave and another comes.

const Controls = preload("res://scripts/controls.gd")
const Layout = preload("res://scripts/street_layout.gd")
const Attacks = preload("res://scripts/attacks.gd")
const Brain = preload("res://scripts/baddie_brain.gd")
const Waves = preload("res://scripts/waves.gd")
const Gems = preload("res://scripts/gems.gd")
const BADDIE_SCENE: PackedScene = preload("res://scenes/baddie.tscn")
const GEM_SCENE: PackedScene = preload("res://scenes/gem.tscn")

@onready var world: Node2D = $World
@onready var hero: Node2D = %Hero
@onready var camera: Camera2D = %Camera
@onready var version_label: Label = %VersionLabel
@onready var gem_label: Label = %GemLabel

var gems: int = 0
## Baddies still on the street, including ones sinking.
var baddies: Array[Node2D] = []
## Gems lying on the street, waiting to be picked up.
var loose_gems: Array[Node2D] = []
## Set false by tests that want to place baddies themselves.
var waves_enabled: bool = true

var _wave_wait: float = 0.0

func _ready() -> void:
	Controls.install()
	hero.position = Layout.HERO_START
	camera.limit_right = Layout.WORLD_WIDTH
	camera.limit_bottom = Layout.SCREEN_HEIGHT
	camera.reset_smoothing()
	version_label.text = "v" + str(ProjectSettings.get_setting("application/config/version"))
	_show_gems()

func _process(delta: float) -> void:
	_hit_baddies()
	_pick_up_gems()
	if waves_enabled and baddies.is_empty():
		_wave_wait += delta
		if _wave_wait >= Waves.PAUSE:
			start_wave()

func start_wave() -> void:
	_wave_wait = 0.0
	var points: Array[Vector2] = Waves.spawn_points(hero.position.x, Layout.WALK_AREA)
	for i: int in points.size():
		spawn_baddie(points[i], Waves.lane(i))

func spawn_baddie(at: Vector2, lane: float = 0.0) -> Node2D:
	var b: Node2D = BADDIE_SCENE.instantiate()
	b.hero = hero
	b.lane = lane
	b.position = at
	b.sunk.connect(_on_baddie_sunk)
	world.add_child(b)
	baddies.append(b)
	return b

func _hit_baddies() -> void:
	if not hero.attack.can_hit():
		return
	var kind: String = hero.attack.kind
	for b: Node2D in baddies:
		if b.alive() and Attacks.hits(kind, hero.position, hero.facing, b.position):
			b.take_hit(Brain.DAMAGE[kind], hero.attack_id, hero.position.x)

func _on_baddie_sunk(b: Node2D) -> void:
	baddies.erase(b)
	var gem: Node2D = GEM_SCENE.instantiate()
	gem.position = b.position
	world.add_child(gem)
	loose_gems.append(gem)

func _pick_up_gems() -> void:
	for gem: Node2D in loose_gems.duplicate():
		if Gems.touching(hero.position, gem.position):
			loose_gems.erase(gem)
			gem.queue_free()
			gems += 1
			_show_gems()

func _show_gems() -> void:
	gem_label.text = str(gems)
