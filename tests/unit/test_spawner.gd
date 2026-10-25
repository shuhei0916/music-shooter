extends GutTest

const Spawner = preload("res://scenes/components/spawner.gd")
const Enemy = preload("res://scenes/characters/enemy/enemy.gd")
const Gate = preload("res://scenes/objects/gate/gate.gd")

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


func test_成長曲線設定時にprogress0でhp_minになる():
	spawner.enemy_hp_min = 10
	spawner.enemy_hp_max = 20
	spawner.set_growth_curve(PackedVector2Array([Vector2(0.0, 0.0), Vector2(10.0, 100.0)]))

	spawner._set_enemy_properties(enemy, 0.0)
	assert_eq(10, enemy.hp)


func test_成長曲線設定時にprogress1でhp_maxになる():
	spawner.enemy_hp_min = 10
	spawner.enemy_hp_max = 20
	spawner.set_growth_curve(PackedVector2Array([Vector2(0.0, 0.0), Vector2(10.0, 100.0)]))

	spawner._set_enemy_properties(enemy, 1.0)
	assert_eq(20, enemy.hp)


func test_加算ゲートの値にインフレ倍率が掛かる():
	var gate = autofree(Gate.new())
	spawner.inflation_end_scale = 100.0
	spawner.minus_gate_probability = 0.0
	spawner._set_gate_properties(gate, 1.0)
	assert_between(gate.value, 5 * 100, 20 * 100)


func test_マイナスのゲートの値にもインフレ倍率が掛かる():
	var gate = autofree(Gate.new())
	spawner.inflation_end_scale = 100.0
	spawner.minus_gate_probability = 1.0
	spawner._set_gate_properties(gate, 1.0)
	assert_between(gate.value, -20 * 100, -5 * 100)


func test_宝箱の値にインフレ倍率が掛かる():
	var chest = autofree(Gate.new())
	spawner.inflation_end_scale = 100.0
	spawner._set_chest_properties(chest, 1.0)
	assert_between(chest.value, 5 * 100, 20 * 100)
