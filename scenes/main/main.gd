extends Node3D

@export var debug_ui_scene: PackedScene
@export_file("*.sf2") var midi_soundfont_path: String
@export var song_manager_path: NodePath = NodePath("/root/SongManager")
@export var utils_path: NodePath = NodePath("/root/Utils")
var world_speed: float = 5.0

var debug_ui
var note_counts = []
var song_manager_node

@onready var midi_player = $MidiPlayer


func _ready():
	$Spawner/SpawnTimer.start()
	
func _process(delta: float) -> void:
	for obj in get_tree().get_nodes_in_group("world_objects"):
		obj.global_translate(Vector3(0, 0, world_speed * delta))
	
	_update_song_progress()
		
func _update_song_progress():
	if not (midi_player.playing and midi_player.smf_data):
		return
		
	var current_ticks = midi_player.position
	var total_ticks = midi_player.last_position
	
	# Correctly convert ticks to seconds
	var ticks_per_beat = midi_player.smf_data.timebase
	var seconds_per_beat = midi_player.timebase_to_seconds
	
	var current_time = (current_ticks / ticks_per_beat) * seconds_per_beat
	var total_time = (total_ticks / ticks_per_beat) * seconds_per_beat

	$GameUI.update_progress(current_time, total_time)

func _on_player_game_over() -> void:
	world_speed = 0.0

func _on_midi_event(channel: Variant, event: Variant) -> void:	if event.type == SMF.MIDIEventType.note_on and event.velocity > 0:
	if event.type == SMF.MIDIEventType.note_on and event.velocity > 0:

		var channel_status = channel as MidiPlayer.GodotMIDIPlayerChannelStatus
		var ch_num = channel_status.number
		#print(channel.track_name)
		
		print("MIDI Event: Channel %d (%s), Note: %d, Velocity: %d" % [ch_num, channel_status.track_name, event.note, event.velocity])
		if ch_num == 9:
			$Player.shoot()
