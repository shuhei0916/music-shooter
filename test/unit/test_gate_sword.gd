extends GutTest
## 剣のゲート。スネアやハイハットでたまる剣の本数を増やす


func test_剣のゲートを通ると剣の段階が上がる():
	var stats := PlayerStats.new(10)
	Gate.new(Gate.Op.SWORD, 1).apply(stats)
	assert_eq(stats.sword_count, 2)


func test_剣のゲートの表示は剣UP():
	assert_eq(Gate.new(Gate.Op.SWORD, 1).label(), "剣UP")


func test_剣のゲートの表示は1回に撃つ本数の取る前と取ったあとになる():
	var stats := PlayerStats.new(10)
	assert_eq(Gate.new(Gate.Op.SWORD, 1).label(stats), "剣UP\n4->8")


func test_乗りかえのゲートを通ると剣が乗りかえられるようになる():
	var stats := PlayerStats.new(10)
	Gate.new(Gate.Op.SWORD_RETARGET, 1).apply(stats)
	assert_true(stats.sword_retarget)


func test_乗りかえのゲートの表示():
	assert_eq(Gate.new(Gate.Op.SWORD_RETARGET, 1).label(), "剣の乗りかえ")
	assert_false(Gate.new(Gate.Op.SWORD_RETARGET, 1).is_harmful())


func test_剣ダメージのゲートを通ると剣のダメージが上がり弾の威力は変わらない():
	var stats := PlayerStats.new(10)
	Gate.new(Gate.Op.SWORD_DAMAGE, 2).apply(stats)
	assert_eq(stats.sword_damage, 3)
	assert_eq(stats.power, 1)


func test_剣ダメージのゲートの表示は取る前と取ったあとのダメージ():
	assert_eq(Gate.new(Gate.Op.SWORD_DAMAGE, 1).label(), "剣ダメージUP\n+1")
	var stats := PlayerStats.new(10)
	stats.sword_damage = 2_500
	assert_eq(Gate.new(Gate.Op.SWORD_DAMAGE, 1_200).label(stats), "剣ダメージUP\n2.5k->3.7k")
