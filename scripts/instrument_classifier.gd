## チャンネルの特徴（SongAnalyzer.channel_profiles()）から楽器の種類を決める
## 将来の音声ファイルの曲に合わせ、種類は音源分離（Demucs）の出力と同じ4つにする
extends RefCounted

enum Instrument { VOCAL, DRUMS, BASS, OTHER }

const DRUM_CHANNEL := 9
## GMの音色の番号のうちベースの範囲（Acoustic Bass〜Synth Bass 2）
const BASS_PROGRAM_FIRST := 32
const BASS_PROGRAM_LAST := 39
## 平均の音の高さがこれより低く単音中心ならベースとみなす（40 = E2。ギターのリフは超える）
const BASS_MAX_MEAN_PITCH := 40.0
## 単音中心とみなす、同じtickに鳴る音の数の平均の上限
const MONOPHONIC_MAX_POLYPHONY := 1.2
## ボーカルを示すトラック名の語（小文字）
const VOCAL_TRACK_WORDS: Array[String] = ["vocal", "voice", "melody"]
## GMの声の音色（Choir Aahs・Voice Oohs・Synth Voice・Voice Lead）
const VOICE_PROGRAMS: Array[int] = [52, 53, 54, 85]
## メロディらしいとみなす条件（和音の少しまじる旋律まで許す）
const MELODY_MAX_POLYPHONY := 1.5
const MELODY_MIN_MEAN_PITCH := 60.0


## { チャンネル: 特徴 } から { チャンネル: Instrument } を返す。ボーカル（メロディ担当）は1チャンネルだけ
static func classify(profiles: Dictionary) -> Dictionary:
	var kinds := {}
	for channel in profiles:
		if channel == DRUM_CHANNEL:
			kinds[channel] = Instrument.DRUMS
		elif _is_bass(profiles[channel]):
			kinds[channel] = Instrument.BASS
		else:
			kinds[channel] = Instrument.OTHER
	var vocal := _choose_vocal(profiles, kinds)
	if vocal != -1:
		kinds[vocal] = Instrument.VOCAL
	return kinds


## classify()の結果から、instrumentのチャンネル（複数あれば番号の小さいもの、なければ-1）を返す
static func channel_of(kinds: Dictionary, instrument: Instrument) -> int:
	var channels: Array = kinds.keys().filter(func(channel): return kinds[channel] == instrument)
	return channels.min() if not channels.is_empty() else -1


## ドラムとベース以外から、トラック名 → 声の音色 → メロディらしさの順に候補を絞り、
## そのうちノートの最も多いチャンネルを返す（候補がなければ-1）
static func _choose_vocal(profiles: Dictionary, kinds: Dictionary) -> int:
	var candidates: Array = profiles.keys().filter(
		func(channel): return kinds[channel] == Instrument.OTHER
	)
	for is_preferred: Callable in [_has_vocal_track_name, _has_voice_program, _is_melodic]:
		var preferred := candidates.filter(
			func(channel): return is_preferred.call(profiles[channel])
		)
		if not preferred.is_empty():
			candidates = preferred
			break
	var vocal := -1
	for channel in candidates:
		if vocal == -1 or profiles[channel].note_count > profiles[vocal].note_count:
			vocal = channel
	return vocal


static func _has_vocal_track_name(profile: Dictionary) -> bool:
	var track_name: String = profile.track_name.to_lower()
	return VOCAL_TRACK_WORDS.any(func(word): return word in track_name)


static func _has_voice_program(profile: Dictionary) -> bool:
	return profile.program in VOICE_PROGRAMS


static func _is_melodic(profile: Dictionary) -> bool:
	return profile.polyphony <= MELODY_MAX_POLYPHONY and profile.mean_pitch >= MELODY_MIN_MEAN_PITCH


static func _is_bass(profile: Dictionary) -> bool:
	if BASS_PROGRAM_FIRST <= profile.program and profile.program <= BASS_PROGRAM_LAST:
		return true
	if "bass" in profile.track_name.to_lower():
		return true
	return (
		profile.mean_pitch < BASS_MAX_MEAN_PITCH and profile.polyphony <= MONOPHONIC_MAX_POLYPHONY
	)
