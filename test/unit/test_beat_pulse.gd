extends GutTest


func test_小節の頭の拍の瞬間は大きくふくらむ():
	assert_almost_eq(BeatPulse.scale(0.0, true), BeatPulse.STRONG, 0.0001)


func test_ほかの拍の瞬間は小さくふくらむ():
	assert_almost_eq(BeatPulse.scale(0.0, false), BeatPulse.WEAK, 0.0001)
	assert_lt(BeatPulse.WEAK, BeatPulse.STRONG)


func test_拍のあと少しずつ元の大きさに戻る():
	var early := BeatPulse.scale(0.03, true)
	var late := BeatPulse.scale(0.1, true)
	assert_lt(early, BeatPulse.STRONG)
	assert_lt(late, early)
	assert_gt(late, 1.0)


func test_戻る時間がたてば元の大きさ():
	assert_almost_eq(BeatPulse.scale(BeatPulse.DURATION, true), 1.0, 0.0001)
	assert_almost_eq(BeatPulse.scale(0.4, false), 1.0, 0.0001)
