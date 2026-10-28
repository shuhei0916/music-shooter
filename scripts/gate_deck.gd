class_name GateDeck
extends RefCounted
## ゲートの選択肢（2つか3つ）のカードを、シードつきの乱数で混ぜて1枚ずつ引く山札

var _cards: Array
var _pile: Array = []
var _rng := RandomNumberGenerator.new()


func _init(cards: Array, seed_value: int) -> void:
	_cards = cards
	_rng.seed = seed_value


## 左から順に [[種類, 数], ...] を返す。選択肢の並びはランダムに入れ替わる
func draw() -> Array:
	if _pile.is_empty():
		_pile = _shuffled(_cards)
	return _shuffled(_pile.pop_back())


func _shuffled(cards: Array) -> Array:
	var result := cards.duplicate()
	for i in range(result.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp = result[i]
		result[i] = result[j]
		result[j] = tmp
	return result
