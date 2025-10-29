extends GutTest

class_name TestPlayerHp

var player

func before_each():
	player = load("res://player/player.gd").new()

func after_each():
	player.free()

func test_add_hpは指定値を加算してシグナルを発火する():
	player.character_count = 10
	watch_signals(player)
	player.add_hp(5)
	var emitted_args = get_signal_parameters(player, "hp_changed")
	assert_eq([15, [15]], [player.character_count, emitted_args])
