extends GutTest
## Main のデバッグモード。床の小節・拍の線は、デバッグモードのときだけ見せる

const MainScene := preload("res://scenes/main.tscn")


func _make_main() -> Main:
	var main: Main = MainScene.instantiate()
	main.song_path = ""
	main.forward_speed = 10.0
	main.course_length = 100.0
	main.layout = []
	return add_child_autofree(main)


func _lines_visible(main: Main) -> Array:
	return [main.get_node("BarLines").visible, main.get_node("BeatLines").visible]


func _press_debug_key(main: Main) -> void:
	var event := InputEventAction.new()
	event.action = "toggle_debug"
	event.pressed = true
	main._unhandled_input(event)


func test_始めはデバッグモードではなく床の線は見せない():
	var main := _make_main()
	assert_false(main.debug)
	assert_eq(_lines_visible(main), [false, false])


func test_デバッグモードにすると床の線を見せる():
	var main := _make_main()
	main.debug = true
	assert_eq(_lines_visible(main), [true, true])


func test_デバッグのキーを押すとデバッグモードが切り替わる():
	var main := _make_main()
	_press_debug_key(main)
	assert_true(main.debug)
	assert_eq(_lines_visible(main), [true, true])
	_press_debug_key(main)
	assert_false(main.debug)
	assert_eq(_lines_visible(main), [false, false])


func test_デバッグのキーはF3():
	var events := InputMap.action_get_events("toggle_debug")
	assert_eq(events.size(), 1)
	assert_eq(events[0].physical_keycode, KEY_F3)
