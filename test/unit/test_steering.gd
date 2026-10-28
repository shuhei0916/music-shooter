extends GutTest


func test_右に入力すると速さと時間の分だけ右へ動く():
	var steering := Steering.new(4.0, 5.0)
	assert_almost_eq(steering.next_x(0.0, 1.0, 0.5), 2.0, 0.001)


func test_道の右端より先へは動かない():
	var steering := Steering.new(4.0, 5.0)
	assert_almost_eq(steering.next_x(4.5, 1.0, 0.5), 5.0, 0.001)


func test_道の左端より先へは動かない():
	var steering := Steering.new(4.0, 5.0)
	assert_almost_eq(steering.next_x(-4.5, -1.0, 0.5), -5.0, 0.001)
