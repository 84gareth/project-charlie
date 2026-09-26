extends Node2D
## The game: one city street, the hero, and waves of baddies that punch
## back and each leave a gem behind (Phase 2, step 4). Beat a wave and
## another comes. Out of hearts: the hero falls down, the fight restarts
## with full hearts, and the gems are kept.

const Controls = preload("res://scripts/controls.gd")
const Layout = preload("res://scripts/street_layout.gd")
const Attacks = preload("res://scripts/attacks.gd")
const Brain = preload("res://scripts/baddie_brain.gd")
const Waves = preload("res://scripts/waves.gd")
const Gems = preload("res://scripts/gems.gd")
const FightState = preload("res://scripts/fight_state.gd")
const PlaytestArgs = preload("res://scripts/playtest_args.gd")
const BADDIE_SCENE: PackedScene = preload("res://scenes/baddie.tscn")
const GEM_SCENE: PackedScene = preload("res://scenes/gem.tscn")

## Seconds the hero lies down after running out of hearts.
const DOWN_TIME: float = 1.5

@onready var world: Node2D = $World
@onready var hero: Node2D = %Hero
@onready var camera: Camera2D = %Camera
@onready var version_label: Label = %VersionLabel
@onready var gem_label: Label = %GemLabel
@onready var hearts_art: Node2D = %Hearts

var fight := FightState.new()
## Baddies still on the street, including ones sinking.
var baddies: Array[Node2D] = []
## Gems lying on the street, waiting to be picked up.
var loose_gems: Array[Node2D] = []
## Set false by tests that want to place baddies themselves.
var waves_enabled: bool = true
## Playtest mode (see playtest_args.gd). Read from the command line unless
## set before the scene enters the tree.
var mode: String = ""

var _wave_wait: float = 0.0
var _down_left: float = 0.0

func _ready() -> void:
	if mode == "":
		mode = PlaytestArgs.mode(OS.get_cmdline_user_args())
	Controls.install()
	hero.position = Layout.HERO_START
	camera.limit_right = Layout.WORLD_WIDTH
	camera.limit_bottom = Layout.SCREEN_HEIGHT
	camera.reset_smoothing()
	version_label.text = "v" + str(ProjectSettings.get_setting("application/config/version"))
	hearts_art.max_hearts = FightState.MAX_HEARTS
	_show_score()
	match mode:
		"practice":
			waves_enabled = false
		"fight":
			start_wave(Waves.CLOSE)

func _process(delta: float) -> void:
	fight.update(delta)
	hero.blinking = fight.is_safe() and not hero.down
	if hero.down:
		_down_left -= delta
		if _down_left <= 0.0:
			_get_back_up()
		return
	_hit_baddies()
	_pick_up_gems()
	if waves_enabled and baddies.is_empty():
		_wave_wait += delta
		if _wave_wait >= Waves.PAUSE:
			start_wave()

func start_wave(start_dist: float = Waves.OFFSCREEN) -> void:
	_wave_wait = 0.0
	var points: Array[Vector2] = Waves.spawn_points(hero.position.x, Layout.WALK_AREA,
			Waves.SIZE, start_dist)
	for i: int in points.size():
		var b: Node2D = spawn_baddie(points[i], Waves.lane(i))
		b.punch_wait = Brain.FIRST_PUNCH + i * Brain.STAGGER

func spawn_baddie(at: Vector2, lane: float = 0.0) -> Node2D:
	var b: Node2D = BADDIE_SCENE.instantiate()
	b.hero = hero
	b.lane = lane
	b.position = at
	b.sunk.connect(_on_baddie_sunk)
	b.punched.connect(_on_baddie_punched)
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

func _on_baddie_punched(b: Node2D) -> void:
	if hero.down or not fight.take_hit():
		return
	hero.bumped(b.position.x)
	hero.blinking = true
	_show_score()
	if fight.out_of_hearts():
		_fall_down()

## Out of hearts: the hero lies down and this fight's baddies go away.
func _fall_down() -> void:
	hero.down = true
	hero.attack = Attacks.State.new()
	_down_left = DOWN_TIME
	for b: Node2D in baddies:
		b.queue_free()
	baddies.clear()
	_wave_wait = 0.0

## Up again with full hearts and every gem kept; the fight starts over.
func _get_back_up() -> void:
	hero.down = false
	fight.restart_fight()
	_show_score()

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
			fight.add_gem()
			_show_score()

func _show_score() -> void:
	gem_label.text = str(fight.gems)
	hearts_art.hearts = fight.hearts
