extends GutTest


## spec [左端のレーン, HP, 占めるレーン数] が占めるレーン
func _lanes_of(spec: Array) -> Array:
	return range(spec[0], spec[0] + spec[2])


func test_敵の列は1から3のレーンを重ならずに埋める():
	var wave := EnemyWave.new(3, 5, 5, 100.0, 1)
	for i in 50:
		var lanes := []
		for spec in wave.make(0.0):
			lanes += _lanes_of(spec)
		assert_between(lanes.size(), 1, 3)
		for lane in lanes:
			assert_between(lane, 0, 2)
			assert_eq(lanes.count(lane), 1)


func test_ときどき2レーンを占める大きな敵が出てHPはふつうの敵の倍():
	var wave := EnemyWave.new(3, 5, 5, 100.0, 1)
	var bigs := []
	var smalls := []
	for i in 50:
		for spec in wave.make(0.0):
			if spec[2] == 2:
				bigs.append(spec)
			else:
				smalls.append(spec)
	assert_gt(bigs.size(), 0)
	assert_gt(smalls.size(), bigs.size())
	for spec in bigs:
		assert_eq(spec[1], 5 * EnemyWave.BIG_HP_RATE)


## ふつうの敵（1レーン）の HP
func _hps_at(distance: float) -> Array:
	var wave := EnemyWave.new(3, 5, 500, 100.0, 1)
	var hps := []
	for i in 10:
		for spec in wave.make(distance):
			if spec[2] == 1:
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
