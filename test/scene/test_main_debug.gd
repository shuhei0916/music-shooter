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


func _graph(main: Main) -> GrowthGraph:
	return main.get_node("UI/GrowthGraph")


func test_成長曲線のグラフはデバッグモードのときだけ見せる():
	var main := _make_main()
	assert_false(_graph(main).visible)
	main.debug = true
	assert_true(_graph(main).visible)


func test_成長曲線のグラフには最後のボスのHPまで入りプレイヤーのHPを時刻とともに記録する():
	var main := _make_main()
	assert_gte(_graph(main).max_value, float(main.boss_hps.back()))
	simulate(main, 3, 0.5)
	assert_eq(_graph(main).time, main.song_time())
	assert_eq(_graph(main).player_points.back().y, float(main.get_node("Player").health.hp))


func test_パートの解析はデバッグモードのときだけ右上の円の下に見せる():
	var main := _make_main()
	var hud: PartHud = main.get_node("UI/PartHud")
	assert_false(hud.visible)
	main.debug = true
	assert_true(hud.visible)


func test_曲の隣にパートの解析があれば読んで曲の時刻に合わせて見せる():
	var file := FileAccess.open("user://test_song.parts.json", FileAccess.WRITE)
	file.store_string(
		'{"frame_rate": 10, "parts": {"kick": {"level": [1, 1, 1, 1], "onsets": []}}}'
	)
	file.close()
	var main: Main = MainScene.instantiate()
	main.song_path = "user://test_song.mp3"
	main.layout = [{"z": 500.0, "enemies": [[1, 1]]}]
	add_child_autofree(main)
	DirAccess.remove_absolute("user://test_song.parts.json")
	simulate(main, 1, 0.2)
	assert_almost_eq(main.get_node("UI/PartHud/Rows/kick/Bar").value, 1.0, 0.001)
