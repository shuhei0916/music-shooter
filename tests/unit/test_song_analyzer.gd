extends GutTest

const SongAnalyzerScript = preload("res://scripts/song_analyzer.gd")

var analyzer


func before_each() -> void:
	analyzer = SongAnalyzerScript.new()


func _make_note_on_chunk(tick: int, channel: int, velocity: int) -> SMF.MIDIEventChunk:
	return SMF.MIDIEventChunk.new(tick, channel, SMF.MIDIEventNoteOn.new(60, velocity))


func _make_smf(chunks: Array, timebase: int = 480) -> SMF.SMFData:
	var track := SMF.MIDITrack.new()
	for c: SMF.MIDIEventChunk in chunks:
		track.events.append(c)
	var smf_data := SMF.SMFData.new(SMF.SMFFormat.format_0, 1, timebase)
	smf_data.tracks.append(track)
	return smf_data


func test_使用チャンネルのnote_onが結果に含まれる() -> void:
	var chunks := [_make_note_on_chunk(480, 0, 100)]
	var smf_data := _make_smf(chunks)
	var result: PackedVector2Array = analyzer.compute_cumulative_counts(smf_data, 1.0 / 480.0, [0])
	assert_eq(result.size(), 1)


func test_未使用チャンネルのnote_onは結果に含まれない() -> void:
	var chunks := [_make_note_on_chunk(480, 5, 100)]
	var smf_data := _make_smf(chunks)
	var result: PackedVector2Array = analyzer.compute_cumulative_counts(smf_data, 1.0 / 480.0, [0])
	assert_eq(result.size(), 0)


func test_velocity0のnote_onはカウントされない() -> void:
	var chunks := [_make_note_on_chunk(480, 0, 0)]
	var smf_data := _make_smf(chunks)
	var result: PackedVector2Array = analyzer.compute_cumulative_counts(smf_data, 1.0 / 480.0, [0])
	assert_eq(result.size(), 0)


func test_複数イベントは累積カウントになる() -> void:
	var chunks := [
		_make_note_on_chunk(480, 0, 100),
		_make_note_on_chunk(960, 0, 100),
		_make_note_on_chunk(1440, 0, 100),
	]
	var smf_data := _make_smf(chunks)
	var result: PackedVector2Array = analyzer.compute_cumulative_counts(smf_data, 1.0 / 480.0, [0])
	assert_eq(result[2].y, 3.0)


func test_空のSMFは空配列を返す() -> void:
	var smf_data := SMF.SMFData.new(SMF.SMFFormat.format_0, 0, 480)
	var result: PackedVector2Array = analyzer.compute_cumulative_counts(smf_data, 1.0 / 480.0, [0])
	assert_eq(result.size(), 0)
