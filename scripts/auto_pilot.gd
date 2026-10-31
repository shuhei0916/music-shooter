class_name AutoPilot
extends RefCounted
## 自動で遊ばせるときの判断。次の列を見て、プレイヤーが向かう位置を決める
## ゲートの列では、取ったときに上がる割合がいちばん大きいゲートへ、
## 敵の列では、ぶつかる敵の HP がいちばん少ないレーン（敵がいなければ 0）へ向かう

## 向かう位置にこれより近ければ止まる
const ARRIVED := 0.1


## ゲートを取ったときに、能力値がどれだけの割合で上がるか。損なゲートはマイナス
static func gate_score(gate: Gate, stats: PlayerStats) -> float:
	match gate.op:
		Gate.Op.MULTIPLY:
			return gate.amount - 1.0
		Gate.Op.POWER:
			return float(gate.amount) / stats.power
		Gate.Op.FIRE_RATE:
			var after := mini(stats.fire_level + gate.amount, PlayerStats.MAX_FIRE_LEVEL)
			return (
				(
					float(PlayerStats.shots_per_bar(after))
					/ PlayerStats.shots_per_bar(stats.fire_level)
				)
				- 1.0
			)
		_:
			return float(gate.amount) / maxi(stats.health.hp, 1)


## gates: [{x, gate}]。得点のいちばん高いゲートの x
static func choose_gate(gates: Array, stats: PlayerStats) -> float:
	var best: Dictionary = gates[0]
	for candidate in gates:
		if gate_score(candidate.gate, stats) > gate_score(best.gate, stats):
			best = candidate
	return best.x


## lanes: レーンの x。enemies: [{x, hp}]。ぶつかる敵の HP がいちばん少ないレーンの x
## 同じだけ少ないレーンが複数あれば、player_x に近いほう
static func choose_lane(lanes: Array, enemies: Array, player_x: float) -> float:
	var best_x: float = lanes[0]
	var best_hp := _hp_in_lane(best_x, lanes, enemies)
	for x in lanes:
		var hp := _hp_in_lane(x, lanes, enemies)
		if hp < best_hp or (hp == best_hp and absf(x - player_x) < absf(best_x - player_x)):
			best_x = x
			best_hp = hp
	return best_x


## 今の位置 x から target へ向かう向き。-1 で左、1 で右、着いていれば 0
static func axis(x: float, target: float) -> float:
	if absf(target - x) < ARRIVED:
		return 0.0
	return signf(target - x)


## レーン lane_x にいる敵の HP の合計。敵は、いちばん近いレーンにいるとみなす
static func _hp_in_lane(lane_x: float, lanes: Array, enemies: Array) -> int:
	var total := 0
	for enemy in enemies:
		if _nearest(lanes, enemy.x) == lane_x:
			total += enemy.hp
	return total


static func _nearest(values: Array, x: float) -> float:
	var nearest: float = values[0]
	for value in values:
		if absf(value - x) < absf(nearest - x):
			nearest = value
	return nearest
