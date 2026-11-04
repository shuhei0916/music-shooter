extends GutTest
## Main のうち、曲をパートに分けたファイルを鳴らし、ゲートでパートの音量を変えるところ

const MainScene := preload("res://scenes/main.tscn")
const STEMS_SONG := "res://test/fixtures/stems_song.mp3"


func _make_main(path: String, layout: Array) -> Main:
	var main: Main = MainScene.instantiate()
	main.song_path = path
	main.layout = layout
	return add_child_autofree(main)


func test_パートに分けた曲なら4つのパートを一緒に鳴らす():
	var main := _make_main(STEMS_SONG, [{"z": 500.0, "enemies": [[1, 1]]}])
	assert_true(main.get_node("Music").stream is AudioStreamSynchronized)


func test_ゲートを取るとそのパートの音量が上がる():
	var main := _make_main(STEMS_SONG, [{"z": 1.0, "gates": [[Gate.Op.FIRE_RATE, 1]]}])
	var player: Player = main.get_node("Player")
	player.position = Vector3(0, 0, -1.0)
	for gate: GateArea in main.find_children("*", "GateArea", true, false):
		gate.give_to(player)
	assert_eq(main.stem_mix().volume_db("drums"), StemMix.START_DB + StemMix.STEP_DB)


func test_パートに分けていない曲ではパートの音量を変えない():
	var main := _make_main("", [{"z": 500.0, "enemies": [[1, 1]]}])
	assert_false(main.stem_mix().has_stems())
