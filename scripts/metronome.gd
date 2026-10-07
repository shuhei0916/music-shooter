## タイミング調整用に、1拍ごとにクリック音を鳴らすMIDIデータを作る
extends RefCounted

const TIMEBASE = 480
const CHANNEL = 9  # ドラムチャンネル
const NOTE = 37  # サイドスティック


static func build(_bpm: float, beats: int) -> SMF.SMFData:
	var events: Array[SMF.MIDIEventChunk] = []
	for beat in beats:
		events.append(
			SMF.MIDIEventChunk.new(beat * TIMEBASE, CHANNEL, SMF.MIDIEventNoteOn.new(NOTE, 100))
		)
	var tracks: Array[SMF.MIDITrack] = [SMF.MIDITrack.new(0, events)]
	return SMF.SMFData.new(SMF.SMFFormat.format_0, 1, TIMEBASE, tracks)
