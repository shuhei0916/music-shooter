extends GutTest
## 衝撃波のゲート。届く広さ（段階）とダメージを上げる


func test_衝撃波のゲートを通ると衝撃波の段階が上がり上限は超えない():
	var stats := PlayerStats.new(10)
	Gate.new(Gate.Op.SHOCKWAVE, 1).apply(stats)
	assert_eq(stats.shockwave_level, 2)
	stats.shockwave_level = PlayerStats.MAX_SHOCKWAVE_LEVEL
	Gate.new(Gate.Op.SHOCKWAVE, 1).apply(stats)
	assert_eq(stats.shockwave_level, PlayerStats.MAX_SHOCKWAVE_LEVEL)


func test_衝撃波のゲートの表示は届く広さの取る前と取ったあと():
	assert_eq(Gate.new(Gate.Op.SHOCKWAVE, 1).label(), "衝撃波UP")
	assert_eq(Gate.new(Gate.Op.SHOCKWAVE, 1).label(PlayerStats.new(10)), "衝撃波UP\n4m->5m")


func test_衝撃波ダメージのゲートを通ると衝撃波のダメージだけ上がる():
	var stats := PlayerStats.new(10)
	Gate.new(Gate.Op.SHOCKWAVE_DAMAGE, 2).apply(stats)
	assert_eq([stats.shockwave_damage, stats.sword_damage, stats.power], [3, 1, 1])


func test_衝撃波ダメージのゲートの表示():
	assert_eq(Gate.new(Gate.Op.SHOCKWAVE_DAMAGE, 1).label(), "衝撃波ダメージUP\n+1")
	assert_eq(Gate.new(Gate.Op.SHOCKWAVE_DAMAGE, 1).label(PlayerStats.new(10)), "衝撃波ダメージUP\n1->2")


func test_衝撃波ダメージは位置の規模に合わせて大きくする():
	var curve := GrowthCurve.new(
		[{"distance": 0.0, "energy": 0.5}, {"distance": 10.0, "energy": 0.5}], 10, [[1, 100.0]]
	)
	assert_eq(curve.scaled_gate([Gate.Op.SHOCKWAVE_DAMAGE, 1], 10.0)[1], 10)
