## スポーナーの出すゲート列と敵の列を、毎回どれかを選びながら通り抜ける1回のプレイを、HPの計算だけで再現する。
## 難易度の調整に使う。弾は計算に入れない（実際のプレイより厳しい）
extends RefCounted

const LANE_COUNT := 3


## spawnerのturn 1〜turnsを進め、最後のHPを返す（途中で0以下になったら0）。
## 進み具合は経過ターン数に比例させる。
## choose: 選んだ後のHPの候補（Array）から1つを選んで返すCallable
static func run(spawner, turns: int, choose: Callable) -> int:
	var hp := 1
	for turn in range(1, turns + 1):
		var progress := float(turn) / turns
		match spawner.turn_kind(turn):
			"gate_row":
				var specs: Array = spawner.gate_row_specs(turn, progress, LANE_COUNT)
				hp = choose.call(specs.map(func(g): return _apply_gate(hp, g)))
			"enemy_row":
				var hps: Array = spawner.enemy_row_hps(progress)
				hp = choose.call(hps.map(func(e): return hp - e))
		if hp <= 0:
			return 0
	return hp


static func _apply_gate(hp: int, gate) -> int:
	match gate.gate_type:
		"add":
			return hp + gate.value
		"multiply":
			return hp * gate.value
	return hp
