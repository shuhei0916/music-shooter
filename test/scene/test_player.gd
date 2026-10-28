extends GutTest

const PlayerScene := preload("res://scenes/player.tscn")


func test_プレイヤーは初期HPを持って登場する():
	var player: Player = PlayerScene.instantiate()
	player.start_hp = 7
	add_child_autofree(player)
	assert_eq(player.health.hp, 7)


func test_右へ動く操作をすると右へ動く():
	var player: Player = add_child_autofree(PlayerScene.instantiate())
	Input.action_press("move_right")
	simulate(player, 1, 0.1)
	Input.action_release("move_right")
	assert_gt(player.position.x, 0.0)


func test_左へ動く操作をすると左へ動く():
	var player: Player = add_child_autofree(PlayerScene.instantiate())
	Input.action_press("move_left")
	simulate(player, 1, 0.1)
	Input.action_release("move_left")
	assert_lt(player.position.x, 0.0)
