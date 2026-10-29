extends GutTest


func test_拍の瞬間に体が一瞬ふくらむ():
	assert_almost_eq(Groove.scale(0.0, 1.0), 1.0 + Groove.PEAK, 0.0001)


func test_拍のあと少しずつ戻り戻る時間がたてば元の大きさ():
	var early := Groove.scale(0.03, 1.0)
	assert_lt(early, 1.0 + Groove.PEAK)
	assert_gt(early, 1.0)
	assert_almost_eq(Groove.scale(Groove.DURATION, 1.0), 1.0, 0.0001)
	assert_almost_eq(Groove.scale(0.4, 1.0), 1.0, 0.0001)


func test_盛り上がりが小さいほど小さくふくらむが止まりはしない():
	var calm := Groove.scale(0.0, 0.0)
	assert_almost_eq(calm, 1.0 + Groove.PEAK * Groove.CALM_AMOUNT, 0.0001)
	assert_gt(calm, 1.0)
	assert_lt(Groove.scale(0.0, 0.5), Groove.scale(0.0, 1.0))
