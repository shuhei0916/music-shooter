extends GutTest
## Main のうち、曲の拍・小節・セクションに合わせて動くところ

const MainScene := preload("res://scenes/main.tscn")


func _make_main(speed: float, length: float) -> Main:
	var main: Main = MainScene.instantiate()
	main.song_path = ""
	main.forward_speed = speed
	main.course_length = length
	return add_child_autofree(main)


func _find_all(root: Node, type: Variant) -> Array:
	return root.find_children("*", "", true, false).filter(func(n): return is_instance_of(n, type))


func test_曲のBPMに合わせてプレイヤーが弾を撃つ():
	var main: Main = MainScene.instantiate()
	main.song_path = ""
	main.layout = [{"z": 500.0, "enemies": [[1, 1]]}]
	main.bpm = 120.0
	add_child_autofree(main)
	main.get_node("Player").stats.fire_level = PlayerStats.MAX_FIRE_LEVEL
	simulate(main, 4, 0.25)
	assert_eq(_find_all(main, Bullet).size(), 3)


func test_曲の隣に拍のJSONがあれば最初の拍の時刻に合わせて撃つ():
	var beats := FileAccess.open("user://test_song.beats.json", FileAccess.WRITE)
	beats.store_string('{"bpm": 60.0, "offset": 0.3}')
	beats.close()
	var main: Main = MainScene.instantiate()
	main.song_path = "user://test_song.mp3"
	main.layout = [{"z": 500.0, "enemies": [[1, 1]]}]
	add_child_autofree(main)
	# 0.25 秒ずつ 1 秒まで。拍の線は 0.3 秒にだけある（JSON がなければ BPM 105 で 0 秒と 0.57 秒）
	simulate(main, 4, 0.25)
	DirAccess.remove_absolute("user://test_song.beats.json")
	assert_eq(_find_all(main, Bullet).size(), 1)


func test_右上の円に曲のいまのセクションと小節を表示する():
	var beats := FileAccess.open("user://test_song.beats.json", FileAccess.WRITE)
	beats.store_string(
		(
			'{"bpm": 120.0, "offset": 0.0, "beats_per_bar": 4, "downbeat": 0.0, '
			+ '"sections": [{"bar": 0, "label": "VERSE", "energy": 0.6}, '
			+ '{"bar": 1, "label": "DROP", "energy": 1.0}], "bar_energy": [0.6, 1.0, 1.0]}'
		)
	)
	beats.close()
	var main: Main = MainScene.instantiate()
	main.song_path = "user://test_song.mp3"
	main.layout = [{"z": 500.0, "enemies": [[1, 1]]}]
	add_child_autofree(main)
	# 1小節は 2 秒。2.5 秒は DROP の 1 小節目の 2 拍目
	simulate(main, 5, 0.5)
	DirAccess.remove_absolute("user://test_song.beats.json")
	var hud: BeatHud = main.get_node("UI/BeatHud")
	assert_eq(hud.get_node("Label").text, "DROP")
	assert_eq(hud.get_node("Bar").text, "1 / 2")
	assert_eq(hud.beat_in_bar, 1)


func test_床に小節の線を引きセクションの始まりは2本線にする():
	var beats := FileAccess.open("user://test_song.beats.json", FileAccess.WRITE)
	beats.store_string(
		(
			'{"bpm": 120.0, "offset": 0.0, "beats_per_bar": 4, "downbeat": 0.0, '
			+ '"sections": [{"bar": 0, "label": "VERSE", "energy": 0.6}, '
			+ '{"bar": 1, "label": "DROP", "energy": 1.0}]}'
		)
	)
	beats.close()
	var main: Main = MainScene.instantiate()
	main.song_path = "user://test_song.mp3"
	main.forward_speed = 10.0
	main.course_length = 100.0
	main.layout = [{"z": 500.0, "enemies": [[1, 1]]}]
	add_child_autofree(main)
	DirAccess.remove_absolute("user://test_song.beats.json")
	# 1小節は 2 秒で 20 進む。0 と 20 はセクションの始まりなので、少し手前にもう1本
	var zs: Array = main.get_node("BarLines").get_children().map(func(n): return n.position.z)
	zs.sort()
	assert_eq(zs, [-100.0, -80.0, -60.0, -40.0, -20.0, -19.5, 0.0, 0.5])


func test_床に拍ごとの線も引く():
	var beats := FileAccess.open("user://test_song.beats.json", FileAccess.WRITE)
	beats.store_string('{"bpm": 120.0, "offset": 0.0, "beats_per_bar": 4, "downbeat": 0.0}')
	beats.close()
	var main: Main = MainScene.instantiate()
	main.song_path = "user://test_song.mp3"
	main.forward_speed = 10.0
	main.course_length = 100.0
	main.layout = [{"z": 500.0, "enemies": [[1, 1]]}]
	add_child_autofree(main)
	DirAccess.remove_absolute("user://test_song.beats.json")
	# 1拍は 0.5 秒で 5 進む。10 秒までの 21 拍のうち、小節の頭の 6 拍を除く
	var zs: Array = main.get_node("BeatLines").get_children().map(func(n): return n.position.z)
	assert_eq(zs.size(), 15)
	assert_eq(zs.slice(0, 4), [-5.0, -10.0, -15.0, -25.0])


func test_自動で並べるときはゲートと敵の列を小節の線の上に置く():
	var beats := FileAccess.open("user://test_song.beats.json", FileAccess.WRITE)
	beats.store_string('{"bpm": 120.0, "offset": 0.0, "beats_per_bar": 4, "downbeat": 0.0}')
	beats.close()
	var main: Main = MainScene.instantiate()
	main.song_path = "user://test_song.mp3"
	main.forward_speed = 7.0
	main.course_length = 100.0
	main.layout_seed = 1
	add_child_autofree(main)
	DirAccess.remove_absolute("user://test_song.beats.json")
	# 1小節は 2 秒で 14 進む。スタートから 20 より先、ゴールの 15 手前（85）までの線
	var gate_zs := {}
	for gate in _find_all(main, GateArea):
		gate_zs[gate.global_position.z] = true
	var enemy_zs := {}
	for enemy in _find_all(main, Enemy):
		enemy_zs[enemy.global_position.z] = true
	assert_eq(gate_zs.keys(), [-28.0, -56.0, -84.0])
	assert_eq(enemy_zs.keys(), [-42.0, -70.0])


func test_プレイヤーは曲の拍に合わせて体を弾ませる():
	# 曲の頭は小節の頭の拍なので、少しあとでは体がふくらんでいる
	var main := _make_main(10.0, 100.0)
	simulate(main, 1, 0.02)
	assert_gt(main.get_node("Player/Pivot").scale.y, 1.0)


func test_初めは小節の頭で弾を撃つ():
	var beats := FileAccess.open("user://test_song.beats.json", FileAccess.WRITE)
	beats.store_string('{"bpm": 120.0, "offset": 0.25, "beats_per_bar": 4, "downbeat": 0.75}')
	beats.close()
	var main: Main = MainScene.instantiate()
	main.song_path = "user://test_song.mp3"
	main.layout = [{"z": 500.0, "enemies": [[1, 1]]}]
	add_child_autofree(main)
	DirAccess.remove_absolute("user://test_song.beats.json")
	# 最初の拍（0.25 秒）では撃たず、小節の頭（0.75 秒）で撃つ
	simulate(main, 2, 0.25)
	assert_eq(_find_all(main, Bullet).size(), 0)
	simulate(main, 2, 0.25)
	assert_eq(_find_all(main, Bullet).size(), 1)
