extends GutTest

const SettingsScript = preload("res://scripts/settings.gd")
const TEST_PATH = "user://test_settings.cfg"

var settings: SettingsScript


func before_each():
	settings = SettingsScript.new()
	settings.path = TEST_PATH


func after_each():
	settings.free()
	DirAccess.remove_absolute(TEST_PATH)


func test_visual_offset_secの初期値は0_15():
	assert_eq(0.15, settings.visual_offset_sec)


func test_保存した値を次回読み込める():
	settings.visual_offset_sec = 0.07
	settings.save_to_file()
	var reloaded: SettingsScript = autofree(SettingsScript.new())
	reloaded.path = TEST_PATH
	reloaded.load_from_file()
	assert_eq(0.07, reloaded.visual_offset_sec)


func test_保存ファイルがなければ初期値のまま():
	settings.load_from_file()
	assert_eq(0.15, settings.visual_offset_sec)
