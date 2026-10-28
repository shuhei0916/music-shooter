extends GutTest


func test_敵の列は1から3のレーンを重ならずに埋める():
	var wave := EnemyWave.new(3, 5, 0.0, 1)
	for i in 50:
		var lanes: Array = wave.make(0.0).map(func(spec): return spec[0])
		assert_between(lanes.size(), 1, 3)
		for lane in lanes:
			assert_between(lane, 0, 2)
			assert_eq(lanes.count(lane), 1)
