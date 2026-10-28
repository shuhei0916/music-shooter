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


func _make_main_with_layout(layout: Array) -> Main:
	var main: Main = MainScene.instantiate()
	main.layout = layout
	return add_child_autofree(main)


func _find_all(root: Node, type: Variant) -> Array:
	return root.find_children("*", "", true, false).filter(func(n): return is_instance_of(n, type))


func test_配置どおりの位置に左右2枚のゲートを並べる():
	var main := _make_main_with_layout(
		[{"z": 10.0, "gates": [[Gate.Op.ADD, 5], [Gate.Op.ADD, -3]]}]
	)
	var gates := _find_all(main, GateArea)
	assert_eq(gates.size(), 2)
	assert_eq([gates[0].global_position, gates[0].amount], [Vector3(-2, 0, -10), 5])
	assert_eq([gates[1].global_position, gates[1].amount], [Vector3(2, 0, -10), -3])


func test_配置どおりの位置とHPで敵を並べる():
	var main := _make_main_with_layout([{"z": 20.0, "enemies": [[1.5, 8]]}])
	var enemies := _find_all(main, Enemy)
	assert_eq(enemies.size(), 1)
	assert_eq([enemies[0].global_position, enemies[0].health.hp], [Vector3(1.5, 0, -20), 8])
