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
