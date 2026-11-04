extends GutTest


## 10m おきの小節の線。energies は小節ごとの盛り上がり
func _lines(energies: Array) -> Array:
	var lines := []
	for i in energies.size():
		lines.append({"distance": 10.0 * i, "energy": energies[i]})
	return lines


## 盛り上がりがどれも 0.5 の、count 本の小節の線
func _flat(count: int) -> Array:
	var energies := []
	energies.resize(count)
	energies.fill(0.5)
	return _lines(energies)


## 小節の線 i から i+1 までで何倍になるか
func _ratio(curve: GrowthCurve, i: int) -> float:
	return curve.value_at(10.0 * (i + 1)) / curve.value_at(10.0 * i)


func test_最初の小節の線ではスタートの値で錨の小節の線では錨の値になる():
	var curve := GrowthCurve.new(_flat(5), 5.0, [[4, 5_000.0]])
	assert_almost_eq(curve.value_at(0.0), 5.0, 0.001)
	assert_almost_eq(curve.value_at(40.0), 5_000.0, 0.01)


func test_錨がいくつもあればそれぞれの錨の小節の線でその値になる():
	var curve := GrowthCurve.new(_flat(9), 1.0, [[3, 100.0], [6, 100_000.0], [8, 1e8]])
	assert_almost_eq(curve.value_at(30.0), 100.0, 0.001)
	assert_almost_eq(curve.value_at(60.0), 100_000.0, 0.1)
	assert_almost_eq(curve.value_at(80.0), 1e8, 100.0)


func test_ゾーンの中では初めはなだらかに増え終わりに向けて加速する():
	var curve := GrowthCurve.new(_flat(5), 1.0, [[4, 10_000.0]])
	for i in 3:
		assert_gt(_ratio(curve, i), 1.0)
		assert_gt(_ratio(curve, i + 1), _ratio(curve, i))


func test_錨を越えると加速はリセットされまたなだらかに増え始める():
	var curve := GrowthCurve.new(_flat(9), 1.0, [[4, 1_000.0], [8, 1_000_000.0]])
	assert_lt(_ratio(curve, 4), _ratio(curve, 3))


func test_盛り上がりの大きい小節ほどゾーンの中の進み具合が大きく進む():
	var hot_first := GrowthCurve.new(_lines([1.0, 0.0, 0.0]), 1.0, [[2, 1_000.0]])
	var calm_first := GrowthCurve.new(_lines([0.0, 1.0, 1.0]), 1.0, [[2, 1_000.0]])
	assert_gt(hot_first.value_at(10.0), calm_first.value_at(10.0))


func test_小節の線のあいだはなめらかにつなぐ():
	var curve := GrowthCurve.new(_flat(3), 1.0, [[2, 10_000.0]])
	var before := curve.value_at(10.0)
	var middle := curve.value_at(15.0)
	assert_gt(middle, before)
	assert_lt(middle, curve.value_at(20.0))


func test_最初の線より手前はスタートの値で最後の錨より先は最後の錨の値():
	var lines := [
		{"distance": 10.0, "energy": 0.5},
		{"distance": 20.0, "energy": 0.5},
		{"distance": 30.0, "energy": 0.5},
	]
	var curve := GrowthCurve.new(lines, 2.0, [[1, 50.0]])
	assert_almost_eq(curve.value_at(3.0), 2.0, 0.001)
	assert_almost_eq(curve.value_at(30.0), 50.0, 0.01)
	assert_almost_eq(curve.value_at(99.0), 50.0, 0.01)


func test_錨が最初の線か錨が無ければ増えずにスタートの値のまま():
	assert_almost_eq(GrowthCurve.new(_flat(2), 3.0, [[0, 100.0]]).value_at(10.0), 3.0, 0.001)
	assert_almost_eq(GrowthCurve.new(_flat(2), 3.0, []).value_at(10.0), 3.0, 0.001)


func test_ゲートの数はスタートからの規模の倍率をかけて上から2桁に丸める():
	# 規模は 5 から 1 小節で 5万（1万倍）
	var curve := GrowthCurve.new(_flat(2), 5.0, [[1, 50_000.0]])
	assert_eq(curve.scaled(10, 0.0), 10)
	assert_eq(curve.scaled(10, 10.0), 100_000)
	assert_eq(curve.scaled(-15, 10.0), -150_000)
	assert_eq(curve.scaled(7, 10.0), 70_000)


func test_丸めは上から2桁で100未満はそのまま整数にする():
	assert_eq(GrowthCurve.round_nice(47.4), 47)
	assert_eq(GrowthCurve.round_nice(123.0), 120)
	assert_eq(GrowthCurve.round_nice(12_345.0), 12_000)
	assert_eq(GrowthCurve.round_nice(-3_456_789.0), -3_500_000)


func test_掛け算のゲートはゾーンの伸びが基準どおりならそのまま():
	# 40 小節で1000倍が基準
	var curve := GrowthCurve.new(_flat(41), 1.0, [[40, 1_000.0]])
	assert_eq(curve.scaled_multiplier(2, 100.0), 2)
	assert_eq(curve.scaled_multiplier(3, 100.0), 3)


func test_掛け算のゲートはゾーンの伸びが速いほど大きくする():
	# 20 小節で1000倍は基準の2倍の速さなので、×2 は ×4、×3 は ×9
	var curve := GrowthCurve.new(_flat(21), 1.0, [[20, 1_000.0]])
	assert_eq(curve.scaled_multiplier(2, 50.0), 4)
	assert_eq(curve.scaled_multiplier(3, 50.0), 9)


func test_掛け算のゲートはゾーンの伸びが遅くても小さくはしない():
	var curve := GrowthCurve.new(_flat(41), 1.0, [[40, 10.0]])
	assert_eq(curve.scaled_multiplier(2, 100.0), 2)


func test_掛け算のゲートはそれぞれのゾーンの伸びで決め最後の錨より先は最後のゾーンと同じ():
	var curve := GrowthCurve.new(_flat(62), 1.0, [[40, 1_000.0], [60, 1_000_000.0]])
	assert_eq(curve.scaled_multiplier(2, 100.0), 2)
	assert_eq(curve.scaled_multiplier(2, 500.0), 4)
	assert_eq(curve.scaled_multiplier(2, 610.0), 4)


func test_掛け算のゲートはとても速いゾーンでも上限の累乗までしか大きくしない():
	var curve := GrowthCurve.new(_flat(3), 1.0, [[2, 1e9]])
	assert_eq(curve.scaled_multiplier(2, 10.0), roundi(pow(2, GrowthCurve.MAX_MULTIPLIER_POWER)))
