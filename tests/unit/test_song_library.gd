extends GutTest

const SongLibrary = preload("res://scripts/song_library.gd")
const TEST_DIR = "user://test_songs"


func before_each():
	DirAccess.make_dir_recursive_absolute(TEST_DIR)


func after_each():
	for file in DirAccess.get_files_at(TEST_DIR):
		DirAccess.remove_absolute(TEST_DIR.path_join(file))
	DirAccess.remove_absolute(TEST_DIR)


func _create_files(names: Array) -> void:
	for file_name in names:
		FileAccess.open(TEST_DIR.path_join(file_name), FileAccess.WRITE).close()


func test_フォルダ内のMIDIファイルを名前順に一覧にする():
	_create_files(["b.mid", "a.mid"])
	assert_eq_deep(SongLibrary.list_songs(TEST_DIR), [TEST_DIR + "/a.mid", TEST_DIR + "/b.mid"])


func test_MIDI以外のファイルを一覧に含めない():
	_create_files(["song.mid", "GeneralUser-GS.sf2", "song.mid.import"])
	assert_eq_deep(SongLibrary.list_songs(TEST_DIR), [TEST_DIR + "/song.mid"])


func test_曲の表示名はファイル名から拡張子を除いたもの():
	assert_eq("Jump!", SongLibrary.display_name("res://assets/audio/Jump!.mid"))
