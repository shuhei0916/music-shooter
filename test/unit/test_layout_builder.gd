extends GutTest

const CARD := [[Gate.Op.ADD, 10], [Gate.Op.ADD, -5]]
## 小節の線の位置（コース上の距離）
const LINES := [0.0, 13.0, 26.0, 39.0, 52.0, 65.0, 78.0, 91.0]


func _make_builder() -> LayoutBuilder:
	var deck := GateDeck.new([CARD], 1)
	var wave := EnemyWave.new(3, 5, 5, 100.0, 1)
	return LayoutBuilder.new(deck, wave, 20.0, 15.0)


func test_スタートの位置より先の最初の線にゲートの列を置く():
	var rows := _make_builder().build(LINES, 100.0)
	assert_almost_eq(rows[0].z, 26.0, 0.001)
	assert_true(rows[0].has("gates"))


func test_線ごとにゲートの列と敵の列が交互に並ぶ():
	var rows := _make_builder().build(LINES, 100.0)
	assert_eq(rows.map(func(row): return row.z), [26.0, 39.0, 52.0, 65.0, 78.0])
	assert_true(rows[1].has("enemies"))
	assert_true(rows[2].has("gates"))


func test_コースの終わりの手前の線には置かない():
	# コースの長さ 100 から 15 手前の 85 より先にある 91 には置かない
	var rows := _make_builder().build(LINES, 100.0)
	assert_almost_eq(rows.back().z, 78.0, 0.001)
