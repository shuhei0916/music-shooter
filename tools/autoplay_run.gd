extends SceneTree
## 曲を自動で遊ばせて、難易度を数字で確かめる
##
## 使い方（プロジェクトのフォルダで）:
##   godot --headless --fixed-fps 60 --script res://tools/autoplay_run.gd -- [--seeds=5] [--out=DIR]
## シードを 0 から順に変えて遊ばせ、シードごとの小節の頭の記録を DIR/autoplay_seed_N.csv に書き、
## 結果（CLEAR か GAME OVER か、どこまで進んだか、最後の強さ）を表示する
## 当たり判定に物理の処理が要るので、--fixed-fps で決まった刻みのフレームを待たずに回す

const MainScene := preload("res://scenes/main.tscn")

var _seeds := 5
var _out_dir := "user://autoplay"
var _seed := 0
var _main: Main
var _autoplay: Autoplay


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--seeds="):
			_seeds = int(arg.trim_prefix("--seeds="))
		elif arg.begins_with("--out="):
			_out_dir = arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(_out_dir)
	print("seed,result,time,section,hp,power,fire_level")
	_start()


func _process(_delta: float) -> bool:
	if _main == null or _main.result() == Judge.Result.PLAYING:
		return false
	_finish()
	_seed += 1
	if _seed >= _seeds:
		return true
	_start()
	return false


func _start() -> void:
	_main = MainScene.instantiate()
	_main.silent = true
	_main.layout_seed = _seed
	root.add_child(_main)
	_autoplay = Autoplay.new()
	_autoplay.main = _main
	root.add_child(_autoplay)


func _finish() -> void:
	var path := _out_dir.path_join("autoplay_seed_%d.csv" % _seed)
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(_autoplay.to_csv())
	file.close()
	var stats: PlayerStats = _main.get_node("Player").stats
	var time := _main.song_time()
	var result := "CLEAR" if _main.result() == Judge.Result.CLEARED else "GAME_OVER"
	var values := [
		_seed,
		result,
		"%.1f" % time,
		_main.song_map().at(time).label,
		stats.health.hp,
		stats.power,
		stats.fire_level,
	]
	print(",".join(values.map(func(v): return str(v))))
	_main.free()
	_autoplay.free()
	_main = null
