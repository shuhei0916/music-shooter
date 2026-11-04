class_name StemMix
extends RefCounted
## 曲をパートに分けたファイル（tools/separate.py で作る「曲の名前.stems/」）があれば4つを一緒に鳴らし、
## 取ったゲートに合わせてパートの音量を変える。強くしたパートほど大きく聞こえる

## パートの並び。一緒に鳴らす曲の中の順番もこのとおり
const STEMS := ["vocals", "drums", "bass", "other"]
const STEMS_SUFFIX := ".stems"
## ゲートで強くなるパートの、初めの音量（dB）と、ゲート1つで上がる大きさ。0 dB（元の曲の大きさ）まで上がる
const START_DB := -9.0
const STEP_DB := 3.0
const FULL_DB := 0.0
## ゲートの種類ごとに強くなるパート。連射はドラム、ダメージはベース、HP はその他（シンセなど）
## ボーカルは、歌の少ない曲でほかの高い音を拾ってしまうことがあるので、まだゲートに結びつけない
const PART_OF_OP := {
	Gate.Op.FIRE_RATE: "drums",
	Gate.Op.POWER: "bass",
	Gate.Op.ADD: "other",
	Gate.Op.MULTIPLY: "other",
}

## 鳴らす曲。パートに分けてあれば AudioStreamSynchronized
var song: AudioStream


func _init(p_song: AudioStream) -> void:
	song = p_song
	if has_stems():
		for part in PART_OF_OP.values():
			_set_volume(part, START_DB)


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


## ゲートで強くなるパート。結びついたパートが無ければ空
static func part_of(gate: Gate) -> String:
	return PART_OF_OP.get(gate.op, "")


func has_stems() -> bool:
	return song is AudioStreamSynchronized


## パートの今の音量（dB）。パートに分けていない曲では 0
func volume_db(part: String) -> float:
	if not has_stems():
		return 0.0
	return song.get_sync_stream_volume(STEMS.find(part))


## 取ったゲートのパートを一段大きくする。悪いゲートなら一段小さくする（初めの音量より小さくはしない）
func take(gate: Gate) -> void:
	var part := part_of(gate)
	if not has_stems() or part.is_empty():
		return
	var step := -STEP_DB if gate.is_harmful() else STEP_DB
	_set_volume(part, clampf(volume_db(part) + step, START_DB, FULL_DB))


func _set_volume(part: String, db: float) -> void:
	song.set_sync_stream_volume(STEMS.find(part), db)


## 取り込み済みの音（エディタで res:// に置いたもの）か、取り込んでいない ogg（遊ぶ人が足した曲）を読む
static func _load_audio(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		return load(path)
	if path.get_extension() == "ogg" and FileAccess.file_exists(path):
		return AudioStreamOggVorbis.load_from_file(path)
	return null
