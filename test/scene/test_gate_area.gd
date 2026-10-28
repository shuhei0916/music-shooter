extends GutTest

const GateScene := preload("res://scenes/gate.tscn")
const PlayerScene := preload("res://scenes/player.tscn")


func _make_gate(op: Gate.Op, amount: int) -> GateArea:
	var gate_area: GateArea = GateScene.instantiate()
	gate_area.op = op
	gate_area.amount = amount
	return add_child_autofree(gate_area)


func _make_player(hp: int) -> Player:
	var player: Player = PlayerScene.instantiate()
	player.start_hp = hp
	return add_child_autofree(player)


func test_プレイヤーがくぐるとゲートの効果でHPが変わる():
	var gate_area := _make_gate(Gate.Op.MULTIPLY, 3)
	var player := _make_player(4)
	gate_area.area_entered.emit(player)
	assert_eq(player.health.hp, 12)
