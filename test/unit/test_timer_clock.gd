extends GutTest


func test_進めた時間だけ時刻が進む():
	var clock := TimerClock.new(60.0)
	clock.advance(0.5)
	clock.advance(0.25)
	assert_almost_eq(clock.time(), 0.75, 0.001)


func test_長さは作ったときに決めた値になる():
	assert_almost_eq(TimerClock.new(60.0).duration(), 60.0, 0.001)
