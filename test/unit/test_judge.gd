extends GutTest


func test_ゴール前でHPが残っていればプレイ中():
	var course := Course.new(10.0, 100.0)
	assert_eq(Judge.result(course, Health.new(5)), Judge.Result.PLAYING)


func test_ゴールしたらクリア():
	var course := Course.new(10.0, 100.0)
	course.advance(10.0)
	assert_eq(Judge.result(course, Health.new(5)), Judge.Result.CLEARED)


func test_HPが0ならゲームオーバー():
	var course := Course.new(10.0, 100.0)
	assert_eq(Judge.result(course, Health.new(0)), Judge.Result.GAME_OVER)


func test_ゴールと同時にHPが0になったらゲームオーバーを優先する():
	var course := Course.new(10.0, 100.0)
	course.advance(10.0)
	assert_eq(Judge.result(course, Health.new(0)), Judge.Result.GAME_OVER)
