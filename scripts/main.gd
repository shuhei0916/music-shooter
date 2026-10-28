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
const MESSAGES := {
	Judge.Result.CLEARED: "CLEAR!",
	Judge.Result.GAME_OVER: "GAME OVER",
}

## 曲のファイル。見つからなければ曲なしで、course_length の長さを時間だけで進む
@export_file("*.mp3", "*.ogg", "*.wav") var song_path := "res://music/tropic_love.mp3"
## 曲のBPM。弾はこの拍に合わせて撃つ（Tropic Love は 105）
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
@export var enemy_base_hp := 5
@export var enemy_hp_per_meter := 0.03
@export var lane_count := 3
@export var lane_width := 3.0

var song: AudioStream
var _course: Course
var _clock: SongClock
var _lanes: Lanes
var _grid: BeatGrid
var _result := Judge.Result.PLAYING

@onready var _player: Player = $Player
@onready var _camera: Camera3D = $Camera3D
@onready var _camera_offset := _camera.position
@onready var _message: Label = $UI/Message
@onready var _hint: Label = $UI/Hint
@onready var _music: AudioStreamPlayer = $Music


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
	_grid = BeatGrid.new(bpm)
	_clock.start()
	$PauseMenu.quit_requested.connect(get_tree().quit)
	$GoalLine.position.z = -course_length
	_fit_road()
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


## 道をスタートの後ろ（ROAD_BEHIND）からゴールの先（ROAD_AHEAD）まで伸ばす
func _fit_road() -> void:
	var road: PlaneMesh = $Road.mesh.duplicate()
	road.size.y = ROAD_BEHIND + course_length + ROAD_AHEAD
	$Road.mesh = road
	$Road.position.z = ROAD_BEHIND - road.size.y / 2.0


func _build_layout() -> Array:
	var seed_value := layout_seed if layout_seed >= 0 else randi()
	var deck := GateDeck.new(GATE_CARDS, seed_value)
	var wave := EnemyWave.new(lane_count, enemy_base_hp, enemy_hp_per_meter, seed_value)
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
