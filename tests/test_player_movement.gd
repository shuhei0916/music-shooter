extends GutTest

class_name TestPlayerMovement

var player

func before_each():
	player = load("res://scenes/characters/player/player.gd").new()

func after_each():
	player.free()

func test_右端を超えた位置は最大値にクランプされる():
	player.horizontal_limit_min = -4.0
	player.horizontal_limit_max = 4.0
	player.position.x = 6.5
	player.clamp_horizontal_position()
	assert_eq(4.0, player.position.x)

func test_左端を超えた位置は最小値にクランプされる():
	player.horizontal_limit_min = -4.0
	player.horizontal_limit_max = 4.0
	player.position.x = -7.2
	player.clamp_horizontal_position()
	assert_eq(-4.0, player.position.x)
