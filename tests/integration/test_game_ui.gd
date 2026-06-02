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


func test_set_growth_curveでグラフにデータが設定される():
	var points := PackedVector2Array([Vector2(0.0, 0.0), Vector2(1.0, 5.0)])
	game_ui.set_growth_curve(points)
	var graph = game_ui.get_node("DebugPanel/GrowthCurveGraph")
	assert_eq(graph.points, points)
