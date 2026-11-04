extends GutTest
## 曲のフォルダから、遊べる曲（拍の JSON と曲のファイルがそろったもの）を探す

const DIR := "user://test_song_library"


func after_each():
	for name in DirAccess.get_files_at(DIR):
		DirAccess.remove_absolute(DIR.path_join(name))
	DirAccess.remove_absolute(DIR)


func _put(file_name: String, text := "") -> void:
	DirAccess.make_dir_recursive_absolute(DIR)
	var file := FileAccess.open(DIR.path_join(file_name), FileAccess.WRITE)
	file.store_string(text)


func test_拍のJSONと曲のファイルがそろった曲だけを名前の順に並べる():
	var names := ["b.mp3", "b.beats.json", "a.ogg", "a.beats.json", "c.mp3", "d.beats.json"]
	assert_eq(SongLibrary.playable(names), ["a.ogg", "b.mp3"])


func test_書き出したゲームでは曲のファイルが取り込み済みのファイルに置き換わっていても見つける():
	var names := ["b.mp3.import", "b.beats.json"]
	assert_eq(SongLibrary.playable(names), ["b.mp3"])


func test_曲の形式ではないファイルは拾わない():
	var names := ["b.txt", "b.beats.json"]
	assert_eq(SongLibrary.playable(names), [])


func test_表示する名前はファイル名から末尾の括弧書きを除いたもの():
	assert_eq(SongLibrary.title("Jim Yosef - Eclipse [NCS Release].mp3"), "Jim Yosef - Eclipse")
	assert_eq(SongLibrary.title("tropic_love.mp3"), "tropic_love")


func test_フォルダの曲を曲のパスと名前とBPMの一覧にする():
	_put("Song A [NCS Release].mp3")
	_put("Song A [NCS Release].beats.json", '{"bpm": 174.0}')
	_put("lonely.beats.json", '{"bpm": 120.0}')
	var songs := SongLibrary.songs(DIR)
	assert_eq(songs.size(), 1)
	assert_eq(songs[0].path, DIR.path_join("Song A [NCS Release].mp3"))
	assert_eq(songs[0].title, "Song A")
	assert_eq(songs[0].bpm, 174.0)


func test_フォルダが無ければ空の一覧():
	assert_eq(SongLibrary.songs("user://no_such_dir"), [])
