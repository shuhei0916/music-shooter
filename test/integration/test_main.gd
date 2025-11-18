extends GutTest

var main

func before_each():
	main = preload("res://scenes/main/main.tscn").instantiate()
	
	add_child_autofree(main)
	await get_tree().process_frame
	#add_child_autofree(player)
	#add_child_autofree(enemy)

func test_game_overするとworld_objectsの移動が止まる():
	var world_obj = Node3D.new()
	world_obj.add_to_group("world_objects")
	main.add_child(world_obj)
	var initial_z = world_obj.global_position.z
	main._on_start_timer_timeout()
	main._process(0.016)
	assert_true(world_obj.global_position.z > initial_z)
	main.player.game_over()
	var z_after_game_over = world_obj.global_position.z
	main._process(0.016)
	assert_eq(z_after_game_over, world_obj.global_position.z)

func test_game_overするとリザルト画面が表示される():
	var game_ui = main.get_node("GameUI")
	assert_false(game_ui.result_panel.visible)
	main.player.game_over()
	assert_true(game_ui.result_panel.visible)

func test_完奏すると勝利パネルが表示される():
	var game_ui = main.get_node("GameUI")
	assert_false(game_ui.result_panel.visible)
	main._on_midi_finished()
	assert_true(game_ui.result_panel.visible)
	assert_true(game_ui.result_label.text.begins_with("Run Completed"))

func test_スタートタイマー経過後にワールドが動き出す():
	var world_obj = Node3D.new()
	world_obj.add_to_group("world_objects")
	main.add_child(world_obj)
	var initial_z = world_obj.global_position.z
	# StartTimerタイムアウト前は動かない想定
	main._process(0.016)
	assert_eq(initial_z, world_obj.global_position.z)
	# タイマータイムアウトを直接呼び出す
	main._on_start_timer_timeout()
	main._process(0.016)
	assert_true(world_obj.global_position.z > initial_z)
