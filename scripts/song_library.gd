class_name SongLibrary
extends RefCounted
## 曲のフォルダから、遊べる曲（曲の隣に tools/analyze.py で作った「曲の名前.beats.json」があるもの）を探す

const AUDIO_EXTENSIONS := ["mp3", "ogg", "wav"]
const BEATS_SUFFIX := ".beats.json"
## 書き出したゲームでは、曲のファイルは取り込み済みのファイル（「曲.mp3.import」）だけが見える
const IMPORT_SUFFIX := ".import"


## dir の中の遊べる曲を、名前の順に [{path, title, bpm}, ...] で返す。フォルダが無ければ空
static func songs(dir: String) -> Array:
	if not DirAccess.dir_exists_absolute(dir):
		return []
	var result := []
	for file_name in playable(Array(DirAccess.get_files_at(dir))):
		var path := dir.path_join(file_name)
		result.append({"path": path, "title": title(file_name), "bpm": _bpm(path)})
	return result


## ファイル名の一覧のうち、拍の JSON がそろった曲のファイル名を、名前の順に返す
static func playable(file_names: Array) -> Array:
	var result := []
	for file_name: String in file_names:
		var audio := file_name.trim_suffix(IMPORT_SUFFIX)
		if audio.get_extension().to_lower() not in AUDIO_EXTENSIONS or audio in result:
			continue
		if audio.get_basename() + BEATS_SUFFIX in file_names:
			result.append(audio)
	result.sort()
	return result


## 画面に出す曲の名前。ファイル名から、拡張子と末尾の括弧書き（「 [NCS Release]」など）を除く
static func title(file_name: String) -> String:
	var name := file_name.get_basename()
	var bracket := name.rfind(" [")
	if bracket > 0 and name.ends_with("]"):
		name = name.substr(0, bracket)
	return name


## 曲の拍の JSON にある BPM。読めなければ 0
static func _bpm(audio_path: String) -> float:
	var text := FileAccess.get_file_as_string(audio_path.get_basename() + BEATS_SUFFIX)
	var data = JSON.parse_string(text)
	if data is Dictionary:
		return float(data.get("bpm", 0.0))
	return 0.0
