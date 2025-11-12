extends Node3D

@export var debug_ui_scene: PackedScene
@export_file("*.sf2") var midi_soundfont_path: String
@export var song_manager_path: NodePath = NodePath("/root/SongManager")
@export var utils_path: NodePath = NodePath("/root/Utils")
const WORLD_SPEED = 5.0

var debug_ui
var note_counts = []
var song_manager_node

@onready var player = $Player
@onready var midi_player = $MidiPlayer
@onready var spawner = $Spawner

func _ready():
	if spawner:
		spawner.start()
	
func _process(delta: float) -> void:
	for obj in get_tree().get_nodes_in_group("world_objects"):
		obj.global_translate(Vector3(0, 0, WORLD_SPEED * delta))
	
func _on_player_entered_gate(gate_type, value, gate_node):
	player.apply_gate_effect(gate_type, value)
