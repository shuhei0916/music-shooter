class_name GateDeck
extends RefCounted
## ゲートのカードの山札。カード1枚が強化1段で、カードの残りの枚数に比例して出やすい
## 引いたカードは、取られるか戻されるまで山札から抜いておく（画面に出ているあいだ、ほかの列には出ない）
## 取られなかったカードは put_back で戻す。なくならないカード（endless）は、引いても取られても減らない
## 枚数を強化の上限に合わせておけば、上限を超えるゲートや、2回取っても意味のないゲートは出ない

## カード。{"gate": [種類, 数], "count": 枚数, "endless": なくならないか（省略で false）}
var _cards: Array
## カードごとの、山札に残っている枚数
var _remaining: Array[int] = []
var _rng := RandomNumberGenerator.new()


func _init(cards: Array, seed_value: int) -> void:
	_cards = cards
	for card in cards:
		_remaining.append(int(card.count))
	_rng.seed = seed_value


## 1列ぶんの選択肢として、別々のカードを choices 枚まで引き、カードの番号を並べて返す
## 残りの枚数に比例して出やすい。残りのカードが足りなければ、あるだけ引く
func draw(choices: int) -> Array:
	var drawn := []
	for i in choices:
		var card := _pick(drawn)
		if card < 0:
			break
		drawn.append(card)
		if not _is_endless(card):
			_remaining[card] -= 1
	return drawn


## 引いたカードを、取られなかったので山札に戻す
func put_back(card: int) -> void:
	if not _is_endless(card):
		_remaining[card] += 1


## カードのゲート。[種類, 数]
func gate_of(card: int) -> Array:
	return _cards[card].gate


## カードの、山札に残っている枚数
func remaining(card: int) -> int:
	return _remaining[card]


## excluded に無いカードから、残りの枚数に比例して1枚選ぶ。選べなければ -1
func _pick(excluded: Array) -> int:
	var total := 0
	for card in _cards.size():
		if not card in excluded:
			total += _remaining[card]
	if total <= 0:
		return -1
	var at := _rng.randi_range(0, total - 1)
	for card in _cards.size():
		if card in excluded:
			continue
		at -= _remaining[card]
		if at < 0:
			return card
	return -1


func _is_endless(card: int) -> bool:
	return _cards[card].get("endless", false)
