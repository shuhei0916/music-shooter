extends GutTest

var player


func before_each():
	player = preload("res://scenes/characters/player/player.tscn").instantiate()
	add_child_autofree(player)


func after_each():
	for bullet in get_tree().get_nodes_in_group("bullet"):
		bullet.queue_free()


func test_shoot0を呼ぶと弾丸がシーンに追加される():
	player.shoot(0)
	assert_eq(1, get_tree().get_nodes_in_group("bullet").size())
