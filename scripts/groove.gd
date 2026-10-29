class_name Groove
extends RefCounted
## 拍に合わせたキャラクターのノリ。右上の円のように、拍の瞬間に体が一瞬ふくらんで戻る
## セクションの盛り上がり（energy）が大きいほど大きくふくらむ

## 小節の頭の拍と、ほかの拍でふくらむ割合（盛り上がりが最も大きいとき）
const STRONG := 0.15
const WEAK := 0.06
## ふくらんだ体が元に戻るまでの秒数
const DURATION := 0.15
## 盛り上がりが最も小さいときに、どれだけの割合でふくらむか
const CALM_AMOUNT := 0.4


## 直前の拍から since_beat 秒たったときの体の大きさ（元の大きさが 1）。strong なら小節の頭の拍
static func scale(since_beat: float, strong: bool, energy: float) -> float:
	var peak := STRONG if strong else WEAK
	var rest := clampf(1.0 - since_beat / DURATION, 0.0, 1.0)
	# 初めは速く、終わりはゆっくり戻る
	return 1.0 + peak * rest * rest * _amount(energy)


static func _amount(energy: float) -> float:
	return lerpf(CALM_AMOUNT, 1.0, clampf(energy, 0.0, 1.0))
