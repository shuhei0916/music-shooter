extends GutTest

var main


func before_each():
	main = preload("res://scenes/main/main.tscn").instantiate()

	add_child_autofree(main)
	await get_tree().process_frame
	#add_child_autofree(player)
	#add_child_autofree(enemy)


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
