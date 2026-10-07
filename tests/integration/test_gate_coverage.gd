extends GutTest
## プレイヤーがゲート列を通るとき、二重取りできず、すり抜けもほぼ起きないことを、シーンの設定値から検証する

const SPAWNER_SCENE = preload("res://scenes/components/spawner.tscn")
const GATE_SCENE = preload("res://scenes/objects/gate/gate.tscn")
const PLAYER_SCENE = preload("res://scenes/characters/player/player.tscn")


func _lane_spacing() -> float:
	var spawner: Node = autofree(SPAWNER_SCENE.instantiate())
	var lanes: Array = spawner.get_node("AnchorRoot").get_children()
	return absf(lanes[1].position.x - lanes[0].position.x)


func _gate() -> Node:
	return autofree(GATE_SCENE.instantiate())


func _gate_width() -> float:
	return _gate().get_node("CollisionShape3D").shape.size.x


func _player_width() -> float:
	var player: Node = autofree(PLAYER_SCENE.instantiate())
	return player.get_node("CollisionShape3D").shape.radius * 2.0


func test_Playerの当たり判定の幅はゲートどうしのすき間より広い():
	var gap := _lane_spacing() - _gate_width()
	assert_gt(_player_width(), gap)


func test_ゲートの見た目の幅と当たり判定の幅が一致する():
	var mesh_width: float = _gate().get_node("Pivot/MeshInstance3D").mesh.size.x
	assert_eq(mesh_width, _gate_width())
