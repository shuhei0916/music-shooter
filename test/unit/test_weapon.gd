extends GutTest
## 武器の共通の形。段階・ダメージ・使うパートを持ち、段階で伸びる値からゲートの文字と自動操縦の得点を出す


func test_段階は上限より上がらない():
	for weapon: Weapon in [SwordWeapon.new(), ShockwaveWeapon.new(), LightningWeapon.new()]:
		weapon.raise_level(weapon.max_level + 3)
		assert_eq(weapon.level, weapon.max_level)


func test_段階のゲートの文字は段階で伸びる値の取る前と取ったあと():
	assert_eq(
		[SwordWeapon.new().level_label(1), ShockwaveWeapon.new().level_label(1)],
		["剣UP\n4->8", "衝撃波UP\n4m->5m"]
	)
	assert_eq(LightningWeapon.new().level_label(1), "落雷UP\n1体->2体")


func test_段階が上限なら段階のゲートの文字はMAX():
	var weapon := SwordWeapon.new()
	weapon.level = weapon.max_level
	assert_eq(weapon.level_label(1), "剣MAX")


func test_段階のゲートの得点は段階で伸びる値が増える割合で上限なら0():
	var weapon := ShockwaveWeapon.new()
	assert_almost_eq(weapon.level_score(1), 0.25, 0.0001)
	weapon.level = weapon.max_level
	assert_eq(weapon.level_score(1), 0.0)


func test_名前の記号から名前を引ける():
	assert_eq(
		[Weapon.name_of("sword"), Weapon.name_of("shockwave"), Weapon.name_of("lightning")],
		["剣", "衝撃波", "落雷"]
	)


func test_剣は段階ごとに1回に撃つ本数が増える():
	var sword := SwordWeapon.new()
	sword.raise_level(1)
	assert_eq(sword.capacity(), SwordWeapon.SWORDS_PER_VOLLEY * 2)


func test_落雷は段階の数だけ一度に落ちる():
	var lightning := LightningWeapon.new()
	lightning.raise_level(2)
	assert_eq(lightning.strikes(), 3)
