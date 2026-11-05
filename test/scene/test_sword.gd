extends GutTest
## 撃ち出した剣。いちばん近い敵を追いかけ、当たると弾と同じようにダメージを与える

const SwordScene := preload("res://scenes/sword.tscn")
const EnemyScene := preload("res://scenes/enemy.tscn")

var _stage: Node3D


func before_each():
	_stage = add_child_autofree(Node3D.new())


func _add_enemy(position: Vector3, hp := 5) -> Enemy:
	var enemy: Enemy = EnemyScene.instantiate()
	enemy.start_hp = hp
	enemy.position = position
	_stage.add_child(enemy)
	return enemy


func _add_sword(position := Vector3.ZERO) -> Sword:
	var sword: Sword = SwordScene.instantiate()
	sword.position = position
	_stage.add_child(sword)
	return sword


func test_剣は弾として敵にダメージを与える():
	var enemy := _add_enemy(Vector3(0, 0, -5))
	var sword := _add_sword()
	sword.damage = 3
	enemy.area_entered.emit(sword)
	assert_eq(enemy.health.hp, 2)


func test_前にいるいちばん近い敵をねらう():
	var near := _add_enemy(Vector3(3, 0, -4))
	_add_enemy(Vector3(0, 0, -10))
	assert_eq(Sword.nearest(Vector3.ZERO, _stage.get_children()), near)


func test_後ろの敵と倒れた敵と遠すぎる敵はねらわない():
	_add_enemy(Vector3(0, 0, 2))
	var dead := _add_enemy(Vector3(0, 0, -2), 1)
	dead.health.damage(1)
	_add_enemy(Vector3(0, 0, -Sword.SEEK_RANGE - 1.0))
	assert_null(Sword.nearest(Vector3.ZERO, _stage.get_children()))


func test_横にいる敵へ向かって近づいていく():
	var enemy := _add_enemy(Vector3(6, 0, -6))
	var sword := _add_sword()
	var before := sword.position.distance_to(enemy.position)
	simulate(sword, 3, 0.05)
	assert_gt(sword.position.x, 0.0)
	assert_lt(sword.position.distance_to(enemy.position), before)


func test_ねらう敵がいなければまっすぐ前へ飛ぶ():
	var sword := _add_sword()
	simulate(sword, 1, 0.1)
	assert_almost_eq(sword.position.x, 0.0, 0.001)
	assert_lt(sword.position.z, 0.0)


func test_ねらった敵が倒れても乗りかえずにそのまま飛ぶ():
	var first := _add_enemy(Vector3(-4, 0, -4), 1)
	_add_enemy(Vector3(6, 0, -6))
	var sword := _add_sword()
	simulate(sword, 1, 0.01)
	first.health.damage(1)
	var x := sword.position.x
	simulate(sword, 3, 0.05)
	assert_lt(sword.position.x, x)


func test_乗りかえられる剣はねらった敵が倒れたら次に近い敵に乗りかえる():
	var first := _add_enemy(Vector3(-4, 0, -4), 1)
	_add_enemy(Vector3(6, 0, -6))
	var sword := _add_sword()
	sword.retarget = true
	simulate(sword, 1, 0.01)
	first.health.damage(1)
	var x := sword.position.x
	simulate(sword, 3, 0.05)
	assert_gt(sword.position.x, x)


func test_撃ったときにねらう敵がいなくてもあとから来た敵をねらう():
	var sword := _add_sword()
	simulate(sword, 1, 0.01)
	_add_enemy(Vector3(6, 0, -6))
	var x := sword.position.x
	simulate(sword, 3, 0.05)
	assert_gt(sword.position.x, x)
