extends GutTest


func test_ダメージを受けるとHPがその分だけ減る():
	var health := Health.new(10)
	health.damage(3)
	assert_eq(health.hp, 7)
