extends GutTest

var enemy


func before_each():
	enemy = preload("res://scenes/characters/enemy/enemy.tscn").instantiate()
	add_child_autofree(enemy)


func test_悪役のスキンでモデルを表示する():
	assert_eq("criminalMaleA.png", enemy.get_node("CharacterModel").skin.resource_path.get_file())


func test_HPのラベルは単位つきで表示する():
	enemy.hp = 35_000_000
	assert_eq("35M", enemy.get_node("HPLabel").text)


func test_被弾するとモデルの被弾演出を再生する():
	enemy.hp = 5
	var model = enemy.get_node("CharacterModel")
	var z_before: float = model.position.z
	enemy.take_damage(1)
	assert_lt(model.position.z, z_before)
