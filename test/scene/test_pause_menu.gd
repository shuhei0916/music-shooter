extends GutTest

const PauseMenuScene := preload("res://scenes/pause_menu.tscn")


func _make_menu() -> PauseMenu:
	return add_child_autofree(PauseMenuScene.instantiate())


func _press_pause(menu: PauseMenu) -> void:
	var event := InputEventAction.new()
	event.action = "pause"
	event.pressed = true
	menu._unhandled_input(event)


func after_each():
	# テストの中で止めたゲームは、次のテストに持ち越さない
	get_tree().paused = false


func test_初めはメニューを表示しない():
	var menu := _make_menu()
	assert_false(menu.visible)


func test_Escキーでゲームを一時停止しメニューを表示する():
	var menu := _make_menu()
	_press_pause(menu)
	assert_true(get_tree().paused)
	assert_true(menu.visible)


func test_再開ボタンを押すとゲームが再開しメニューを閉じる():
	var menu := _make_menu()
	_press_pause(menu)
	menu.get_node("Box/ResumeButton").pressed.emit()
	assert_false(get_tree().paused)
	assert_false(menu.visible)


func test_一時停止中にEscキーを押すと再開する():
	var menu := _make_menu()
	_press_pause(menu)
	_press_pause(menu)
	assert_false(get_tree().paused)
	assert_false(menu.visible)


func test_終了ボタンを押すとゲームの終了を求める():
	var menu := _make_menu()
	watch_signals(menu)
	_press_pause(menu)
	menu.get_node("Box/QuitButton").pressed.emit()
	assert_signal_emitted(menu, "quit_requested")
