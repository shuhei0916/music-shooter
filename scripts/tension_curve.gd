class_name TensionCurve
extends RefCounted
## 緊張の曲線。規模の曲線（GrowthCurve）に対して、ふつうの敵をどれだけ強くするかの倍率を、セクションで上げ下げする
## 単調な坂にせず、デコボコさせる：BUILD は上り（溜め）、DROP は一度落ちる（解放）、BREAK は平坦で楽に
## ボスとゲートの数にはかけない

## BUILD では、セクションの始まりの BUILD_FROM 倍から、終わりに向けて BUILD_TO 倍までだんだん強くする
const BUILD_FROM := 1.0
const BUILD_TO := 1.5
## DROP（ボスのすぐあと）は弱い敵をまとめて倒す解放の場所
const DROP_RATE := 0.4
## BREAK はひと息つく平坦な場所
const BREAK_RATE := 0.6

var _distances: Array[float] = []
var _rates: Array[float] = []


## lines: 小節の頭の線 {distance, label: セクションの名前, progress: セクションの中の進み具合 0〜1}（近い順）
func _init(lines: Array) -> void:
	for line in lines:
		_distances.append(float(line.distance))
		_rates.append(_rate_of(str(line.label), float(line.progress)))


## distance の位置の倍率。その位置を含む小節の倍率で、最初の線より手前は 1 倍
func rate_at(distance: float) -> float:
	var rate := 1.0
	for i in _distances.size():
		if _distances[i] > distance:
			break
		rate = _rates[i]
	return rate


static func _rate_of(label: String, progress: float) -> float:
	match label:
		"BUILD":
			return lerpf(BUILD_FROM, BUILD_TO, progress)
		"DROP":
			return DROP_RATE
		"BREAK":
			return BREAK_RATE
		_:
			return 1.0
