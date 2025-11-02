extends GutTest

class_name TestGate

var gate_scene := load("res://scenes/objects/gate/gate.tscn")
var player_scene := load("res://scenes/characters/player/player.tscn")
var gate
var player
var emitted := []

func before_each():
	gate = gate_scene.instantiate()
	player = player_scene.instantiate()
	gate.player_entered_gate.connect(_on_gate_signal)
	get_tree().root.add_child(gate)
	get_tree().root.add_child(player)
	emitted.clear()

func after_each():
	if is_instance_valid(gate):
		gate.queue_free()
	if is_instance_valid(player):
		player.queue_free()
	emitted.clear()
	await get_tree().process_frame

func _on_gate_signal(gate_type, value, gate_node):
	emitted.append({"type": gate_type, "value": value, "node": gate_node})

func test_ゲートは衝突時にシグナルを発火する():
	gate.gate_type = "add"
	gate.value = 3
	gate._on_body_entered(player)
	assert_eq(1, emitted.size())
	var record = emitted[0]
	assert_eq("add", record["type"])
	assert_eq(3, record["value"])
	assert_eq(gate, record["node"])
