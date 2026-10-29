class_name BeatPulse
extends RefCounted
## 拍に合わせて脈打つ大きさ。拍の瞬間にふくらみ、DURATION 秒かけて元の大きさ（1）に戻る

## 小節の頭の拍と、ほかの拍でふくらむ大きさ
const STRONG := 1.25
const WEAK := 1.1
const DURATION := 0.15


## 直前の拍から since_beat 秒たったときの大きさ。strong なら小節の頭の拍
static func scale(since_beat: float, strong: bool) -> float:
	var peak := STRONG if strong else WEAK
	var rest := clampf(1.0 - since_beat / DURATION, 0.0, 1.0)
	# 初めは速く、終わりはゆっくり戻る
	return 1.0 + (peak - 1.0) * rest * rest
