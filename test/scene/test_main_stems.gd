extends GutTest
## Main のうち、曲をパートに分けたファイルを鳴らすところ

const MainScene := preload("res://scenes/main.tscn")
const STEMS_SONG := "res://test/fixtures/stems_song.mp3"


func _make_main(path: String, layout: Array) -> Main:
	var main: Main = MainScene.instantiate()
	main.song_path = path
	main.layout = layout
	return add_child_autofree(main)


func test_パートに分けた曲なら4つのパートを一緒に鳴らす():
	var main := _make_main(STEMS_SONG, [{"z": 500.0, "enemies": [[1, 1]]}])
	assert_true(main.get_node("Music").stream is AudioStreamSynchronized)


func test_パートに分けていない曲はそのまま鳴らす():
	var main := _make_main(
		"res://test/fixtures/plain_song.ogg", [{"z": 500.0, "enemies": [[1, 1]]}]
	)
	assert_true(main.get_node("Music").stream is AudioStreamOggVorbis)
