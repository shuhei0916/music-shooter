class_name EnemyWave
extends RefCounted
## 敵の1列ぶんを作る。どのレーンを埋めるかはシードつきの乱数で決める
## HPはスタートの start_hp から、ゴールの goal_hp まで一定の比率で増える
## ふつうの敵の列は、必ず1レーンは空けて避けられるようにする（避けられないのはボスだけ）

## ボスの HP が、同じ位置のふつうの敵の何倍か（仮の値）
const BOSS_HP_RATE := 10

var _lane_count: int
var _start_hp: int
var _goal_hp: int
var _length: float
var _rng := RandomNumberGenerator.new()


func _init(lane_count: int, start_hp: int, goal_hp: int, length: float, seed_value: int) -> void:
	_lane_count = lane_count
	_start_hp = start_hp
	_goal_hp = goal_hp
	_length = length
	_rng.seed = seed_value


## [[レーン番号, HP, 占めるレーン数（1）], ...] を返す。敵どうしのレーンは重ならず、1レーンは空ける
func make(distance: float) -> Array:
	var free := range(_lane_count)
	var hp := hp_at(distance)
	var result := []
	for i in _rng.randi_range(1, maxi(_lane_count - 1, 1)):
		var lane: int = free.pop_at(_rng.randi_range(0, free.size() - 1))
		result.append([lane, hp, 1])
	return result


## distance の位置のふつうの敵の HP
func hp_at(distance: float) -> int:
	return roundi(_start_hp * pow(float(_goal_hp) / _start_hp, distance / _length))


## distance の位置のボス。全部のレーンを埋める1体で、[[0, HP, レーンの数]]
func boss(distance: float) -> Array:
	return [[0, hp_at(distance) * BOSS_HP_RATE, _lane_count]]
