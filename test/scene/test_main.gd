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


func test_ゴールするとクリアと表示する():
	var main := _make_main(10.0, 5.0)
	simulate(main, 1, 1.0)
	var message: Label = main.get_node("UI/Message")
	assert_true(message.visible)
	assert_eq(message.text, "CLEAR!")


func test_HPが0になるとゲームオーバーと表示する():
	var main := _make_main(10.0, 100.0)
	main.get_node("Player").health.hp = 0
	simulate(main, 1, 0.1)
	var message: Label = main.get_node("UI/Message")
	assert_true(message.visible)
	assert_eq(message.text, "GAME OVER")


func test_ゲームオーバーになったらそれ以上は進まない():
	var main := _make_main(10.0, 100.0)
	main.get_node("Player").health.hp = 0
	simulate(main, 1, 0.1)
	var z: float = main.get_node("Player").position.z
	simulate(main, 3, 0.1)
	assert_almost_eq(main.get_node("Player").position.z, z, 0.001)


func test_プレイ中は何も表示しない():
	var main := _make_main(10.0, 100.0)
	simulate(main, 1, 0.1)
	assert_false(main.get_node("UI/Message").visible)
