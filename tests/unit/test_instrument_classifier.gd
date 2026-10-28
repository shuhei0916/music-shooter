extends GutTest

const InstrumentClassifier = preload("res://scripts/instrument_classifier.gd")


## SongAnalyzer.channel_profiles()の1チャンネル分と同じ形の特徴を作る
func _profile(overrides: Dictionary = {}) -> Dictionary:
	var profile := {
		"note_count": 100, "program": 0, "mean_pitch": 60.0, "polyphony": 1.0, "track_name": ""
	}
	profile.merge(overrides, true)
	return profile


func test_ch9はドラム() -> void:
	var kinds := InstrumentClassifier.classify({9: _profile()})
	assert_eq(kinds[9], InstrumentClassifier.Instrument.DRUMS)


func test_音色の番号が32から39のチャンネルはベース() -> void:
	var kinds := InstrumentClassifier.classify(
		{0: _profile({"program": 31}), 1: _profile({"program": 32}), 2: _profile({"program": 39})}
	)
	assert_eq(kinds[1], InstrumentClassifier.Instrument.BASS)
	assert_eq(kinds[2], InstrumentClassifier.Instrument.BASS)
	assert_ne(kinds[0], InstrumentClassifier.Instrument.BASS)


func test_トラック名にbassを含むチャンネルは大文字小文字によらずベース() -> void:
	var kinds := InstrumentClassifier.classify(
		{0: _profile({"track_name": "Sub Bass"}), 1: _profile({"track_name": "BASS SYNTH"})}
	)
	assert_eq(kinds[0], InstrumentClassifier.Instrument.BASS)
	assert_eq(kinds[1], InstrumentClassifier.Instrument.BASS)


func test_平均の音の高さが40未満で単音中心のチャンネルはベース() -> void:
	var kinds := InstrumentClassifier.classify(
		{0: _profile({"mean_pitch": 39.9}), 1: _profile({"mean_pitch": 40.0})}
	)
	assert_eq(kinds[0], InstrumentClassifier.Instrument.BASS)
	assert_ne(kinds[1], InstrumentClassifier.Instrument.BASS)


func test_平均の音の高さが低くても和音の多いチャンネルはベースにしない() -> void:
	var kinds := InstrumentClassifier.classify(
		{0: _profile({"mean_pitch": 35.0, "polyphony": 2.0})}
	)
	assert_ne(kinds[0], InstrumentClassifier.Instrument.BASS)


func test_ch9はベースらしい特徴があってもドラム() -> void:
	var kinds := InstrumentClassifier.classify({9: _profile({"program": 33, "mean_pitch": 36.0})})
	assert_eq(kinds[9], InstrumentClassifier.Instrument.DRUMS)


func _vocal_channels(kinds: Dictionary) -> Array:
	return kinds.keys().filter(
		func(channel): return kinds[channel] == InstrumentClassifier.Instrument.VOCAL
	)


func test_ボーカルは1チャンネルだけ選ぶ() -> void:
	var kinds := InstrumentClassifier.classify({0: _profile(), 1: _profile(), 2: _profile()})
	assert_eq(_vocal_channels(kinds).size(), 1)


func test_単音中心で高めのチャンネルのうちノートの最も多いものをボーカルにする() -> void:
	var kinds := (
		InstrumentClassifier
		. classify(
			{
				0: _profile({"note_count": 100}),
				1: _profile({"note_count": 300}),
				2: _profile({"note_count": 500, "polyphony": 3.0}),  # 和音の伴奏
				3: _profile({"note_count": 500, "mean_pitch": 50.0}),  # 低めの伴奏
			}
		)
	)
	assert_eq(_vocal_channels(kinds), [1])


func test_声の音色のチャンネルはノートが少なくてもボーカルにする() -> void:
	var kinds := InstrumentClassifier.classify(
		{0: _profile({"note_count": 500}), 1: _profile({"note_count": 50, "program": 53})}
	)
	assert_eq(_vocal_channels(kinds), [1])


func test_トラック名にvocalかvoiceかmelodyを含むチャンネルを最優先でボーカルにする() -> void:
	for track_name in ["Vocals", "VOICE", "MELODY"]:
		var kinds := (
			InstrumentClassifier
			. classify(
				{
					0: _profile({"note_count": 500, "program": 53}),
					1: _profile({"note_count": 50, "polyphony": 2.0, "track_name": track_name}),
				}
			)
		)
		assert_eq(_vocal_channels(kinds), [1], track_name)


func test_単音中心で高めのチャンネルがなければノートの最も多いものをボーカルにする() -> void:
	var kinds := InstrumentClassifier.classify(
		{
			0: _profile({"note_count": 100, "polyphony": 3.0}),
			1: _profile({"note_count": 300, "polyphony": 3.0})
		}
	)
	assert_eq(_vocal_channels(kinds), [1])


func test_ドラムとベースしかない曲にはボーカルがない() -> void:
	var kinds := InstrumentClassifier.classify({9: _profile(), 1: _profile({"program": 33})})
	assert_eq(_vocal_channels(kinds), [])
