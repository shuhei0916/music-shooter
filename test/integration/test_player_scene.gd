extends GutTest

var gate
var player
var enemy 

func before_each():
	gate = preload("res://scenes/objects/gate/gate.tscn").instantiate()
	player = preload("res://scenes/characters/player/player.tscn").instantiate()
	enemy = preload("res://scenes/characters/enemy/enemy.tscn").instantiate()
	
	add_child_autofree(gate)
	add_child_autofree(player)
	add_child_autofree(enemy)


func after_each():
	player.free()
	
# 単体テストへの切り出しに失敗。とりあえずここに残している。
func test_shootが呼ばれると弾丸がシーンに追加される():
	var bullet_parent = Node3D.new()
	add_child_autofree(bullet_parent)

	player.bullet_container = bullet_parent
	player.shoot()

	var bullets = bullet_parent.get_children()
	assert_eq(1, bullets.size())
	assert_true(bullets[0].is_in_group("bullet"))

# test_enemyへ移行予定。
func test_弾丸と敵が衝突すると敵にダメージが入る():
	var bullet = preload("res://scenes/objects/bullet/bullet.tscn").instantiate()
	add_child_autofree(bullet)
	var hp_before = enemy.hp
	enemy._on_area_entered(bullet)
	assert_true(enemy.hp < hp_before)
	assert_eq(enemy.hp, hp_before - 1)
	
