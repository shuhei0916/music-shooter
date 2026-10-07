extends Node3D

## カウントダウン中にタイミング調整画面を開くよう要求されたとき
signal calibration_requested
## リザルト画面から曲選択画面に戻るよう要求されたとき
signal song_select_requested

const SongAnalyzerScript = preload("res://scripts/song_analyzer.gd")
const NoteScheduler = preload("res://scripts/note_scheduler.gd")
const SoundfontCache = preload("res://scripts/soundfont_cache.gd")

## MidiPlayerのsoundfontはplay()後に設定する。シーンに直接書くと曲の解析前に全音色を読み込み、生成が数秒かかるため
@export_file("*.sf2") var midi_soundfont_path: String
@export var world_speed: float = 5.0
@export var initial_world_speed: float = 5.0
## タイミング調整画面（空ならシーンを切り替えない）
@export_file("*.tscn") var calibration_scene := "res://scenes/ui/calibration/calibration.tscn"
## 曲選択画面（空ならシーンを切り替えない）
@export_file("*.tscn") var song_select_scene := "res://scenes/ui/song_select/song_select.tscn"
## 映像（発射）を音より何秒先行させるか。開始時にSettings（タイミング調整画面で設定）から読む
var visual_offset_sec: float

var _note_scheduler: NoteScheduler

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
	_fire_due_notes()


func _move_world_objects(delta: float):
	for obj in get_tree().get_nodes_in_group("world_objects"):
		obj.global_translate(Vector3(0, 0, world_speed * delta))


func _fire_due_notes() -> void:
	if _note_scheduler == null:
		return
	for chunk in _note_scheduler.pop_due_ahead(midi_player, visual_offset_sec):
		player.on_note(chunk.channel_number, chunk.time, midi_player.smf_data.timebase)


func _end_game(is_win: bool) -> void:
	world_speed = 0.0
	_note_scheduler = null
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
		game_ui.notify_midi_event(ch_num, channel_status.track_name, event.note, event.velocity)


func _on_midi_finished() -> void:
	_end_game(true)


func _on_start_timer_timeout() -> void:
	world_speed = initial_world_speed
	visual_offset_sec = Settings.visual_offset_sec
	spawner.start()
	if Session.song_path:
		midi_player.file = Session.song_path
	midi_player.play()
	SoundfontCache.load_into(midi_player, midi_soundfont_path)
	_note_scheduler = NoteScheduler.new(midi_player.track_status.events)
	start_timer.stop()
	game_ui.update_countdown("")
	spawner.set_weapon_colors(player.get_weapon_colors())
	_setup_growth_curve()


func _setup_growth_curve() -> void:
	if midi_player.smf_data == null:
		return
	var used_channels: Array = player.get_weapon_channels()
	var analyzer = SongAnalyzerScript.new()
	var points: PackedVector2Array = analyzer.compute_cumulative_counts(
		midi_player.smf_data, midi_player.timebase_to_seconds, used_channels
	)
	spawner.set_growth_curve(points)


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and game_ui.result_panel.visible:
		get_tree().reload_current_scene()
	if event.is_action_pressed("ui_cancel") and game_ui.result_panel.visible:
		song_select_requested.emit()
		if song_select_scene:
			get_tree().change_scene_to_file(song_select_scene)
	if event.is_action_pressed("debug_toggle"):
		game_ui.toggle_debug()
	if event.is_action_pressed("calibrate") and not start_timer.is_stopped():
		_open_calibration()


func _open_calibration() -> void:
	Session.calibration_return_scene = scene_file_path
	calibration_requested.emit()
	if calibration_scene:
		get_tree().change_scene_to_file(calibration_scene)


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
