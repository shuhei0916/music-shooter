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

func test_multiply_hpは指定値を乗算してシグナルを発火する():
	player.character_count = 4
	watch_signals(player)
	player.multiply_hp(3)
	var emitted_args = get_signal_parameters(player, "hp_changed")
	assert_eq([12, [12]], [player.character_count, emitted_args])

func test_致死ダメージでhpを0にしてゲームオーバーシグナルを発火する():
	player.character_count = 3
	watch_signals(player)
	player.take_damage(5)
	var hp_args = get_signal_parameters(player, "hp_changed")
	var game_over_params = get_signal_parameters(player, "game_over_signal")
	assert_eq([0, [0], []], [player.character_count, hp_args, game_over_params])
