extends GutTest
## Main のうち、パートの解析に合わせてプレイヤーが剣をため、キックで撃ち出すところ

const MainScene := preload("res://scenes/main.tscn")
const PARTS_PATH := "user://sword_song.parts.json"


func _make_main(parts_json: String) -> Main:
	var file := FileAccess.open(PARTS_PATH, FileAccess.WRITE)
	file.store_string(parts_json)
	file.close()
	var main: Main = MainScene.instantiate()
	main.song_path = "user://sword_song.mp3"
	main.layout = [{"z": 500.0, "enemies": [[1, 1]]}]
	add_child_autofree(main)
	DirAccess.remove_absolute(PARTS_PATH)
	return main


func _swords_of(main: Main) -> Array:
	return main.get_children().filter(func(n): return n is Sword)


func test_曲の時刻に合わせて剣をためキックで撃ち出す():
	var main := _make_main(
		(
			'{"frame_rate": 10, "parts": {'
			+ '"snare": {"level": [], "onsets": [0.1, 0.2]},'
			+ '"hihat": {"level": [], "onsets": [0.3, 0.4]},'
			+ '"kick": {"level": [], "onsets": [0.5]}}}'
		)
	)
	simulate(main, 4, 0.1)
	assert_eq(main.get_node("Player").swords.count, PlayerStats.SWORDS_PER_VOLLEY)
	simulate(main, 2, 0.1)
	assert_eq(_swords_of(main).size(), PlayerStats.SWORDS_PER_VOLLEY)


func test_左上に武器の強化の状況を出し取ったゲートに合わせて変わる():
	var main := _make_main("")
	var player: Player = main.get_node("Player")
	Gate.new(Gate.Op.SWORD, 1).apply(player.stats)
	simulate(main, 1, 0.1)
	var rows := main.get_node("UI/LoadoutHud/Rows").get_children()
	assert_string_starts_with(rows[1].text, "剣 Lv2")


func test_剣のパートを切りかえるキーで剣のパートの組み合わせが次に変わる():
	var main := _make_main("")
	var event := InputEventAction.new()
	event.action = "cycle_sword_parts"
	event.pressed = true
	main._unhandled_input(event)
	var stats: PlayerStats = main.get_node("Player").stats
	assert_eq(
		[stats.sword_charge_parts, stats.sword_release_part], PlayerStats.SWORD_PART_PRESETS[1]
	)


func test_剣のパートを切りかえるキーはF4():
	var events := InputMap.action_get_events("cycle_sword_parts")
	assert_eq(events.size(), 1)
	assert_eq(events[0].physical_keycode, KEY_F4)
