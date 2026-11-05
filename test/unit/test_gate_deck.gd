extends GutTest
## ゲートのカードの山札。カード1枚が強化1段で、残りの枚数に比例して出やすい
## 引いたカードは山札から抜き、取られなかったカードは戻す。なくならないカードもある

const ADD := 0
const SWORD := 1
const FIRE_RATE := 2
const CARDS := [
	{"gate": [Gate.Op.ADD, 10], "count": 5, "endless": true},
	{"gate": [Gate.Op.SWORD, 1], "count": 3},
	{"gate": [Gate.Op.FIRE_RATE, 1], "count": 1},
]


func test_カードのゲートを返す():
	var deck := GateDeck.new(CARDS, 1)
	assert_eq(deck.gate_of(SWORD), [Gate.Op.SWORD, 1])


func test_1列ぶんの選択肢は別々のカードから引く():
	var deck := GateDeck.new(CARDS, 1)
	for i in 20:
		var drawn := deck.draw(3)
		var sorted := drawn.duplicate()
		sorted.sort()
		assert_eq(sorted, [ADD, SWORD, FIRE_RATE])
		for card in drawn:
			deck.put_back(card)


func test_引いたカードは戻すまで山札から抜ける():
	var deck := GateDeck.new(CARDS, 1)
	var drawn := deck.draw(3)
	assert_eq(deck.remaining(SWORD), 2)
	assert_eq(deck.remaining(FIRE_RATE), 0)
	for card in drawn:
		deck.put_back(card)
	assert_eq(deck.remaining(SWORD), 3)
	assert_eq(deck.remaining(FIRE_RATE), 1)


func test_なくなったカードは出ない():
	var deck := GateDeck.new(CARDS, 1)
	deck.draw(3)
	for i in 20:
		assert_false(FIRE_RATE in deck.draw(2))


func test_なくならないカードは引いても減らない():
	var deck := GateDeck.new(CARDS, 1)
	deck.draw(3)
	assert_eq(deck.remaining(ADD), 5)


func test_残りのカードが選択肢の数より少なければあるだけ引く():
	var deck := GateDeck.new([CARDS[1]], 1)
	assert_eq(deck.draw(2), [0])
	assert_eq(deck.draw(2), [0])
	assert_eq(deck.draw(2), [0])
	assert_eq(deck.draw(2), [])


func test_残りの枚数が多いカードほど出やすい():
	var cards := [
		{"gate": [Gate.Op.ADD, 10], "count": 9, "endless": true},
		{"gate": [Gate.Op.ADD, 5], "count": 1, "endless": true},
	]
	var deck := GateDeck.new(cards, 3)
	var counts := [0, 0]
	for i in 200:
		counts[deck.draw(1)[0]] += 1
	assert_gt(counts[0], counts[1] * 4)


func test_同じシードなら同じ順番で出る():
	var a := GateDeck.new(CARDS, 42)
	var b := GateDeck.new(CARDS, 42)
	for i in 10:
		var drawn := a.draw(2)
		assert_eq(drawn, b.draw(2))
		for card in drawn:
			a.put_back(card)
			b.put_back(card)


func test_選択肢の並びは入れ替わる():
	var deck := GateDeck.new(CARDS, 7)
	var orders := {}
	for i in 30:
		var drawn := deck.draw(2)
		orders[drawn] = true
		for card in drawn:
			deck.put_back(card)
	assert_gt(orders.size(), 2)
