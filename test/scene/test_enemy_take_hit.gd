extends GutTest
## 敵が、弾のほかに衝撃波などプレイヤーの武器から直接ダメージを受けるところ

const EnemyScene := preload("res://scenes/enemy.tscn")


func _make_enemy(hp: int) -> Enemy:
	var enemy: Enemy = EnemyScene.instantiate()
	enemy.start_hp = hp
	add_child_autofree(Node3D.new()).add_child(enemy)
	return enemy


func test_武器のダメージを受けるとHPが減る():
	var enemy := _make_enemy(5)
	enemy.take_hit(2)
	assert_eq(enemy.health.hp, 3)
	assert_eq(enemy.get_node("HpLabel").text, "3")


func test_倒れた敵は武器のダメージを受けない():
	var enemy := _make_enemy(1)
	enemy.take_hit(1)
	enemy.take_hit(1)
	assert_eq(enemy.health.hp, 0)
