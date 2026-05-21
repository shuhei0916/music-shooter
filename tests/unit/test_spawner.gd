extends GutTest

const Spawner = preload("res://scenes/components/spawner.gd")
const Enemy = preload("res://scenes/characters/enemy/enemy.gd")

var spawner
var enemy

func before_each():
	spawner = Spawner.new()
	enemy = Enemy.new()
	
func after_each():
	spawner.free()
	enemy.free()
	
func test_敵のHPが範囲内に収まる():
	spawner.enemy_hp_min = 12
	spawner.enemy_hp_max = 12
	enemy.hp = 0
	
	spawner._set_enemy_properties(enemy)
	assert_eq(12, enemy.hp)
