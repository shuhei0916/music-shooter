extends Node3D

@export var debug_ui_scene: PackedScene
@export_file("*.sf2") var midi_soundfont_path: String
@export var song_manager_path: NodePath = NodePath("/root/SongManager")
@export var utils_path: NodePath = NodePath("/root/Utils")
const WORLD_SPEED = 5.0

var player
var debug_ui
var note_counts = []
var song_manager_node

@onready var midi_player = $MidiPlayer

func _ready():
	# Setup Note Counts
	for i in range(16):
		note_counts.append(0)

	# Setup Debug UI
	if debug_ui_scene:
		debug_ui = debug_ui_scene.instantiate()
		add_child(debug_ui)
	else:
		debug_ui = null
		printerr("debug_ui_scene が未設定です")

	# Setup MidiPlayer
	song_manager_node = get_node_or_null(song_manager_path)
	if song_manager_node == null:
		printerr("SongManager が見つかりません: ", song_manager_path)
		return

	var selected_song = song_manager_node.get_selected_song()
	if selected_song.is_empty():
		printerr("No song selected, defaulting to first song in list.")
		var songs = song_manager_node.get_song_list()
		if songs.size() > 0:
			selected_song = songs[0]
			song_manager_node.select_song(selected_song)
		else:
			printerr("SongManager に楽曲がありません。")
			return
	else:
		song_manager_node.select_song(selected_song)

	if midi_soundfont_path != "":
		midi_player.soundfont = midi_soundfont_path
	else:
		printerr("midi_soundfont_path が未設定です")
	midi_player.file = selected_song
	midi_player.midi_event.connect(_on_midi_event)
	midi_player.finished.connect(_on_midi_player_finished)
	midi_player.play()

	if debug_ui and song_manager_node:
		var growth_curve = song_manager_node.get_growth_curve()
		debug_ui.update_growth_curve(growth_curve)

	player = get_node("Player")
	player.hp_changed.connect(_on_player_hp_changed)
	player.game_over_signal.connect(_on_game_over)
	

	# Connect to Spawner
	var spawner = get_node("Spawner")
	spawner.spawn_object.connect(_on_spawn_object)
	spawner.start_spawning()

func _on_spawn_object(object_scene, properties):
	var instance = object_scene.instantiate()
	
	if instance.is_in_group("world_objects"):
		add_child(instance)
		instance.transform.origin = properties.position
		
		if instance.has_method("set_hp"): # For enemies
			instance.set_hp(properties.hp)
			instance.player_collided_with_enemy.connect(_on_player_collided_with_enemy)
		elif instance.has_method("set_gate_properties"): # For gates
			instance.set_gate_properties(properties.type, properties.value)
			instance.player_entered_gate.connect(_on_player_entered_gate)

func _on_player_entered_gate(gate_type, value, gate_node):
	if player:
		player.apply_gate_effect(gate_type, value)
		if is_instance_valid(gate_node):
			gate_node.queue_free()

func _on_player_collided_with_enemy(enemy_hp):
	if player:
		player.take_damage(enemy_hp)

func _on_game_over():
	midi_player.stop()
	var ui = get_node("GameUI")
	if ui:
		ui.show_result(false) # It's a loss

func _on_midi_player_finished():
	var ui = get_node("GameUI")
	if ui:
		ui.show_result(true) # It's a win
	
	# Also stop the player from moving
	if player:
		player.set_physics_process(false)

func _on_player_hp_changed(new_hp):
	var hp_label = player.get_node("HPLabel")
	if hp_label:
		var utils = get_node_or_null(utils_path)
		if utils:
			hp_label.text = utils.format_number(new_hp)
		else:
			printerr("Utils が見つかりません: ", utils_path)

func _process(delta):
	for obj in get_tree().get_nodes_in_group("world_objects"):
		obj.global_translate(Vector3(0, 0, WORLD_SPEED * delta))
	
	# Update song progress UI
	if midi_player.playing and midi_player.smf_data:
		var current_ticks = midi_player.position
		var total_ticks = midi_player.last_position
		
		# Correctly convert ticks to seconds
		var ticks_per_beat = midi_player.smf_data.timebase
		var seconds_per_beat = midi_player.timebase_to_seconds
		
		var current_time = (current_ticks / ticks_per_beat) * seconds_per_beat
		var total_time = (total_ticks / ticks_per_beat) * seconds_per_beat
		
		get_node("GameUI").update_progress(current_time, total_time, current_ticks, total_ticks)

	# Update debug UI if visible
	if debug_ui and debug_ui.is_ui_visible():
		for i in range(16):
			var channel_status = midi_player.channel_status[i]
			debug_ui.update_track_data(i, channel_status.instrument_name, note_counts[i])

func _unhandled_input(event):
	# Use the Input singleton to check for actions, not the event object itself
	if Input.is_action_just_pressed("ui_cancel"): # Corresponds to Esc key by default
		get_tree().quit()
	if Input.is_action_just_pressed("debug_toggle"):
		if debug_ui:
			debug_ui.toggle_ui()
			if debug_ui.is_ui_visible() and song_manager_node:
				debug_ui.update_growth_curve(song_manager_node.get_growth_curve())

func _on_midi_event(channel, event):
	# We are interested in Note On events
	if event.type == SMF.MIDIEventType.note_on and event.velocity > 0:
		var channel_status = channel as MidiPlayer.GodotMIDIPlayerChannelStatus
		var ch_num = channel_status.number

		if player:
			player.attack(ch_num)
			
		if ch_num >= 0 and ch_num < 16:
			note_counts[ch_num] += 1
		# Keep the print for now, it's still useful
		# print("MIDI Event: Channel %d (%s), Note: %d, Velocity: %d" % [ch_num, channel_status.track_name, event.note, event.velocity])
