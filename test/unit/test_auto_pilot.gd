extends GutTest


func _stats(hp: int, power := 1, fire_level := 0) -> PlayerStats:
	var stats := PlayerStats.new(hp)
	stats.power = power
	stats.fire_level = fire_level
	return stats


func test_ゲートの得点はHPが増える割合():
	var stats := _stats(20)
	assert_almost_eq(AutoPilot.gate_score(Gate.new(Gate.Op.ADD, 10), stats), 0.5, 0.0001)
	assert_almost_eq(AutoPilot.gate_score(Gate.new(Gate.Op.ADD, -5), stats), -0.25, 0.0001)
	assert_almost_eq(AutoPilot.gate_score(Gate.new(Gate.Op.MULTIPLY, 3), stats), 2.0, 0.0001)


func test_威力のゲートの得点はダメージが増える割合():
	var stats := _stats(20, 2)
	assert_almost_eq(AutoPilot.gate_score(Gate.new(Gate.Op.POWER, 1), stats), 0.5, 0.0001)


func test_連射のゲートの得点は1小節に撃つ数が増える割合で上限なら0():
	assert_almost_eq(AutoPilot.gate_score(Gate.new(Gate.Op.FIRE_RATE, 1), _stats(20)), 1.0, 0.0001)
	var maxed := _stats(20, 1, PlayerStats.MAX_FIRE_LEVEL)
	assert_almost_eq(AutoPilot.gate_score(Gate.new(Gate.Op.FIRE_RATE, 1), maxed), 0.0, 0.0001)


func test_ゲートの列では得点のいちばん高いゲートへ向かう():
	var gates := [
		{"x": -2.0, "gate": Gate.new(Gate.Op.ADD, 5)},
		{"x": 2.0, "gate": Gate.new(Gate.Op.MULTIPLY, 2)},
	]
	assert_eq(AutoPilot.choose_gate(gates, _stats(10)), 2.0)


func test_敵の列では敵のいないレーンへ向かう():
	var enemies := [{"x": -3.0, "hp": 5}, {"x": 0.0, "hp": 5}]
	assert_eq(AutoPilot.choose_lane([-3.0, 0.0, 3.0], enemies, -3.0), 3.0)


func test_全部のレーンに敵がいればHPのいちばん少ない敵へ向かう():
	var enemies := [{"x": -3.0, "hp": 9}, {"x": 0.0, "hp": 4}, {"x": 3.0, "hp": 7}]
	assert_eq(AutoPilot.choose_lane([-3.0, 0.0, 3.0], enemies, 3.0), 0.0)


func test_同じだけ良いレーンが複数あれば今の位置に近いほうへ向かう():
	var enemies := [{"x": 0.0, "hp": 5}]
	assert_eq(AutoPilot.choose_lane([-3.0, 0.0, 3.0], enemies, 2.0), 3.0)
	assert_eq(AutoPilot.choose_lane([-3.0, 0.0, 3.0], enemies, -1.0), -3.0)


func test_向かう位置が右なら右へ左なら左へ近ければ止まる():
	assert_eq(AutoPilot.axis(0.0, 3.0), 1.0)
	assert_eq(AutoPilot.axis(0.0, -3.0), -1.0)
	assert_eq(AutoPilot.axis(2.95, 3.0), 0.0)


func test_2レーンを占める敵は両方のレーンをふさぐ():
	var enemies := [{"x": -1.5, "hp": 5, "lanes": 2}]
	assert_eq(AutoPilot.choose_lane([-3.0, 0.0, 3.0], enemies, -3.0), 3.0)


func test_剣のゲートの得点は剣が増える割合():
	var stats := _stats(20)
	stats.sword_count = 2
	assert_almost_eq(AutoPilot.gate_score(Gate.new(Gate.Op.SWORD, 1), stats), 0.5, 0.0001)


func test_剣ダメージのゲートの得点は剣のダメージが増える割合():
	var stats := _stats(20)
	stats.sword_damage = 4
	assert_almost_eq(AutoPilot.gate_score(Gate.new(Gate.Op.SWORD_DAMAGE, 2), stats), 0.5, 0.0001)


func test_乗りかえのゲートの得点はまだなら決めた値ですでに持っていれば0():
	var stats := _stats(20)
	var gate := Gate.new(Gate.Op.SWORD_RETARGET, 1)
	assert_almost_eq(AutoPilot.gate_score(gate, stats), AutoPilot.RETARGET_SCORE, 0.0001)
	stats.sword_retarget = true
	assert_almost_eq(AutoPilot.gate_score(gate, stats), 0.0, 0.0001)


func test_衝撃波のゲートの得点は届く広さが広がる割合で上限なら0():
	var stats := PlayerStats.new(10)
	assert_almost_eq(AutoPilot.gate_score(Gate.new(Gate.Op.SHOCKWAVE, 1), stats), 0.25, 0.001)
	stats.shockwave_level = PlayerStats.MAX_SHOCKWAVE_LEVEL
	assert_eq(AutoPilot.gate_score(Gate.new(Gate.Op.SHOCKWAVE, 1), stats), 0.0)


func test_衝撃波ダメージのゲートの得点は衝撃波のダメージが増える割合():
	var stats := PlayerStats.new(10)
	stats.shockwave_damage = 4
	assert_eq(AutoPilot.gate_score(Gate.new(Gate.Op.SHOCKWAVE_DAMAGE, 2), stats), 0.5)
