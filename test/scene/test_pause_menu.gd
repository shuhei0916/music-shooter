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
