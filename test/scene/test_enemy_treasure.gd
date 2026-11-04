extends GutTest
## 倒した敵が宝箱を落とす動き

const EnemyScene := preload("res://scenes/enemy.tscn")
const PlayerScene := preload("res://scenes/player.tscn")
const BulletScene := preload("res://scenes/bullet.tscn")


## 敵が親に置くもの（宝箱など）を調べやすいよう、テストごとに専用の親の下に置く
func _make_enemy(hp: int, lanes := 1) -> Enemy:
	var enemy: Enemy = EnemyScene.instantiate()
	enemy.start_hp = hp
	enemy.lanes_wide = lanes
	add_child_autofree(Node3D.new()).add_child(enemy)
	return enemy


func _treasures(enemy: Enemy) -> Array:
	return enemy.get_parent().get_children().filter(func(n): return n is Treasure)


func test_弾で倒すとその場所に出たときのHPを中身とする宝箱を落とす():
	var enemy := _make_enemy(5)
	enemy.position = Vector3(3, 0, -40)
	var bullet: Bullet = add_child_autofree(BulletScene.instantiate())
	bullet.damage = 5
	enemy.area_entered.emit(bullet)
	var treasures := _treasures(enemy)
	assert_eq(treasures.size(), 1)
	assert_eq(treasures[0].hp_bonus, 5)
	assert_eq(treasures[0].position, Vector3(3, 0, -40))


func test_倒しきれなければ宝箱は落とさない():
	var enemy := _make_enemy(5)
	enemy.area_entered.emit(add_child_autofree(BulletScene.instantiate()))
	assert_eq(_treasures(enemy).size(), 0)


func test_ぶつかって倒したときは宝箱を落とさない():
	var enemy := _make_enemy(3)
	var player: Player = add_child_autofree(PlayerScene.instantiate())
	player.health.hp = 10
	enemy.area_entered.emit(player)
	assert_eq(_treasures(enemy).size(), 0)


func test_ボスの宝箱はボスと同じだけのレーンを占める():
	var boss := _make_enemy(1, 3)
	boss.area_entered.emit(add_child_autofree(BulletScene.instantiate()))
	assert_eq(_treasures(boss)[0].lanes_wide, 3)
