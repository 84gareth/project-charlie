extends Node2D
## The game: pick a boy or a girl, then one city street, the hero, and
## waves of baddies that punch back and each leave a gem behind (Phase 2).
## Beat a wave and another comes. Out of hearts: the hero falls down, the
## fight restarts with full hearts, and the gems are kept.

const Controls = preload("res://scripts/controls.gd")
const Layout = preload("res://scripts/street_layout.gd")
const Attacks = preload("res://scripts/attacks.gd")
const Brain = preload("res://scripts/baddie_brain.gd")
const Waves = preload("res://scripts/waves.gd")
const Gems = preload("res://scripts/gems.gd")
const FightState = preload("res://scripts/fight_state.gd")
const PlaytestArgs = preload("res://scripts/playtest_args.gd")
const Helpers = preload("res://scripts/helpers.gd")
const Powers = preload("res://scripts/helper_powers.gd")
const BADDIE_SCENE: PackedScene = preload("res://scenes/baddie.tscn")
const HELPER_SCENE: PackedScene = preload("res://scenes/helper.tscn")
const WAVE_SCENE: PackedScene = preload("res://scenes/wave.tscn")
const HEART_POP_SCENE: PackedScene = preload("res://scenes/heart_pop.tscn")
const GEM_SCENE: PackedScene = preload("res://scenes/gem.tscn")

## Seconds the hero lies down after running out of hearts.
const DOWN_TIME: float = 1.5

@onready var world: Node2D = $World
@onready var hero: Node2D = %Hero
@onready var camera: Camera2D = %Camera
@onready var version_label: Label = %VersionLabel
@onready var gem_label: Label = %GemLabel
@onready var hearts_art: Node2D = %Hearts
@onready var picker: CanvasLayer = $HeroPicker

var fight := FightState.new()
## Baddies still on the street, including ones sinking.
var baddies: Array[Node2D] = []
## Gems lying on the street, waiting to be picked up.
var loose_gems: Array[Node2D] = []
## Charlie's helpers that have joined, in level order.
var helpers: Array[Node2D] = []
## The blue helper's waves still rolling.
var waves: Array[Node2D] = []
## Set false by tests that want to place baddies themselves.
var waves_enabled: bool = true
## Playtest mode (see playtest_args.gd). Read from the command line unless
## set before the scene enters the tree.
var mode: String = ""
## "boy" or "girl". If still "" at the start (not set by a test or
## --hero=), the street mode shows the picker; other modes use the boy.
var hero_look: String = ""
## True while the start screen is up: no fighting yet.
var picking: bool = false

var _wave_wait: float = 0.0
var _down_left: float = 0.0
## Helper powers count down from -1, so they never clash with the hero's
## attack numbers (which count up from 1).
var _helper_attack: int = 0

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
	if hero_look == "":
		hero_look = PlaytestArgs.hero(OS.get_cmdline_user_args())
	if hero_look == "" and mode == "street":
		picking = true
		hero.controls_on = false
		picker.get_node("%Board").picked.connect(_on_hero_picked)
	else:
		_use_look(hero_look if hero_look != "" else "boy")
	match mode:
		"practice":
			waves_enabled = false
		"fight":
			start_wave(Waves.CLOSE)
		"helpers":
			set_gems(Helpers.UNLOCK["green"])
			start_wave(Waves.CLOSE)

## Sets the gem total directly (playtesting and tests); any helpers the
## new total earns join straight away.
func set_gems(total: int) -> void:
	var before: int = fight.gems
	fight.gems = total
	_helpers_join(before)
	_show_score()

func _helpers_join(gems_before: int) -> void:
	for kind: String in Helpers.newly_unlocked(gems_before, fight.gems):
		var h: Node2D = HELPER_SCENE.instantiate()
		h.kind = kind
		h.index = helpers.size()
		h.hero = hero
		h.position = Helpers.follow_spot(hero.position, hero.facing, h.index, Layout.WALK_AREA)
		h.made_wave.connect(_on_helper_wave)
		h.bonked.connect(_on_helper_bonk)
		h.wants_to_heal.connect(_on_helper_heal)
		world.add_child(h)
		helpers.append(h)

func _new_helper_attack() -> int:
	_helper_attack -= 1
	return _helper_attack

## Each helper that's ready goes for the nearest baddie near the hero.
func _use_helper_powers() -> void:
	var targets: Array[Node2D] = []
	var spots: Array[Vector2] = []
	for b: Node2D in baddies:
		if b.alive():
			targets.append(b)
			spots.append(b.position)
	if targets.is_empty():
		return
	for h: Node2D in helpers:
		if h.ready_for_power():
			var i: int = Powers.pick_target(hero.position, spots)
			if i >= 0:
				h.use_power(targets[i])

func _on_helper_wave(_h: Node2D, at: Vector2, dir: int) -> void:
	var w: Node2D = WAVE_SCENE.instantiate()
	w.dir = dir
	w.attack_id = _new_helper_attack()
	w.position = at
	world.add_child(w)
	waves.append(w)

func _roll_waves() -> void:
	# Drop finished waves first. Read them untyped: putting a freed wave into
	# a typed loop variable is an error, which would stop every later wave.
	var rolling: Array[Node2D] = []
	for i: int in waves.size():
		var maybe: Variant = waves[i]
		if is_instance_valid(maybe) and not (maybe as Node2D).is_queued_for_deletion():
			rolling.append(maybe)
	waves = rolling
	for w: Node2D in waves:
		for b: Node2D in baddies:
			if b.alive() and Powers.wave_hits(w.prev_x, w.position.x, w.position.y, b.position):
				# Knocked the way the wave is rolling.
				b.take_hit(Powers.DAMAGE["blue"], w.attack_id, b.position.x - w.dir)

func _on_helper_bonk(h: Node2D, target: Node2D, damage: int) -> void:
	if is_instance_valid(target) and target.alive():
		target.take_hit(damage, _new_helper_attack(), h.position.x)

func _on_helper_heal(h: Node2D) -> void:
	if picking or hero.down or not fight.heal():
		return
	h.heal_wait = Powers.HEAL_EVERY
	var pop: Node2D = HEART_POP_SCENE.instantiate()
	pop.position = h.position + Vector2(0, -170)
	world.add_child(pop)
	_show_score()

func _on_hero_picked(look: String) -> void:
	_use_look(look)
	picking = false
	hero.controls_on = true

func _use_look(look: String) -> void:
	hero_look = look
	hero.art.look = look
	if is_instance_valid(picker):
		picker.queue_free()

func _process(delta: float) -> void:
	if picking:
		return
	fight.update(delta)
	hero.blinking = fight.is_safe() and not hero.down
	if hero.down:
		_down_left -= delta
		if _down_left <= 0.0:
			_get_back_up()
		return
	_hit_baddies()
	_use_helper_powers()
	_roll_waves()
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
	for w: Node2D in waves:
		if is_instance_valid(w):
			w.queue_free()
	waves.clear()
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
			var before: int = fight.gems
			fight.add_gem()
			_helpers_join(before)
			_show_score()

func _show_score() -> void:
	gem_label.text = str(fight.gems)
	hearts_art.hearts = fight.hearts
