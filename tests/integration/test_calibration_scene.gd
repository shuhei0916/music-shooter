extends GutTest

const CALIBRATION_SCENE = preload("res://scenes/ui/calibration/calibration.tscn")

var calibration
var _saved_offset: float


func before_each():
	_saved_offset = Settings.visual_offset_sec
	calibration = _spawn()


func after_each():
	Settings.visual_offset_sec = _saved_offset
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
