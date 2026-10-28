extends GutTest


func test_敵の列は1から3のレーンを重ならずに埋める():
	var wave := EnemyWave.new(3, 5, 5, 100.0, 1)
	for i in 50:
		var lanes: Array = wave.make(0.0).map(func(spec): return spec[0])
		assert_between(lanes.size(), 1, 3)
		for lane in lanes:
			assert_between(lane, 0, 2)
			assert_eq(lanes.count(lane), 1)


func _hps_at(distance: float) -> Array:
	var wave := EnemyWave.new(3, 5, 500, 100.0, 1)
	return wave.make(distance).map(func(spec): return spec[1])


func test_敵のHPはスタート地点ではスタートのHPになる():
	for hp in _hps_at(0.0):
		assert_eq(hp, 5)


func test_敵のHPはゴールではゴールのHPになる():
	for hp in _hps_at(100.0):
		assert_eq(hp, 500)


func test_敵のHPは一定の比率で増え中間地点では相乗平均になる():
	for hp in _hps_at(50.0):
		assert_eq(hp, 50)
