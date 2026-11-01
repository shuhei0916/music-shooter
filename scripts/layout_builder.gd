class_name LayoutBuilder
extends RefCounted
## 曲の小節の線の上に、ゲートの列と敵の列を並べた配置データを作る
## ゲートの列は小節の線1本おき（2小節ごと）に置き、そのあいだの拍の線に敵の列を 0〜2 列置く
## 規模の曲線を渡すと、HP と威力の足し算のゲートの数を置く位置の規模に合わせて、
## 掛け算のゲートの数をそのゾーンの伸びの速さに合わせて大きくする

## ゲートのあいだに置く敵の列の数の上限
const MAX_ENEMY_ROWS := 2
## 敵の列を1列ずつ置くかどうかの確率。盛り上がり（energy）が 0 のときと 1 のとき。そのあいだは線形
const ENEMY_ROW_CHANCE_CALM := 0.2
const ENEMY_ROW_CHANCE_HOT := 0.9
## 敵の列は、ゲートの列からも、ほかの敵の列からも、この拍数以上あける（避けたり選んだりする余裕）
const ENEMY_GAP_BEATS := 2

var _deck: GateDeck
var _wave: EnemyWave
var _start: float
var _end_margin: float
var _growth: GrowthCurve
var _rng := RandomNumberGenerator.new()


func _init(
	deck: GateDeck,
	wave: EnemyWave,
	start: float,
	end_margin: float,
	seed_value := 0,
	growth: GrowthCurve = null
) -> void:
	_deck = deck
	_growth = growth
	_wave = wave
	_start = start
	_end_margin = end_margin
	_rng.seed = seed_value


## lines: 小節の頭の線 {distance: コース上の距離, energy: その小節の盛り上がり,
## boss: ボスを置くか（省略で置かない）}（近い順）
## ボスの線にはボスの列だけを置く。ゲートの線ならゲートの代わりに置き、ゲートのあいだの線なら
## そのあいだにはほかの敵の列を置かない
## length: コースの長さ。スタートから start より先、ゴールの end_margin 手前までに置く
func build(lines: Array, length: float, beats_per_bar := 4) -> Array:
	var usable := lines.filter(
		func(line): return line.distance >= _start and line.distance <= length - _end_margin
	)
	var gate_lines := []
	for i in range(0, usable.size(), 2):
		gate_lines.append(usable[i])
	var rows := []
	for i in gate_lines.size():
		var gate_z: float = gate_lines[i].distance
		if gate_lines[i].get("boss", false):
			rows.append(_boss_row(gate_z))
		else:
			rows.append({"z": gate_z, "gates": _gates_at(gate_z)})
		if i + 1 >= gate_lines.size():
			continue
		var next_z: float = gate_lines[i + 1].distance
		var bosses := usable.filter(
			func(line):
				return line.get("boss", false) and line.distance > gate_z and line.distance < next_z
		)
		if not bosses.is_empty():
			for line in bosses:
				rows.append(_boss_row(line.distance))
			continue
		var beats := beats_per_bar * 2
		var beat_length: float = (next_z - gate_z) / beats
		for beat in _enemy_beats(beats, gate_lines[i].energy):
			var z: float = gate_z + beat * beat_length
			rows.append({"z": z, "enemies": _wave.make(z)})
	return rows


## 山札から引いたゲート。規模の曲線があれば、足し算（HP と威力）の数は z の位置の規模に、
## 掛け算の数はそのゾーンの伸びの速さに合わせる
func _gates_at(z: float) -> Array:
	var gates := _deck.draw()
	if _growth == null:
		return gates
	return gates.map(
		func(gate):
			if gate[0] in [Gate.Op.ADD, Gate.Op.POWER]:
				return [gate[0], _growth.scaled(gate[1], z)]
			if gate[0] == Gate.Op.MULTIPLY:
				return [gate[0], _growth.scaled_multiplier(gate[1], z)]
			return gate
	)


func _boss_row(z: float) -> Dictionary:
	return {"z": z, "enemies": _wave.boss(z)}


## ゲートのあいだ（beats 拍）のうち、敵の列を置く拍（ゲートからの拍数、小さい順）
## 盛り上がり energy が大きいほど、たくさん置く
func _enemy_beats(beats: int, energy: float) -> Array:
	var candidates := range(ENEMY_GAP_BEATS, beats - ENEMY_GAP_BEATS + 1)
	var chance := lerpf(ENEMY_ROW_CHANCE_CALM, ENEMY_ROW_CHANCE_HOT, clampf(energy, 0.0, 1.0))
	var chosen := []
	for i in MAX_ENEMY_ROWS:
		if _rng.randf() >= chance:
			continue
		var free := candidates.filter(
			func(c): return chosen.all(func(b): return absi(c - b) >= ENEMY_GAP_BEATS)
		)
		if free.is_empty():
			break
		chosen.append(free[_rng.randi_range(0, free.size() - 1)])
	chosen.sort()
	return chosen
