extends GutTest

const TIMEBASE = 480
const BAR = TIMEBASE * 4

var player


func before_each():
	player = preload("res://scenes/characters/player/player.tscn").instantiate()
	add_child_autofree(player)


func after_each():
	for bullet in get_tree().get_nodes_in_group("bullet"):
		bullet.free()


func test_グリッド上のノートを受け取ると対応チャンネルの武器から弾を発射する():
	player.on_note(0, BAR, TIMEBASE)
	assert_eq(1, get_tree().get_nodes_in_group("bullet").size())


func test_グリッド外のノートを受け取っても弾を発射しない():
	player.on_note(0, BAR + TIMEBASE, TIMEBASE)
	assert_eq(0, get_tree().get_nodes_in_group("bullet").size())


func test_武器が割り当てられていないチャンネルのノートでは弾を発射しない():
	player.on_note(99, BAR, TIMEBASE)
	assert_eq(0, get_tree().get_nodes_in_group("bullet").size())


func test_武器は発射時に光るマズルフラッシュを持たない():
	var lights = player._weapon_map.values().map(func(w): return w.find_children("*", "Light3D"))
	assert_eq(lights.filter(func(found): return not found.is_empty()), [])


func test_スケーター男性のスキンで走るモデルを表示する():
	var model = player.get_node("CharacterModel")
	assert_eq(["run", "skaterMaleA.png"], [model.animation, model.skin.resource_path.get_file()])


func test_HPのラベルは単位つきで表示する():
	player.hp = 1500
	assert_eq("1.5k", player.get_node("HPLabel").text)


func test_同じチャンネルの同じtickのノートは和音として1発だけ発射する():
	for i in 3:
		player.on_note(0, BAR, TIMEBASE)
	assert_eq(1, get_tree().get_nodes_in_group("bullet").size())


func test_違うtickのノートではそれぞれ発射する():
	player.on_note(0, BAR, TIMEBASE)
	player.on_note(0, BAR * 2, TIMEBASE)
	assert_eq(2, get_tree().get_nodes_in_group("bullet").size())
