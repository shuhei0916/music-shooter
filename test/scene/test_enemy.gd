extends GutTest

const EnemyScene := preload("res://scenes/enemy.tscn")
const PlayerScene := preload("res://scenes/player.tscn")
const BulletScene := preload("res://scenes/bullet.tscn")


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


func _shape_width(scene: PackedScene) -> float:
	var node: Node = autofree(scene.instantiate())
	var shape: Shape3D = node.get_node("CollisionShape3D").shape
	if shape is CylinderShape3D:
		return shape.radius * 2.0
	return shape.size.x


func test_隣り合うレーンの敵のあいだはプレイヤーが通れないほど狭い():
	var main: Main = autofree(preload("res://scenes/main.tscn").instantiate())
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


## BPM 120（1拍 0.5 秒）の曲を time 秒まで進めた時計と拍の線を、敵に渡す
func _sync_to_beat(enemy: Enemy, time: float) -> TimerClock:
	var clock := TimerClock.new(100.0)
	clock.advance(time)
	enemy.clock = clock
	enemy.grid = BeatGrid.new(120.0)
	return clock


func _hit(enemy: Enemy, damage: int) -> void:
	var bullet: Bullet = add_child_autofree(BulletScene.instantiate())
	bullet.damage = damage
	enemy.area_entered.emit(bullet)


func test_拍に合わせるときは当たってすぐにはHPだけが減り演出はまだ出ない():
	var enemy := _make_enemy(5)
	var original := _body_color(enemy)
	_sync_to_beat(enemy, 0.3)
	_hit(enemy, 2)
	assert_eq(enemy.health.hp, 3)
	assert_eq(_body_color(enemy), original)
	assert_eq(_damage_texts(enemy).size(), 0)


func test_拍に合わせるときは次の四分の一拍で光り数字が出る():
	var enemy := _make_enemy(5)
	var clock := _sync_to_beat(enemy, 0.3)
	_hit(enemy, 2)
	clock.advance(0.075)
	simulate(enemy, 1, 0.0)
	assert_eq(_body_color(enemy), Color.WHITE)
	assert_eq(_damage_texts(enemy).map(func(t): return t.text), ["2"])


func test_演出が出るまでに続けて当たったダメージは1つの数字にまとめる():
	var enemy := _make_enemy(10)
	var clock := _sync_to_beat(enemy, 0.3)
	_hit(enemy, 2)
	_hit(enemy, 3)
	clock.advance(0.075)
	simulate(enemy, 1, 0.0)
	assert_eq(_damage_texts(enemy).map(func(t): return t.text), ["5"])
