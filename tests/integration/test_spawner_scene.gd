extends GutTest

const SPAWNER_SCENE := preload("res://scenes/components/spawner.tscn")
var spawner


func before_each():
	spawner = SPAWNER_SCENE.instantiate()
	add_child_autofree(spawner)
	await get_tree().process_frame


func test_敵スポーン確率が100パーセントならゲート非発生ターンで敵が1体スポーンする():
	spawner.enemy_spawn_probability = 1.0
	spawner.spawn_counter = 0

	var enemies_before = get_tree().get_nodes_in_group("enemy").size()
	spawner._on_spawn_timer_timeout()
	var enemies_after = get_tree().get_nodes_in_group("enemy").size()

	assert_eq(enemies_before + 1, enemies_after)
