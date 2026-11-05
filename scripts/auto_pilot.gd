class_name AutoPilot
extends RefCounted
## 自動で遊ばせるときの判断。次の列を見て、プレイヤーが向かう位置を決める
## ゲートの列では、取ったときに上がる割合がいちばん大きいゲートへ、
## 敵の列では、ぶつかる敵の HP がいちばん少ないレーン（敵がいなければ 0）へ向かう

## 向かう位置にこれより近ければ止まる
const ARRIVED := 0.1
## 剣の乗りかえのゲートの得点。強さが何割上がるか測りにくいので、決めておいた値にする
const RETARGET_SCORE := 0.5


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
		Gate.Op.WEAPON_LEVEL:
			return stats.weapon(gate.weapon).level_score(gate.amount)
		Gate.Op.WEAPON_DAMAGE:
			return float(gate.amount) / stats.weapon(gate.weapon).damage
		Gate.Op.SWORD_RETARGET:
			return 0.0 if stats.sword.retarget else RETARGET_SCORE
		_:
			return float(gate.amount) / maxi(stats.health.hp, 1)


## gates: [{x, gate}]。得点のいちばん高いゲートの x
static func choose_gate(gates: Array, stats: PlayerStats) -> float:
	var best: Dictionary = gates[0]
	for candidate in gates:
		if gate_score(candidate.gate, stats) > gate_score(best.gate, stats):
			best = candidate
	return best.x


## lanes: レーンの x（左から等間隔）。enemies: [{x, hp, lanes: 占めるレーン数（省略で 1）}]。ぶつかる敵の HP がいちばん少ないレーンの x
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


## レーン lane_x をふさぐ敵の HP の合計。敵は、x を中心に lanes（無ければ 1）レーン分の幅を占める
static func _hp_in_lane(lane_x: float, lanes: Array, enemies: Array) -> int:
	var spacing: float = lanes[1] - lanes[0] if lanes.size() > 1 else INF
	var total := 0
	for enemy in enemies:
		var half_width: float = enemy.get("lanes", 1) * spacing / 2.0
		if absf(lane_x - enemy.x) < half_width:
			total += enemy.hp
	return total
