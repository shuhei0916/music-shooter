extends Node3D

@export var debug_ui_scene: PackedScene
@export_file("*.sf2") var midi_soundfont_path: String
@export var song_manager_path: NodePath = NodePath("/root/SongManager")
@export var utils_path: NodePath = NodePath("/root/Utils")
const WORLD_SPEED = 5.0

var debug_ui
var note_counts = []
var song_manager_node

var spawn_counter = 0

@onready var player = $Player
@onready var midi_player = $MidiPlayer
@onready var anchor_root: Node3D = $Spawner/AnchorRoot
@export var gate_scene: PackedScene

func _ready():
	$Spawner/SpawnTimer.start()
	
func _process(delta: float) -> void:
	for obj in get_tree().get_nodes_in_group("world_objects"):
		obj.global_translate(Vector3(0, 0, WORLD_SPEED * delta))
	
func _on_player_entered_gate(gate_type, value, gate_node):
	player.apply_gate_effect(gate_type, value)

func _on_spawn_timer_timeout() -> void:
	spawn_counter += 1
	if spawn_counter % 5 == 0:
		gate_spawn()
	else:
		print("hoge")

func gate_spawn():
	for marker in anchor_root.get_children():
		var gate = gate_scene.instantiate()
		gate.global_transform = marker.global_transform
		add_child(gate)
	print("Gate spawned!")
