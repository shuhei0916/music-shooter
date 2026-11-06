extends GutTest
## 音の解析と曲の組み立てから、背景の演出の値を求める


func _track(parts: Dictionary) -> PartTrack:
	return PartTrack.from_json(JSON.stringify({"frame_rate": 1, "parts": parts}))


## 120 BPM（1拍 0.5 秒、1小節 2 秒）で、0小節目から VERSE、4小節目から BUILD、8小節目から DROP
func _map() -> SongMap:
	var sections := [
		{"bar": 0, "label": "VERSE", "energy": 0.5},
		{"bar": 4, "label": "BUILD", "energy": 0.6},
		{"bar": 8, "label": "DROP", "energy": 1.0},
	]
	return SongMap.new(BeatGrid.new(120.0, 0.0), 0.0, 4, sections, 16)


func _look(time: float, parts := {}, map := _map()) -> Dictionary:
	return MusicVisual.new(_track(parts), map).at(time, map.at(time))


func test_キックが鳴ってからの秒数を返す():
	var look := _look(1.5, {"kick": {"level": [], "onsets": [1.0]}})
	assert_almost_eq(look.kick_age, 0.5, 0.001)


func test_キックが鳴っていなければ秒数は大きな有限の値():
	var look := _look(1.0)
	assert_eq(look.kick_age, MusicVisual.NEVER_AGE)


func test_音の光は鳴った瞬間が最も強く時間で消える():
	var parts := {"snare": {"level": [], "onsets": [1.0]}}
	assert_almost_eq(_look(1.0, parts).snare, 1.0, 0.001)
	assert_between(_look(1.1, parts).snare, 0.01, 0.99)
	assert_eq(_look(3.0, parts).snare, 0.0)


func test_まだ鳴っていないパートの光は0():
	assert_eq(_look(1.0).hihat, 0.0)


func test_ベースは鳴っている大きさをそのまま使う():
	var look := _look(1.0, {"bass": {"level": [0.25, 0.25, 0.25], "onsets": []}})
	assert_almost_eq(look.bass, 0.25, 0.001)


func test_ふだんの粒の広がりは1():
	assert_eq(_look(1.0).spread, 1.0)


func test_BUILDのあいだ粒は集まっていく():
	assert_almost_eq(_look(8.0).spread, 1.0, 0.001)
	var middle: float = _look(12.0).spread
	assert_lt(middle, 1.0)
	assert_gt(middle, _look(15.9).spread)
	assert_gte(_look(15.9).spread, MusicVisual.GATHERED_SPREAD)


func test_DROPの頭で粒が弾けて数拍で落ち着く():
	var start := _look(16.0)
	assert_eq(start.burst, 1.0)
	assert_gt(start.spread, 1.0)
	var settled := _look(16.0 + MusicVisual.BURST_BEATS * 0.5)
	assert_eq(settled.burst, 0.0)
	assert_eq(settled.spread, 1.0)


func test_盛り上がりはセクションの値を使う():
	assert_eq(_look(1.0).energy, 0.5)
	assert_eq(_look(16.0).energy, 1.0)


func test_セクションが分からない曲は中くらいの盛り上がり():
	var map := SongMap.new(BeatGrid.new(120.0, 0.0), 0.0)
	assert_eq(_look(1.0, {}, map).energy, MusicVisual.UNKNOWN_ENERGY)


func test_セクションごとに色が変わる():
	assert_ne(_look(1.0).color_a, _look(16.0).color_a)
	assert_eq(_look(16.0).color_a, MusicVisual.PALETTES["DROP"][0])
	assert_eq(_look(16.0).color_b, MusicVisual.PALETTES["DROP"][1])


func test_知らないセクションはVERSEの色():
	var map := SongMap.new(BeatGrid.new(120.0, 0.0), 0.0)
	assert_eq(_look(1.0, {}, map).color_a, MusicVisual.PALETTES["VERSE"][0])
