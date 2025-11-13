extends Node

signal gate_spawned(gate_instance)

@export var gate_scene: PackedScene

@onready var anchor_root: Node3D = $AnchorRoot
@onready var spawn_timer: Timer = $SpawnTimer
@onready var spawn_parent: Node = get_parent()

var spawn_counter := 0

func _ready():
	if spawn_timer and not spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func start():
	if spawn_timer:
		spawn_timer.start()

func stop():
	if spawn_timer:
		spawn_timer.stop()

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
		if gate.has_signal("player_entered_gate") and spawn_parent.has_method("_on_player_entered_gate"):
			gate.player_entered_gate.connect(spawn_parent._on_player_entered_gate)
		gate_spawned.emit(gate)
