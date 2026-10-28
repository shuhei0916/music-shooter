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


func build(_length: float) -> Array:
	return [{"z": _start, "gates": _deck.draw()}]
