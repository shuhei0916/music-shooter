extends GutTest

const CharacterModel = preload("res://scenes/characters/character_model/character_model.gd")

var model: CharacterModel


func before_each():
	model = CharacterModel.new()


func _animation_player() -> AnimationPlayer:
	return model.find_children("*", "AnimationPlayer", true, false)[0]


func test_指定したアニメーションを再生する():
	model.animation = "idle"
	add_child_autofree(model)
	assert_eq("idle", _animation_player().current_animation)


func test_アニメーションはループする():
	add_child_autofree(model)
	var animation_player := _animation_player()
	var current := animation_player.get_animation(animation_player.current_animation)
	assert_eq(Animation.LOOP_LINEAR, current.loop_mode)


func test_指定したスキンのテクスチャをメッシュに適用する():
	var skin := load(CharacterModel.ASSET_DIR + "Skins/criminalMaleA.png")
	model.skin = skin
	add_child_autofree(model)
	var mesh: MeshInstance3D = model.find_children("*", "MeshInstance3D", true, false)[0]
	assert_eq(skin, mesh.get_active_material(0).albedo_texture)


func _material() -> StandardMaterial3D:
	var mesh: MeshInstance3D = model.find_children("*", "MeshInstance3D", true, false)[0]
	return mesh.get_active_material(0)


func test_被弾演出を再生するとモデルが白く光る():
	add_child_autofree(model)
	model.play_hit()
	assert_true(_material().emission_enabled)
	assert_gt(_material().emission_energy_multiplier, 0.0)


func test_被弾演出の光は時間がたつと消える():
	add_child_autofree(model)
	model.play_hit()
	await wait_seconds(CharacterModel.HIT_DURATION + 0.1)
	assert_eq(_material().emission_energy_multiplier, 0.0)


func test_被弾演出を再生するとモデルが奥にのけぞる():
	add_child_autofree(model)
	var z_before := model.position.z
	model.play_hit()
	assert_lt(model.position.z, z_before)


func test_被弾演出ののけぞりは時間がたつと元の位置に戻る():
	add_child_autofree(model)
	var position_before := model.position
	model.play_hit()
	await wait_seconds(CharacterModel.HIT_DURATION + 0.1)
	assert_eq(model.position, position_before)


func test_連続で被弾してものけぞりは元の位置からやり直す():
	add_child_autofree(model)
	model.play_hit()
	var z_hit := model.position.z
	model.play_hit()
	assert_eq(model.position.z, z_hit)
