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


func test_一度くぐったゲートは二度は効かない():
	var gate_area := _make_gate(Gate.Op.ADD, 5)
	var player := _make_player(1)
	gate_area.area_entered.emit(player)
	gate_area.area_entered.emit(player)
	assert_eq(player.health.hp, 6)


func test_弾が当たってもゲートは使われない():
	var gate_area := _make_gate(Gate.Op.ADD, 5)
	var player := _make_player(1)
	gate_area.area_entered.emit(add_child_autofree(Bullet.new()))
	gate_area.area_entered.emit(player)
	assert_eq(player.health.hp, 6)


func test_ゲートに効果の文字を表示する():
	var gate_area := _make_gate(Gate.Op.MULTIPLY, 2)
	assert_eq(gate_area.get_node("Label").text, "×2")


func test_並んだゲートの片方をくぐると隣のゲートは効かなくなる():
	var pair: Node3D = add_child_autofree(Node3D.new())
	var left: GateArea = GateScene.instantiate()
	var right: GateArea = GateScene.instantiate()
	left.amount = 5
	right.amount = 100
	pair.add_child(left)
	pair.add_child(right)
	var player := _make_player(1)
	left.area_entered.emit(player)
	right.area_entered.emit(player)
	assert_eq(player.health.hp, 6)


func test_くぐったゲートは消える():
	var gate_area := _make_gate(Gate.Op.ADD, 5)
	gate_area.area_entered.emit(_make_player(1))
	assert_true(gate_area.is_queued_for_deletion())


func test_くぐらなかった隣のゲートは消えずに残る():
	var pair: Node3D = add_child_autofree(Node3D.new())
	var left: GateArea = GateScene.instantiate()
	var right: GateArea = GateScene.instantiate()
	pair.add_child(left)
	pair.add_child(right)
	left.area_entered.emit(_make_player(1))
	assert_false(right.is_queued_for_deletion())


func test_両方のゲートに触れたときはプレイヤーに近いほうが効く():
	var pair: Node3D = add_child_autofree(Node3D.new())
	var left: GateArea = GateScene.instantiate()
	var right: GateArea = GateScene.instantiate()
	left.position.x = -2.0
	left.amount = 5
	right.position.x = 2.0
	right.amount = 100
	pair.add_child(left)
	pair.add_child(right)
	var player := _make_player(1)
	player.position.x = 0.3
	left.area_entered.emit(player)
	right.area_entered.emit(player)
	assert_eq(player.health.hp, 101)
	assert_true(right.is_queued_for_deletion())
	assert_false(left.is_queued_for_deletion())


func test_左右のゲートからちょうど同じ距離なら左のゲートが効く():
	var pair: Node3D = add_child_autofree(Node3D.new())
	var left: GateArea = GateScene.instantiate()
	var right: GateArea = GateScene.instantiate()
	left.position.x = -2.0
	left.amount = 5
	right.position.x = 2.0
	right.amount = 100
	pair.add_child(left)
	pair.add_child(right)
	var player := _make_player(1)
	right.area_entered.emit(player)
	assert_eq(player.health.hp, 6)
