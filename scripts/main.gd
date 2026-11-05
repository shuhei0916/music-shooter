class_name Main
extends Node3D

const GateScene := preload("res://scenes/gate.tscn")
const EnemyScene := preload("res://scenes/enemy.tscn")
## 自分のシーンは preload すると循環するので、使うときに読む
const MAIN_SCENE := "res://scenes/main.tscn"
const SONG_SELECT_SCENE := "res://scenes/song_select.tscn"
## 山札に入れるゲートのカード。{"gate": [種類, 数], "count": 枚数, "endless": なくならないか}
## カード1枚が強化1段。取ったカードは山札から抜ける。強化に上限があるものは、枚数を上限に合わせる
## HP・威力・剣のダメージ・掛け算はなくならないカードで、枚数は出やすさの重み
const GATE_CARDS := [
	{"gate": [Gate.Op.ADD, 10], "count": 6, "endless": true},
	{"gate": [Gate.Op.ADD, 5], "count": 4, "endless": true},
	{"gate": [Gate.Op.ADD, 20], "count": 2, "endless": true},
	{"gate": [Gate.Op.ADD, -5], "count": 3, "endless": true},
	{"gate": [Gate.Op.ADD, -10], "count": 3, "endless": true},
	{"gate": [Gate.Op.ADD, -15], "count": 1, "endless": true},
	{"gate": [Gate.Op.MULTIPLY, 2], "count": 4, "endless": true},
	{"gate": [Gate.Op.MULTIPLY, 3], "count": 1, "endless": true},
	{"gate": [Gate.Op.POWER, 1], "count": 4, "endless": true},
	{"gate": [Gate.Op.POWER, 2], "count": 1, "endless": true},
	{"gate": [Gate.Op.FIRE_RATE, 1], "count": PlayerStats.MAX_FIRE_LEVEL},
	{"gate": [Gate.Op.SWORD, 1], "count": 7},
	{"gate": [Gate.Op.SWORD_DAMAGE, 1], "count": 3, "endless": true},
	{"gate": [Gate.Op.SWORD_RETARGET, 1], "count": 1},
]
## ゲートの列は、プレイヤーのこの距離（m）先に入ったら山札から引いて出す（カメラから見える遠さくらい）
const DEAL_AHEAD := 90.0
const ROAD_BEHIND := 10.0
const ROAD_AHEAD := 60.0
## 床に引く小節の線の太さと色。セクションの始まりは、BAR_LINE_GAP だけ手前にもう1本引き、
## 円の UI と同じく盛り上がりで色を変える
const BAR_LINE_WIDTH := 0.12
const BAR_LINE_GAP := 0.5
const BAR_LINE_COLOR := Color(1, 1, 1, 0.35)
## 拍ごとの線は、小節の線より細く薄くする
const BEAT_LINE_WIDTH := 0.06
const BEAT_LINE_COLOR := Color(1, 1, 1, 0.15)
## セクションが分からない曲で、敵を並べるときに使う盛り上がり（中くらい）
const UNKNOWN_ENERGY := 0.5
const MESSAGES := {
	Judge.Result.CLEARED: "CLEAR!",
	Judge.Result.GAME_OVER: "GAME OVER",
}

## 曲のファイル。見つからなければ曲なしで、course_length の長さを時間だけで進む
@export_file("*.mp3", "*.ogg", "*.wav") var song_path := "res://music/tropic_love.mp3"
## 曲のBPM。弾はこの拍に合わせて撃つ（Tropic Love は 105）
## 曲の隣に「曲の名前.beats.json」（tools/analyze.py で作る）があれば、そちらのBPMと最初の拍の時刻を使う
## 小節やセクションも、その JSON から読んで右上の円に表示する
@export var bpm := 105.0
@export var forward_speed := 6.0
@export var course_length := 150.0
## z: スタートからの距離、gates: 左から順にゲートの [種類, 数]、enemies: 敵の [左端のレーン番号, HP, 占めるレーン数（省略で 1）]
## 自動で並べるときは、サビの前などの小節（SongMap.boss_bars）に全部のレーンを埋めるボスを置く
## 空なら、コースの長さに合わせて自動で並べる
@export var layout: Array = []
## 自動で並べるときの乱数のシード。-1 なら遊ぶたびに変わる
@export var layout_seed := -1
## ゲートの山札に入れるカード（GATE_CARDS の形）
@export var gate_cards: Array = GATE_CARDS
@export var row_start := 20.0
@export var row_end_margin := 15.0
@export var enemy_start_hp := 5
## ボスの HP（中ボス1・中ボス2・最後のボス）。自動で並べるときの、数字の規模の基準
## ボスが少ない曲では後ろから順に当てる。ボスが無い曲では、最後の小節の線の敵を最後の値にする
## 敵の HP は、ボスで区切ったゾーンごとに、初めはなだらかに終わりに向けて加速して増える（GrowthCurve）
## ボスを越えるころにプレイヤーの数字の単位が変わる（k→m→b）くらいにしている（自動で遊ばせて大まかに決めた値）
## 最後の5億は、プレイヤーの HP が10億あればぶつかっても半分残る
@export var boss_hps: Array[int] = [2_000, 500_000, 500_000_000]
@export var lane_count := 3
@export var lane_width := 3.0

var song: AudioStream
## 音を出さないモード。曲は流さず、曲の長さだけ経過時間で進む（自動で遊ばせるときに使う）
var silent := false
## デバッグモード。床の小節・拍の線と成長曲線のグラフは、デバッグモードのときだけ見せる
var debug := false:
	set(value):
		debug = value
		_show_debug()
var _course: Course
var _clock: SongClock
var _lanes: Lanes
var _shot_grid: BeatGrid
var _map: SongMap
var _growth: GrowthCurve
## 並べ方と山札の乱数のシード。layout_seed が -1 なら遊ぶたびに決める
var _seed: int
var _deck: GateDeck
## まだ山札から引いていないゲートの列（{z, gate_count}、近い順）
var _undealt_gate_rows: Array = []
## 曲のパートの項目ごとの、鳴っている大きさと鳴った瞬間。剣はこれに合わせてためて撃つ
var _parts: PartTrack
var _result := Judge.Result.PLAYING

@onready var _player: Player = $Player
@onready var _camera: Camera3D = $Camera3D
@onready var _camera_offset := _camera.position
@onready var _message: Label = $UI/Message
@onready var _hint: Label = $UI/Hint
@onready var _music: AudioStreamPlayer = $Music
@onready var _beat_hud: BeatHud = $UI/BeatHud
@onready var _growth_graph: GrowthGraph = $UI/GrowthGraph
@onready var _part_hud: PartHud = $UI/PartHud


func _ready() -> void:
	_seed = layout_seed if layout_seed >= 0 else randi()
	if song == null:
		song = StemMix.load_song(song_path)
	if song != null:
		if silent:
			_clock = TimerClock.new(song.get_length())
		else:
			_music.stream = song
			_clock = MusicClock.new(_music)
		course_length = _clock.duration() * forward_speed
	else:
		_clock = TimerClock.new(course_length / forward_speed)
	_course = Course.new(forward_speed, course_length)
	_lanes = Lanes.new(lane_count, lane_width)
	_map = SongMap.from_json(_read_beside(".beats.json"), bpm)
	_parts = PartTrack.from_json(_read_beside(".parts.json"))
	_part_hud.track = _parts
	_shot_grid = _map.shot_grid()
	_beat_hud.beats_per_bar = _map.beats_per_bar
	_clock.start()
	$PauseMenu.quit_requested.connect(get_tree().quit)
	$PauseMenu.song_select_requested.connect(_back_to_song_select)
	$GoalLine.position.z = -course_length
	_fit_road()
	_draw_bar_lines()
	_draw_beat_lines()
	_show_debug()
	if layout.is_empty():
		layout = _build_layout()
	_deck = GateDeck.new(gate_cards, _seed)
	for row in layout:
		if row.has("gate_count"):
			_undealt_gate_rows.append(row)
		else:
			_spawn_row(row)
	_undealt_gate_rows.sort_custom(func(a, b): return a.z < b.z)
	_deal_near_gates()


func _process(delta: float) -> void:
	if _result != Judge.Result.PLAYING:
		return
	_clock.advance(delta)
	_course.seek(_clock.time())
	_player.shoot_on_beat(_clock.time(), _shot_grid)
	_player.play_swords(_clock.time(), _parts)
	var pos := _map.at(_clock.time())
	_player.dance(pos)
	_beat_hud.show_at(pos)
	_growth_graph.show_at(_clock.time(), _player.health.hp)
	_part_hud.show_at(_clock.time())
	_player.position.z = -_course.distance
	_deal_near_gates()
	_camera.position = _camera_offset + Vector3(0, 0, _player.position.z)
	_result = Judge.result(_course, _player.health)
	if _result != Judge.Result.PLAYING:
		_finish()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		debug = not debug
	elif _result != Judge.Result.PLAYING and event.is_action_pressed("ui_accept"):
		Main.start(get_tree(), song_path)


## path の曲で遊ぶゲームを作る
static func create(path: String) -> Main:
	var main: Main = load(MAIN_SCENE).instantiate()
	main.song_path = path
	return main


## 今の画面を、path の曲で遊ぶゲームに置き換える（曲を選んだときと、同じ曲でやり直すとき）
static func start(tree: SceneTree, path: String) -> void:
	tree.change_scene_to_node(create(path))


## 一時停止のメニューから、曲を選ぶ画面に戻る
func _back_to_song_select() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(SONG_SELECT_SCENE)


## レーンの中心の x（左から順）
func lane_xs() -> Array:
	return range(lane_count).map(func(i): return _lanes.x_of(i))


## 曲の今の時刻と、曲の組み立て、今の勝ち負け（自動で遊ばせて記録するときに使う）
func song_time() -> float:
	return _clock.time()


func gate_deck() -> GateDeck:
	return _deck


func song_map() -> SongMap:
	return _map


func result() -> Judge.Result:
	return _result


## デバッグモードかどうかに合わせて、床の線を見せたり隠したりする。線を引く前なら何もしない
func _show_debug() -> void:
	for node_name in ["BarLines", "BeatLines", "UI/GrowthGraph", "UI/PartHud"]:
		var node := get_node_or_null(node_name)
		if node != null:
			node.visible = debug


func _finish() -> void:
	_player.process_mode = Node.PROCESS_MODE_DISABLED
	if _result == Judge.Result.GAME_OVER:
		_music.stop()
	_message.text = MESSAGES[_result]
	_message.visible = true
	_hint.visible = true


## 曲の隣にある「曲の名前 + suffix」のファイルの中身。無ければ空
func _read_beside(suffix: String) -> String:
	var path := song_path.get_basename() + suffix
	if not FileAccess.file_exists(path):
		return ""
	return FileAccess.get_file_as_string(path)


## 道をスタートの後ろ（ROAD_BEHIND）からゴールの先（ROAD_AHEAD）まで伸ばす
func _fit_road() -> void:
	var road: PlaneMesh = $Road.mesh.duplicate()
	road.size.y = ROAD_BEHIND + course_length + ROAD_AHEAD
	$Road.mesh = road
	$Road.position.z = ROAD_BEHIND - road.size.y / 2.0


## 床に小節の線を引く。セクションの始まりは2本線にする
func _draw_bar_lines() -> void:
	var bar_lines := _add_line_group("BarLines")
	var bar_material := _line_material(BAR_LINE_COLOR)
	for line in _map.bar_lines(forward_speed, course_length / forward_speed):
		if not line.section_start:
			_add_line(bar_lines, line.distance, BAR_LINE_WIDTH, bar_material)
			continue
		var color := BeatHud.CALM_COLOR.lerp(BeatHud.HOT_COLOR, line.energy)
		var material := _line_material(color)
		_add_line(bar_lines, line.distance, BAR_LINE_WIDTH, material)
		_add_line(bar_lines, line.distance - BAR_LINE_GAP, BAR_LINE_WIDTH, material)


## 床に拍ごとの線を引く（小節の頭は小節の線があるので除く）
func _draw_beat_lines() -> void:
	var beat_lines := _add_line_group("BeatLines")
	var material := _line_material(BEAT_LINE_COLOR)
	for distance in _map.beat_lines(forward_speed, course_length / forward_speed):
		_add_line(beat_lines, distance, BEAT_LINE_WIDTH, material)


func _add_line_group(group_name: String) -> Node3D:
	var group := Node3D.new()
	group.name = group_name
	add_child(group)
	return group


func _add_line(parent: Node3D, distance: float, width: float, material: Material) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(lane_count * lane_width, 0.02, width)
	mesh.material = material
	var line := MeshInstance3D.new()
	line.mesh = mesh
	line.position = Vector3(0, 0.01, -distance)
	parent.add_child(line)


func _line_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _build_layout() -> Array:
	var seed_value := _seed
	var lines := _map.bar_lines(forward_speed, course_length / forward_speed)
	if _map.sections.is_empty():
		for line in lines:
			line.energy = UNKNOWN_ENERGY
	# 小節の線は 0 小節目から順に並ぶので、番号がそのまま小節になる
	var boss_bars := []
	for bar in _map.boss_bars():
		if bar >= 0 and bar < lines.size():
			lines[bar].boss = true
			boss_bars.append(bar)
	_growth = GrowthCurve.new(lines, enemy_start_hp, _growth_anchors(boss_bars, lines.size()))
	var tension := TensionCurve.new(lines)
	_setup_growth_graph(lines, tension)
	var wave := EnemyWave.new(lane_count, _growth, seed_value, tension)
	var builder := LayoutBuilder.new(wave, row_start, row_end_margin, seed_value)
	return builder.build(lines, course_length, _map.beats_per_bar)


## 規模の曲線の錨。ボスの小節の線で、ボスの HP が boss_hps の値（後ろから順）になるように、
## ふつうの敵の規模（ボスの HP ÷ BOSS_HP_RATE）を決める。ボスが無ければ、最後の小節の線で最後の値
func _growth_anchors(boss_bars: Array, line_count: int) -> Array:
	if boss_bars.is_empty():
		return [[line_count - 1, float(boss_hps.back())]]
	var anchors := []
	var hps := boss_hps.slice(maxi(boss_hps.size() - boss_bars.size(), 0))
	for i in mini(boss_bars.size(), hps.size()):
		var bar: int = boss_bars[boss_bars.size() - hps.size() + i]
		anchors.append([bar, float(hps[i]) / EnemyWave.BOSS_HP_RATE])
	return anchors


## デバッグモードの成長曲線のグラフに、小節ごとのふつうの敵の HP（規模 × 緊張の倍率）とボスの HP を渡す
func _setup_growth_graph(lines: Array, tension: TensionCurve) -> void:
	var curve_points := []
	var boss_points := []
	for line in lines:
		var time: float = line.distance / forward_speed
		var value := _growth.value_at(line.distance)
		curve_points.append(Vector2(time, value * tension.rate_at(line.distance)))
		if line.get("boss", false):
			boss_points.append(Vector2(time, value * EnemyWave.BOSS_HP_RATE))
	_growth_graph.setup(curve_points, boss_points, course_length / forward_speed)


## プレイヤーの DEAL_AHEAD 先までに入ったゲートの列を、山札から引いて出す
## 規模の曲線があれば（自動で並べたとき）、ゲートの数を置く位置に合わせて大きくする
func _deal_near_gates() -> void:
	while not _undealt_gate_rows.is_empty():
		var row: Dictionary = _undealt_gate_rows[0]
		if row.z > _course.distance + DEAL_AHEAD:
			return
		_undealt_gate_rows.pop_front()
		var cards := _deck.draw(row.gate_count)
		var gates := cards.map(
			func(card):
				var gate := _deck.gate_of(card)
				return _growth.scaled_gate(gate, row.z) if _growth != null else gate
		)
		var areas := _spawn_gates(row.z, gates)
		for i in areas.size():
			areas[i].taken.connect(_put_back_unchosen.bind(cards, cards[i]))


## ゲートの列のうち、取られなかったゲートのカードを山札に戻す
func _put_back_unchosen(_gate: Gate, cards: Array, chosen: int) -> void:
	for card in cards:
		if card != chosen:
			_deck.put_back(card)


## z の位置に、gates（[[種類, 数], ...]、左から順）のゲートを道の幅いっぱいに並べる
func _spawn_gates(z: float, gates: Array) -> Array:
	var pair := Node3D.new()
	pair.position.z = -z
	add_child(pair)
	var count := gates.size()
	var road_width := lane_count * lane_width
	var slots := Lanes.new(count, road_width / count)
	var areas := []
	for i in count:
		var gate_area: GateArea = GateScene.instantiate()
		gate_area.op = gates[i][0]
		gate_area.amount = gates[i][1]
		gate_area.width = slots.width
		gate_area.grid = _map.grid
		gate_area.stats = _player.stats
		gate_area.position.x = slots.x_of(i)
		pair.add_child(gate_area)
		areas.append(gate_area)
	return areas


func _spawn_row(row: Dictionary) -> void:
	var z := -float(row.z)
	if row.has("gates"):
		_spawn_gates(row.z, row.gates)
	for spec in row.get("enemies", []):
		var enemy: Enemy = EnemyScene.instantiate()
		enemy.start_hp = spec[1]
		enemy.clock = _clock
		enemy.grid = _map.grid
		# 3つめは占めるレーンの数（無ければ 1）。占めるレーンのまんなかに置く
		var wide: int = spec[2] if spec.size() > 2 else 1
		enemy.lanes_wide = wide
		var x := (_lanes.x_of(spec[0]) + _lanes.x_of(spec[0] + wide - 1)) / 2.0
		enemy.position = Vector3(x, 0, z)
		add_child(enemy)
