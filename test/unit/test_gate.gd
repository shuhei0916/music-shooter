extends GutTest


func test_プラスのゲートを通るとHPがその数だけ増える():
	var gate := Gate.new(Gate.Op.ADD, 5)
	assert_eq(gate.apply(10), 15)


func test_かけ算のゲートを通るとHPがその数の倍になる():
	var gate := Gate.new(Gate.Op.MULTIPLY, 2)
	assert_eq(gate.apply(10), 20)


func test_マイナスのゲートを通るとHPがその数だけ減る():
	var gate := Gate.new(Gate.Op.ADD, -3)
	assert_eq(gate.apply(10), 7)


func test_ゲートの表示はプラスなら符号つきの数になる():
	assert_eq(Gate.new(Gate.Op.ADD, 5).label(), "+5")


func test_ゲートの表示はマイナスならマイナスの数になる():
	assert_eq(Gate.new(Gate.Op.ADD, -3).label(), "-3")


func test_ゲートの表示はかけ算ならバツ印つきの数になる():
	assert_eq(Gate.new(Gate.Op.MULTIPLY, 2).label(), "×2")
