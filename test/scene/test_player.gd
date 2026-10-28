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


func _make_player_on_stage() -> Player:
	var stage: Node3D = add_child_autofree(Node3D.new())
	var player: Player = PlayerScene.instantiate()
	stage.add_child(player)
	return player


func _bullets_of(player: Player) -> Array:
	return player.get_parent().get_children().filter(func(n): return n is Bullet)


func test_拍ごとに弾を撃つ():
	var player := _make_player_on_stage()
	var grid := BeatGrid.new(120.0)
	for time in [0.0, 0.25, 0.5, 0.75, 1.0]:
		player.shoot_on_beat(time, grid)
	assert_eq(_bullets_of(player).size(), 3)


func test_連射の段階が上がると半拍ごとに撃つ():
	var player := _make_player_on_stage()
	player.stats.fire_level = 1
	var grid := BeatGrid.new(120.0)
	for time in [0.0, 0.25, 0.5, 0.75, 1.0]:
		player.shoot_on_beat(time, grid)
	assert_eq(_bullets_of(player).size(), 5)


func test_時間がたつだけでは弾を撃たない():
	var player := _make_player_on_stage()
	simulate(player.get_parent(), 5, 0.1)
	assert_eq(_bullets_of(player).size(), 0)


func test_撃った弾は今の威力を持つ():
	var player := _make_player_on_stage()
	player.stats.power = 4
	player.shoot_on_beat(0.0, BeatGrid.new(120.0))
	assert_eq(_bullets_of(player)[0].damage, 4)
