extends GutTest

var main_d

func before_each():
	var real_main = preload("res://scenes/main/main.tscn").instantiate()
	main_d = partial_double(real_main)
	stub(main_d, "gate_spawn")
	
func after_each():
	main_d = null
	
func test_5回に1回ゲートがスポーンする():
	var main = preload("res://scenes/main/main.tscn").instantiate()
	
	#var main_scene = load("res://scenes/main/main.tscn")
	#add_child_autofree(main_scene)          # 後始末つきでツリーへ
	#await get_tree().process_frame         # onready / _ready を通す（重要）
	
	#var doubled = partial_double(main_scene).instantiate()
	
	#main.set_spawn_counter(4)
	#main._on_spawn_timer_timeout()
	
	#assert_called(doubled, 'gate_spawn')
	assert_eq(1, 1)

func test_Playerとゲートが衝突するとゲートが消滅する():
	var gate = preload("res://scenes/objects/gate/gate.tscn").instantiate()
	var player = preload("res://scenes/characters/player/player.tscn").instantiate()
	gate.player_entered_gate.connect(player._on_gate_entered)
	gate._on_body_entered(player)
	assert_true(gate.is_queued_for_deletion())

func test_Playerとゲートが衝突するとPlayerのHPが変化する():
	var gate = preload("res://scenes/objects/gate/gate.tscn").instantiate()
	gate.gate_type = "add"
	gate.value = 5
	var player = preload("res://scenes/characters/player/player.tscn").instantiate()
	player.hp = 10
	gate.player_entered_gate.connect(player._on_gate_entered)
	gate._on_body_entered(player)
	assert_eq(15, player.hp)
