extends GutTest

var player


func before_each():
	player = preload("res://scenes/characters/player/player.tscn").instantiate()
	add_child_autofree(player)


func after_each():
	for bullet in get_tree().get_nodes_in_group("bullet"):
		bullet.free()


func test_shoot0を呼ぶと弾丸がシーンに追加される():
	player.shoot(0)
	assert_eq(1, get_tree().get_nodes_in_group("bullet").size())


func test_shoot9を呼ぶとch9の弾丸がシーンに追加される():
	player.shoot(9)
	assert_eq(1, get_tree().get_nodes_in_group("bullet").size())


func test_未割り当てchannelではshootしても弾丸が追加されない():
	player.shoot(99)
	assert_eq(0, get_tree().get_nodes_in_group("bullet").size())


func test_グリッド上のノートを受け取ると対応チャンネルの武器から弾を発射する():
	player.on_note(0, 480 * 4, 480)
	assert_eq(1, get_tree().get_nodes_in_group("bullet").size())


func test_グリッド外のノートを受け取っても弾を発射しない():
	player.on_note(0, 480 * 4 + 480, 480)
	assert_eq(0, get_tree().get_nodes_in_group("bullet").size())


func test_グリッド上のノートを受け取ると武器のマズルフラッシュが光る():
	player.on_note(0, 480 * 4, 480)
	assert_gt(player._weapon_map[0]._flash.light_energy, 0.0)
