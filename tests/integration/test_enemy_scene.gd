extends GutTest

var enemy


func before_each():
	enemy = preload("res://scenes/characters/enemy/enemy.tscn").instantiate()
	add_child_autofree(enemy)


func test_悪役のスキンでモデルを表示する():
	assert_eq("criminalMaleA.png", enemy.get_node("CharacterModel").skin.resource_path.get_file())
