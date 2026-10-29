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
