extends GutTest

const GAME_UI_SCENE := preload("res://scenes/ui/game_ui.tscn")

var game_ui


func before_each():
	game_ui = GAME_UI_SCENE.instantiate()
	add_child_autofree(game_ui)
	await get_tree().process_frame
	self.game_ui = game_ui


func test_show_resultで敗北パネルが表示される():
	assert_false(game_ui.result_panel.visible)

	game_ui.show_result(false)

	assert_true(game_ui.result_panel.visible)
	assert_true(game_ui.result_label.text.begins_with("Game Over"))


func test_show_resultで勝利パネルが表示される():
	assert_false(game_ui.result_panel.visible)

	game_ui.show_result(true)

	assert_true(game_ui.result_panel.visible)
	assert_true(game_ui.result_label.text.begins_with("Run Completed"))


func test_toggle_debugでデバッグオーバーレイの表示が切り替わる():
	var initial = game_ui.debug_overlay.visible
	game_ui.toggle_debug()
	assert_eq(not initial, game_ui.debug_overlay.visible)


func test_notify_midi_eventで新チャンネルの行が追加される():
	var vbox = game_ui.debug_overlay.get_node("VBoxContainer")
	var before = vbox.get_child_count()
	game_ui.notify_midi_event(0, "Track A", 60, 80)
	assert_eq(before + 1, vbox.get_child_count())


func test_notify_midi_event同一チャンネルを2回呼んでも行が増えない():
	var vbox = game_ui.debug_overlay.get_node("VBoxContainer")
	game_ui.notify_midi_event(0, "Track A", 60, 80)
	var after_first = vbox.get_child_count()
	game_ui.notify_midi_event(0, "Track A", 62, 90)
	assert_eq(after_first, vbox.get_child_count())
