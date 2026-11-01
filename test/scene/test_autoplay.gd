extends GutTest
## Main を自動で遊ばせ、小節ごとにプレイヤーと敵の強さを記録する Autoplay

const MainScene := preload("res://scenes/main.tscn")


func _make_main(layout: Array) -> Main:
	var main: Main = MainScene.instantiate()
	main.song_path = ""
	main.bpm = 120.0
	main.forward_speed = 10.0
	main.course_length = 200.0
	main.layout = layout
	return add_child_autofree(main)


func _make_autoplay(main: Main) -> Autoplay:
	var autoplay := Autoplay.new()
	autoplay.main = main
	return add_child_autofree(autoplay)


func _run(main: Main, autoplay: Autoplay, frames: int, delta: float) -> void:
	for i in frames:
		autoplay._process(delta)
		simulate(main, 1, delta)


func test_レーンの位置は道を均等に分けた位置():
	var main := _make_main([])
	assert_eq(main.lane_xs(), [-3.0, 0.0, 3.0])


func test_次のゲートの列では得なゲートへ向かう():
	var main := _make_main([{"z": 30.0, "gates": [[Gate.Op.ADD, 1], [Gate.Op.MULTIPLY, 3]]}])
	var autoplay := _make_autoplay(main)
	_run(main, autoplay, 10, 0.1)
	assert_gt(main.get_node("Player").position.x, 1.0)


func test_次の敵の列では敵のいないレーンへ向かう():
	var main := _make_main([{"z": 30.0, "enemies": [[1, 5], [2, 5]]}])
	var autoplay := _make_autoplay(main)
	_run(main, autoplay, 10, 0.1)
	assert_lt(main.get_node("Player").position.x, -1.0)


func test_小節の頭ごとにプレイヤーの強さと次の敵のHPを記録する():
	var main := _make_main([{"z": 60.0, "enemies": [[0, 7], [1, 9]]}])
	var autoplay := _make_autoplay(main)
	# 120 BPM で 1小節は 2 秒。0 秒と 2 秒の小節の頭で記録する
	_run(main, autoplay, 25, 0.1)
	assert_eq(autoplay.samples.size(), 2)
	var sample: Dictionary = autoplay.samples[1]
	assert_almost_eq(sample.time, 2.0, 0.11)
	assert_eq([sample.hp, sample.power, sample.fire_level, sample.enemy_hp], [10, 1, 0, 9])


func test_記録はCSVにできる():
	var autoplay := Autoplay.new()
	autoplay.samples = [
		{
			"time": 2.0,
			"label": "DROP",
			"energy": 1.0,
			"hp": 10,
			"power": 2,
			"fire_level": 1,
			"dps": 2.0,
			"enemy_hp": 9,
		}
	]
	var lines := autoplay.to_csv().split("\n", false)
	assert_eq(lines[0], "time,label,energy,hp,power,fire_level,dps,enemy_hp")
	assert_eq(lines[1], "2.00,DROP,1.00,10,2,1,2.00,9")
	autoplay.free()


func test_2レーンを占める敵がいればあいているレーンへ向かう():
	var main := _make_main([{"z": 30.0, "enemies": [[0, 5, 2]]}])
	var autoplay := _make_autoplay(main)
	_run(main, autoplay, 10, 0.1)
	assert_gt(main.get_node("Player").position.x, 1.0)


func test_ボスにぶつかる直前のプレイヤーのHPとボスの残りのHPを記録する():
	var main := _make_main([{"z": 30.0, "enemies": [[0, 50, 3]]}])
	var autoplay := _make_autoplay(main)
	_run(main, autoplay, 40, 0.1)
	assert_eq(autoplay.boss_records.size(), 1)
	var record: Dictionary = autoplay.boss_records[0]
	assert_eq(record.player_hp, 10)
	assert_between(record.boss_hp, 45, 50)
	assert_eq(autoplay.zone(), 1)


func test_HPでボスを上回ればそのボスを越えて次のゾーンに進む():
	var layout := [{"z": 30.0, "enemies": [[0, 4, 3]]}, {"z": 80.0, "enemies": [[0, 500, 3]]}]
	var main := _make_main(layout)
	var autoplay := _make_autoplay(main)
	_run(main, autoplay, 100, 0.1)
	assert_eq(autoplay.boss_records.size(), 2)
	assert_eq(autoplay.zone(), 2)


func test_ふつうの敵はボスとして記録しない():
	var main := _make_main([{"z": 30.0, "enemies": [[0, 5]]}])
	var autoplay := _make_autoplay(main)
	_run(main, autoplay, 40, 0.1)
	assert_eq(autoplay.boss_records, [])


func test_ボスごとの余裕はプレイヤーのHPをボスの残りのHPで割った値():
	var autoplay := Autoplay.new()
	autoplay.boss_records = [{"player_hp": 30, "boss_hp": 20}, {"player_hp": 50, "boss_hp": 200}]
	assert_eq(autoplay.boss_margins(), [1.5, 0.25])
	autoplay.free()
