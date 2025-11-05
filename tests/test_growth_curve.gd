extends GutTest

const SMF = preload("res://addons/midi/SMF.gd")
const GrowthCurve = preload("res://scripts/growth_curve.gd")

func test_ノートオンイベントを累積できる():
	var events: Array[SMF.MIDIEventChunk] = []
	events.append(SMF.MIDIEventChunk.new(0, 0, SMF.MIDIEventNoteOn.new(60, 100)))
	events.append(SMF.MIDIEventChunk.new(240, 0, SMF.MIDIEventNoteOn.new(62, 100)))
	events.append(SMF.MIDIEventChunk.new(300, 0, SMF.MIDIEventNoteOn.new(64, 0)))
	var track = SMF.MIDITrack.new(0, events)
	var smf_data = SMF.SMFData.new(SMF.SMFFormat.format_0, 1, 480, [track])

	var result = GrowthCurve.compute_from_smf(smf_data)
	var expected = PackedVector2Array()
	expected.append(Vector2(0, 1))
	expected.append(Vector2(240, 2))
	assert_eq(expected, result)
