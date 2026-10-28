extends GutTest

const CARD := [[Gate.Op.ADD, 10], [Gate.Op.ADD, -5]]


func _make_builder() -> LayoutBuilder:
	var deck := GateDeck.new([CARD], 1)
	var wave := EnemyWave.new(3, 5, 5, 200.0, 1)
	return LayoutBuilder.new(deck, wave, 20.0, 10.0, 15.0)


func test_最初の列はスタートの位置に置くゲートの列():
	var rows := _make_builder().build(200.0)
	assert_almost_eq(rows[0].z, 20.0, 0.001)
	assert_true(rows[0].has("gates"))


func test_間隔ごとにゲートの列と敵の列が交互に並ぶ():
	var rows := _make_builder().build(200.0)
	assert_almost_eq(rows[1].z, 30.0, 0.001)
	assert_true(rows[1].has("enemies"))
	assert_almost_eq(rows[2].z, 40.0, 0.001)
	assert_true(rows[2].has("gates"))


func test_コースの終わりの手前で並べるのをやめる():
	var rows := _make_builder().build(200.0)
	assert_almost_eq(rows.back().z, 180.0, 0.001)
