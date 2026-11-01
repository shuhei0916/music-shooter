extends GutTest

const EnemyScene := preload("res://scenes/enemy.tscn")
const PlayerScene := preload("res://scenes/player.tscn")
const BulletScene := preload("res://scenes/bullet.tscn")
const MainScene := preload("res://scenes/main.tscn")


## 敵が親に置くもの（ダメージの数字など）を調べやすいよう、テストごとに専用の親の下に置く
func _make_enemy(hp: int) -> Enemy:
	var enemy: Enemy = EnemyScene.instantiate()
	enemy.start_hp = hp
	add_child_autofree(Node3D.new()).add_child(enemy)
	return enemy


func test_弾が当たるとHPが1減り弾は消える():
	var enemy := _make_enemy(3)
	var bullet: Bullet = add_child_autofree(BulletScene.instantiate())
	enemy.area_entered.emit(bullet)
	assert_eq(enemy.health.hp, 2)
	assert_true(bullet.is_queued_for_deletion())


func test_HPが0になった敵は倒れる演出が終わると消える():
	var enemy := _make_enemy(1)
	enemy.area_entered.emit(add_child_autofree(BulletScene.instantiate()))
	assert_false(enemy.is_queued_for_deletion())
	simulate(enemy, 2, enemy.death_duration / 2.0)
	assert_true(enemy.is_queued_for_deletion())


func test_倒れる演出のあいだはふくらみながら薄くなる():
	var enemy := _make_enemy(1)
	enemy.area_entered.emit(add_child_autofree(BulletScene.instantiate()))
	simulate(enemy, 1, enemy.death_duration / 2.0)
	assert_gt(enemy.get_node("Body").scale.x, 1.0)
	assert_lt(_body_color(enemy).a, 1.0)
	assert_gt(_body_color(enemy).a, 0.0)
	assert_false(enemy.get_node("HpLabel").visible)


func test_倒れた敵には弾が当たらない():
	var enemy := _make_enemy(1)
	enemy.area_entered.emit(add_child_autofree(BulletScene.instantiate()))
	var bullet: Bullet = add_child_autofree(BulletScene.instantiate())
	enemy.area_entered.emit(bullet)
	assert_false(bullet.is_queued_for_deletion())


func test_倒れた敵にはぶつからない():
	var enemy := _make_enemy(1)
	enemy.area_entered.emit(add_child_autofree(BulletScene.instantiate()))
	var player: Player = add_child_autofree(PlayerScene.instantiate())
	player.health.hp = 10
	enemy.area_entered.emit(player)
	assert_eq(player.health.hp, 10)


func test_プレイヤーとぶつかるとHPを削り合う():
	var enemy := _make_enemy(3)
	var player: Player = add_child_autofree(PlayerScene.instantiate())
	player.health.hp = 10
	enemy.area_entered.emit(player)
	assert_eq(player.health.hp, 7)
	assert_true(enemy.health.is_dead())


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


func _shape_width(scene: PackedScene) -> float:
	var node: Node = autofree(scene.instantiate())
	var shape: Shape3D = node.get_node("CollisionShape3D").shape
	if shape is CylinderShape3D:
		return shape.radius * 2.0
	return shape.size.x


func test_隣り合うレーンの敵のあいだはプレイヤーが通れないほど狭い():
	var main: Main = autofree(MainScene.instantiate())
	var gap := main.lane_width - _shape_width(EnemyScene)
	assert_lt(gap, _shape_width(PlayerScene))


func test_弾の威力の分だけHPが減る():
	var enemy := _make_enemy(5)
	var bullet: Bullet = add_child_autofree(BulletScene.instantiate())
	bullet.damage = 3
	enemy.area_entered.emit(bullet)
	assert_eq(enemy.health.hp, 2)


func test_大きなHPは短く表示する():
	var enemy := _make_enemy(1_234_567_890)
	assert_eq(enemy.get_node("HpLabel").text, "1.2b")


func _damage_texts(enemy: Enemy) -> Array:
	return enemy.get_parent().get_children().filter(func(n): return n is FloatingText)


func test_弾が当たると受けたダメージの数字が出る():
	var enemy := _make_enemy(5000)
	var bullet: Bullet = add_child_autofree(BulletScene.instantiate())
	bullet.damage = 1200
	enemy.area_entered.emit(bullet)
	var texts := _damage_texts(enemy)
	assert_eq(texts.size(), 1)
	assert_eq(texts[0].text, "1.2k")
	assert_gt(texts[0].global_position.y, enemy.global_position.y)


func _make_big_enemy(hp: int, lanes := 3) -> Enemy:
	var enemy: Enemy = EnemyScene.instantiate()
	enemy.start_hp = hp
	enemy.lanes_wide = lanes
	add_child_autofree(Node3D.new()).add_child(enemy)
	return enemy


func test_ボスは高さはふつうの敵と同じで横と奥行きだけ大きく出る():
	var boss := _make_big_enemy(5, 3)
	assert_almost_eq(boss.scale.y, 1.0, 0.001)
	assert_gt(boss.scale.x, 2.0)
	assert_almost_eq(boss.scale.z, boss.scale.x, 0.001)
	assert_eq(_make_enemy(5).scale, Vector3.ONE)


func test_ボスの横には端まで寄ったプレイヤーもすり抜けられない():
	var boss := _make_big_enemy(5, 3)
	var player: Player = autofree(PlayerScene.instantiate())
	var reach: float = (_shape_width(EnemyScene) * boss.scale.x + _shape_width(PlayerScene)) / 2
	assert_gt(reach, player.road_half_width)
	# すり抜けられないことが保証できれば十分なので、それより大きくはしすぎない
	assert_lt(reach, player.road_half_width + 0.5)


func test_ボスのHPの文字は横に伸びない():
	var boss := _make_big_enemy(5, 3)
	var label_scale: Vector3 = boss.get_node("HpLabel").global_transform.basis.get_scale()
	assert_almost_eq(label_scale.x, label_scale.y, 0.001)


func test_ボスのダメージの数字はふつうの敵と同じ高さに出る():
	var small := _make_enemy(5000)
	var big := _make_big_enemy(5000)
	for enemy in [small, big]:
		var bullet: Bullet = add_child_autofree(BulletScene.instantiate())
		enemy.area_entered.emit(bullet)
	var small_y: float = _damage_texts(small)[0].position.y
	var big_y: float = _damage_texts(big)[0].position.y
	assert_almost_eq(big_y, small_y, 0.001)
