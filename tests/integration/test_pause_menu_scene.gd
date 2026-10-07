extends GutTest

const PAUSE_MENU_SCENE = preload("res://scenes/ui/pause_menu/pause_menu.tscn")

var pause_menu


func before_each():
	pause_menu = PAUSE_MENU_SCENE.instantiate()
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
