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


func test_大きなHPは短く表示する():
	var player: Player = add_child_autofree(PlayerScene.instantiate())
	player.health.hp = 1_234_567
	simulate(player, 1, 0.1)
	assert_eq(player.get_node("HpLabel").text, "1.2m")


func _pos(beat_in_bar: int, since_beat: float, energy: float) -> Dictionary:
	return {"beat_in_bar": beat_in_bar, "since_beat": since_beat, "energy": energy}


func test_小節の頭の拍の瞬間は体が縦につぶれて横にふくらむ():
	var player: Player = add_child_autofree(PlayerScene.instantiate())
	player.dance(_pos(0, 0.0, 1.0), 0.5)
	var pivot: Node3D = player.get_node("Pivot")
	assert_almost_eq(pivot.scale.y, 1.0 - Groove.SQUASH_STRONG, 0.0001)
	assert_almost_eq(pivot.scale.x, 1.0 + Groove.SQUASH_STRONG / 2, 0.0001)
	assert_almost_eq(pivot.scale.z, 1.0 + Groove.SQUASH_STRONG / 2, 0.0001)


func test_拍ごとに体を左右交互に傾ける():
	var player: Player = add_child_autofree(PlayerScene.instantiate())
	var pivot: Node3D = player.get_node("Pivot")
	player.dance(_pos(0, 0.0, 1.0), 0.5)
	assert_almost_eq(pivot.rotation.z, Groove.SWAY, 0.0001)
	player.dance(_pos(1, 0.0, 1.0), 0.5)
	assert_almost_eq(pivot.rotation.z, -Groove.SWAY, 0.0001)


func test_体は足もとを支点にして動く():
	var player: Player = add_child_autofree(PlayerScene.instantiate())
	assert_eq(player.get_node("Pivot").position, Vector3.ZERO)
	assert_true(player.has_node("Pivot/Body"))
