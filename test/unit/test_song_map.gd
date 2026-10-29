extends GutTest

# BPM 120（1拍 0.5 秒、1小節 2 秒）。最初の拍は 0.25 秒、最初の小節の頭は 0.75 秒。
# セクションは 0 小節目からの BUILD と、2 小節目からの DROP。曲は全部で 5 小節
const JSON_TEXT := """{
	"bpm": 120.0, "offset": 0.25, "beats_per_bar": 4, "downbeat": 0.75,
	"sections": [
		{"bar": 0, "start": 0.75, "energy": 0.3, "label": "BUILD"},
		{"bar": 2, "start": 4.75, "energy": 1.0, "label": "DROP"}
	],
	"bar_energy": [0.3, 0.3, 1.0, 1.0, 1.0]
}"""


func _map() -> SongMap:
	return SongMap.from_json(JSON_TEXT, 100.0)


func test_JSONから拍の線も作る():
	var grid := _map().grid
	assert_almost_eq(grid.bpm, 120.0, 0.0001)
	assert_almost_eq(grid.offset, 0.25, 0.0001)


func test_時刻からセクションと小節と拍を求める():
	# 2 小節目の頭（4.75 秒）から 1 拍と 0.1 秒あと
	var pos := _map().at(5.35)
	assert_eq(pos.section_index, 1)
	assert_eq(pos.section_count, 2)
	assert_eq(pos.label, "DROP")
	assert_almost_eq(pos.energy, 1.0, 0.0001)
	assert_eq([pos.bar_in_section, pos.bars_in_section], [0, 3])
	assert_eq(pos.beat_in_bar, 1)
	assert_almost_eq(pos.since_beat, 0.1, 0.0001)


func test_セクションの中の小節を数える():
	var pos := _map().at(0.75 + 2.0 + 0.1)
	assert_eq([pos.section_index, pos.bar_in_section, pos.bars_in_section], [0, 1, 2])
	assert_eq(pos.beat_in_bar, 0)


func test_最初の小節の頭より前は最初のセクションの最初の小節とする():
	# 0.25 秒の拍は、0.75 秒の小節の頭の 1 拍前なので 4 拍目
	var pos := _map().at(0.3)
	assert_eq([pos.section_index, pos.bar_in_section], [0, 0])
	assert_eq(pos.beat_in_bar, 3)
	assert_almost_eq(pos.since_beat, 0.05, 0.0001)


func test_小節の頭が書かれていなければ最初の拍を小節の頭とする():
	var pos := SongMap.from_json('{"bpm": 120.0, "offset": 0.25}', 100.0).at(0.8)
	assert_eq(pos.beat_in_bar, 1)
	assert_eq(pos.section_count, 0)
	assert_eq(pos.label, "")


func test_JSONが読めなければ決めておいたBPMで0秒から拍を数える():
	var map := SongMap.from_json("", 120.0)
	assert_almost_eq(map.grid.bpm, 120.0, 0.0001)
	var pos := map.at(1.1)
	assert_eq(pos.beat_in_bar, 2)
	assert_almost_eq(pos.since_beat, 0.1, 0.0001)


func test_小節の線はコース上の距離に並べる():
	# 小節の頭は 0.75 秒から 2 秒ごと。速さ 10 で、曲の長さは 9 秒
	var lines := _map().bar_lines(10.0, 9.0)
	assert_eq(lines.map(func(line): return line.distance), [7.5, 27.5, 47.5, 67.5, 87.5])


func test_セクションの始まりの小節の線には印をつけ盛り上がりも添える():
	var lines := _map().bar_lines(10.0, 9.0)
	assert_eq(lines.map(func(line): return line.section_start), [true, false, true, false, false])
	assert_almost_eq(lines[2].energy, 1.0, 0.0001)
	assert_almost_eq(lines[0].energy, 0.3, 0.0001)


func test_セクションがなければ小節の線に印はつけない():
	var lines := SongMap.from_json("", 120.0).bar_lines(1.0, 4.0)
	assert_eq(lines.map(func(line): return line.distance), [0.0, 2.0, 4.0])
	assert_eq(lines.map(func(line): return line.section_start), [false, false, false])
