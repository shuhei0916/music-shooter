extends GutTest


func test_時間がたつと前へ速さの分だけ進む():
	var course := Course.new(3.0, 100.0)
	course.advance(2.0)
	assert_almost_eq(course.distance, 6.0, 0.001)
