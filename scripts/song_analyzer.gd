class_name SongAnalyzer
extends RefCounted

## テンポ指定のない曲のテンポ（120BPM）の1拍のマイクロ秒
const DEFAULT_USEC_PER_BEAT := 500_000.0


## used_channelsのノートの累積数を、(tick, そのtickまでの累積数)の点として時刻順に返す
func compute_cumulative_counts(smf_data: SMF.SMFData, used_channels: Array) -> PackedVector2Array:
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
		result.append(Vector2(tick, cumulative))

	return result



## tickを曲の先頭からの秒にする。途中のテンポ変更も反映する（テンポ指定がなければ120BPM）
func ticks_to_seconds(smf_data: SMF.SMFData, tick: int) -> float:
	return seconds_at(tempo_map(smf_data), smf_data.timebase, tick)


## 曲のテンポの変化点を[tick, 1拍のマイクロ秒]の組として時刻順に返す
func tempo_map(smf_data: SMF.SMFData) -> Array:
	var changes: Array = []
	for track: SMF.MIDITrack in smf_data.tracks:
		for chunk: SMF.MIDIEventChunk in track.events:
			if chunk.event is SMF.MIDIEventSystemEvent:
				var args: Dictionary = chunk.event.args
				if args.type == SMF.MIDISystemEventType.set_tempo:
					changes.append([chunk.time, args.bpm])
	changes.sort_custom(func(a, b): return a[0] < b[0])
	return changes


## tempo_map()で求めたテンポの変化点を使って、tickを秒にする（再生中に毎フレーム呼べるよう曲を走査しない）
func seconds_at(changes: Array, timebase: int, tick: float) -> float:
	var seconds := 0.0
	var last_tick := 0.0
	var usec_per_beat := DEFAULT_USEC_PER_BEAT
	for change in changes:
		if change[0] >= tick:
			break
		seconds += (change[0] - last_tick) * usec_per_beat / 1e6 / timebase
		last_tick = change[0]
		usec_per_beat = change[1]
	return seconds + (tick - last_tick) * usec_per_beat / 1e6 / timebase
