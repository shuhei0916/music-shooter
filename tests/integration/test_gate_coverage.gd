extends GutTest
## プレイヤーがどこを通っても、ゲート列のいずれかのゲートに触れることを、シーンの設定値から検証する


func _lane_spacing() -> float:
	var spawner: Node = autofree(preload("res://scenes/components/spawner.tscn").instantiate())
	var lanes: Array = spawner.get_node("AnchorRoot").get_children()
	return absf(lanes[1].position.x - lanes[0].position.x)


func _gate_width() -> float:
	var gate: Node = autofree(preload("res://scenes/objects/gate/gate.tscn").instantiate())
	return gate.get_node("CollisionShape3D").shape.size.x


func _player_width() -> float:
	var player: Node = autofree(preload("res://scenes/characters/player/player.tscn").instantiate())
	return player.get_node("CollisionShape3D").shape.radius * 2.0


func test_Playerの当たり判定の幅はゲートどうしのすき間より広い():
	var gap := _lane_spacing() - _gate_width()
	assert_gt(_player_width(), gap)
