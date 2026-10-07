extends GutTest

const Settings = preload("res://scripts/settings.gd")
const TEST_PATH = "user://test_settings.cfg"

var settings: Settings


func before_each():
	settings = Settings.new()
	settings.path = TEST_PATH


func after_each():
	settings.free()
	DirAccess.remove_absolute(TEST_PATH)


func test_visual_offset_secの初期値は0_04():
	assert_eq(0.04, settings.visual_offset_sec)


func test_保存した値を次回読み込める():
	settings.visual_offset_sec = 0.07
	settings.save_to_file()
	var reloaded: Settings = autofree(Settings.new())
	reloaded.path = TEST_PATH
	reloaded.load_from_file()
	assert_eq(0.07, reloaded.visual_offset_sec)
