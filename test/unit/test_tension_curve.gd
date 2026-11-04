extends GutTest


## 10m おきの小節の線。sections は [名前, 進み具合] の並び
func _lines(sections: Array) -> Array:
	var lines := []
	for i in sections.size():
		lines.append({"distance": 10.0 * i, "label": sections[i][0], "progress": sections[i][1]})
	return lines


func test_BUILDではセクションの進み具合に合わせて敵がだんだん強くなる():
	var curve := TensionCurve.new(_lines([["BUILD", 0.0], ["BUILD", 0.5]]))
	assert_almost_eq(curve.rate_at(0.0), TensionCurve.BUILD_FROM, 0.0001)
	var middle := lerpf(TensionCurve.BUILD_FROM, TensionCurve.BUILD_TO, 0.5)
	assert_almost_eq(curve.rate_at(10.0), middle, 0.0001)
	assert_gt(TensionCurve.BUILD_TO, TensionCurve.BUILD_FROM)


func test_DROPでは敵が弱くなりBREAKではそれより弱くならないがふつうより弱い():
	var curve := TensionCurve.new(_lines([["DROP", 0.0], ["BREAK", 0.0], ["VERSE", 0.0]]))
	assert_almost_eq(curve.rate_at(0.0), TensionCurve.DROP_RATE, 0.0001)
	assert_almost_eq(curve.rate_at(10.0), TensionCurve.BREAK_RATE, 0.0001)
	assert_almost_eq(curve.rate_at(20.0), 1.0, 0.0001)
	assert_lt(TensionCurve.DROP_RATE, TensionCurve.BREAK_RATE)
	assert_lt(TensionCurve.BREAK_RATE, 1.0)


func test_小節の線のあいだはその小節の倍率で最初の線より手前は1倍():
	var curve := TensionCurve.new(_lines([["VERSE", 0.0], ["DROP", 0.0]]))
	assert_almost_eq(curve.rate_at(15.0), TensionCurve.DROP_RATE, 0.0001)
	assert_almost_eq(curve.rate_at(-5.0), 1.0, 0.0001)


func test_セクションが分からなければいつも1倍():
	var curve := TensionCurve.new(_lines([["", 0.0], ["", 0.0]]))
	assert_almost_eq(curve.rate_at(5.0), 1.0, 0.0001)
	assert_almost_eq(TensionCurve.new([]).rate_at(5.0), 1.0, 0.0001)
