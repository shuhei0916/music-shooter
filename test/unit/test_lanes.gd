extends GutTest


func test_真ん中のレーンは道の中央にある():
	assert_almost_eq(Lanes.new(3, 3.0).x_of(1), 0.0, 0.001)


func test_左端と右端のレーンはレーンの幅だけ中央から離れている():
	var lanes := Lanes.new(3, 3.0)
	assert_almost_eq(lanes.x_of(0), -3.0, 0.001)
	assert_almost_eq(lanes.x_of(2), 3.0, 0.001)


func test_レーンが偶数本なら中央をはさんで並ぶ():
	var lanes := Lanes.new(2, 3.0)
	assert_almost_eq(lanes.x_of(0), -1.5, 0.001)
	assert_almost_eq(lanes.x_of(1), 1.5, 0.001)
