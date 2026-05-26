extends Node

const CHEST_SPAWN_OFFSET_Z := -5.0

@export var gate_scene: PackedScene
@export var enemy_scene: PackedScene
@export var chest_scene: PackedScene
@export var enemy_spawn_probability: float = 0.1
@export_range(1, 100) var enemy_hp_min: int = 5
@export_range(1, 100) var enemy_hp_max: int = 20

var spawn_counter := 0
var markers: Array = []

@onready var anchor_root: Node3D = $AnchorRoot
@onready var spawn_timer: Timer = $SpawnTimer
@onready var main_scene: Node = get_parent()


func _ready() -> void:
	if anchor_root:
		markers = anchor_root.get_children()


func start() -> void:
	spawn_timer.start()


func stop() -> void:
	spawn_timer.stop()


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
		return
	if randf() < enemy_spawn_probability:
		_spawn_enemy()


func _spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	enemy.global_transform = _pick_random_marker().global_transform
	_set_enemy_properties(enemy)
	enemy.died.connect(_on_enemy_died.bind(enemy))
	main_scene.add_child(enemy)


func _on_enemy_died(enemy: Node) -> void:
	if chest_scene == null:
		return
	var chest = chest_scene.instantiate()
	chest.gate_type = "add"
	chest.value = randi_range(5, 20)
	main_scene.add_child(chest)
	chest.global_position = enemy.global_position + Vector3(0, 0, CHEST_SPAWN_OFFSET_Z)


func _pick_random_marker() -> Marker3D:
	if markers:
		return markers[randi() % markers.size()]
	return null


func _set_enemy_properties(enemy: Node) -> void:
	var value = randi_range(enemy_hp_min, enemy_hp_max)
	enemy.hp = value
