extends GutTest

func test_成長曲線データをグラフに渡す():
	var scene = load("res://scenes/ui/debug_midi_ui.tscn").instantiate()
	add_child_autofree(scene)

	var growth_points = PackedVector2Array([Vector2(0, 0), Vector2(120, 3), Vector2(240, 5)])
	scene.update_growth_curve(growth_points)

	var graph = scene.get_node_or_null("GrowthCurveGraph")
	assert_true(graph != null and graph.points == growth_points, "成長曲線データがグラフに反映されること")
