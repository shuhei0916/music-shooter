extends GutTest

const MainScene := preload("res://scenes/main.tscn")


func _make_main(speed: float, length: float) -> Main:
	var main: Main = MainScene.instantiate()
	main.forward_speed = speed
	main.course_length = length
	return add_child_autofree(main)


func test_時間がたつとプレイヤーが前へ進む():
	var main := _make_main(10.0, 100.0)
	simulate(main, 1, 0.5)
	assert_almost_eq(main.get_node("Player").position.z, -5.0, 0.001)
