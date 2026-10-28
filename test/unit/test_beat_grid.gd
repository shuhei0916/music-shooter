extends GutTest


func test_BPM120なら1拍は0点5秒():
	assert_almost_eq(BeatGrid.new(120.0).seconds_per_beat(), 0.5, 0.0001)


func test_前回から今までのあいだに拍の線をまたいだら撃つ():
	assert_true(BeatGrid.new(120.0).crossed(0.4, 0.6, 1.0))


func test_拍の線をまたいでいなければ撃たない():
	assert_false(BeatGrid.new(120.0).crossed(0.1, 0.4, 1.0))


func test_半拍ごとなら半拍の線をまたいだら撃つ():
	assert_true(BeatGrid.new(120.0).crossed(0.2, 0.3, 0.5))
