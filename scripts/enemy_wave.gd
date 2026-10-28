class_name EnemyWave
extends RefCounted
## 敵の1列ぶんを作る。どのレーンを埋めるかはシードつきの乱数で決める

var _lane_count: int
var _base_hp: int
var _hp_per_meter: float
var _rng := RandomNumberGenerator.new()


func _init(lane_count: int, base_hp: int, hp_per_meter: float, seed_value: int) -> void:
	_lane_count = lane_count
	_base_hp = base_hp
	_hp_per_meter = hp_per_meter
	_rng.seed = seed_value


## [[レーン番号, HP], ...] を返す
func make(distance: float) -> Array:
	var lanes := range(_lane_count)
	var count := _rng.randi_range(1, _lane_count)
	var hp := _base_hp + roundi(_hp_per_meter * distance)
	var result := []
	for i in count:
		var lane: int = lanes.pop_at(_rng.randi_range(0, lanes.size() - 1))
		result.append([lane, hp])
	return result
