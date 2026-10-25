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


func test_進み具合0の敵のHPは基本の範囲に収まる():
	spawner.enemy_hp_min = 10
	spawner.enemy_hp_max = 20
	spawner.inflation_end_scale = 100.0
	spawner._set_enemy_properties(enemy, 0.0)
	assert_between(enemy.hp, 10, 20)


func test_敵のHPにインフレ倍率が掛かる():
	spawner.enemy_hp_min = 10
	spawner.enemy_hp_max = 20
	spawner.inflation_end_scale = 100.0
	spawner._set_enemy_properties(enemy, 1.0)
	assert_between(enemy.hp, 10 * 100, 20 * 100)


func test_加算ゲートの値にインフレ倍率が掛かる():
	var gate = autofree(Gate.new())
	spawner.inflation_end_scale = 100.0
	spawner.multiply_gate_probability = 0.0
	spawner.minus_gate_probability = 0.0
	spawner._set_gate_properties(gate, 1.0)
	assert_between(gate.value, 5 * 100, 20 * 100)


func test_マイナスのゲートの値にもインフレ倍率が掛かる():
	var gate = autofree(Gate.new())
	spawner.inflation_end_scale = 100.0
	spawner.multiply_gate_probability = 0.0
	spawner.minus_gate_probability = 1.0
	spawner._set_gate_properties(gate, 1.0)
	assert_between(gate.value, -20 * 100, -5 * 100)


func test_宝箱の値にインフレ倍率が掛かる():
	var chest = autofree(Gate.new())
	spawner.inflation_end_scale = 100.0
	spawner._set_chest_properties(chest, 1.0)
	assert_between(chest.value, 5 * 100, 20 * 100)


func test_乗算ゲートの確率が100パーセントならx2かx3の乗算ゲートになる():
	var gate = autofree(Gate.new())
	spawner.multiply_gate_probability = 1.0
	spawner._set_gate_properties(gate, 1.0)
	assert_eq("multiply", gate.gate_type)
	assert_between(gate.value, 2, 3)


func test_ターンの種類は5ターンごとにゲート列で最初のゲート列の後はその3ターン後に敵の列():
	var kinds = range(1, 14).map(func(turn): return spawner.turn_kind(turn))
	var expected = ["single", "single", "single", "single", "gate_row"]
	expected += ["single", "single", "enemy_row", "single", "gate_row"]
	expected += ["single", "single", "enemy_row"]
	assert_eq(kinds, expected)


func test_敵の列の3体のHPは同じ基本のHPの0点5倍と1倍と2倍():
	spawner.enemy_hp_min = 1
	spawner.enemy_hp_max = 1000
	var hps: Array = spawner.enemy_row_hps(-1.0)
	hps.sort()
	assert_eq(hps[2], hps[1] * 2)
	assert_almost_eq(hps[0] * 2, hps[1], 1)


func test_ゲート列の中身はレーンの数だけあり1つがレベルアップゲート():
	var specs: Array = spawner.gate_row_specs(10, -1.0, 3)
	assert_eq(specs.size(), 3)
	assert_eq(specs.filter(func(g): return g.gate_type == "level_up").size(), 1)


func _plus_gates(turn: int) -> Array:
	spawner.minus_gate_probability = 1.0
	spawner.multiply_gate_probability = 1.0
	var specs: Array = spawner.gate_row_specs(turn, -1.0, 3)
	return specs.filter(func(g): return g.gate_type == "add" and g.value > 0)


func test_最初のゲート列には必ずプラスの加算ゲートが1つ含まれる():
	assert_eq(_plus_gates(5).size(), 1)


func test_2回目以降のゲート列にはプラスのゲートは保証されない():
	assert_eq(_plus_gates(10).size(), 0)
