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


func test_武器の一覧は拍の弾とドラム剣で初めはどちらもLv1():
	var weapons := PlayerStats.new(10).weapons()
	assert_eq(weapons.map(func(w): return [w.name, w.level]), [["ビート弾", 1], ["ドラム剣", 1]])


func test_武器の段階の上限は強化の上限と同じ():
	var weapons := PlayerStats.new(10).weapons()
	assert_eq(
		weapons.map(func(w): return w.max_level),
		[PlayerStats.MAX_FIRE_LEVEL + 1, PlayerStats.MAX_SWORD_LEVEL]
	)


func test_武器の段階は連射と剣の段階に合わせて上がる():
	var stats := PlayerStats.new(10)
	stats.raise_fire_level(1)
	stats.raise_sword_level(2)
	assert_eq(stats.weapons().map(func(w): return w.level), [2, 3])


func test_武器の項目にダメージと解放した能力を並べる():
	var stats := PlayerStats.new(10)
	stats.power = 12_000
	stats.sword_damage = 3
	stats.sword_retarget = true
	assert_eq(stats.weapons().map(func(w): return w.details), [["ダメージ 12k"], ["ダメージ 3", "乗りかえ"]])
