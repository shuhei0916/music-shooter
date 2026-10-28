extends GutTest


func test_時間がたつと前へ速さの分だけ進む():
	var course := Course.new(3.0, 100.0)
	course.advance(2.0)
	assert_almost_eq(course.distance, 6.0, 0.001)


func test_コースの長さまで進むとゴールしている():
	var course := Course.new(10.0, 100.0)
	course.advance(10.0)
	assert_true(course.is_finished())


func test_コースの長さに届かなければまだゴールしていない():
	var course := Course.new(10.0, 100.0)
	course.advance(9.9)
	assert_false(course.is_finished())


func test_ゴールしたらそれより先へは進まない():
	var course := Course.new(10.0, 100.0)
	course.advance(20.0)
	assert_almost_eq(course.distance, 100.0, 0.001)
