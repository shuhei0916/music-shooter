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
