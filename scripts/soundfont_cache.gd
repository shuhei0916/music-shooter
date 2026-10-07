## サウンドフォントの読み込み（約2.3秒）を、同じ音色構成なら2回目以降省略する
extends RefCounted

static var _banks := {}


## MidiPlayerのplay()後（曲で使う音色が解析された後）に呼ぶ
static func load_into(midi_player: MidiPlayer, path: String) -> void:
	var key := "%s:%s" % [path, midi_player._used_program_numbers]
	if not _banks.has(key):
		midi_player.soundfont = path
		_banks[key] = midi_player.bank
	midi_player.bank = _banks[key]
