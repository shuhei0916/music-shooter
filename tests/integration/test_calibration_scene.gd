extends GutTest

var calibration


func before_each():
	calibration = load("res://scenes/ui/calibration/calibration.tscn").instantiate()
	add_child_autofree(calibration)


func after_each():
	for bullet in get_tree().get_nodes_in_group("bullet"):
		bullet.free()


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
