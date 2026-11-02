extends GutTest


## spec [左端のレーン, HP, 占めるレーン数] が占めるレーン
func _lanes_of(spec: Array) -> Array:
	return range(spec[0], spec[0] + spec[2])


## 距離 0・50・100 に小節の線があり、5 から始まって 100 で goal_hp になる規模の曲線
func _curve(goal_hp: float) -> GrowthCurve:
	var lines := []
	for distance in [0.0, 50.0, 100.0]:
		lines.append({"distance": distance, "energy": 0.5})
	return GrowthCurve.new(lines, 5.0, [[2, goal_hp]])


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


## distance の位置で作った列（10列ぶん）の、敵の HP の並び（列ごと）
func _row_hps_at(distance: float, goal_hp := 500.0) -> Array:
	var wave := EnemyWave.new(3, _curve(goal_hp), 1)
	var rows := []
	for i in 10:
		rows.append(wave.make(distance).map(func(spec): return spec[1]))
	return rows


func test_敵のHPはその位置の規模の曲線の値をもとにした範囲でばらつく():
	var curve := _curve(500.0)
	for distance in [0.0, 50.0, 100.0]:
		var base := curve.value_at(distance)
		var seen := {}
		for hps in _row_hps_at(distance):
			for hp in hps:
				assert_between(
					hp,
					roundi(base * EnemyWave.HP_SPREAD_MIN),
					roundi(base * EnemyWave.HP_SPREAD_MAX)
				)
				seen[hp] = true
		assert_gt(seen.size(), 1)


func test_同じ列の敵のHPはどれも違う():
	# 規模が小さく丸めるとそろいやすい 5 でも違う
	for goal_hp in [5.0, 500.0]:
		var pairs := 0
		for hps in _row_hps_at(0.0, goal_hp) + _row_hps_at(100.0, goal_hp):
			var unique := {}
			for hp in hps:
				unique[hp] = true
			assert_eq(unique.size(), hps.size(), str(hps))
			if hps.size() == 2:
				pairs += 1
		assert_gt(pairs, 0)


func test_ボスは全部のレーンを埋める1体でHPはその位置のふつうの敵の何倍もある():
	var wave := EnemyWave.new(3, _curve(500.0), 1)
	assert_eq(wave.boss(50.0), [[0, wave.hp_at(50.0) * EnemyWave.BOSS_HP_RATE, 3]])
	assert_gt(EnemyWave.BOSS_HP_RATE, 1)


func test_緊張の曲線を渡すとふつうの敵のHPに倍率をかけボスにはかけない():
	var tension := TensionCurve.new([{"distance": 0.0, "label": "DROP", "progress": 0.0}])
	var wave := EnemyWave.new(3, _curve(500.0), 1, tension)
	var expected := roundi(_curve(500.0).value_at(100.0) * TensionCurve.DROP_RATE)
	assert_eq(wave.hp_at(100.0), expected)
	for spec in wave.make(100.0):
		assert_lte(spec[1], roundi(expected * EnemyWave.HP_SPREAD_MAX))
	assert_eq(wave.boss(100.0)[0][1], 500 * EnemyWave.BOSS_HP_RATE)
