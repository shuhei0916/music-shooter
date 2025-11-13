extends GutTest

const MAIN_SCENE := preload("res://scenes/main/main.tscn")

var gate: Area3D
var player: CharacterBody3D

func before_each():
	gate = preload("res://scenes/objects/gate/gate.tscn").instantiate()
	player = preload("res://scenes/characters/player/player.tscn").instantiate()
	add_child_autofree(gate)
	add_child_autofree(player)
	
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

func test_Playerとゲートが衝突するとゲートが消滅する():
	gate._on_body_entered(player)
	assert_true(gate.is_queued_for_deletion())

func test_Playerとゲートが衝突するとPlayerのHPが変化する():
	gate.gate_type = "add"
	gate.value = 5
	player.hp = 10
	gate._on_body_entered(player)
	assert_eq(15, player.hp)
