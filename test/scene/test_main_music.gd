extends GutTest
## Main のうち、曲の拍・小節・セクションに合わせて動くところ

const MainScene := preload("res://scenes/main.tscn")
## 自動で並べたとき、ゲートのあいだに敵の列が出るシード
const SEED_WITH_ENEMIES := 2


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


func test_自動で並べるときはゲートの列を小節の線に敵の列をゲートのあいだの拍の線に置く():
	var beats := FileAccess.open("user://test_song.beats.json", FileAccess.WRITE)
	beats.store_string('{"bpm": 120.0, "offset": 0.0, "beats_per_bar": 4, "downbeat": 0.0}')
	beats.close()
	var main: Main = MainScene.instantiate()
	main.song_path = "user://test_song.mp3"
	main.forward_speed = 7.0
	main.course_length = 100.0
	main.layout_seed = SEED_WITH_ENEMIES
	add_child_autofree(main)
	DirAccess.remove_absolute("user://test_song.beats.json")
	# 1小節は 2 秒で 14 進む。スタートから 20 より先、ゴールの 15 手前（85）までの線
	var gate_zs := {}
	for gate in _find_all(main, GateArea):
		gate_zs[gate.global_position.z] = true
	var enemy_zs := {}
	for enemy in _find_all(main, Enemy):
		enemy_zs[enemy.global_position.z] = true
	# 1拍は 3.5 進む
	assert_eq(gate_zs.keys(), [-28.0, -56.0, -84.0])
	assert_gt(enemy_zs.size(), 0)
	for z: float in enemy_zs:
		assert_almost_eq(fposmod(z, 3.5), 0.0, 0.001)
		assert_between(z, -84.0, -28.0)
		assert_false(z in gate_zs)


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


func test_セクションが分からない曲では盛り上がりを中くらいとして敵の列を並べる():
	var counts := []
	for seed_value in 10:
		var main: Main = MainScene.instantiate()
		main.song_path = ""
		main.course_length = 600.0
		main.layout_seed = seed_value
		add_child_autofree(main)
		counts.append(main.layout.filter(func(row): return row.has("enemies")).size())
		var gates: int = main.layout.filter(func(row): return row.has("gates")).size()
		counts[-1] = float(counts[-1]) / (gates - 1)
	var mean: float = counts.reduce(func(a, b): return a + b) / counts.size()
	# 盛り上がり 0.5 なら1列ごとの確率は 0.55 で、ゲートのあいだに平均 1.1 列
	assert_gt(mean, 0.8)


func test_自動で並べるときはサビの前の小節にボスを置く():
	# 1小節は 2 秒で 14 進む。4 小節目からが DROP なので、3 小節目の線（42）にボスを置く
	var beats := FileAccess.open("user://test_song.beats.json", FileAccess.WRITE)
	beats.store_string(
		(
			'{"bpm": 120.0, "offset": 0.0, "beats_per_bar": 4, "downbeat": 0.0, "sections": ['
			+ '{"bar": 0, "energy": 0.5, "label": "BUILD"},'
			+ '{"bar": 4, "energy": 1.0, "label": "DROP"}],'
			+ '"bar_energy": [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]}'
		)
	)
	beats.close()
	var main: Main = MainScene.instantiate()
	main.song_path = "user://test_song.mp3"
	main.forward_speed = 7.0
	main.course_length = 200.0
	main.layout_seed = 1
	add_child_autofree(main)
	DirAccess.remove_absolute("user://test_song.beats.json")
	var bosses := _find_all(main, Enemy).filter(func(e): return e.lanes_wide == 3)
	assert_eq(bosses.map(func(e): return e.global_position), [Vector3(0, 0, -42)])


func test_自動で並べるときは最後のボスのHPがちょうど最後のボスのHPの設定値になる():
	# 1小節は 14 進む。サビは 4〜7 小節目の1回だけなので、ボスは 3 小節目（42）と 7 小節目（98）
	var beats := FileAccess.open("user://test_song.beats.json", FileAccess.WRITE)
	beats.store_string(
		(
			'{"bpm": 120.0, "offset": 0.0, "beats_per_bar": 4, "downbeat": 0.0, "sections": ['
			+ '{"bar": 0, "energy": 0.5, "label": "BUILD"},'
			+ '{"bar": 4, "energy": 1.0, "label": "DROP"}],'
			+ '"bar_energy": [0, 0, 0, 0, 1, 1, 1, 1]}'
		)
	)
	beats.close()
	var main: Main = MainScene.instantiate()
	main.song_path = "user://test_song.mp3"
	main.forward_speed = 7.0
	main.course_length = 200.0
	main.layout_seed = 1
	main.final_boss_hp = 1_000_000
	add_child_autofree(main)
	DirAccess.remove_absolute("user://test_song.beats.json")
	var bosses := _find_all(main, Enemy).filter(func(e): return e.lanes_wide == 3)
	var hp_by_z := {}
	for boss in bosses:
		hp_by_z[boss.global_position.z] = boss.start_hp
	assert_eq(hp_by_z.get(-98.0), 1_000_000)
	assert_lt(hp_by_z.get(-42.0, 0), 1_000_000)
