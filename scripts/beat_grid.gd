class_name BeatGrid
extends RefCounted
## 曲のBPMと最初の拍の時刻から拍の線を引き、時刻がその線をまたいだかを判定する

var bpm: float
## 最初の拍の時刻（秒）。拍の線はここから 1 拍ごとに引く
var offset: float


func _init(p_bpm: float, p_offset := 0.0) -> void:
	bpm = p_bpm
	offset = p_offset


func seconds_per_beat() -> float:
	return 60.0 / bpm


## prev_time より後、now 以下に、beats 拍ごとの線があれば true
func crossed(prev_time: float, now: float, beats: float) -> bool:
	var step := seconds_per_beat() * beats
	return floori((now - offset) / step) > floori((prev_time - offset) / step)


## 曲を調べるツール（tools/analyze.py）が書き出した JSON から作る
## 読めなければ、BPM は fallback_bpm、最初の拍は 0 秒とする
static func from_json(text: String, fallback_bpm: float) -> BeatGrid:
	var json := JSON.new()
	if json.parse(text) != OK:
		return BeatGrid.new(fallback_bpm)
	var data = json.data
	if not (data is Dictionary and data.has("bpm") and data.has("offset")):
		return BeatGrid.new(fallback_bpm)
	return BeatGrid.new(data.bpm, data.offset)
