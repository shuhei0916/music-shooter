extends GutTest

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
var main
var spawner

func before_each():
	main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	
	spawner = main.get_node("Spawner")
	
func test_敵スポーン確率が100パーセントならゲート非発生ターンで敵が1体スポーンする():
	spawner.enemy_spawn_probability = 1.0
	spawner.spawn_counter = 0
	
	var enemies_before = get_tree().get_nodes_in_group("enemy").size()
	spawner._on_spawn_timer_timeout()
	var enemies_after = get_tree().get_nodes_in_group("enemy").size()
	
	assert_eq(enemies_before + 1, enemies_after)

func test_敵はスポーン時にenemy_hp_minとenemy_hp_maxの設定値の範囲で生成される():
	spawner.enemy_spawn_probability = 1.0
	spawner.enemy_hp_min = 12
	spawner.enemy_hp_max = 12
	spawner.spawn_counter = 0
	
	spawner._on_spawn_timer_timeout()
	for enemy in get_tree().get_nodes_in_group("enemy"):
		assert_eq(12, enemy.hp)
