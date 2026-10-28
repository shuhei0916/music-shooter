extends GutTest


func test_時刻に速さをかけた距離まで進んでいる():
	var course := Course.new(3.0, 100.0)
	course.seek(2.0)
	assert_almost_eq(course.distance, 6.0, 0.001)


func test_同じ時刻を何度渡しても距離は変わらない():
	var course := Course.new(3.0, 100.0)
	course.seek(2.0)
	course.seek(2.0)
	assert_almost_eq(course.distance, 6.0, 0.001)


func test_コースの長さまで進むとゴールしている():
	var course := Course.new(10.0, 100.0)
	course.seek(10.0)
	assert_true(course.is_finished())


func test_コースの長さに届かなければまだゴールしていない():
	var course := Course.new(10.0, 100.0)
	course.seek(9.9)
	assert_false(course.is_finished())


func test_ゴールしたらそれより先へは進まない():
	var course := Course.new(10.0, 100.0)
	course.seek(20.0)
	assert_almost_eq(course.distance, 100.0, 0.001)
