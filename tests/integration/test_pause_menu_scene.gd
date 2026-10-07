extends GutTest

const PAUSE_MENU_SCENE = preload("res://scenes/ui/pause_menu/pause_menu.tscn")

var pause_menu


func before_each():
	pause_menu = PAUSE_MENU_SCENE.instantiate()
	pause_menu.title_scene = ""  # テスト中にシーンを切り替えない
	add_child_autofree(pause_menu)
	pause_menu.open()


func after_each():
	get_tree().paused = false  # ツリーを止めたままにしない


func test_再開でゲームが再開する():
	pause_menu.get_node("%ResumeButton").pressed.emit()
	assert_false(get_tree().paused)


func test_再開でメニューが閉じる():
	pause_menu.get_node("%ResumeButton").pressed.emit()
	assert_false(pause_menu.visible)


func test_一時停止中にEscを押すと再開する():
	var event := InputEventAction.new()
	event.action = "ui_cancel"
	event.pressed = true
	pause_menu._unhandled_input(event)
	assert_false(get_tree().paused)


func test_タイトルへ戻るとき一時停止を解除する():
	pause_menu.get_node("%TitleButton").pressed.emit()
	assert_false(get_tree().paused)


func test_タイトルへ戻るでタイトル画面へ移る():
	watch_signals(pause_menu)
	pause_menu.get_node("%TitleButton").pressed.emit()
	assert_signal_emitted(pause_menu, "title_requested")
