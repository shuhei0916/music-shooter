extends GutTest

class_name TestMainGate

var main_scene
var player

func before_each():
	main_scene = load("res://main.gd").new()
	player = load("res://player/player.gd").new()
	main_scene.player = player

func after_each():
	player.free()
	main_scene.free()

func test_クールダウン中のゲート効果はメインで再適用されない():
	player.character_count = 8
	watch_signals(player)
	main_scene._on_player_entered_gate("add", 2)
	var first_emit_count = get_signal_emit_count(player, "hp_changed")
	main_scene._on_player_entered_gate("multiply", 3)
	var emit_count = get_signal_emit_count(player, "hp_changed")
	assert_eq(
		{
			"hp": player.character_count,
			"emit_count": emit_count,
			"first_emit_count": first_emit_count
		},
		{
			"hp": 10,
			"emit_count": 1,
			"first_emit_count": 1
		}
	)
