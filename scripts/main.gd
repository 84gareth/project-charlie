extends Node2D
## The game: one city street with the hero on it (Phase 2, step 1).

const Controls = preload("res://scripts/controls.gd")
const Layout = preload("res://scripts/street_layout.gd")

@onready var hero: Node2D = %Hero
@onready var camera: Camera2D = %Camera
@onready var version_label: Label = %VersionLabel

func _ready() -> void:
	Controls.install()
	hero.position = Layout.HERO_START
	camera.limit_right = Layout.WORLD_WIDTH
	camera.limit_bottom = Layout.SCREEN_HEIGHT
	camera.reset_smoothing()
	version_label.text = "v" + str(ProjectSettings.get_setting("application/config/version"))
