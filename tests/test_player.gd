extends GutTest

var gate
var player

func before_each():
	gate = preload("res://scenes/objects/gate/gate.tscn").instantiate()
	player = preload("res://scenes/characters/player/player.tscn").instantiate()
	
	add_child_autofree(gate)
	add_child_autofree(player)
	player.horizontal_limit_min = -4.0
	player.horizontal_limit_max = 4.0

func after_each():
	player.free()

func test_右端を超えた位置は最大値にクランプされる():
	player.position.x = 6.5
	player.clamp_horizontal_position()
	assert_eq(4.0, player.position.x)

func test_左端を超えた位置は最小値にクランプされる():
	player.position.x = -7.2
	player.clamp_horizontal_position()
	assert_eq(-4.0, player.position.x)

func test_Playerとゲートが衝突するとPlayerのHPが変化する():
	gate.gate_type = "add"
	gate.value = 5
	player.hp = 10
	gate._on_body_entered(player)
	assert_eq(15, player.hp)
