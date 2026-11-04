extends GutTest
## Main の音を出さないモード。曲は流さず、曲の長さだけ経過時間で進む（自動で遊ばせるときに使う）

const MainScene := preload("res://scenes/main.tscn")


func _make_silent_main(seconds: float) -> Main:
	var main: Main = MainScene.instantiate()
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = 8000
	var data := PackedByteArray()
	data.resize(int(8000 * seconds))
	wav.data = data
	main.song = wav
	main.silent = true
	main.forward_speed = 10.0
	main.layout = []
	return add_child_autofree(main)


func test_音を出さないモードでは曲を流さない():
	var main := _make_silent_main(2.0)
	assert_false(main.get_node("Music").playing)


func test_音を出さないモードでもコースの長さは曲の長さに合わせる():
	var main := _make_silent_main(2.0)
	assert_almost_eq(main.course_length, 20.0, 0.01)


func test_音を出さないモードでは経過時間で進む():
	var main := _make_silent_main(2.0)
	simulate(main, 5, 0.1)
	assert_almost_eq(main.get_node("Player").position.z, -5.0, 0.01)
