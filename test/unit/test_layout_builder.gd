extends GutTest

const CARD := [[Gate.Op.ADD, 10], [Gate.Op.ADD, -5]]
## 小節の線の位置（コース上の距離）。1小節は 4 拍で 16、1拍は 4
const DISTANCES := [0.0, 16.0, 32.0, 48.0, 64.0, 80.0, 96.0, 112.0, 128.0]
const LENGTH := 140.0
const BEAT := 4.0


## 小節の線 {distance, energy}。盛り上がりはどれも energy
static func _lines(energy: float) -> Array:
	return DISTANCES.map(func(d): return {"distance": d, "energy": energy})


func _make_builder(seed_value := 1) -> LayoutBuilder:
	var deck := GateDeck.new([CARD], seed_value)
	var wave := EnemyWave.new(3, GrowthCurve.new([], 5.0, []), seed_value)
	return LayoutBuilder.new(deck, wave, 20.0, 15.0, seed_value)


func _gate_zs(rows: Array) -> Array:
	return rows.filter(func(row): return row.has("gates")).map(func(row): return row.z)


## 各ゲートの列から次のゲートの列までに置いた敵の列の、ゲートからの拍数
func _enemy_beats_between_gates(rows: Array) -> Array:
	var result := []
	var gate_z := 0.0
	for row in rows:
		if row.has("gates"):
			gate_z = row.z
			result.append([])
		else:
			result.back().append((row.z - gate_z) / BEAT)
	return result


func test_スタートの位置より先の最初の線にゲートの列を置く():
	var rows := _make_builder().build(_lines(0.5), LENGTH)
	assert_almost_eq(rows[0].z, 32.0, 0.001)
	assert_true(rows[0].has("gates"))


func test_ゲートの列は小節の線1本おきに置く():
	var rows := _make_builder().build(_lines(0.5), LENGTH)
	assert_eq(_gate_zs(rows), [32.0, 64.0, 96.0])


func test_ゲートのあいだの敵の列はゲートから2拍以上離れた拍の線に0から2列置き列どうしも2拍以上あける():
	for seed_value in 30:
		var rows := _make_builder(seed_value).build(_lines(0.5), LENGTH)
		for beats: Array in _enemy_beats_between_gates(rows):
			assert_between(beats.size(), 0, 2)
			for beat in beats:
				assert_almost_eq(beat, roundf(beat), 0.001)
				assert_between(beat, 2.0, 6.0)
			if beats.size() == 2:
				assert_gte(beats[1] - beats[0], 2.0)


func test_ゲートのあいだの敵の列の数は0列も1列も2列も出る():
	var counts := {}
	for seed_value in 30:
		var rows := _make_builder(seed_value).build(_lines(0.5), LENGTH)
		for beats: Array in _enemy_beats_between_gates(rows):
			counts[beats.size()] = true
	assert_eq_deep(counts.keys().filter(func(k): return k <= 2).size(), 3)


func test_同じシードなら同じ配置になる():
	assert_eq_deep(
		_make_builder(7).build(_lines(0.5), LENGTH), _make_builder(7).build(_lines(0.5), LENGTH)
	)


func test_コースの終わりの手前より先には置かない():
	# コースの長さ 140 から 15 手前の 125 より先には置かない
	for seed_value in 10:
		var rows := _make_builder(seed_value).build(_lines(0.5), LENGTH)
		assert_lte(rows.back().z, 125.0)


func _mean_enemy_rows(energy: float) -> float:
	var total := 0
	var gaps := 0
	for seed_value in 50:
		var rows := _make_builder(seed_value).build(_lines(energy), LENGTH)
		for beats: Array in _enemy_beats_between_gates(rows):
			total += beats.size()
			gaps += 1
	return float(total) / gaps


func test_盛り上がりが大きいほどゲートのあいだの敵の列が多い():
	assert_gt(_mean_enemy_rows(1.0), _mean_enemy_rows(0.25) + 0.5)


## 小節の線 at（番号）にボスの印をつけた線
static func _lines_with_boss(at: int) -> Array:
	var lines := _lines(1.0)
	lines[at].boss = true
	return lines


func test_ボスの印のある線にはボスの列を置きそのゲートのあいだにはほかの敵を置かない():
	for seed_value in 10:
		# 48 はゲート（32 と 64）のあいだの線
		var rows := _make_builder(seed_value).build(_lines_with_boss(3), LENGTH)
		var between := rows.filter(func(row): return row.z > 32.0 and row.z < 64.0)
		assert_eq(between.size(), 1)
		assert_eq(between[0].z, 48.0)
		assert_eq(between[0].enemies, [[0, 5 * EnemyWave.BOSS_HP_RATE, 3]])


func test_ゲートを置く線にボスの印があればゲートの代わりにボスを置く():
	var rows := _make_builder().build(_lines_with_boss(4), LENGTH)
	var at_64 := rows.filter(func(row): return is_equal_approx(row.z, 64.0))
	assert_eq(at_64.size(), 1)
	assert_false(at_64[0].has("gates"))
	assert_eq(at_64[0].enemies[0][2], 3)


func test_規模の曲線を渡すとHPと威力の足し算のゲートの数を規模に合わせて大きくし掛け算と連射はそのまま():
	# 規模は 5 から、最初のゲートの線（32）で 500（100倍）
	var growth := GrowthCurve.new(_lines(0.5), 5.0, [[2, 500.0]])
	var card := [
		[Gate.Op.ADD, -5], [Gate.Op.POWER, 1], [Gate.Op.MULTIPLY, 2], [Gate.Op.FIRE_RATE, 1]
	]
	var deck := GateDeck.new([card], 1)
	var wave := EnemyWave.new(3, growth, 1)
	var builder := LayoutBuilder.new(deck, wave, 20.0, 15.0, 1, growth)
	var gates: Array = builder.build(_lines(0.5), LENGTH)[0].gates.duplicate()
	gates.sort()
	assert_eq(
		gates,
		[[Gate.Op.ADD, -500], [Gate.Op.MULTIPLY, 2], [Gate.Op.POWER, 100], [Gate.Op.FIRE_RATE, 1]]
	)
