extends GutTest

const NoteScheduler = preload("res://scripts/note_scheduler.gd")

var main


func before_each():
	main = preload("res://scenes/main/main.tscn").instantiate()
	main.midi_soundfont_path = ""  # 音色の読み込み（約2.3秒）を省く

	add_child_autofree(main)
	await get_tree().process_frame
	#add_child_autofree(player)
	#add_child_autofree(enemy)


func after_each():
	for bullet in get_tree().get_nodes_in_group("bullet"):
		bullet.free()


func test_スタートタイマー経過後にワールドが動き出す():
	var world_obj = Node3D.new()
	world_obj.add_to_group("world_objects")
	main.add_child(world_obj)
	var initial_z = world_obj.global_position.z
	# StartTimerタイムアウト前は動かない想定
	main._process(0.016)
	assert_eq(initial_z, world_obj.global_position.z)
	# タイマータイムアウトを直接呼び出す
	main._on_start_timer_timeout()
	main._process(0.016)
	assert_true(world_obj.global_position.z > initial_z)


func test_midi_eventシグナルでは発射しない():
	var event := SMF.MIDIEventNoteOn.new(60, 100)
	main._on_midi_event(MidiPlayer.GodotMIDIPlayerChannelStatus.new(0), event)
	assert_eq(0, get_tree().get_nodes_in_group("bullet").size())


func test_ゲーム開始時にPlayerの武器の色がスポーナーに渡される():
	main._on_start_timer_timeout()
	assert_eq_deep(main.spawner._weapon_colors.keys(), [0, 9])


## テンポ120（1拍=0.5秒=480tick）で再生位置positionにいる状態を作り、tickのノートを予約する
func _schedule_note_at(tick: int, position: float) -> void:
	main.midi_player.smf_data = SMF.SMFData.new(SMF.SMFFormat.format_0, 1, 480)
	main.midi_player.seconds_to_timebase = 2.0
	main.midi_player.position = position
	var events: Array[SMF.MIDIEventChunk] = [
		SMF.MIDIEventChunk.new(tick, 0, SMF.MIDIEventNoteOn.new(60, 100))
	]
	main._note_scheduler = NoteScheduler.new(events)


func test_再生位置よりvisual_offset秒先までのノートで発射する():
	main.visual_offset_sec = 0.5  # 480tick先まで
	_schedule_note_at(1920, 1440)
	main._process(0.0)
	assert_eq(1, get_tree().get_nodes_in_group("bullet").size())


func test_visual_offset秒より先のノートではまだ発射しない():
	main.visual_offset_sec = 0.5  # 480tick先まで
	_schedule_note_at(1920, 1439)
	main._process(0.0)
	assert_eq(0, get_tree().get_nodes_in_group("bullet").size())


func test_ゲーム開始後は曲のノートで弾が発射される():
	main._on_start_timer_timeout()
	main.midi_player.position = main.midi_player.last_position
	main._process(0.0)
	assert_gt(get_tree().get_nodes_in_group("bullet").size(), 0)


func test_ゲームオーバー後はノートを処理しない():
	main._on_start_timer_timeout()
	main._on_player_game_over()
	await get_tree().process_frame  # playerのqueue_freeを反映させる
	main.midi_player.position = main.midi_player.last_position
	main._process(0.0)
	assert_engine_error_count(0)


func test_開始時にSettingsのvisual_offset_secを使う():
	var saved_offset: float = Settings.visual_offset_sec
	Settings.visual_offset_sec = 0.09
	main._on_start_timer_timeout()
	Settings.visual_offset_sec = saved_offset
	assert_eq(0.09, main.visual_offset_sec)


func _press(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	main._unhandled_input(event)


func test_カウントダウン中にCキーでタイミング調整画面を開く():
	main.calibration_scene = ""  # テスト中にシーンを切り替えない
	watch_signals(main)
	_press("calibrate")
	assert_signal_emitted(main, "calibration_requested")


func test_ゲーム開始後はCキーでタイミング調整画面を開かない():
	main.calibration_scene = ""
	main._on_start_timer_timeout()
	watch_signals(main)
	_press("calibrate")
	assert_signal_not_emitted(main, "calibration_requested")


func test_Sessionで選ばれた曲を再生する():
	var saved_song: String = Session.song_path
	Session.song_path = "res://assets/audio/Jump!.mid"
	main._on_start_timer_timeout()
	Session.song_path = saved_song
	assert_eq("res://assets/audio/Jump!.mid", main.midi_player.file)


func test_調整画面を開くとき戻り先としてゲームを記録する():
	var saved_return_scene: String = Session.calibration_return_scene
	main.calibration_scene = ""
	_press("calibrate")
	var recorded: String = Session.calibration_return_scene
	Session.calibration_return_scene = saved_return_scene
	assert_eq("res://scenes/main/main.tscn", recorded)
