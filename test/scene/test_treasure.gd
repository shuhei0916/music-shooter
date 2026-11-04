extends GutTest
## 倒した敵が落とす宝箱。プレイヤーが触れると中身の分だけ HP が増える

const TreasureScene := preload("res://scenes/treasure.tscn")
const PlayerScene := preload("res://scenes/player.tscn")
const BulletScene := preload("res://scenes/bullet.tscn")


func _make_treasure(hp_bonus: int, lanes := 1) -> Treasure:
	var treasure: Treasure = TreasureScene.instantiate()
	treasure.hp_bonus = hp_bonus
	treasure.lanes_wide = lanes
	add_child_autofree(treasure)
	return treasure


func _make_player(hp: int) -> Player:
	var player: Player = add_child_autofree(PlayerScene.instantiate())
	player.health.hp = hp
	return player


func test_プレイヤーが触れると中身の分だけHPが増え宝箱は消える():
	var treasure := _make_treasure(30)
	var player := _make_player(10)
	treasure.area_entered.emit(player)
	assert_eq(player.health.hp, 40)
	assert_true(treasure.is_queued_for_deletion())


func test_取れるのは1回だけ():
	var treasure := _make_treasure(30)
	var player := _make_player(10)
	treasure.area_entered.emit(player)
	treasure.area_entered.emit(player)
	assert_eq(player.health.hp, 40)


func test_弾が当たっても何も起きない():
	var treasure := _make_treasure(30)
	var bullet: Bullet = add_child_autofree(BulletScene.instantiate())
	treasure.area_entered.emit(bullet)
	assert_false(treasure.is_queued_for_deletion())
	assert_false(bullet.is_queued_for_deletion())


func test_頭の上に中身を短く表示する():
	var treasure := _make_treasure(1_234)
	assert_eq(treasure.get_node("Label").text, "+1.2k")


func test_取るとプレイヤーの頭の上に増えた数が出る():
	var treasure := _make_treasure(1_234)
	var player := _make_player(10)
	treasure.area_entered.emit(player)
	var texts := player.get_children().filter(func(n): return n is FloatingText)
	assert_eq(texts.map(func(t): return t.text), ["+1.2k"])


func test_拍の線があれば数字は2拍で消える():
	var treasure := _make_treasure(30)
	treasure.grid = BeatGrid.new(120.0)
	var player := _make_player(10)
	treasure.area_entered.emit(player)
	var text: FloatingText = player.get_children().filter(func(n): return n is FloatingText)[0]
	assert_almost_eq(text.duration, 1.0, 0.001)


func test_ボスの宝箱はボスと同じだけ横と奥行きが大きく高さは変わらない():
	var treasure := _make_treasure(30, 3)
	assert_almost_eq(treasure.scale.x, Enemy.SCALE_PER_LANE * 3, 0.001)
	assert_almost_eq(treasure.scale.z, Enemy.SCALE_PER_LANE * 3, 0.001)
	assert_almost_eq(treasure.scale.y, 1.0, 0.001)
	assert_eq(_make_treasure(30).scale, Vector3.ONE)


func test_当たり判定の幅は敵と同じ():
	var treasure := _make_treasure(30)
	var enemy: Enemy = autofree(preload("res://scenes/enemy.tscn").instantiate())
	var enemy_shape: CylinderShape3D = enemy.get_node("CollisionShape3D").shape
	var shape: BoxShape3D = treasure.get_node("CollisionShape3D").shape
	assert_almost_eq(shape.size.x, enemy_shape.radius * 2.0, 0.001)
