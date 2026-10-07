## 曲（MIDIファイル）の一覧を扱う
extends RefCounted


static func list_songs(dir: String) -> Array[String]:
	var songs: Array[String] = []
	for file in DirAccess.get_files_at(dir):
		songs.append(dir.path_join(file))
	songs.sort()
	return songs
