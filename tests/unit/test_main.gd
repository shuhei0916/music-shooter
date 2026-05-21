extends GutTest

const MainScript = preload("res://scenes/main/main.gd")

var main_double
var obj


func before_each():
	main_double = partial_double(MainScript).new()
	stub(main_double._update_song_progress).to_do_nothing()
	add_child_autofree(main_double)

	obj = Node3D.new()
	obj.add_to_group("world_objects")
	add_child_autofree(obj)


func test_move_world_objects_稼働中はworld_objectsが前進する():
	var initial_z = obj.global_position.z
	main_double.world_speed = 10.0
	main_double._move_world_objects(0.016)
	assert_true(obj.global_position.z > initial_z)


func test_move_world_objects_停止中はworld_objectsが動かない():
	var initial_z = obj.global_position.z
	main_double.world_speed = 0
	main_double._move_world_objects(0.016)
	assert_eq(initial_z, obj.global_position.z)
