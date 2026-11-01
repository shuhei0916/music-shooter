extends GutTest

const CARD := [[Gate.Op.ADD, 10], [Gate.Op.ADD, -5]]
## 小節の線の位置（コース上の距離）。1小節は 4 拍で 16、1拍は 4
const LINES := [0.0, 16.0, 32.0, 48.0, 64.0, 80.0, 96.0, 112.0, 128.0]
const LENGTH := 140.0
const BEAT := 4.0


func _make_builder(seed_value := 1) -> LayoutBuilder:
	var deck := GateDeck.new([CARD], seed_value)
	var wave := EnemyWave.new(3, 5, 5, LENGTH, seed_value)
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
	var rows := _make_builder().build(LINES, LENGTH)
	assert_almost_eq(rows[0].z, 32.0, 0.001)
	assert_true(rows[0].has("gates"))


func test_ゲートの列は小節の線1本おきに置く():
	var rows := _make_builder().build(LINES, LENGTH)
	assert_eq(_gate_zs(rows), [32.0, 64.0, 96.0])


func test_ゲートのあいだの敵の列はゲートから2拍以上離れた拍の線に0から2列置き列どうしも2拍以上あける():
	for seed_value in 30:
		var rows := _make_builder(seed_value).build(LINES, LENGTH)
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
		var rows := _make_builder(seed_value).build(LINES, LENGTH)
		for beats: Array in _enemy_beats_between_gates(rows):
			counts[beats.size()] = true
	assert_eq_deep(counts.keys().filter(func(k): return k <= 2).size(), 3)


func test_同じシードなら同じ配置になる():
	assert_eq_deep(_make_builder(7).build(LINES, LENGTH), _make_builder(7).build(LINES, LENGTH))


func test_コースの終わりの手前より先には置かない():
	# コースの長さ 140 から 15 手前の 125 より先には置かない
	for seed_value in 10:
		var rows := _make_builder(seed_value).build(LINES, LENGTH)
		assert_lte(rows.back().z, 125.0)
