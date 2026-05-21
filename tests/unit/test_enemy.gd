extends GutTest

const Enemy = preload("res://scenes/characters/enemy/enemy.gd")
const Bullet = preload("res://scenes/objects/bullet/bullet.gd")

var enemy
var bullet

func before_each():
	enemy = Enemy.new()
	enemy.hp = 5
	bullet = Bullet.new()
	bullet.add_to_group("bullet")
	add_child_autofree(enemy)
	add_child_autofree(bullet)

func test_弾丸と衝突すると敵にダメージが入る():
	var hp_before = enemy.hp
	enemy._on_area_entered(bullet)
	assert_eq(enemy.hp, hp_before - 1)
