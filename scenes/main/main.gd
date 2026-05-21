extends Node3D

@export var debug_ui_scene: PackedScene
@export_file("*.sf2") var midi_soundfont_path: String
@export var song_manager_path: NodePath = NodePath("/root/SongManager")
@export var utils_path: NodePath = NodePath("/root/Utils")
@export var world_speed: float = 5.0
@export var initial_world_speed: float = 5.0

var debug_ui
var note_counts = []
var song_manager_node

@onready var midi_player = get_node_or_null("MidiPlayer")
@onready var player = get_node_or_null("Player")
@onready var game_ui = get_node_or_null("GameUI")
@onready var start_timer = get_node_or_null("StartTimer")


func _ready():
	world_speed = 0.0
	if start_timer:
		start_timer.start()


func _process(delta: float) -> void:
	_move_world_objects(delta)
	_update_song_progress()


func _move_world_objects(delta: float):
	for obj in get_tree().get_nodes_in_group("world_objects"):
		obj.global_translate(Vector3(0, 0, world_speed * delta))


func _on_player_game_over() -> void:
	world_speed = 0.0
	game_ui.show_result(false)
	$Spawner/SpawnTimer.stop()
	player.queue_free()
	midi_player.stop()


func _on_midi_event(channel: Variant, event: Variant) -> void:
	if event.type == SMF.MIDIEventType.note_on and event.velocity > 0:
		var channel_status = channel as MidiPlayer.GodotMIDIPlayerChannelStatus
		var ch_num = channel_status.number

		print(
			(
				"MIDI Event: Channel %d (%s), Note: %d, Velocity: %d"
				% [ch_num, channel_status.track_name, event.note, event.velocity]
			)
		)
		if ch_num == 9:
			player.shoot()


func _on_midi_finished() -> void:
	world_speed = 0.0
	game_ui.show_result(true)
	$Spawner/SpawnTimer.stop()
	midi_player.stop()


func _on_start_timer_timeout() -> void:
	world_speed = initial_world_speed
	$Spawner/SpawnTimer.start()
	midi_player.play()
	$StartTimer.stop()
	game_ui.update_countdown("")


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $GameUI/ResultPanel.visible:
		get_tree().reload_current_scene()  # This restarts the current scene.


func _update_song_progress():
	if not start_timer.is_stopped():
		var remaining = int(ceil($StartTimer.time_left))
		if remaining > 0:
			game_ui.update_countdown(str(remaining))
		else:
			game_ui.update_countdown("")
		return

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
