class_name EnemyWave
extends RefCounted
## 敵の1列ぶんを作る。どのレーンを埋めるかはシードつきの乱数で決める
## HPはスタートの start_hp から、ゴールの goal_hp まで一定の比率で増える
## ときどき、2レーンを占める大きな敵を混ぜる

## 列に大きな敵を混ぜる確率と、大きな敵の HP がふつうの敵の何倍か
const BIG_CHANCE := 0.3
const BIG_HP_RATE := 2

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


## [[左端のレーン番号, HP, 占めるレーン数], ...] を返す。敵どうしのレーンは重ならない
func make(distance: float) -> Array:
	var free := range(_lane_count)
	var hp := roundi(_start_hp * pow(float(_goal_hp) / _start_hp, distance / _length))
	var result := []
	var min_smalls := 1
	if _lane_count >= 2 and _rng.randf() < BIG_CHANCE:
		var left := _rng.randi_range(0, _lane_count - 2)
		result.append([left, hp * BIG_HP_RATE, 2])
		free.erase(left)
		free.erase(left + 1)
		min_smalls = 0
	for i in _rng.randi_range(min_smalls, free.size()):
		var lane: int = free.pop_at(_rng.randi_range(0, free.size() - 1))
		result.append([lane, hp, 1])
	return result
