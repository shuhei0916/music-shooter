class_name StemMix
extends RefCounted
## 曲をパートに分けたファイル（tools/separate.py で作る「曲の名前.stems/」）があれば、4つを一緒に鳴らす曲を作る

## パートの並び。一緒に鳴らす曲の中の順番もこのとおり
const STEMS := ["vocals", "drums", "bass", "other"]
const STEMS_SUFFIX := ".stems"


## 曲を読む。隣にパートのフォルダがあれば4つを一緒に鳴らす曲にし、無ければ曲のファイルをそのまま使う
static func load_song(song_path: String) -> AudioStream:
	var folder := song_path.get_basename() + STEMS_SUFFIX
	var stems := []
	for part in STEMS:
		var stem := _load_audio(folder.path_join(part + ".ogg"))
		if stem == null:
			stems.clear()
			break
		stems.append(stem)
	if stems.is_empty():
		return _load_audio(song_path)
	var synced := AudioStreamSynchronized.new()
	synced.stream_count = stems.size()
	for i in stems.size():
		synced.set_sync_stream(i, stems[i])
	return synced


## 取り込み済みの音（エディタで res:// に置いたもの）か、取り込んでいない ogg（遊ぶ人が足した曲）を読む
static func _load_audio(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		return load(path)
	if path.get_extension() == "ogg" and FileAccess.file_exists(path):
		return AudioStreamOggVorbis.load_from_file(path)
	return null
