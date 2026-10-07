extends GutTest

const NoteScheduler = preload("res://scripts/note_scheduler.gd")

var main


func before_each():
	main = preload("res://scenes/main/main.tscn").instantiate()

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
