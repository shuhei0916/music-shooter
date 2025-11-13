extends Node

@export var gate_scene: PackedScene

@onready var anchor_root: Node3D = $AnchorRoot
@onready var spawn_timer: Timer = $SpawnTimer

var spawn_counter := 0

func _ready() -> void:
	pass

func _on_spawn_timer_timeout() -> void:
	spawn_counter += 1
	if spawn_counter % 5 == 0:
		_spawn_gate_row()
	else:
		# TODO: 敵スポーン実装
		pass

func _spawn_gate_row() -> void:
	for marker in anchor_root.get_children():
		var gate = gate_scene.instantiate()
		gate.global_transform = marker.global_transform
		_set_gate_properties(gate)
		add_child(gate)

func _set_gate_properties(gate: Node) -> void:
	gate.gate_type = "add"
	gate.value = randi_range(5, 20)
