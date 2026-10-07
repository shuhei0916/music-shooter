extends GutTest

const SongLibrary = preload("res://scripts/song_library.gd")
const SONG_SELECT_SCENE = preload("res://scenes/ui/song_select/song_select.tscn")

var song_select
var _saved_song: String


func before_each():
	_saved_song = Session.song_path
	song_select = SONG_SELECT_SCENE.instantiate()
	song_select.next_scene = ""  # テスト中にシーンを切り替えない
	song_select.back_scene = ""
	add_child_autofree(song_select)


func after_each():
	Session.song_path = _saved_song


func _song_buttons() -> Array:
	return song_select.get_node("%SongList").get_children()


func test_曲の一覧をボタンとして表示する():
	var names := _song_buttons().map(func(button): return button.text)
	var expected := SongLibrary.list_songs(song_select.songs_dir).map(SongLibrary.display_name)
	assert_eq_deep(names, expected)


func test_曲を選ぶとSessionに記録する():
	_song_buttons()[1].pressed.emit()
	assert_eq(SongLibrary.list_songs(song_select.songs_dir)[1], Session.song_path)


func test_Escでタイトルに戻る():
	watch_signals(song_select)
	var event := InputEventAction.new()
	event.action = "ui_cancel"
	event.pressed = true
	song_select._unhandled_input(event)
	assert_signal_emitted(song_select, "back_requested")


func test_開いたとき最初の曲にフォーカスがある():
	assert_true(_song_buttons()[0].has_focus())
