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
	for chunk in _sounding_notes(smf_data):
		if chunk.channel_number in used_channels:
			note_ticks.append(chunk.time)
	note_ticks.sort()

	var cumulative := 0
	for tick in note_ticks:
		cumulative += 1
		result.append(Vector2(tick, cumulative))

	return result


## 楽器の種類を推定するための、チャンネルごとの特徴を
## { チャンネル: { note_count, program, mean_pitch, polyphony, track_name } } として返す
## programは最初に指定された音色の番号（指定がなければ-1）、polyphonyは同じtickに鳴る音の数の平均、
## track_nameはそのチャンネルのノートがある最初のトラックの名前（なければ空）。ノートのないチャンネルは含めない
func channel_profiles(smf_data: SMF.SMFData) -> Dictionary:
	var programs := _first_programs(smf_data)
	var track_names := _channel_track_names(smf_data)
	var pitch_sums := {}
	var note_ticks := {}  # チャンネル -> { 音が鳴ったtick: true }
	var profiles := {}
	for chunk in _sounding_notes(smf_data):
		var channel := chunk.channel_number
		if not profiles.has(channel):
			profiles[channel] = {
				"note_count": 0,
				"program": programs.get(channel, -1),
				"track_name": track_names.get(channel, ""),
			}
			pitch_sums[channel] = 0
			note_ticks[channel] = {}
		profiles[channel].note_count += 1
		pitch_sums[channel] += (chunk.event as SMF.MIDIEventNoteOn).note
		note_ticks[channel][chunk.time] = true
	for channel in profiles:
		var note_count: int = profiles[channel].note_count
		profiles[channel].mean_pitch = float(pitch_sums[channel]) / note_count
		profiles[channel].polyphony = float(note_count) / note_ticks[channel].size()
	return profiles


## チャンネルごとに、そのチャンネルのノートがある最初のトラックの名前
func _channel_track_names(smf_data: SMF.SMFData) -> Dictionary:
	var names := {}
	for track: SMF.MIDITrack in smf_data.tracks:
		var track_name := ""
		for chunk: SMF.MIDIEventChunk in track.events:
			if chunk.event is SMF.MIDIEventSystemEvent:
				var args: Dictionary = chunk.event.args
				if args.type == SMF.MIDISystemEventType.track_name and track_name == "":
					track_name = args.text
			elif chunk.event.type == SMF.MIDIEventType.note_on and track_name != "":
				if not names.has(chunk.channel_number):
					names[chunk.channel_number] = track_name
	return names


## チャンネルごとに、いちばん早いプログラムチェンジの音色の番号
func _first_programs(smf_data: SMF.SMFData) -> Dictionary:
	var programs := {}
	var program_ticks := {}
	for track: SMF.MIDITrack in smf_data.tracks:
		for chunk: SMF.MIDIEventChunk in track.events:
			if chunk.event.type != SMF.MIDIEventType.program_change:
				continue
			var channel := chunk.channel_number
			if program_ticks.has(channel) and program_ticks[channel] <= chunk.time:
				continue
			program_ticks[channel] = chunk.time
			programs[channel] = (chunk.event as SMF.MIDIEventProgramChange).number
	return programs


## 全トラックの、音の鳴るnote_on（velocity 0のノートオフ扱いを除く）
func _sounding_notes(smf_data: SMF.SMFData) -> Array[SMF.MIDIEventChunk]:
	var notes: Array[SMF.MIDIEventChunk] = []
	for track: SMF.MIDITrack in smf_data.tracks:
		for chunk: SMF.MIDIEventChunk in track.events:
			if chunk.event.type != SMF.MIDIEventType.note_on:
				continue
			if (chunk.event as SMF.MIDIEventNoteOn).velocity == 0:
				continue
			notes.append(chunk)
	return notes


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
