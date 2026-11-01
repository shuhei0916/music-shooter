class_name GrowthCurve
extends RefCounted
## ゲームの数字の規模（敵の HP やゲートの数の基準）が、コースの上でどう増えるか
## 小節ごとに、その小節の盛り上がり（energy）に応じた分だけ増える。盛り上がりの大きい小節ほど大きく増える
## 増え方の形は曲で決まり、大きさは「錨の小節の線でちょうど錨の値になる」ようにそろえる

## 1小節で増える量（対数で）の重み。盛り上がりが 0 のときと 1 のとき。そのあいだは線形
const CALM_WEIGHT := 0.25
const HOT_WEIGHT := 1.0

var _distances: Array[float] = []
## 各小節の線までに積み上がった重み
var _levels: Array[float] = []
var _start: float
## 重み 1 あたりに、規模が何倍になるか（の自然対数）
var _rate := 0.0


## lines: 小節の頭の線 {distance, energy}（近い順）。start: 最初の線での値
## anchor_index の線で anchor_value になるように、増える比率を決める
func _init(lines: Array, start: float, anchor_index: int, anchor_value: float) -> void:
	_start = start
	var level := 0.0
	for line in lines:
		_distances.append(float(line.distance))
		_levels.append(level)
		level += lerpf(CALM_WEIGHT, HOT_WEIGHT, clampf(float(line.energy), 0.0, 1.0))
	if anchor_index > 0 and anchor_index < _levels.size():
		_rate = log(anchor_value / start) / _levels[anchor_index]


## distance の位置の規模。小節の線のあいだは、同じ比率で増えるようにつなぐ
## 最初の線より手前は最初の線の値、最後の線より先は最後の線の値
func value_at(distance: float) -> float:
	return _start * exp(_rate * _level_at(distance))


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
