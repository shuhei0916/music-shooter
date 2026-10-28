extends GutTest


func test_プラスのゲートを通るとHPがその数だけ増える():
	var gate := Gate.new(Gate.Op.ADD, 5)
	assert_eq(gate.apply(10), 15)
