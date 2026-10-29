class_name Main
extends Node3D

const GateScene := preload("res://scenes/gate.tscn")
const EnemyScene := preload("res://scenes/enemy.tscn")
## 山札に入れるゲートのカード。選択肢は2つか3つで、[[種類, 数], ...]
const GATE_CARDS := [
	[[Gate.Op.ADD, 10], [Gate.Op.ADD, -5]],
	[[Gate.Op.MULTIPLY, 2], [Gate.Op.ADD, 5]],
	[[Gate.Op.ADD, -10], [Gate.Op.MULTIPLY, 3]],
	[[Gate.Op.POWER, 1], [Gate.Op.ADD, 10]],
	[[Gate.Op.FIRE_RATE, 1], [Gate.Op.MULTIPLY, 2]],
	[[Gate.Op.POWER, 1], [Gate.Op.ADD, -5]],
	[[Gate.Op.ADD, 15], [Gate.Op.POWER, 1], [Gate.Op.FIRE_RATE, 1]],
	[[Gate.Op.MULTIPLY, 2], [Gate.Op.POWER, 2], [Gate.Op.ADD, -10]],
	[[Gate.Op.ADD, 20], [Gate.Op.ADD, -15], [Gate.Op.POWER, 1]],
]
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
## z: スタートからの距離、gates: 左から順にゲートの [種類, 数]、enemies: 敵の [レーン番号, HP]
## 空なら、コースの長さに合わせて自動で並べる
@export var layout: Array = []
## 自動で並べるときの乱数のシード。-1 なら遊ぶたびに変わる
@export var layout_seed := -1
@export var row_start := 20.0
@export var row_spacing := 12.0
@export var row_end_margin := 15.0
@export var enemy_start_hp := 5
## ゴールでの敵のHP。敵のHPはスタートからここまで一定の比率で増える
## 約700万にすると、コースの後半（後ろ半分）の敵のHPの平均が約100万になる
@export var enemy_goal_hp := 7_000_000
@export var lane_count := 3
@export var lane_width := 3.0

var song: AudioStream
var _course: Course
var _clock: SongClock
var _lanes: Lanes
var _grid: BeatGrid
var _map: SongMap
var _result := Judge.Result.PLAYING

@onready var _player: Player = $Player
@onready var _camera: Camera3D = $Camera3D
@onready var _camera_offset := _camera.position
@onready var _message: Label = $UI/Message
@onready var _hint: Label = $UI/Hint
@onready var _music: AudioStreamPlayer = $Music
@onready var _beat_hud: BeatHud = $UI/BeatHud


func _ready() -> void:
	if song == null and ResourceLoader.exists(song_path):
		song = load(song_path)
	if song != null:
		_music.stream = song
		_clock = MusicClock.new(_music)
		course_length = _clock.duration() * forward_speed
	else:
		_clock = TimerClock.new(course_length / forward_speed)
	_course = Course.new(forward_speed, course_length)
	_lanes = Lanes.new(lane_count, lane_width)
	_map = SongMap.from_json(_read_beats_json(), bpm)
	_grid = _map.grid
	_beat_hud.beats_per_bar = _map.beats_per_bar
	_clock.start()
	$PauseMenu.quit_requested.connect(get_tree().quit)
	$GoalLine.position.z = -course_length
	_fit_road()
	_draw_bar_lines()
	_draw_beat_lines()
	if layout.is_empty():
		layout = _build_layout()
	for row in layout:
		_spawn_row(row)


func _process(delta: float) -> void:
	if _result != Judge.Result.PLAYING:
		return
	_clock.advance(delta)
	_course.seek(_clock.time())
	_player.shoot_on_beat(_clock.time(), _grid)
	_beat_hud.show_at(_map.at(_clock.time()))
	_player.position.z = -_course.distance
	_camera.position = _camera_offset + Vector3(0, 0, _player.position.z)
	_result = Judge.result(_course, _player.health)
	if _result != Judge.Result.PLAYING:
		_finish()


func _unhandled_input(event: InputEvent) -> void:
	if _result != Judge.Result.PLAYING and event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()


func _finish() -> void:
	_player.process_mode = Node.PROCESS_MODE_DISABLED
	if _result == Judge.Result.GAME_OVER:
		_music.stop()
	_message.text = MESSAGES[_result]
	_message.visible = true
	_hint.visible = true


func _read_beats_json() -> String:
	var path := song_path.get_basename() + ".beats.json"
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
	var seed_value := layout_seed if layout_seed >= 0 else randi()
	var deck := GateDeck.new(GATE_CARDS, seed_value)
	var wave := EnemyWave.new(lane_count, enemy_start_hp, enemy_goal_hp, course_length, seed_value)
	var builder := LayoutBuilder.new(deck, wave, row_start, row_spacing, row_end_margin)
	return builder.build(course_length)


func _spawn_row(row: Dictionary) -> void:
	var z := -float(row.z)
	if row.has("gates"):
		var pair := Node3D.new()
		pair.position.z = z
		add_child(pair)
		var count: int = row.gates.size()
		var road_width := lane_count * lane_width
		var slots := Lanes.new(count, road_width / count)
		for i in count:
			var gate_area: GateArea = GateScene.instantiate()
			gate_area.op = row.gates[i][0]
			gate_area.amount = row.gates[i][1]
			gate_area.width = slots.width
			gate_area.position.x = slots.x_of(i)
			pair.add_child(gate_area)
	for spec in row.get("enemies", []):
		var enemy: Enemy = EnemyScene.instantiate()
		enemy.start_hp = spec[1]
		enemy.position = Vector3(_lanes.x_of(spec[0]), 0, z)
		add_child(enemy)
