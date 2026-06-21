extends GutTest

const MainScript = preload("res://scenes/main/main.gd")

var main_double
var obj


func before_each():
	main_double = partial_double(MainScript).new()
	stub(main_double._update_song_progress).to_do_nothing()
	add_child_autofree(main_double)

	obj = Node3D.new()
	obj.add_to_group("world_objects")
	add_child_autofree(obj)


func test_move_world_objects_稼働中はworld_objectsが前進する():
	var initial_z = obj.global_position.z
	main_double.world_speed = 10.0
	main_double._move_world_objects(0.016)
	assert_true(obj.global_position.z > initial_z)


func test_move_world_objects_停止中はworld_objectsが動かない():
	var initial_z = obj.global_position.z
	main_double.world_speed = 0
	main_double._move_world_objects(0.016)
	assert_eq(initial_z, obj.global_position.z)


func test_build_event_scheduleがnote_onイベントのタイムラインを構築する():
	var smf_data = SMF.SMFData.new(SMF.SMFFormat.format_0, 1, 480)

	var note_on = SMF.MIDIEventNoteOn.new()
	note_on.velocity = 100
	var chunk = SMF.MIDIEventChunk.new()
	chunk.time = 480
	chunk.channel_number = 0
	chunk.event = note_on

	var track = SMF.MIDITrack.new()
	track.events.append(chunk)
	smf_data.tracks.append(track)

	main_double._build_event_schedule(smf_data, 1.0 / 480.0)

	assert_eq(1, main_double._event_schedule.size())
	assert_eq(0, main_double._event_schedule[0].channel)
	assert_almost_eq(1.0, main_double._event_schedule[0].time_sec, 0.001)
