extends GutTest

const HandgunScript = preload("res://scenes/objects/weapons/handgun/handgun.gd")

var handgun
var gun_point
var container


func before_each():
	handgun = HandgunScript.new()
	handgun.bullet_scene = preload("res://scenes/objects/bullet/bullet.tscn")
	gun_point = Node3D.new()
	container = Node3D.new()
	add_child_autofree(handgun)
	add_child_autofree(gun_point)
	add_child_autofree(container)


func test_fireを呼ぶと弾がcontainerに追加される():
	handgun.fire(gun_point, container)
	assert_eq(1, container.get_children().size())


func test_fireで発射された弾はbulletグループに属する():
	handgun.fire(gun_point, container)
	var bullet = container.get_children()[0]
	assert_true(bullet.is_in_group("bullet"))
