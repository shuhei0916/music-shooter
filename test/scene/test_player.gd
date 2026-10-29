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


func _shots(fire_level: int, times: Array) -> int:
	var player := _make_player_on_stage()
	player.stats.fire_level = fire_level
	var grid := BeatGrid.new(120.0)
	for time in times:
		player.shoot_on_beat(time, grid)
	return _bullets_of(player).size()


func test_初めは1小節ごとに弾を撃つ():
	# BPM 120 なので1拍は 0.5 秒、1小節は 2 秒。0・2・4 秒で撃つ
	assert_eq(_shots(0, [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0]), 3)


func test_連射の段階が上がると2拍ごとに撃つ():
	assert_eq(_shots(1, [0.0, 0.5, 1.0, 1.5, 2.0]), 3)


func test_連射の段階が上限なら1拍ごとに撃つ():
	assert_eq(_shots(PlayerStats.MAX_FIRE_LEVEL, [0.0, 0.25, 0.5, 0.75, 1.0]), 3)


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


func test_拍の瞬間は体が一瞬ふくらむ():
	var player: Player = add_child_autofree(PlayerScene.instantiate())
	player.dance(_pos(0, 0.0, 1.0))
	assert_eq(player.get_node("Pivot").scale, Vector3.ONE * (1.0 + Groove.PEAK))


func test_体がふくらんでも当たり判定の大きさは変わらない():
	var player: Player = add_child_autofree(PlayerScene.instantiate())
	player.dance(_pos(0, 0.0, 1.0))
	var shape: CollisionShape3D = player.get_node("CollisionShape3D")
	assert_eq(shape.global_basis.get_scale(), Vector3.ONE)


func test_体は足もとを支点にして動く():
	var player: Player = add_child_autofree(PlayerScene.instantiate())
	assert_eq(player.get_node("Pivot").position, Vector3.ZERO)
	assert_true(player.has_node("Pivot/Body"))


func test_弾は銃口から出る():
	var player := _make_player_on_stage()
	player.position = Vector3(2, 0, -5)
	player.shoot_on_beat(0.0, BeatGrid.new(120.0))
	var muzzle: Node3D = player.get_node("Muzzle")
	assert_eq(_bullets_of(player)[0].position, player.position + muzzle.position)
