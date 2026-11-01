extends GutTest


## spec [左端のレーン, HP, 占めるレーン数] が占めるレーン
func _lanes_of(spec: Array) -> Array:
	return range(spec[0], spec[0] + spec[2])


## 距離 0・50・100 に小節の線があり、5 から始まって 100 で goal_hp になる規模の曲線
func _curve(goal_hp: float) -> GrowthCurve:
	var lines := []
	for distance in [0.0, 50.0, 100.0]:
		lines.append({"distance": distance, "energy": 0.5})
	return GrowthCurve.new(lines, 5.0, 2, goal_hp)


func test_ふつうの敵の列は1レーンの敵で1から2のレーンを重ならずに埋め必ず1レーンは空ける():
	var wave := EnemyWave.new(3, _curve(5.0), 1)
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
	var wave := EnemyWave.new(3, _curve(500.0), 1)
	var hps := []
	for i in 10:
		for spec in wave.make(distance):
			hps.append(spec[1])
	return hps


func test_敵のHPはその位置の規模の曲線の値を丸めたものになる():
	for distance in [0.0, 50.0, 100.0]:
		var expected: int = [5, 50, 500][int(distance / 50.0)]
		for hp in _hps_at(distance):
			assert_eq(hp, expected)


func test_ボスは全部のレーンを埋める1体でHPはその位置のふつうの敵の何倍もある():
	var wave := EnemyWave.new(3, _curve(500.0), 1)
	assert_eq(wave.boss(50.0), [[0, 50 * EnemyWave.BOSS_HP_RATE, 3]])
	assert_gt(EnemyWave.BOSS_HP_RATE, 1)
