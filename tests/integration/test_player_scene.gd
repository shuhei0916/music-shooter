extends GutTest

var player

func before_each():
	player = preload("res://scenes/characters/player/player.tscn").instantiate()
	add_child_autofree(player)

func test_shootが呼ばれると弾丸がシーンに追加される():
	var bullet_parent = Node3D.new()
	add_child_autofree(bullet_parent)

	player.bullet_container = bullet_parent
	player.shoot()

	var bullets = bullet_parent.get_children()
	assert_eq(1, bullets.size())
	assert_true(bullets[0].is_in_group("bullet"))
