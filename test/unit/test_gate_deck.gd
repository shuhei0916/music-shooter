extends GutTest

const CARDS := [
	[[Gate.Op.ADD, 10], [Gate.Op.ADD, -5]],
	[[Gate.Op.MULTIPLY, 2], [Gate.Op.ADD, 5]],
	[[Gate.Op.ADD, -10], [Gate.Op.MULTIPLY, 3]],
]


## 左右の入れ替えを無視して比べるため、ペアの中身を並べ替えた形にする
func _normalize(pair: Array) -> Array:
	var sorted := pair.duplicate()
	sorted.sort()
	return sorted


func test_山札のカードを全部引くまでは同じカードが出ない():
	var deck := GateDeck.new(CARDS, 1)
	var drawn := []
	for i in CARDS.size():
		drawn.append(_normalize(deck.draw()))
	drawn.sort()
	var expected := CARDS.map(_normalize)
	expected.sort()
	assert_eq(drawn, expected)


func test_全部引いたら混ぜ直して引き続けられる():
	var deck := GateDeck.new(CARDS, 1)
	var drawn := []
	for i in CARDS.size() * 2:
		drawn.append(_normalize(deck.draw()))
	for card in CARDS:
		assert_eq(drawn.count(_normalize(card)), 2)


func test_同じシードなら同じ順番で出る():
	var a := GateDeck.new(CARDS, 42)
	var b := GateDeck.new(CARDS, 42)
	for i in 10:
		assert_eq(a.draw(), b.draw())


func test_同じカードでも左右が入れ替わって出ることがある():
	var deck := GateDeck.new([CARDS[0]], 7)
	var orders := {}
	for i in 20:
		orders[deck.draw()] = true
	assert_eq(orders.size(), 2)
