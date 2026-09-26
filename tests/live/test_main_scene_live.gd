extends "res://tests/framework/live_case.gd"
## The main scene loads in a real tree: the street, the hero at the start
## spot, and the version in the corner.

const Layout = preload("res://scripts/street_layout.gd")

var _main: Node

func after_each() -> void:
	if is_instance_valid(_main):
		_main.queue_free()

func test_main_scene_shows_street_hero_and_version() -> void:
	var path: String = str(ProjectSettings.get_setting("application/run/main_scene"))
	_main = load(path).instantiate()
	add_child(_main)
	await frames(1)
	var version: String = str(ProjectSettings.get_setting("application/config/version"))
	assert_eq(_main.get_node("%VersionLabel").text, "v" + version, "version label")
	assert_eq(_main.get_node("%Hero").position, Layout.HERO_START, "hero at the start spot")
	assert_eq(_main.get_node("%Camera").limit_right, Layout.WORLD_WIDTH, "camera stops at the street's end")
