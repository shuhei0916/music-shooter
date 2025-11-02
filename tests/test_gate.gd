extends GutTest

class_name TestGate

var gate_scene := load("res://scenes/objects/gate/gate.tscn")
var player_scene := load("res://scenes/characters/player/player.tscn")
var gate
var player

func before_each():
	gate = gate_scene.instantiate()
	player = player_scene.instantiate()
	get_tree().root.add_child(gate)
	get_tree().root.add_child(player)

func after_each():
	if is_instance_valid(gate):
		gate.queue_free()
	if is_instance_valid(player):
		player.queue_free()
	await get_tree().process_frame

func test_クールダウン中のゲートは破棄されない():
	player.try_apply_gate_effect("add", 1)
	gate._on_body_entered(player)
	assert_false(gate.is_queued_for_deletion())
