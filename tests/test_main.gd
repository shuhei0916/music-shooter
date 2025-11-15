extends GutTest

const MAIN_SCENE := preload("res://scenes/main/main.tscn")

var main

func before_each():
	main = preload("res://scenes/main/main.tscn").instantiate()
	
	add_child_autofree(main)
	#add_child_autofree(player)
	#add_child_autofree(enemy)

func test_game_overするとworld_objectsの移動が止まる():
	await get_tree().process_frame
	var world_obj = Node3D.new()
	world_obj.add_to_group("world_objects")
	main.add_child(world_obj)
	var initial_z = world_obj.global_position.z
	main._process(0.016)
	assert_true(world_obj.global_position.z > initial_z)
	main.player.game_over()
	var z_after_game_over = world_obj.global_position.z
	main._process(0.016)
	assert_eq(z_after_game_over, world_obj.global_position.z)

func test_game_overするとリザルト画面が表示される():
	await get_tree().process_frame
	var game_ui = main.get_node("GameUI")
	assert_false(game_ui.result_panel.visible)
	main.player.game_over()
	assert_true(game_ui.result_panel.visible)
