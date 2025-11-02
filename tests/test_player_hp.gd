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

func test_非致死ダメージでは残量を減らしゲームオーバーにならない():
	player.character_count = 10
	watch_signals(player)
	player.take_damage(3)
	var hp_args = get_signal_parameters(player, "hp_changed")
	var game_over_params = get_signal_parameters(player, "game_over_signal")
	assert_eq([7, [7], null], [player.character_count, hp_args, game_over_params])

func test_ゲート効果適用でhpが増えクールダウンが開始される():
	player.character_count = 10
	watch_signals(player)
	var result = player.try_apply_gate_effect("add", 5)
	var emit_count = get_signal_emit_count(player, "hp_changed")
	assert_eq(
		{
			"hp": player.character_count,
			"result": result,
			"emit_count": emit_count,
			"ready": player.is_gate_ready()
		},
		{
			"hp": 15,
			"result": true,
			"emit_count": 1,
			"ready": false
		}
	)

func test_クールダウン中のゲート効果は無視される():
	player.character_count = 10
	watch_signals(player)
	player.try_apply_gate_effect("add", 5)
	var after_first_hp = player.character_count
	var first_emit_count = get_signal_emit_count(player, "hp_changed")
	var second_result = player.try_apply_gate_effect("multiply", 3)
	var emit_count = get_signal_emit_count(player, "hp_changed")
	assert_eq(
		{
			"hp": player.character_count,
			"emit_count": emit_count,
			"first_emit_count": first_emit_count,
			"second_result": second_result
		},
		{
			"hp": after_first_hp,
			"emit_count": first_emit_count,
			"first_emit_count": 1,
			"second_result": false
		}
	)
