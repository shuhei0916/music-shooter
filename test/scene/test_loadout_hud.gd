extends GutTest
## 左上に、持っている武器ごとに名前と段階、使うパート、ダメージなどの強化の状況を並べる


func _make_hud() -> LoadoutHud:
	return add_child_autofree(LoadoutHud.new())


func _texts(hud: LoadoutHud) -> Array:
	return hud.get_node("Rows").get_children().map(func(label): return label.text)


func test_武器ごとに名前と段階と使うパートと項目を出す():
	var hud := _make_hud()
	hud.show_stats(PlayerStats.new(10))
	assert_eq(_texts(hud), ["ビート弾 Lv1\n拍\nダメージ 1", "剣 Lv1\nスネア・ハイハット → キック\nダメージ 1"])


func test_段階が上限ならMAXと出す():
	var hud := _make_hud()
	var stats := PlayerStats.new(10)
	stats.raise_fire_level(PlayerStats.MAX_FIRE_LEVEL)
	hud.show_stats(stats)
	assert_string_starts_with(_texts(hud)[0], "ビート弾 Lv MAX")


func test_強化すると出す文字も変わる():
	var hud := _make_hud()
	var stats := PlayerStats.new(10)
	hud.show_stats(stats)
	stats.raise_sword_level(1)
	stats.sword_retarget = true
	hud.show_stats(stats)
	assert_eq(_texts(hud)[1], "剣 Lv2\nスネア・ハイハット → キック\nダメージ 1  乗りかえ")
