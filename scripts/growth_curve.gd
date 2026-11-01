class_name GrowthCurve
extends RefCounted
## ゲームの数字の規模（敵の HP やゲートの数の基準）が、コースの上でどう増えるか
## 錨（ボスの小節の線など）で区切ったゾーンごとに、錨の小節の線でちょうど錨の値になるように増える
## ゾーンの中では、初めはなだらかに、終わりに向けて加速して増える。錨を越えると加速はリセットされる
## ゾーンの中の進み具合は、小節ごとの盛り上がり（energy）で測る。盛り上がりの大きい小節ほど大きく進む

## 1小節で進む量の重み。盛り上がりが 0 のときと 1 のとき。そのあいだは線形
const CALM_WEIGHT := 0.25
const HOT_WEIGHT := 1.0
## ゾーンの中の加速の強さ。進み具合（0〜1）をこの数で累乗して、規模（の対数）の進み具合にする
## 1 なら一定の比率で増え、大きいほど初めはなだらかで終わりに急になる
const ZONE_POWER := 2.0

var _distances: Array[float] = []
## 各小節の線までに積み上がった重み
var _levels: Array[float] = []
var _start: float
## ゾーンの区切り。[積み上がった重み, 規模の自然対数] の並びで、最初はスタート
var _anchors: Array = []


## lines: 小節の頭の線 {distance, energy}（近い順）。start: 最初の線での値
## anchors: [[小節の線の番号, その線での値], ...]（近い順）。最初の線より先の錨だけを使う
func _init(lines: Array, start: float, anchors: Array) -> void:
	_start = start
	var level := 0.0
	for line in lines:
		_distances.append(float(line.distance))
		_levels.append(level)
		level += lerpf(CALM_WEIGHT, HOT_WEIGHT, clampf(float(line.energy), 0.0, 1.0))
	_anchors.append([0.0, log(start)])
	for anchor in anchors:
		var index: int = anchor[0]
		if index > 0 and index < _levels.size() and _levels[index] > _anchors.back()[0]:
			_anchors.append([_levels[index], log(float(anchor[1]))])


## distance の位置の規模。小節の線のあいだもなめらかにつなぐ
## 最初の線より手前はスタートの値、最後の錨より先は最後の錨の値
func value_at(distance: float) -> float:
	var level := _level_at(distance)
	for i in range(1, _anchors.size()):
		var from: Array = _anchors[i - 1]
		var to: Array = _anchors[i]
		if level <= to[0]:
			var progress := inverse_lerp(from[0], to[0], level)
			return exp(lerpf(from[1], to[1], pow(progress, ZONE_POWER)))
	return exp(_anchors.back()[1])


func _level_at(distance: float) -> float:
	if _distances.is_empty() or distance <= _distances[0]:
		return 0.0
	for i in range(1, _distances.size()):
		if distance <= _distances[i]:
			var t := inverse_lerp(_distances[i - 1], _distances[i], distance)
			return lerpf(_levels[i - 1], _levels[i], t)
	return _levels.back()


## ゲートなどの数 amount を、distance の位置の規模に合わせて大きくする
## スタートで amount のまま、規模が10倍になったところで10倍。キリのいい数に丸める
func scaled(amount: int, distance: float) -> int:
	return round_nice(amount * value_at(distance) / _start)


## 上から2桁に丸める（12,345 → 12,000）。100 未満はそのまま整数に丸める
static func round_nice(value: float) -> int:
	var size := absf(value)
	if size < 100.0:
		return roundi(value)
	var step := pow(10.0, floorf(log(size) / log(10.0)) - 1.0)
	return roundi(roundf(value / step) * step)
