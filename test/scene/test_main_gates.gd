extends GutTest
## Main のうち、ゲートの列が近づいたら山札から引いて出し、取られなかったカードを山札に戻すところ

const MainScene := preload("res://scenes/main.tscn")
const CARDS := [
	{"gate": [Gate.Op.ADD, 10], "count": 3},
	{"gate": [Gate.Op.SWORD, 1], "count": 3},
	{"gate": [Gate.Op.FIRE_RATE, 1], "count": 3},
]


func _make_main(layout: Array) -> Main:
	var main: Main = MainScene.instantiate()
	main.song_path = ""
	main.forward_speed = 10.0
	main.course_length = 1000.0
	main.layout_seed = 1
	main.gate_cards = CARDS
	main.layout = layout
	return add_child_autofree(main)


func _gates_of(main: Main) -> Array:
	return main.find_children("*", "GateArea", true, false)


func test_近くのゲートの列は始めから山札から引いて選択肢の数だけ出す():
	var main := _make_main([{"z": 20.0, "gate_count": 3}])
	var gates := _gates_of(main)
	assert_eq(gates.size(), 3)
	assert_eq(gates.map(func(g): return g.global_position.z), [-20.0, -20.0, -20.0])


func test_遠くのゲートの列は近づくまで出さない():
	var z := Main.DEAL_AHEAD + 5.0
	var main := _make_main([{"z": z, "gate_count": 2}])
	assert_eq(_gates_of(main).size(), 0)
	simulate(main, 10, 0.1)
	assert_eq(_gates_of(main).size(), 2)


func test_出ているあいだは山札から抜け取られなかったカードは山札に戻る():
	var main := _make_main([{"z": 20.0, "gate_count": 3}])
	var deck := main.gate_deck()
	for card in CARDS.size():
		assert_eq(deck.remaining(card), 2)
	var gates := _gates_of(main)
	var chosen: GateArea = gates[0]
	chosen.give_to(main.get_node("Player"))
	for card in CARDS.size():
		var expected := 2 if deck.gate_of(card) == [chosen.op, chosen.amount] else 3
		assert_eq(deck.remaining(card), expected)
