## 時刻順に並んだMIDIイベントから、指定tickまでに到達したノートを取り出す
extends RefCounted

var _events: Array[SMF.MIDIEventChunk]
var _pointer := 0


func _init(events: Array[SMF.MIDIEventChunk]) -> void:
	_events = events


func pop_due(tick_limit: float) -> Array[SMF.MIDIEventChunk]:
	var due: Array[SMF.MIDIEventChunk] = []
	while _pointer < _events.size() and _events[_pointer].time <= tick_limit:
		due.append(_events[_pointer])
		_pointer += 1
	return due
