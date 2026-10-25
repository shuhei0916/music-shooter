class_name SongAnalyzer
extends RefCounted


func compute_cumulative_counts(
	smf_data: SMF.SMFData, timebase_to_seconds: float, used_channels: Array
) -> PackedVector2Array:
	var result := PackedVector2Array()
	if smf_data == null or smf_data.tracks.is_empty():
		return result

	# 複数トラックの曲でも時刻順に累積するよう、全トラックのノートの時刻を集めて並べる
	var note_ticks: Array[int] = []
	for track: SMF.MIDITrack in smf_data.tracks:
		for chunk: SMF.MIDIEventChunk in track.events:
			if chunk.channel_number not in used_channels:
				continue
			if chunk.event.type != SMF.MIDIEventType.note_on:
				continue
			var note_on := chunk.event as SMF.MIDIEventNoteOn
			if note_on.velocity == 0:
				continue
			note_ticks.append(chunk.time)
	note_ticks.sort()

	var cumulative := 0
	for tick in note_ticks:
		cumulative += 1
		result.append(Vector2(tick * timebase_to_seconds, cumulative))

	return result
