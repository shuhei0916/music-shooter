class_name GateDeck
extends RefCounted
## ゲートのペアのカードを、シードつきの乱数で混ぜて1枚ずつ引く山札

var _cards: Array
var _pile: Array = []
var _rng := RandomNumberGenerator.new()


func _init(cards: Array, seed_value: int) -> void:
	_cards = cards
	_rng.seed = seed_value


## [[左の種類, 数], [右の種類, 数]] を返す。左右はランダムに入れ替わる
func draw() -> Array:
	if _pile.is_empty():
		_pile = _shuffled(_cards)
	var pair: Array = _pile.pop_back()
	if _rng.randi_range(0, 1) == 1:
		return [pair[1], pair[0]]
	return pair


func _shuffled(cards: Array) -> Array:
	var result := cards.duplicate()
	for i in range(result.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp = result[i]
		result[i] = result[j]
		result[j] = tmp
	return result
