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
	var result: PackedVector2Array = analyzer.compute_cumulative_counts(smf_data, [0])
	assert_eq(result.size(), 1)


func test_未使用チャンネルのnote_onは結果に含まれない() -> void:
	var chunks := [_make_note_on_chunk(480, 5, 100)]
	var smf_data := _make_smf(chunks)
	var result: PackedVector2Array = analyzer.compute_cumulative_counts(smf_data, [0])
	assert_eq(result.size(), 0)


func test_velocity0のnote_onはカウントされない() -> void:
	var chunks := [_make_note_on_chunk(480, 0, 0)]
	var smf_data := _make_smf(chunks)
	var result: PackedVector2Array = analyzer.compute_cumulative_counts(smf_data, [0])
	assert_eq(result.size(), 0)


func test_複数イベントは累積カウントになる() -> void:
	var chunks := [
		_make_note_on_chunk(480, 0, 100),
		_make_note_on_chunk(960, 0, 100),
		_make_note_on_chunk(1440, 0, 100),
	]
	var smf_data := _make_smf(chunks)
	var result: PackedVector2Array = analyzer.compute_cumulative_counts(smf_data, [0])
	assert_eq(result[2].y, 3.0)


func test_空のSMFは空配列を返す() -> void:
	var smf_data := SMF.SMFData.new(SMF.SMFFormat.format_0, 0, 480)
	var result: PackedVector2Array = analyzer.compute_cumulative_counts(smf_data, [0])
	assert_eq(result.size(), 0)


func test_複数トラックのノートは時刻順に累積する() -> void:
	var smf_data := SMF.SMFData.new(SMF.SMFFormat.format_1, 2, 480)
	for tick in [960, 480]:  # 1本目のトラックのほうが後ろの時刻
		var track := SMF.MIDITrack.new()
		track.events.append(_make_note_on_chunk(tick, 0, 100))
		smf_data.tracks.append(track)
	var result: PackedVector2Array = analyzer.compute_cumulative_counts(smf_data, [0])
	assert_eq(result, PackedVector2Array([Vector2(480, 1), Vector2(960, 2)]))


func _make_tempo_chunk(tick: int, bpm: float) -> SMF.MIDIEventChunk:
	var args := {"type": SMF.MIDISystemEventType.set_tempo, "bpm": roundi(60_000_000.0 / bpm)}
	return SMF.MIDIEventChunk.new(tick, 0, SMF.MIDIEventSystemEvent.new(args))


func test_テンポ指定のない曲は120BPMとしてtickを秒にする() -> void:
	var smf_data := _make_smf([])
	assert_almost_eq(analyzer.ticks_to_seconds(smf_data, 480 * 4), 2.0, 0.001)


func test_途中でテンポが変わる曲は区間ごとのテンポでtickを秒にする() -> void:
	# 最初の4拍は120BPM（2秒）、その後の4拍は60BPM（4秒）
	var smf_data := _make_smf([_make_tempo_chunk(0, 120.0), _make_tempo_chunk(480 * 4, 60.0)])
	assert_almost_eq(analyzer.ticks_to_seconds(smf_data, 480 * 8), 6.0, 0.001)
