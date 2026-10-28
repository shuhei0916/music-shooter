class_name EnemyWave
extends RefCounted
## 敵の1列ぶんを作る。どのレーンを埋めるかはシードつきの乱数で決める
## HPはスタートの start_hp から、ゴールの goal_hp まで一定の比率で増える

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


## [[レーン番号, HP], ...] を返す
func make(distance: float) -> Array:
	var lanes := range(_lane_count)
	var count := _rng.randi_range(1, _lane_count)
	var hp := roundi(_start_hp * pow(float(_goal_hp) / _start_hp, distance / _length))
	var result := []
	for i in count:
		var lane: int = lanes.pop_at(_rng.randi_range(0, lanes.size() - 1))
		result.append([lane, hp])
	return result
