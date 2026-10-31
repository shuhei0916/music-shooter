class_name Autoplay
extends Node
## Main を自動で遊ばせ、小節の頭ごとにプレイヤーと次の敵の強さを記録する
## 向かう位置は AutoPilot で決める。難易度を数字で確かめるために使う

const CSV_COLUMNS := ["time", "label", "energy", "hp", "power", "fire_level", "dps", "enemy_hp"]

var main: Main
## 小節の頭ごとの記録。{time, label, energy, hp, power, fire_level, dps（1秒あたりのダメージ）,
## enemy_hp（次の敵の列でいちばん多い HP。敵の列が無ければ 0）}
var samples: Array = []
## 時刻 0 ちょうどの小節の頭でも記録できるよう、最初は 0 より少し前にしておく
var _last_time := -0.001


func _process(_delta: float) -> void:
	if main == null or main.result() != Judge.Result.PLAYING:
		return
	var player: Player = main.get_node("Player")
	player.autopilot = true
	player.auto_axis = AutoPilot.axis(player.position.x, _target_x(player))
	_record(player)


## 小節の頭をまたいでいたら記録する
func _record(player: Player) -> void:
	var map := main.song_map()
	var time := main.song_time()
	var crossed := map.shot_grid().crossed(_last_time, time, map.beats_per_bar)
	_last_time = time
	if not crossed:
		return
	var pos := map.at(time)
	var bar_seconds := map.grid.seconds_per_beat() * map.beats_per_bar
	var stats := player.stats
	var sample := {
		"time": time,
		"label": pos.label,
		"energy": pos.energy,
		"hp": stats.health.hp,
		"power": stats.power,
		"fire_level": stats.fire_level,
		"dps": stats.power * PlayerStats.shots_per_bar(stats.fire_level) / bar_seconds,
		"enemy_hp": _next_enemy_hp(player),
	}
	samples.append(sample)


func to_csv() -> String:
	var lines := [",".join(CSV_COLUMNS)]
	for s in samples:
		var values := [
			"%.2f" % s.time,
			s.label,
			"%.2f" % s.energy,
			s.hp,
			s.power,
			s.fire_level,
			"%.2f" % s.dps,
			s.enemy_hp,
		]
		lines.append(",".join(values.map(func(v): return str(v))))
	return "\n".join(lines) + "\n"


## プレイヤーより前にある、いちばん近い列（ゲートか、まだ倒れていない敵）を見て向かう位置を決める
func _target_x(player: Player) -> float:
	var gates := _ahead(player, _gates())
	var enemies := _ahead(player, _enemies())
	var gate_z := _nearest_z(gates)
	var enemy_z := _nearest_z(enemies)
	if gates.is_empty() and enemies.is_empty():
		return player.position.x
	if gate_z >= enemy_z:
		var row := gates.filter(func(g): return is_equal_approx(g.global_position.z, gate_z))
		var choices := row.map(func(g): return {"x": g.global_position.x, "gate": g.gate()})
		return AutoPilot.choose_gate(choices, player.stats)
	var row := enemies.filter(func(e): return is_equal_approx(e.global_position.z, enemy_z))
	var specs := row.map(func(e): return {"x": e.global_position.x, "hp": e.health.hp})
	return AutoPilot.choose_lane(main.lane_xs(), specs, player.position.x)


## 次の敵の列でいちばん多い HP。敵の列が無ければ 0
func _next_enemy_hp(player: Player) -> int:
	var enemies := _ahead(player, _enemies())
	var z := _nearest_z(enemies)
	var hp := 0
	for enemy: Enemy in enemies:
		if is_equal_approx(enemy.global_position.z, z):
			hp = maxi(hp, enemy.health.hp)
	return hp


func _gates() -> Array:
	var result := []
	for child in main.get_children():
		for grandchild in child.get_children():
			if grandchild is GateArea:
				result.append(grandchild)
	return result


func _enemies() -> Array:
	return main.get_children().filter(func(n): return n is Enemy and not n.health.is_dead())


## プレイヤーより前（z が小さい）にあるものだけ
static func _ahead(player: Player, nodes: Array) -> Array:
	return nodes.filter(func(n): return n.global_position.z < player.position.z)


## いちばん近い（z がいちばん大きい）ものの z。無ければ -INF
static func _nearest_z(nodes: Array) -> float:
	var z := -INF
	for node: Node3D in nodes:
		z = maxf(z, node.global_position.z)
	return z
