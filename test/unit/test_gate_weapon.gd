extends GutTest
## 武器の段階とダメージを上げるゲート。どの武器かは名前の記号（"sword" など）で指定する


func test_段階のゲートを通るとその武器の段階だけ上がる():
	var stats := PlayerStats.new(10)
	Gate.new(Gate.Op.WEAPON_LEVEL, 1, "lightning").apply(stats)
	assert_eq([stats.lightning.level, stats.sword.level, stats.shockwave.level], [2, 1, 1])


func test_ダメージのゲートを通るとその武器のダメージだけ上がる():
	var stats := PlayerStats.new(10)
	Gate.new(Gate.Op.WEAPON_DAMAGE, 2, "lightning").apply(stats)
	assert_eq([stats.lightning.damage, stats.sword.damage, stats.power], [3, 1, 1])


func test_能力値が分からなければ武器の名前と上がる数だけ出す():
	assert_eq(Gate.new(Gate.Op.WEAPON_LEVEL, 1, "lightning").label(), "落雷UP")
	assert_eq(Gate.new(Gate.Op.WEAPON_DAMAGE, 1, "lightning").label(), "落雷ダメージUP\n+1")


func test_能力値が分かれば取る前と取ったあとを出す():
	var stats := PlayerStats.new(10)
	assert_eq(Gate.new(Gate.Op.WEAPON_LEVEL, 1, "lightning").label(stats), "落雷UP\n1体->2体")
	assert_eq(Gate.new(Gate.Op.WEAPON_DAMAGE, 1, "lightning").label(stats), "落雷ダメージUP\n1->2")


func test_自動操縦の得点は段階なら伸びる値ダメージならダメージが増える割合():
	var stats := PlayerStats.new(10)
	stats.lightning.damage = 4
	assert_eq(AutoPilot.gate_score(Gate.new(Gate.Op.WEAPON_LEVEL, 1, "lightning"), stats), 1.0)
	assert_eq(AutoPilot.gate_score(Gate.new(Gate.Op.WEAPON_DAMAGE, 2, "lightning"), stats), 0.5)


func test_ダメージのゲートは位置の規模に合わせて大きくし武器はそのまま():
	var curve := GrowthCurve.new(
		[{"distance": 0.0, "energy": 0.5}, {"distance": 10.0, "energy": 0.5}], 10, [[1, 100.0]]
	)
	assert_eq(
		curve.scaled_gate([Gate.Op.WEAPON_DAMAGE, 1, "lightning"], 10.0),
		[Gate.Op.WEAPON_DAMAGE, 10, "lightning"]
	)
