extends GutTest

const Inflation = preload("res://scripts/inflation.gd")


func test_進み具合0では倍率1():
	assert_almost_eq(Inflation.scale_at(0.0, 1e8), 1.0, 1e-6)


func test_進み具合1では最終倍率():
	assert_almost_eq(Inflation.scale_at(1.0, 1e8), 1e8, 1.0)


func test_進み具合の半分では最終倍率の平方根になり指数関数的に増える():
	assert_almost_eq(Inflation.scale_at(0.5, 1e8), 1e4, 0.01)
