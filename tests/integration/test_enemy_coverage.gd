extends GutTest
## 3レーンに並んだ敵の列を、プレイヤーがよけられない（すり抜けも2体同時の衝突も起きない）ことを、シーンの設定値から検証する

const SPAWNER_SCENE = preload("res://scenes/components/spawner.tscn")
const ENEMY_SCENE = preload("res://scenes/characters/enemy/enemy.tscn")
const PLAYER_SCENE = preload("res://scenes/characters/player/player.tscn")


func _lanes() -> Array:
	var spawner: Node = autofree(SPAWNER_SCENE.instantiate())
	return spawner.get_node("AnchorRoot").get_children()


func _lane_spacing() -> float:
	var lanes := _lanes()
	return absf(lanes[1].position.x - lanes[0].position.x)


func _enemy_width() -> float:
	var enemy: Node = autofree(ENEMY_SCENE.instantiate())
	return enemy.get_node("CollisionShape3D").shape.size.x


func _player_width() -> float:
	var player: Node = autofree(PLAYER_SCENE.instantiate())
	return player.get_node("CollisionShape3D").shape.radius * 2.0


func test_敵と敵のすき間はPlayerの当たり判定の幅と同じ():
	assert_almost_eq(_lane_spacing() - _enemy_width(), _player_width(), 0.001)


func test_端のレーンの敵の外側を通り抜けられない():
	var player: Node = autofree(PLAYER_SCENE.instantiate())
	var lanes := _lanes()
	var half := _player_width() / 2.0
	var enemy_half := _enemy_width() / 2.0
	assert_lt(player.horizontal_limit_max - half, lanes[-1].position.x + enemy_half, "右端")
	assert_gt(player.horizontal_limit_min + half, lanes[0].position.x - enemy_half, "左端")
