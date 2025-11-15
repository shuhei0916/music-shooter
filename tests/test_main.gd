extends GutTest

const MAIN_SCENE := preload("res://scenes/main/main.tscn")

func test_game_overするとworld_objectsの移動が止まる():
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
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
