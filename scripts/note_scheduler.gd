## 時刻順に並んだMIDIイベントから、指定tickまでに到達したノートを取り出す
extends RefCounted

var _events: Array[SMF.MIDIEventChunk]
var _pointer := 0


func _init(events: Array[SMF.MIDIEventChunk]) -> void:
	_events = events


func pop_due(tick_limit: float) -> Array[SMF.MIDIEventChunk]:
	var due: Array[SMF.MIDIEventChunk] = []
	while _pointer < _events.size() and _events[_pointer].time <= tick_limit:
		if _is_sounding_note_on(_events[_pointer].event):
			due.append(_events[_pointer])
		_pointer += 1
	return due


## 再生中のMidiPlayerの位置よりlookahead_sec秒先までに到達したノートを取り出す
func pop_due_ahead(midi_player: MidiPlayer, lookahead_sec: float) -> Array[SMF.MIDIEventChunk]:
	var lookahead_ticks: float = (
		lookahead_sec
		* midi_player.seconds_to_timebase
		* midi_player.smf_data.timebase
		* midi_player.play_speed
	)
	return pop_due(midi_player.position + lookahead_ticks)


func _is_sounding_note_on(event: SMF.MIDIEvent) -> bool:
	return event.type == SMF.MIDIEventType.note_on and event.velocity > 0
