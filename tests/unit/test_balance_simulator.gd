extends GutTest

const BalanceSimulator = preload("res://scripts/balance_simulator.gd")
const Spawner = preload("res://scenes/components/spawner.gd")


## 決まったターンの種類と中身を返すスポーナー
class FakeSpawner:
	var kinds := {}  # ターン -> 種類
	var gates: Array = []
	var enemy_hps: Array[int] = []

	func turn_kind(turn: int) -> String:
		return kinds.get(turn, "single")

	func gate_row_specs(_turn: int, _progress: float, _lane_count: int) -> Array:
		return gates

	func enemy_row_hps(_progress: float) -> Array[int]:
		return enemy_hps


func _gate(gate_type: String, value: int) -> Spawner.GateSpec:
	var spec := Spawner.GateSpec.new()
	spec.gate_type = gate_type
	spec.value = value
	return spec


func _best(candidates: Array) -> int:
	return candidates.max()


func _worst(candidates: Array) -> int:
	return candidates.min()


func test_ゲート列では選んだゲートの効果がHPに反映される():
	var spawner := FakeSpawner.new()
	spawner.kinds = {1: "gate_row"}
	spawner.gates = [_gate("add", 10), _gate("multiply", 3), _gate("level_up", 0)]
	assert_eq(BalanceSimulator.run(spawner, 1, _best), 11)
	assert_eq(BalanceSimulator.run(spawner, 1, _worst), 1)


func test_敵の列では選んだ敵のHPだけHPが減る():
	var spawner := FakeSpawner.new()
	spawner.kinds = {1: "gate_row", 2: "enemy_row"}
	spawner.gates = [_gate("add", 10)]
	spawner.enemy_hps = [3, 6]
	assert_eq(BalanceSimulator.run(spawner, 2, _best), 8)


func test_HPが0以下になったら0を返す():
	var spawner := FakeSpawner.new()
	spawner.kinds = {1: "enemy_row", 2: "gate_row"}
	spawner.enemy_hps = [5]
	spawner.gates = [_gate("add", 100)]
	assert_eq(BalanceSimulator.run(spawner, 2, _best), 0)
