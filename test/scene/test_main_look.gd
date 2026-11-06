extends GutTest
## 派手な表示とシンプル表示の切り替え

const MainScene := preload("res://scenes/main.tscn")
const PATH := "user://test_main_look.cfg"


func after_each() -> void:
	DirAccess.remove_absolute(PATH)


func _make_main(path := "") -> Main:
	var main: Main = MainScene.instantiate()
	main.song_path = ""
	main.forward_speed = 10.0
	main.course_length = 100.0
	main.layout = []
	main.look_settings_path = path
	return add_child_autofree(main)


func _glow(main: Main) -> bool:
	return main.get_node("WorldEnvironment").environment.glow_enabled


func _stars_visible(main: Main) -> bool:
	return main.get_node("Backdrop/Stars").visible


func _press_look_key(main: Main) -> void:
	var event := InputEventAction.new()
	event.action = "toggle_look"
	event.pressed = true
	main._unhandled_input(event)


func test_始めは派手な表示():
	var main := _make_main()
	assert_true(main.fancy_look)
	assert_true(_glow(main))
	assert_true(_stars_visible(main))


func test_シンプル表示では発光のにじみと粒を消す():
	var main := _make_main()
	main.fancy_look = false
	assert_false(_glow(main))
	assert_false(_stars_visible(main))


func test_キーで切り替えて元にも戻せる():
	var main := _make_main()
	_press_look_key(main)
	assert_false(main.fancy_look)
	assert_false(_glow(main))
	_press_look_key(main)
	assert_true(main.fancy_look)
	assert_true(_glow(main))
	assert_true(_stars_visible(main))


func test_切り替えのキーはF2():
	var events := InputMap.action_get_events("toggle_look")
	assert_eq(events.size(), 1)
	assert_eq(events[0].physical_keycode, KEY_F2)


func test_切り替えた設定は次のゲームに引き継がれる():
	_press_look_key(_make_main(PATH))
	var next := _make_main(PATH)
	assert_false(next.fancy_look)
	assert_false(_glow(next))
	assert_false(_stars_visible(next))


func test_保存先がなければ設定を保存しない():
	_press_look_key(_make_main())
	assert_true(_make_main().fancy_look)


func test_遊ぶゲームは決まった場所の設定を使う():
	var main: Main = autofree(Main.create(""))
	assert_eq(main.look_settings_path, LookSettings.PATH)


func test_シンプル表示でもゲームは進む():
	var main := _make_main()
	main.fancy_look = false
	main._process(0.5)
	assert_lt(main.get_node("Player").position.z, 0.0)
