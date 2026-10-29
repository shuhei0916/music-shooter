extends GutTest


func test_拍の瞬間に体がつぶれる():
	assert_almost_eq(Groove.squash(0.0, false, 1.0), Groove.SQUASH_WEAK, 0.0001)


func test_小節の頭の拍では強くつぶれる():
	assert_almost_eq(Groove.squash(0.0, true, 1.0), Groove.SQUASH_STRONG, 0.0001)
	assert_lt(Groove.SQUASH_WEAK, Groove.SQUASH_STRONG)


func test_拍のあと少しずつ戻り戻る時間がたてばつぶれない():
	var early := Groove.squash(0.05, true, 1.0)
	assert_lt(early, Groove.SQUASH_STRONG)
	assert_gt(early, 0.0)
	assert_almost_eq(Groove.squash(Groove.DURATION, true, 1.0), 0.0, 0.0001)


func test_盛り上がりが小さいほど小さく動くが止まりはしない():
	var calm := Groove.squash(0.0, true, 0.0)
	assert_almost_eq(calm, Groove.SQUASH_STRONG * Groove.CALM_AMOUNT, 0.0001)
	assert_gt(calm, 0.0)
	assert_lt(Groove.squash(0.0, true, 0.5), Groove.squash(0.0, true, 1.0))


func test_拍の瞬間は拍ごとに左右交互に傾く():
	assert_almost_eq(Groove.sway(0, 0.0, 0.5, 1.0), Groove.SWAY, 0.0001)
	assert_almost_eq(Groove.sway(1, 0.0, 0.5, 1.0), -Groove.SWAY, 0.0001)
	assert_almost_eq(Groove.sway(2, 0.0, 0.5, 1.0), Groove.SWAY, 0.0001)


func test_拍と拍のまん中ではまっすぐに戻る():
	assert_almost_eq(Groove.sway(0, 0.25, 0.5, 1.0), 0.0, 0.0001)


func test_盛り上がりが小さいほど小さく傾く():
	assert_almost_eq(Groove.sway(0, 0.0, 0.5, 0.0), Groove.SWAY * Groove.CALM_AMOUNT, 0.0001)
