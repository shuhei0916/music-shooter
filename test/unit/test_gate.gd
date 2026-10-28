extends GutTest


func test_プラスのゲートを通るとHPがその数だけ増える():
	var stats := PlayerStats.new(10)
	Gate.new(Gate.Op.ADD, 5).apply(stats)
	assert_eq(stats.health.hp, 15)


func test_かけ算のゲートを通るとHPがその数の倍になる():
	var stats := PlayerStats.new(10)
	Gate.new(Gate.Op.MULTIPLY, 2).apply(stats)
	assert_eq(stats.health.hp, 20)


func test_マイナスのゲートを通るとHPがその数だけ減る():
	var stats := PlayerStats.new(10)
	Gate.new(Gate.Op.ADD, -3).apply(stats)
	assert_eq(stats.health.hp, 7)


func test_ゲートの表示はプラスなら符号つきの数になる():
	assert_eq(Gate.new(Gate.Op.ADD, 5).label(), "+5")


func test_ゲートの表示はマイナスならマイナスの数になる():
	assert_eq(Gate.new(Gate.Op.ADD, -3).label(), "-3")


func test_ゲートの表示はかけ算ならバツ印つきの数になる():
	assert_eq(Gate.new(Gate.Op.MULTIPLY, 2).label(), "×2")


func test_HPが減るゲートは損なゲート():
	assert_true(Gate.new(Gate.Op.ADD, -3).is_harmful())


func test_HPが増えるゲートは損なゲートではない():
	assert_false(Gate.new(Gate.Op.ADD, 3).is_harmful())
	assert_false(Gate.new(Gate.Op.MULTIPLY, 2).is_harmful())


func test_威力のゲートを通ると弾の威力がその数だけ上がる():
	var stats := PlayerStats.new(10)
	Gate.new(Gate.Op.POWER, 2).apply(stats)
	assert_eq([stats.power, stats.health.hp], [3, 10])


func test_威力のゲートの表示は威力と符号つきの数になる():
	assert_eq(Gate.new(Gate.Op.POWER, 2).label(), "威力+2")


func test_連射のゲートを通ると連射の段階が上がる():
	var stats := PlayerStats.new(10)
	Gate.new(Gate.Op.FIRE_RATE, 1).apply(stats)
	assert_eq(stats.fire_level, 1)


func test_連射の段階は上限より上がらない():
	var stats := PlayerStats.new(10)
	for i in 5:
		Gate.new(Gate.Op.FIRE_RATE, 1).apply(stats)
	assert_eq(stats.fire_level, PlayerStats.MAX_FIRE_LEVEL)


func test_連射のゲートの表示は連射UP():
	assert_eq(Gate.new(Gate.Op.FIRE_RATE, 1).label(), "連射UP")
