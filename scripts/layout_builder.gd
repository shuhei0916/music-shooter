class_name LayoutBuilder
extends RefCounted
## 曲の小節の線の上に、ゲートの列と敵の列を交互に並べた配置データを作る

var _deck: GateDeck
var _wave: EnemyWave
var _start: float
var _end_margin: float


func _init(deck: GateDeck, wave: EnemyWave, start: float, end_margin: float) -> void:
	_deck = deck
	_wave = wave
	_start = start
	_end_margin = end_margin


## lines: 列を置ける線のコース上の距離（小さい順）。length: コースの長さ
## スタートから start より先、ゴールの end_margin 手前までの線に置く
func build(lines: Array, length: float) -> Array:
	var rows := []
	for z in lines:
		if z < _start or z > length - _end_margin:
			continue
		if rows.size() % 2 == 0:
			rows.append({"z": z, "gates": _deck.draw()})
		else:
			rows.append({"z": z, "enemies": _wave.make(z)})
	return rows
