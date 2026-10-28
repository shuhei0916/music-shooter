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


func test_頭の上に今のHPを表示する():
	var player: Player = add_child_autofree(PlayerScene.instantiate())
	player.health.hp = 15
	simulate(player, 1, 0.1)
	assert_eq(player.get_node("HpLabel").text, "15")


func test_一定の間隔ごとに弾を撃つ():
	var stage: Node3D = add_child_autofree(Node3D.new())
	var player: Player = PlayerScene.instantiate()
	player.fire_interval = 0.25
	stage.add_child(player)
	simulate(stage, 4, 0.1)
	var bullets := stage.get_children().filter(func(n): return n is Bullet)
	assert_eq(bullets.size(), 2)


func test_撃った弾は今の威力を持つ():
	var stage: Node3D = add_child_autofree(Node3D.new())
	var player: Player = PlayerScene.instantiate()
	stage.add_child(player)
	player.stats.power = 4
	simulate(stage, 1, 0.1)
	var bullets := stage.get_children().filter(func(n): return n is Bullet)
	assert_eq(bullets[0].damage, 4)
