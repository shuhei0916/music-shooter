class_name LayoutBuilder
extends RefCounted
## コースの長さに合わせて、ゲートの列と敵の列を並べた配置データを作る

var _deck: GateDeck
var _wave: EnemyWave
var _start: float
var _spacing: float
var _end_margin: float


func _init(
	deck: GateDeck, wave: EnemyWave, start: float, spacing: float, end_margin: float
) -> void:
	_deck = deck
	_wave = wave
	_start = start
	_spacing = spacing
	_end_margin = end_margin


func build(length: float) -> Array:
	var rows := []
	var z := _start
	while z <= length - _end_margin:
		if rows.size() % 2 == 0:
			rows.append({"z": z, "gates": _deck.draw()})
		else:
			rows.append({"z": z, "enemies": _wave.make(z)})
		z += _spacing
	return rows
