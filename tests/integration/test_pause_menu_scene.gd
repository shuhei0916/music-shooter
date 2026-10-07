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
