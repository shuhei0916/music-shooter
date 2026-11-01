extends GutTest


## 10m おきの小節の線。energies は小節ごとの盛り上がり
func _lines(energies: Array) -> Array:
	var lines := []
	for i in energies.size():
		lines.append({"distance": 10.0 * i, "energy": energies[i]})
	return lines


func test_最初の小節の線ではスタートの値で錨の小節の線では錨の値になる():
	var curve := GrowthCurve.new(_lines([0.5, 0.5, 0.5, 0.5, 0.5]), 5.0, 4, 5_000.0)
	assert_almost_eq(curve.value_at(0.0), 5.0, 0.001)
	assert_almost_eq(curve.value_at(40.0), 5_000.0, 0.01)


func test_盛り上がりが一定なら小節ごとに同じ比率で増える():
	var curve := GrowthCurve.new(_lines([0.5, 0.5, 0.5, 0.5]), 1.0, 3, 1_000.0)
	assert_almost_eq(curve.value_at(10.0), 10.0, 0.001)
	assert_almost_eq(curve.value_at(20.0), 100.0, 0.01)


func test_盛り上がりの大きい小節ほど大きく増える():
	var curve := GrowthCurve.new(_lines([0.0, 1.0, 1.0]), 1.0, 2, 1_000.0)
	var calm := curve.value_at(10.0) / curve.value_at(0.0)
	var hot := curve.value_at(20.0) / curve.value_at(10.0)
	assert_gt(calm, 1.0)
	assert_gt(hot, calm)


func test_小節の線のあいだは同じ比率で増えるようにつなぐ():
	var curve := GrowthCurve.new(_lines([0.5, 0.5]), 1.0, 1, 100.0)
	assert_almost_eq(curve.value_at(5.0), 10.0, 0.001)


func test_最初の線より手前はスタートの値で最後の線より先は最後の線の値():
	var lines := [{"distance": 10.0, "energy": 0.5}, {"distance": 20.0, "energy": 0.5}]
	var curve := GrowthCurve.new(lines, 2.0, 1, 50.0)
	assert_almost_eq(curve.value_at(3.0), 2.0, 0.001)
	assert_almost_eq(curve.value_at(99.0), 50.0, 0.01)


func test_錨が最初の線なら増えずにスタートの値のまま():
	var curve := GrowthCurve.new(_lines([0.5, 0.5]), 3.0, 0, 100.0)
	assert_almost_eq(curve.value_at(10.0), 3.0, 0.001)


func test_ゲートの数はスタートからの規模の倍率をかけて上から2桁に丸める():
	# 規模は 5 から 4 小節で 5万。1小節で10倍
	var curve := GrowthCurve.new(_lines([0.5, 0.5, 0.5, 0.5, 0.5]), 5.0, 4, 50_000.0)
	assert_eq(curve.scaled(10, 0.0), 10)
	assert_eq(curve.scaled(10, 10.0), 100)
	assert_eq(curve.scaled(-15, 30.0), -15_000)
	assert_eq(curve.scaled(1, 15.0), 32)
	assert_eq(curve.scaled(7, 35.0), 22_000)


func test_丸めは上から2桁で100未満はそのまま整数にする():
	assert_eq(GrowthCurve.round_nice(47.4), 47)
	assert_eq(GrowthCurve.round_nice(123.0), 120)
	assert_eq(GrowthCurve.round_nice(12_345.0), 12_000)
	assert_eq(GrowthCurve.round_nice(-3_456_789.0), -3_500_000)
