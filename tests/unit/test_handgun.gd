extends GutTest

var handgun


func before_each():
	handgun = preload("res://scenes/objects/weapons/handgun/handgun.tscn").instantiate()
	add_child_autofree(handgun)


func after_each():
	for bullet in get_tree().get_nodes_in_group("bullet"):
		bullet.free()


func test_fireを呼ぶと弾がシーンに追加される():
	handgun.fire()
	assert_eq(1, get_tree().get_nodes_in_group("bullet").size())


func test_fireで発射された弾はbulletグループに属する():
	handgun.fire()
	var bullet = get_tree().get_nodes_in_group("bullet")[0]
	assert_true(bullet.is_in_group("bullet"))


func test_fireを呼ぶとフラッシュが発動する():
	handgun.fire()
	assert_gt(handgun._flash.light_energy, 0.0)


func test_trigger_flashを呼ぶとフラッシュが発動する():
	handgun.trigger_flash()
	assert_gt(handgun._flash.light_energy, 0.0)
