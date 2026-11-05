class_name ShockwaveWeapon
extends Weapon
## 衝撃波。パート（初めはキック）が鳴るたびに、プレイヤーから前に向けた扇形の中の敵にまとめてダメージを与える
## （Shockwave）。段階で伸びる値は届く広さ（半径 m）

## 段階の上限と、段階が 1 のときの届く広さ（半径 m）、段階が1つ上がるごとに広がる長さ
const MAX_LEVEL := 5
const BASE_RADIUS := 4.0
const RADIUS_STEP := 1.0

## 鳴ると衝撃波を出すパート
var part := "kick"


func _init() -> void:
	super("shockwave", MAX_LEVEL)


## 届く広さ（半径 m）。段階が lv のとき（省略すると今の段階）
func radius(lv := level) -> float:
	return BASE_RADIUS + RADIUS_STEP * (lv - 1)


func level_value(lv: int) -> float:
	return radius(lv)


func format_value(value: float) -> String:
	return ShockwaveWeapon.meters(value)


func parts_text() -> String:
	return PartTrack.display_name(part)


func extra_details() -> Array:
	return ["広さ " + ShockwaveWeapon.meters(radius())]


## 長さ（m）の文字。整数ならそのまま、そうでなければ小数1桁（4m、4.5m）
static func meters(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return "%dm" % roundi(value)
	return "%.1fm" % value
