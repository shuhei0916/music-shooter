extends GutTest


func test_プラスのゲートを通るとHPがその数だけ増える():
	var gate := Gate.new(Gate.Op.ADD, 5)
	assert_eq(gate.apply(10), 15)


func test_かけ算のゲートを通るとHPがその数の倍になる():
	var gate := Gate.new(Gate.Op.MULTIPLY, 2)
	assert_eq(gate.apply(10), 20)
