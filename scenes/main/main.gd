extends Node3D

const SongAnalyzerScript = preload("res://scripts/song_analyzer.gd")

@export_file("*.sf2") var midi_soundfont_path: String
@export var world_speed: float = 5.0
@export var initial_world_speed: float = 5.0

var _debug_ch_rows: Dictionary = {}
var _debug_row_count: int = 0
var _event_schedule: Array = []
var _schedule_index: int = 0

@onready var midi_player = get_node_or_null("MidiPlayer")
@onready var player = get_node_or_null("Player")
@onready var game_ui = get_node_or_null("GameUI")
@onready var start_timer = get_node_or_null("StartTimer")
@onready var spawner = get_node_or_null("Spawner")


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


func _end_game(is_win: bool) -> void:
	world_speed = 0.0
	spawner.stop()
	midi_player.stop()
	game_ui.show_result(is_win)


func _on_player_game_over() -> void:
	player.queue_free()
	_end_game(false)


func _on_midi_event(channel: Variant, event: Variant) -> void:
	if event.type == SMF.MIDIEventType.note_on and event.velocity > 0:
		var channel_status = channel as MidiPlayer.GodotMIDIPlayerChannelStatus
		var ch_num = channel_status.number

		if ch_num not in _debug_ch_rows:
			_debug_ch_rows[ch_num] = _debug_row_count
			_debug_row_count += 1
			print("")
		var row: int = _debug_ch_rows[ch_num]
		var up: int = _debug_row_count - row
		var text := (
			"ch%02d | %-20s | note=%-3d | vel=%d"
			% [ch_num, channel_status.track_name, event.note, event.velocity]
		)
		var esc := char(27)
		print("%s[%dA%s[2K%s%s[%dB" % [esc, up, esc, text, esc, up - 1])

		player.shoot(ch_num)


func _on_midi_finished() -> void:
	_end_game(true)


func _on_start_timer_timeout() -> void:
	world_speed = initial_world_speed
	spawner.start()
	midi_player.play()
	start_timer.stop()
	game_ui.update_countdown("")
	_setup_growth_curve()


func _build_event_schedule(smf_data: SMF.SMFData, timebase_to_seconds: float) -> void:
	_event_schedule.clear()
	_schedule_index = 0
	for track: SMF.MIDITrack in smf_data.tracks:
		for chunk: SMF.MIDIEventChunk in track.events:
			if chunk.event.type != SMF.MIDIEventType.note_on:
				continue
			var note_on := chunk.event as SMF.MIDIEventNoteOn
			if note_on.velocity == 0:
				continue
			(
				_event_schedule
				. append(
					{
						"time_sec": chunk.time * timebase_to_seconds,
						"channel": chunk.channel_number,
					}
				)
			)
	_event_schedule.sort_custom(func(a, b): return a.time_sec < b.time_sec)


func _setup_growth_curve() -> void:
	if midi_player.smf_data == null:
		return
	var used_channels: Array = player._weapon_map.keys()
	var analyzer = SongAnalyzerScript.new()
	var points: PackedVector2Array = analyzer.compute_cumulative_counts(
		midi_player.smf_data, midi_player.timebase_to_seconds, used_channels
	)
	spawner.set_growth_curve(points)


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and game_ui.result_panel.visible:
		get_tree().reload_current_scene()  # This restarts the current scene.


func _update_song_progress():
	if not start_timer.is_stopped():
		var remaining = int(ceil(start_timer.time_left))
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

	game_ui.update_progress(current_time, total_time)
