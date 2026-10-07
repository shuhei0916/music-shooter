extends GutTest

const Metronome = preload("res://scripts/metronome.gd")


func _note_on_ticks(smf: SMF.SMFData) -> Array:
	var ticks := []
	for chunk in smf.tracks[0].events:
		if chunk.event.type == SMF.MIDIEventType.note_on:
			ticks.append(chunk.time)
	return ticks


func test_指定拍数ぶん1拍ごとにnote_onを持つ():
	var smf := Metronome.build(120.0, 3)
	assert_eq_deep(_note_on_ticks(smf), [0, smf.timebase, smf.timebase * 2])


func test_指定テンポのテンポイベントを持つ():
	var smf := Metronome.build(90.0, 1)
	var tempo_events = smf.tracks[0].events.filter(
		func(chunk): return chunk.event.type == SMF.MIDIEventType.system_event
	)
	# SMFのset_tempoの"bpm"キーは名前に反して1拍あたりのマイクロ秒を持つ
	assert_eq(60000000.0 / 90.0, tempo_events[0].event.args.bpm)
