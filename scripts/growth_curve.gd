extends Resource

class_name GrowthCurve

const SMF = preload("res://addons/midi/SMF.gd")

static func compute_from_smf(smf_data) -> PackedVector2Array:
	var result := PackedVector2Array()
	if smf_data == null:
		return result

	var note_times: Array[int] = []
	for track in smf_data.tracks:
		for chunk in track.events:
			if _is_note_on(chunk):
				note_times.append(chunk.time)

	if note_times.is_empty():
		return result

	note_times.sort()

	var running_total := 0
	for time in note_times:
		running_total += 1
		result.append(Vector2(time, running_total))

	return result

static func _is_note_on(chunk) -> bool:
	if chunk == null or chunk.event == null:
		return false
	if not chunk.event is SMF.MIDIEventNoteOn:
		return false
	return chunk.event.velocity > 0
