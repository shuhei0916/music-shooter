extends GutTest


func _make_wav(seconds: float) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = 8000
	var data := PackedByteArray()
	data.resize(int(8000 * seconds))
	wav.data = data
	return wav


func test_長さは曲の長さになる():
	var player: AudioStreamPlayer = add_child_autofree(AudioStreamPlayer.new())
	player.stream = _make_wav(2.0)
	assert_almost_eq(MusicClock.new(player).duration(), 2.0, 0.01)


func test_始めると曲を再生する():
	var player: AudioStreamPlayer = add_child_autofree(AudioStreamPlayer.new())
	player.stream = _make_wav(2.0)
	MusicClock.new(player).start()
	assert_true(player.playing)
