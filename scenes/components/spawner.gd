extends Node

signal gate_spawned(gate_instance)

@export var gate_scene: PackedScene
@export var spawn_parent_path: NodePath = NodePath("..")

@onready var anchor_root: Node3D = $AnchorRoot
@onready var spawn_timer: Timer = $SpawnTimer
@onready var spawn_parent: Node = get_node_or_null(spawn_parent_path)

var spawn_counter := 0

func _ready():
	if spawn_timer and not spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	if spawn_parent == null:
		spawn_parent = get_parent()

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
		if marker is Marker3D:
			_spawn_gate_at_marker(marker)

func _spawn_gate_at_marker(marker: Marker3D) -> void:
	if gate_scene == null:
		printerr("gate_scene が未設定です")
		return
	var gate = gate_scene.instantiate()
	if spawn_parent == null:
		printerr("spawn_parent が見つかりません")
		gate.queue_free()
		return
	spawn_parent.add_child(gate)
	gate.global_transform = marker.global_transform
	if gate.has_signal("player_entered_gate") and spawn_parent.has_method("_on_player_entered_gate"):
		gate.player_entered_gate.connect(spawn_parent._on_player_entered_gate)
	gate_spawned.emit(gate)
