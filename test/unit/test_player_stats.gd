extends GutTest


func test_初めはHPが指定の値で威力は1で連射は最初の段階():
	var stats := PlayerStats.new(10)
	assert_eq([stats.health.hp, stats.power, stats.fire_level], [10, 1, 0])


func test_初めは1小節に1発で連射の段階が上がるごとに撃つ間隔の拍が半分になる():
	var stats := PlayerStats.new(10)
	var beats := []
	for level in PlayerStats.MAX_FIRE_LEVEL + 1:
		stats.fire_level = level
		beats.append(stats.beats_per_shot())
	assert_eq(beats, [4.0, 2.0, 1.0])


func test_1小節に撃つ数は連射の段階が上がるたびに倍になる():
	assert_eq(
		[PlayerStats.shots_per_bar(0), PlayerStats.shots_per_bar(1), PlayerStats.shots_per_bar(2)],
		[1, 2, 4]
	)


func test_剣の段階は上限より上がらない():
	var stats := PlayerStats.new(10)
	stats.raise_sword_level(PlayerStats.MAX_SWORD_LEVEL + 3)
	assert_eq(stats.sword_count, PlayerStats.MAX_SWORD_LEVEL)


func test_武器の一覧はビート弾と剣と衝撃波で初めはどれもLv1():
	var weapons := PlayerStats.new(10).weapons()
	assert_eq(weapons.map(func(w): return [w.name, w.level]), [["ビート弾", 1], ["剣", 1], ["衝撃波", 1]])


func test_武器の段階の上限は強化の上限と同じ():
	var weapons := PlayerStats.new(10).weapons()
	assert_eq(
		weapons.map(func(w): return w.max_level),
		[
			PlayerStats.MAX_FIRE_LEVEL + 1,
			PlayerStats.MAX_SWORD_LEVEL,
			PlayerStats.MAX_SHOCKWAVE_LEVEL,
		]
	)


func test_武器の段階は連射と剣の段階に合わせて上がる():
	var stats := PlayerStats.new(10)
	stats.raise_fire_level(1)
	stats.raise_sword_level(2)
	stats.raise_shockwave_level(3)
	assert_eq(stats.weapons().map(func(w): return w.level), [2, 3, 4])


func test_武器の項目にダメージと解放した能力を並べる():
	var stats := PlayerStats.new(10)
	stats.power = 12_000
	stats.sword_damage = 3
	stats.sword_retarget = true
	stats.shockwave_damage = 4
	stats.raise_shockwave_level(1)
	assert_eq(
		stats.weapons().map(func(w): return w.details),
		[["ダメージ 12k"], ["ダメージ 3", "乗りかえ"], ["ダメージ 4", "広さ 5m"]]
	)


func test_剣は初めハイハットでためてスネアで撃つ_キックは衝撃波が使う():
	var stats := PlayerStats.new(10)
	assert_eq([stats.sword_charge_parts, stats.sword_release_part], [["hihat"], "snare"])
	assert_eq(stats.shockwave_part, "kick")


func test_剣のパートの組み合わせを順に切りかえ最後の次は最初に戻る():
	var stats := PlayerStats.new(10)
	var seen := []
	for i in PlayerStats.SWORD_PART_PRESETS.size():
		stats.cycle_sword_parts()
		seen.append([stats.sword_charge_parts, stats.sword_release_part])
	assert_eq(seen.back(), [["hihat"], "snare"])
	assert_eq(seen[0], PlayerStats.SWORD_PART_PRESETS[1])


func test_武器の一覧に使うパートを書く():
	var stats := PlayerStats.new(10)
	assert_eq(stats.weapons().map(func(w): return w.parts), ["拍", "ハイハット → スネア", "キック"])


func test_衝撃波の届く広さは段階が上がるごとに広がり段階は上限より上がらない():
	var stats := PlayerStats.new(10)
	var radii := [stats.shockwave_radius()]
	stats.raise_shockwave_level(1)
	radii.append(stats.shockwave_radius())
	assert_eq(radii, [4.0, 5.0])
	stats.raise_shockwave_level(PlayerStats.MAX_SHOCKWAVE_LEVEL)
	assert_eq(stats.shockwave_level, PlayerStats.MAX_SHOCKWAVE_LEVEL)


func test_長さの文字は整数ならそのままでなければ小数1桁():
	assert_eq([PlayerStats.meters(4.0), PlayerStats.meters(4.5)], ["4m", "4.5m"])
