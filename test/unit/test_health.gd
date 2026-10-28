extends GutTest


func test_ダメージを受けるとHPがその分だけ減る():
	var health := Health.new(10)
	health.damage(3)
	assert_eq(health.hp, 7)


func test_HPより大きいダメージを受けてもHPはマイナスにならない():
	var health := Health.new(3)
	health.damage(10)
	assert_eq(health.hp, 0)


func test_ゲートなどでHPを直接書き換えてもマイナスにならない():
	var health := Health.new(3)
	health.hp = -5
	assert_eq(health.hp, 0)


func test_HPが0になると死亡する():
	var health := Health.new(3)
	health.damage(3)
	assert_true(health.is_dead())


func test_HPが残っていれば生きている():
	var health := Health.new(3)
	health.damage(2)
	assert_false(health.is_dead())
