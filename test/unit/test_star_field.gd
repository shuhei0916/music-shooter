extends GutTest
## 背景の星の並び


func test_頼んだ数だけ作る():
	assert_eq(StarField.generate(500, 1).size(), 500)


func test_同じシードなら同じ並びになる():
	assert_eq(StarField.generate(50, 1), StarField.generate(50, 1))
	assert_ne(StarField.generate(50, 1), StarField.generate(50, 2))


func test_奥行きはくり返す長さに収まる():
	var outside := StarField.generate(2000, 3).filter(
		func(star): return star.position.z < 0.0 or star.position.z >= StarField.LENGTH
	)
	assert_eq(outside, [])


func test_道の上は粒でふさがない():
	var blocking := StarField.generate(5000, 4).filter(
		func(star):
			return (
				absf(star.position.x) < StarField.CLEAR_HALF_WIDTH
				and star.position.y > StarField.CLEAR_BELOW
			)
	)
	assert_eq(blocking, [])


func test_光の川は奥行きの端と端でつながる():
	for river in StarField.RIVERS.size():
		var near := StarField.river_center(river, 0.0)
		var far := StarField.river_center(river, StarField.LENGTH)
		assert_almost_eq(near.x, far.x, 0.001)
		assert_almost_eq(near.y, far.y, 0.001)


func test_小さな粒が多く大きな粒は少ない():
	var sizes: Array = StarField.generate(2000, 5).map(func(star): return star.size)
	sizes.sort()
	assert_lt(sizes[sizes.size() / 2] * 3.0, sizes.back())


func test_粒ごとの値は0から1():
	var outside := StarField.generate(500, 6).filter(
		func(star): return star.seed < 0.0 or star.seed > 1.0 or star.tint < 0.0 or star.tint > 1.0
	)
	assert_eq(outside, [])
