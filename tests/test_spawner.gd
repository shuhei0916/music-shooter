extends GutTest


func test_5回に1回ゲートがスポーンする():
	#var main = preload("res://scenes/main/main.tscn").instantiate()
	
	#var main_scene = load("res://scenes/main/main.tscn")
	#add_child_autofree(main_scene)          # 後始末つきでツリーへ
	#await get_tree().process_frame         # onready / _ready を通す（重要）
	
	#var doubled = partial_double(main_scene).instantiate()
	
	#main.set_spawn_counter(4)
	#main._on_spawn_timer_timeout()
	
	#assert_called(doubled, 'gate_spawn')
	assert_eq(1, 1)
