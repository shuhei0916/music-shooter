extends GutTest

class_name TestMainGate

var main_script := preload("res://scenes/main/main.gd")
var player_scene := preload("res://scenes/characters/player/player.tscn")
var gate_scene := preload("res://scenes/objects/gate/gate.tscn")

var main_node: Node3D
var player
var _gates = []

func before_each():
	main_node = main_script.new()
	player = player_scene.instantiate()
	main_node.player = player
	get_tree().root.add_child(player)
	_gates.clear()

func after_each():
	for gate in _gates:
		if is_instance_valid(gate):
			gate.queue_free()
	if is_instance_valid(player):
		player.queue_free()
	if is_instance_valid(main_node):
		main_node.player = null
		main_node.queue_free()
	main_node = null
	await get_tree().process_frame

func _new_gate():
	var gate = gate_scene.instantiate()
	get_tree().root.add_child(gate)
	_gates.append(gate)
	return gate

func test_ゲート効果適用後にゲートを破棄する():
	player.character_count = 10
	var gate = _new_gate()
	main_node._on_player_entered_gate("add", 5, gate)
	assert_eq(15, player.character_count)
	assert_true(gate.is_queued_for_deletion())

func test_複数回呼び出すとその都度効果が適用される():
	player.character_count = 2
	var gate = _new_gate()
	main_node._on_player_entered_gate("multiply", 3, gate)
	assert_eq(6, player.character_count)
	assert_true(gate.is_queued_for_deletion())

	var second_gate = _new_gate()
	main_node._on_player_entered_gate("add", 4, second_gate)
	assert_eq(10, player.character_count)
	assert_true(second_gate.is_queued_for_deletion())
