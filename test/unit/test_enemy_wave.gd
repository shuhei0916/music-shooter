extends GutTest


## spec [左端のレーン, HP, 占めるレーン数] が占めるレーン
func _lanes_of(spec: Array) -> Array:
	return range(spec[0], spec[0] + spec[2])


func test_ふつうの敵の列は1レーンの敵で1から2のレーンを重ならずに埋め必ず1レーンは空ける():
	var wave := EnemyWave.new(3, 5, 5, 100.0, 1)
	var counts := {}
	for i in 50:
		var lanes := []
		for spec in wave.make(0.0):
			assert_eq(spec[2], 1)
			lanes += _lanes_of(spec)
		assert_between(lanes.size(), 1, 2)
		counts[lanes.size()] = true
		for lane in lanes:
			assert_between(lane, 0, 2)
			assert_eq(lanes.count(lane), 1)
	assert_eq(counts.size(), 2)


func _hps_at(distance: float) -> Array:
	var wave := EnemyWave.new(3, 5, 500, 100.0, 1)
	var hps := []
	for i in 10:
		for spec in wave.make(distance):
			hps.append(spec[1])
	return hps


func test_敵のHPはスタート地点ではスタートのHPになる():
	for hp in _hps_at(0.0):
		assert_eq(hp, 5)


func test_敵のHPはゴールではゴールのHPになる():
	for hp in _hps_at(100.0):
		assert_eq(hp, 500)


func test_敵のHPは一定の比率で増え中間地点では相乗平均になる():
	for hp in _hps_at(50.0):
		assert_eq(hp, 50)


func test_ボスは全部のレーンを埋める1体でHPはその位置のふつうの敵の何倍もある():
	var wave := EnemyWave.new(3, 5, 500, 100.0, 1)
	assert_eq(wave.boss(50.0), [[0, 50 * EnemyWave.BOSS_HP_RATE, 3]])
	assert_gt(EnemyWave.BOSS_HP_RATE, 1)
