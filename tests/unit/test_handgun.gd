extends GutTest

var handgun
var container


func before_each():
	handgun = preload("res://scenes/objects/weapons/handgun/handgun.tscn").instantiate()
	container = Node3D.new()
	add_child_autofree(handgun)
	add_child_autofree(container)


func test_fireを呼ぶと弾がcontainerに追加される():
	handgun.fire(container)
	assert_eq(1, container.get_children().size())


func test_fireで発射された弾はbulletグループに属する():
	handgun.fire(container)
	var bullet = container.get_children()[0]
	assert_true(bullet.is_in_group("bullet"))
