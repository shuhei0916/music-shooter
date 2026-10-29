class_name Groove
extends RefCounted
## 拍に合わせたキャラクターのノリ。拍の瞬間に体がつぶれ、すぐに戻る
## セクションの盛り上がり（energy）が大きいほど大きく動く

## 小節の頭の拍と、ほかの拍で体がつぶれる割合（盛り上がりが最も大きいとき）
const SQUASH_STRONG := 0.2
const SQUASH_WEAK := 0.1
## つぶれた体が元に戻るまでの秒数
const DURATION := 0.2
## 盛り上がりが最も小さいときに、どれだけの割合で動くか
const CALM_AMOUNT := 0.4


## 直前の拍から since_beat 秒たったときに、体の高さが縮む割合。strong なら小節の頭の拍
static func squash(since_beat: float, strong: bool, energy: float) -> float:
	var peak := SQUASH_STRONG if strong else SQUASH_WEAK
	var rest := clampf(1.0 - since_beat / DURATION, 0.0, 1.0)
	# 初めは速く、終わりはゆっくり戻る
	return peak * rest * rest * _amount(energy)


static func _amount(energy: float) -> float:
	return lerpf(CALM_AMOUNT, 1.0, clampf(energy, 0.0, 1.0))
