## 時刻順に並んだMIDIイベントから、指定tickまでに到達したノートを取り出す
extends RefCounted

var _events: Array[SMF.MIDIEventChunk]


func _init(events: Array[SMF.MIDIEventChunk]) -> void:
	_events = events


func pop_due(_tick_limit: float) -> Array[SMF.MIDIEventChunk]:
	return _events
