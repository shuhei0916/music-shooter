extends GutTest

const SMF = preload("res://addons/midi/SMF.gd")
const GrowthCurve = preload("res://scripts/growth_curve.gd")

class FakeSMFReader:
	var result

	func _init(_result):
		result = _result

	func read_file(_path):
		return result

func test_曲選択で成長曲線を保持する():
	var events: Array[SMF.MIDIEventChunk] = []
	events.append(SMF.MIDIEventChunk.new(0, 0, SMF.MIDIEventNoteOn.new(60, 100)))
	events.append(SMF.MIDIEventChunk.new(120, 0, SMF.MIDIEventNoteOn.new(62, 100)))
	var track = SMF.MIDITrack.new(0, events)
	var smf_data = SMF.SMFData.new(SMF.SMFFormat.format_0, 1, 480, [track])
	var parse_result = SMF.SMFParseResult.new()
	parse_result.error = OK
	parse_result.data = smf_data

	var manager = load("res://scripts/song_manager.gd").new()
	manager.song_list = ["res://dummy.mid"]
	manager.set_smf_reader_factory(func():
		return FakeSMFReader.new(parse_result)
	)

	manager.select_song("res://dummy.mid")

	var expected = GrowthCurve.compute_from_smf(smf_data)
	assert_eq(expected, manager.get_growth_curve())
