class_name EnemyWave
extends RefCounted
## 敵の1列ぶんを作る。どのレーンを埋めるかはシードつきの乱数で決める
## HPは規模の曲線（GrowthCurve）に合わせて増える。緊張の曲線（TensionCurve）を渡すと、ふつうの敵にだけその倍率をかける
## ふつうの敵の列は、必ず1レーンは空けて避けられるようにする（避けられないのはボスだけ）
## ふつうの敵の HP は1体ずつばらつかせ、同じ列の敵の HP がそろわないようにする

## ボスの HP が、同じ位置のふつうの敵の何倍か（仮の値）
const BOSS_HP_RATE := 10
## ふつうの敵の HP は、その位置の HP（基準値）のこの倍率の範囲でばらつく
const HP_SPREAD_MIN := 0.5
const HP_SPREAD_MAX := 2.0

var _lane_count: int
var _curve: GrowthCurve
var _tension: TensionCurve
var _rng := RandomNumberGenerator.new()


func _init(
	lane_count: int, curve: GrowthCurve, seed_value: int, tension: TensionCurve = null
) -> void:
	_lane_count = lane_count
	_curve = curve
	_tension = tension
	_rng.seed = seed_value


## [[レーン番号, HP, 占めるレーン数（1）], ...] を返す。敵どうしのレーンは重ならず、1レーンは空ける
## HP は hp_at の HP_SPREAD_MIN〜HP_SPREAD_MAX 倍で、同じ列の敵どうしでは違う
func make(distance: float) -> Array:
	var free := range(_lane_count)
	var count := _rng.randi_range(1, maxi(_lane_count - 1, 1))
	var hps := _spread_hps(hp_at(distance), count)
	var result := []
	for hp in hps:
		var lane: int = free.pop_at(_rng.randi_range(0, free.size() - 1))
		result.append([lane, hp, 1])
	return result


## 基準値 base をもとにばらつかせた、互いに違う count 個の HP
## 倍率の範囲を対数で count 等分した区間から1つずつ引くので、弱い敵と強い敵が混ざる
## 丸めてそろってしまったら（基準値が小さいとき）、1ずつ足してずらす
func _spread_hps(base: int, count: int) -> Array:
	var low := log(HP_SPREAD_MIN)
	var width := (log(HP_SPREAD_MAX) - low) / count
	var slots := range(count)
	var hps := []
	for i in count:
		var slot: int = slots.pop_at(_rng.randi_range(0, slots.size() - 1))
		var rate := exp(low + width * (slot + _rng.randf()))
		var hp := maxi(roundi(base * rate), 1)
		while hp in hps:
			hp += 1
		hps.append(hp)
	return hps


## distance の位置のふつうの敵の HP。規模に緊張の倍率をかける
func hp_at(distance: float) -> int:
	var rate := _tension.rate_at(distance) if _tension != null else 1.0
	return roundi(_curve.value_at(distance) * rate)


## distance の位置のボス。全部のレーンを埋める1体で、[[0, HP, レーンの数]]。HP に緊張の倍率はかけない
func boss(distance: float) -> Array:
	return [[0, roundi(_curve.value_at(distance)) * BOSS_HP_RATE, _lane_count]]
