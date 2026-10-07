extends GutTest

const SoundfontCache = preload("res://scripts/soundfont_cache.gd")
const SOUNDFONT = "res://assets/audio/GeneralUser-GS.sf2"


func _midi_player() -> MidiPlayer:
	var midi_player: MidiPlayer = autofree(MidiPlayer.new())
	midi_player._used_program_numbers.assign([0])
	return midi_player


func test_同じサウンドフォントと音色構成なら読み込んだバンクを共有する():
	var first := _midi_player()
	var second := _midi_player()
	SoundfontCache.load_into(first, SOUNDFONT)
	SoundfontCache.load_into(second, SOUNDFONT)
	assert_same(first.bank, second.bank)
