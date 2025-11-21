extends Node

@export var gate_scene: PackedScene
@export var enemy_scene: PackedScene
@export var enemy_spawn_probability: float = 0.1
@export_range(1, 100) var enemy_hp_min: int = 5
@export_range(1, 100) var enemy_hp_max: int = 20

@onready var anchor_root: Node3D = $AnchorRoot
@onready var spawn_timer: Timer = $SpawnTimer
@onready var main_scene: Node = get_parent()

var spawn_counter := 0
var markers: Array = []

func _ready() -> void:
	if anchor_root:
		markers = anchor_root.get_children()

func _on_spawn_timer_timeout() -> void:
	spawn_counter += 1
	if spawn_counter % 5 == 0:
		_spawn_gate_row()
	else:
		_maybe_spawn_enemy()

func _spawn_gate_row() -> void:
	if markers.is_empty():
		return
	for marker in markers:
		var gate = gate_scene.instantiate()
		gate.global_transform = marker.global_transform
		_set_gate_properties(gate)
		main_scene.add_child(gate)

func _set_gate_properties(gate: Node) -> void:
	gate.gate_type = "add"
	gate.value = randi_range(5, 20)		

func _maybe_spawn_enemy() -> void:
	if enemy_scene == null:
		print("hogehoge")
		return
	if randf() < enemy_spawn_probability:
		_spawn_enemy()

func _spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	enemy.global_transform = _pick_random_marker().global_transform
	_set_enemy_properties(enemy)
	main_scene.add_child(enemy)

func _pick_random_marker() -> Marker3D:
	if markers:
		return markers[randi() % markers.size()]
	else:
		return null

func _set_enemy_properties(enemy: Node) -> void:
	var value = randi_range(enemy_hp_min, enemy_hp_max)
	enemy.hp = value
	
func _hoge():
	print("hgoe")
