extends Node

signal gate_spawned(gate_instance)

@export var gate_scene: PackedScene

@onready var anchor_root: Node3D = $AnchorRoot
@onready var spawn_timer: Timer = $SpawnTimer

var spawn_counter := 0

func _ready():
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
		add_child(gate)
		gate_spawned.emit(gate)
