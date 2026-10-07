extends GutTest

const CALIBRATION_SCENE = preload("res://scenes/ui/calibration/calibration.tscn")
const TEST_SETTINGS_PATH = "user://test_calibration_settings.cfg"

var calibration
var _saved_offset: float
var _saved_path: String


func before_each():
	_saved_offset = Settings.visual_offset_sec
	_saved_path = Settings.path
	Settings.path = TEST_SETTINGS_PATH  # 実際の設定ファイルを上書きしない
	calibration = _spawn()
	calibration.return_scene = ""  # テスト中にシーンを切り替えない


func after_each():
	Settings.visual_offset_sec = _saved_offset
	Settings.path = _saved_path
	DirAccess.remove_absolute(TEST_SETTINGS_PATH)
	for bullet in get_tree().get_nodes_in_group("bullet"):
		bullet.free()


func _spawn():
	return add_child_autofree(CALIBRATION_SCENE.instantiate())


func _press(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	calibration._unhandled_input(event)


func test_右キーでオフセットを5ms増やす():
	var before: float = calibration.offset_sec
	_press("ui_right")
	assert_almost_eq(calibration.offset_sec, before + 0.005, 0.0001)


func test_左キーでオフセットを5ms減らす():
	var before: float = calibration.offset_sec
	_press("ui_left")
	assert_almost_eq(calibration.offset_sec, before - 0.005, 0.0001)


func test_現在のオフセットをmsで表示する():
	calibration.offset_sec = 0.04
	_press("ui_right")
	assert_string_contains(calibration.get_node("UI/OffsetLabel").text, "+45 ms")


func test_開始時はSettingsの値から始まる():
	Settings.visual_offset_sec = 0.06
	assert_eq(0.06, _spawn().offset_sec)


func test_決定でSettingsにオフセットを保存する():
	calibration.offset_sec = 0.07
	_press("ui_accept")
	assert_eq(0.07, Settings.visual_offset_sec)
