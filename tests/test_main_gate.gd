extends GutTest

class_name TestMainGate

var main_script := preload("res://main.gd")
var player_scene := preload("res://player/player.tscn")
var gate_scene := preload("res://gate.tscn")

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

func test_ゲート効果適用時のみゲートが破棄される():
	var gate1 = _new_gate()
	main_node._on_player_entered_gate("add", 2, gate1)
	assert_true(gate1.is_queued_for_deletion())
	await get_tree().process_frame

	var gate2 = _new_gate()
	main_node._on_player_entered_gate("multiply", 3, gate2)
	assert_false(gate2.is_queued_for_deletion())
