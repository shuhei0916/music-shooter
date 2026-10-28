class_name TimerClock
extends SongClock
## 曲がないときに使う、経過時間で進む時計

var _duration: float
var _time := 0.0


func _init(p_duration: float) -> void:
	_duration = p_duration


func advance(delta: float) -> void:
	_time += delta


func time() -> float:
	return _time


func duration() -> float:
	return _duration
