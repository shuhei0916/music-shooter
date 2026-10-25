extends GutTest
## ゲーム中の曲の進み具合（インフレの進み具合・進捗表示）

const MainScene = preload("res://scenes/main/main.tscn")

var main


func before_each():
	main = MainScene.instantiate()
	main.midi_soundfont_path = ""  # 音色の読み込み（約2.3秒）を省く
	add_child_autofree(main)
	await get_tree().process_frame


func after_each():
	for bullet in get_tree().get_nodes_in_group("bullet"):
		bullet.free()


func test_プレイ中は今のインフレ倍率が弾のダメージになる():
	main._on_start_timer_timeout()
	main.spawner.inflation_end_scale = 50.0
	main.spawner.set_growth_curve(PackedVector2Array([Vector2(0.0, 100.0)]))  # 再生位置0で進み具合1
	main._process(0.016)
	for weapon in main.player.get_children().filter(func(n): return n.is_in_group("weapon")):
		assert_eq(50, weapon.damage)


func test_インフレの進み具合はテンポによらず再生位置のtickで決まる():
	main.spawner.set_growth_curve(
		PackedVector2Array([Vector2(0, 0), Vector2(100, 50), Vector2(200, 100)])
	)
	main.midi_player.position = 100
	main.midi_player.timebase_to_seconds = 0.26  # テンポ230相当
	assert_almost_eq(main.spawner._get_spawn_progress(), 0.5, 0.001)


func test_曲の進捗表示はテンポ変更を反映した経過時間になる():
	main._on_start_timer_timeout()
	var analyzer = SongAnalyzer.new()
	var tick: int = main.midi_player.smf_data.timebase * 100
	main.midi_player.position = tick
	main.midi_player.timebase_to_seconds = 0.1  # 再生中のテンポ（600BPM相当）には左右されない
	main._update_song_progress()
	var expected = main.game_ui.format_seconds_to_string(
		analyzer.ticks_to_seconds(main.midi_player.smf_data, tick)
	)
	assert_string_starts_with(main.game_ui.get_node("SongProgressLabel").text, expected + "/")
