extends Node

@export var gate_scene: PackedScene
@export var enemy_scene: PackedScene
@export var enemy_spawn_probability: float = 0.1

@onready var anchor_root: Node3D = $AnchorRoot
@onready var spawn_timer: Timer = $SpawnTimer
@onready var main_scene: Node = get_parent()

var spawn_counter := 0
var markers

func _ready() -> void:
	markers = anchor_root.get_children()

func _on_spawn_timer_timeout() -> void:
	spawn_counter += 1
	if spawn_counter % 5 == 0:
		_spawn_gate_row()
	else:
		_maybe_spawn_enemy()

func _spawn_gate_row() -> void:
	for marker in markers:
		var gate = gate_scene.instantiate()
		gate.global_transform = marker.global_transform
		_set_gate_properties(gate)
		main_scene.add_child(gate)

func _set_gate_properties(gate: Node) -> void:
	gate.gate_type = "add"
	gate.value = randi_range(5, 20)		

func _maybe_spawn_enemy() -> void:
	if randf() < enemy_spawn_probability:
		_spawn_enemy()

func _spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	enemy.global_transform = _pick_random_marker().global_transform
	main_scene.add_child(enemy)

func _pick_random_marker() -> Marker3D:
	return markers[randi() % markers.size()]
