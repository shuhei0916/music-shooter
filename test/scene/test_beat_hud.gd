extends GutTest

const BeatHudScene := preload("res://scenes/beat_hud.tscn")


func _make_hud() -> BeatHud:
	return add_child_autofree(BeatHudScene.instantiate())


func _pos(overrides := {}) -> Dictionary:
	var pos := {
		"section_index": 4,
		"section_count": 13,
		"label": "DROP",
		"energy": 1.0,
		"bar_in_section": 2,
		"bars_in_section": 16,
		"beat_in_bar": 0,
		"since_beat": 0.0,
	}
	pos.merge(overrides, true)
	return pos


func test_セクションの名前と番号と小節を表示する():
	var hud := _make_hud()
	hud.show_at(_pos())
	assert_eq(hud.get_node("Label").text, "DROP")
	assert_eq(hud.get_node("Bar").text, "3 / 16")
	assert_eq(hud.get_node("Section").text, "SEC 5 / 13")


func test_小節の数が分からなければ今の小節だけ表示する():
	var hud := _make_hud()
	hud.show_at(_pos({"bars_in_section": 0}))
	assert_eq(hud.get_node("Bar").text, "3")


func test_セクションがなければ名前と番号は表示しない():
	var hud := _make_hud()
	hud.show_at(_pos({"section_count": 0, "label": ""}))
	assert_eq(hud.get_node("Label").text, "")
	assert_eq(hud.get_node("Section").text, "")


func test_拍に合わせて脈打つ():
	var hud := _make_hud()
	hud.show_at(_pos({"beat_in_bar": 0, "since_beat": 0.0}))
	assert_almost_eq(hud.pulse, BeatPulse.STRONG, 0.0001)
	hud.show_at(_pos({"beat_in_bar": 2, "since_beat": 0.0}))
	assert_almost_eq(hud.pulse, BeatPulse.WEAK, 0.0001)
	hud.show_at(_pos({"beat_in_bar": 2, "since_beat": 0.3}))
	assert_almost_eq(hud.pulse, 1.0, 0.0001)


func test_今が何拍目かを覚えておく():
	var hud := _make_hud()
	hud.show_at(_pos({"beat_in_bar": 3}))
	assert_eq(hud.beat_in_bar, 3)


func test_盛り上がりが大きいほど暑い色になる():
	var hud := _make_hud()
	hud.show_at(_pos({"energy": 0.0}))
	var calm := hud.color
	hud.show_at(_pos({"energy": 1.0}))
	assert_eq(calm, BeatHud.CALM_COLOR)
	assert_eq(hud.color, BeatHud.HOT_COLOR)
