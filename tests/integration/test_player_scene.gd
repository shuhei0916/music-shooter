extends GutTest

var player


func before_each():
	player = preload("res://scenes/characters/player/player.tscn").instantiate()
	var scenes: Array[PackedScene] = [preload("res://scenes/objects/weapons/handgun/handgun.tscn")]
	player.weapon_scenes = scenes
	add_child_autofree(player)


func test_shoot0を呼ぶと弾丸がシーンに追加される():
	var bullet_parent = Node3D.new()
	add_child_autofree(bullet_parent)

	player.bullet_container = bullet_parent
	player.shoot(0)

	var bullets = bullet_parent.get_children()
	assert_eq(1, bullets.size())
	assert_true(bullets[0].is_in_group("bullet"))
