extends GutTest


func test_撃った瞬間に銃口がいちばん明るく光る():
	assert_almost_eq(ShotEffect.flash_brightness(0.0), 1.0, 0.0001)


func test_光は少しずつ暗くなり光る時間がたてば消える():
	var early := ShotEffect.flash_brightness(0.02)
	assert_lt(early, 1.0)
	assert_gt(early, 0.0)
	assert_almost_eq(ShotEffect.flash_brightness(ShotEffect.FLASH_DURATION), 0.0, 0.0001)
	assert_almost_eq(ShotEffect.flash_brightness(1.0), 0.0, 0.0001)


func test_光は小さく始まり広がる():
	assert_almost_eq(ShotEffect.flash_size(0.0), ShotEffect.FLASH_START_SIZE, 0.0001)
	assert_gt(ShotEffect.flash_size(0.04), ShotEffect.FLASH_START_SIZE)
	assert_almost_eq(
		ShotEffect.flash_size(ShotEffect.FLASH_DURATION), ShotEffect.FLASH_END_SIZE, 0.0001
	)


func test_撃った瞬間にいちばんのけぞり少しずつ戻る():
	assert_almost_eq(ShotEffect.recoil(0.0), ShotEffect.RECOIL, 0.0001)
	var early := ShotEffect.recoil(0.03)
	assert_lt(early, ShotEffect.RECOIL)
	assert_gt(early, 0.0)
	assert_almost_eq(ShotEffect.recoil(ShotEffect.RECOIL_DURATION), 0.0, 0.0001)
