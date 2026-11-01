extends GutTest
## デバッグモードで見せる成長曲線のグラフ。横は時刻、縦は強さ（対数）


func _make_graph() -> GrowthGraph:
	var graph := GrowthGraph.new()
	graph.size = Vector2(200, 100)
	add_child_autofree(graph)
	# 規模は 0 秒で 1、10 秒で 1万。ボスは 5 秒で 100
	graph.setup([Vector2(0, 1), Vector2(10, 10_000)], [Vector2(5, 100)], 10.0)
	return graph


func test_横は時刻で縦は強さの対数で左下が始まり右上がいちばん大きい値():
	var graph := _make_graph()
	assert_eq(graph.point_of(0.0, 1.0), Vector2(0, 100))
	assert_eq(graph.point_of(10.0, graph.max_value), Vector2(200, 0))
	var middle := graph.point_of(5.0, sqrt(graph.max_value))
	assert_almost_eq(middle.x, 100.0, 0.001)
	assert_almost_eq(middle.y, 50.0, 0.001)


func test_縦のいちばん大きい値は曲線とボスのいちばん大きい値より上に余裕をとる():
	var graph := _make_graph()
	assert_gt(graph.max_value, 10_000.0)


func test_1より小さい値と大きすぎる値はグラフの枠に収める():
	var graph := _make_graph()
	assert_eq(graph.point_of(0.0, 0.0).y, 100.0)
	assert_eq(graph.point_of(0.0, graph.max_value * 1000).y, 0.0)


func test_いまの時刻とプレイヤーの強さを渡すと記録して縦線を進める():
	var graph := _make_graph()
	graph.show_at(2.0, 50)
	graph.show_at(4.0, 80)
	assert_eq(graph.time, 4.0)
	assert_eq(graph.player_points, [Vector2(2, 50), Vector2(4, 80)])


func test_毎フレーム少しずつ進んでも一定の間隔ごとに点を残し最後の点はいまの値にする():
	var graph := _make_graph()
	for frame in 61:
		graph.show_at(frame / 60.0, 10 + frame)
	assert_gte(graph.player_points.size(), 4)
	assert_eq(graph.player_points.back(), Vector2(1, 70))
	for i in range(1, graph.player_points.size() - 1):
		var gap := graph.player_points[i].x - graph.player_points[i - 1].x
		assert_gte(gap, GrowthGraph.RECORD_STEP - 0.001)


func test_プレイヤーの値が縦の上限に近づくと上限を広げて枠に収める():
	var graph := _make_graph()
	var before := graph.max_value
	graph.show_at(1.0, before * 5)
	assert_gt(graph.max_value, before * 5)
	assert_gt(graph.point_of(1.0, before * 5).y, 0.0)
