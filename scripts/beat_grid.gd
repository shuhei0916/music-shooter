class_name BeatGrid
extends RefCounted
## 曲のBPMから拍の線を引き、時刻がその線をまたいだかを判定する

var bpm: float


func _init(p_bpm: float) -> void:
	bpm = p_bpm


func seconds_per_beat() -> float:
	return 60.0 / bpm


## prev_time より後、now 以下に、beats 拍ごとの線があれば true
func crossed(prev_time: float, now: float, beats: float) -> bool:
	var step := seconds_per_beat() * beats
	return floori(now / step) > floori(prev_time / step)
