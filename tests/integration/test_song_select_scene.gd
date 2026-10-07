extends GutTest

const SongLibrary = preload("res://scripts/song_library.gd")
const SONG_SELECT_SCENE = preload("res://scenes/ui/song_select/song_select.tscn")

var song_select


func before_each():
	song_select = SONG_SELECT_SCENE.instantiate()
	song_select.next_scene = ""  # テスト中にシーンを切り替えない
	add_child_autofree(song_select)


func _song_buttons() -> Array:
	return song_select.get_node("%SongList").get_children()


func test_曲の一覧をボタンとして表示する():
	var names := _song_buttons().map(func(button): return button.text)
	var expected := SongLibrary.list_songs(song_select.songs_dir).map(SongLibrary.display_name)
	assert_eq_deep(names, expected)
