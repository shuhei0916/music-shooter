extends GutTest


func test_BPM120なら1拍は0点5秒():
	assert_almost_eq(BeatGrid.new(120.0).seconds_per_beat(), 0.5, 0.0001)


func test_前回から今までのあいだに拍の線をまたいだら撃つ():
	assert_true(BeatGrid.new(120.0).crossed(0.4, 0.6, 1.0))


func test_拍の線をまたいでいなければ撃たない():
	assert_false(BeatGrid.new(120.0).crossed(0.1, 0.4, 1.0))


func test_半拍ごとなら半拍の線をまたいだら撃つ():
	assert_true(BeatGrid.new(120.0).crossed(0.2, 0.3, 0.5))


func test_最初の拍の時刻があれば拍の線もその分だけずれる():
	var grid := BeatGrid.new(120.0, 0.45)
	assert_true(grid.crossed(0.4, 0.46, 1.0))


func test_最初の拍の時刻がずれていれば元の拍の線では撃たない():
	var grid := BeatGrid.new(120.0, 0.45)
	assert_false(grid.crossed(0.4, 0.44, 1.0))
	assert_false(grid.crossed(0.46, 0.6, 1.0))


func test_拍のJSONからBPMと最初の拍の時刻を読む():
	var grid := BeatGrid.from_json('{"bpm": 105.0, "offset": 0.4528}', 120.0)
	assert_almost_eq(grid.bpm, 105.0, 0.0001)
	assert_almost_eq(grid.offset, 0.4528, 0.0001)


func test_拍のJSONが空ならBPMは決めておいた値で最初の拍は0秒():
	var grid := BeatGrid.from_json("", 120.0)
	assert_almost_eq(grid.bpm, 120.0, 0.0001)
	assert_almost_eq(grid.offset, 0.0, 0.0001)


func test_拍のJSONに必要な値がなければBPMは決めておいた値で最初の拍は0秒():
	var grid := BeatGrid.from_json('{"bpm": 105.0}', 120.0)
	assert_almost_eq(grid.bpm, 120.0, 0.0001)
	assert_almost_eq(grid.offset, 0.0, 0.0001)


func test_拍のJSONが壊れていればBPMは決めておいた値で最初の拍は0秒():
	var grid := BeatGrid.from_json('{"bpm": 105', 120.0)
	assert_almost_eq(grid.bpm, 120.0, 0.0001)
	assert_almost_eq(grid.offset, 0.0, 0.0001)
