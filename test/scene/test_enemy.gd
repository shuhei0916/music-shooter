extends GutTest

const EnemyScene := preload("res://scenes/enemy.tscn")
const PlayerScene := preload("res://scenes/player.tscn")
const BulletScene := preload("res://scenes/bullet.tscn")


func _make_enemy(hp: int) -> Enemy:
	var enemy: Enemy = EnemyScene.instantiate()
	enemy.start_hp = hp
	return add_child_autofree(enemy)


func test_弾が当たるとHPが1減り弾は消える():
	var enemy := _make_enemy(3)
	var bullet: Bullet = add_child_autofree(BulletScene.instantiate())
	enemy.area_entered.emit(bullet)
	assert_eq(enemy.health.hp, 2)
	assert_true(bullet.is_queued_for_deletion())


func test_HPが0になった敵は消える():
	var enemy := _make_enemy(1)
	enemy.area_entered.emit(add_child_autofree(BulletScene.instantiate()))
	assert_true(enemy.is_queued_for_deletion())


func test_プレイヤーとぶつかるとHPを削り合う():
	var enemy := _make_enemy(3)
	var player: Player = add_child_autofree(PlayerScene.instantiate())
	player.health.hp = 10
	enemy.area_entered.emit(player)
	assert_eq(player.health.hp, 7)
	assert_true(enemy.is_queued_for_deletion())


func test_頭の上に今のHPを表示する():
	var enemy := _make_enemy(5)
	enemy.area_entered.emit(add_child_autofree(BulletScene.instantiate()))
	assert_eq(enemy.get_node("HpLabel").text, "4")


func _body_color(enemy: Enemy) -> Color:
	return enemy.get_node("Body").material_override.albedo_color


func test_弾が当たると白く光る():
	var enemy := _make_enemy(5)
	enemy.area_entered.emit(add_child_autofree(BulletScene.instantiate()))
	assert_eq(_body_color(enemy), Color.WHITE)


func test_光ったあと時間がたつと元の色に戻る():
	var enemy := _make_enemy(5)
	var original := _body_color(enemy)
	enemy.area_entered.emit(add_child_autofree(BulletScene.instantiate()))
	simulate(enemy, 3, 0.1)
	assert_eq(_body_color(enemy), original)


func test_弾が当たると少しふくらむ():
	var enemy := _make_enemy(5)
	enemy.area_entered.emit(add_child_autofree(BulletScene.instantiate()))
	assert_gt(enemy.get_node("Body").scale.x, 1.0)


func test_ふくらんだあと時間がたつと元の大きさに戻る():
	var enemy := _make_enemy(5)
	enemy.area_entered.emit(add_child_autofree(BulletScene.instantiate()))
	simulate(enemy, 3, 0.1)
	assert_eq(enemy.get_node("Body").scale, Vector3.ONE)
