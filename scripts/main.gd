class_name Main
extends Node3D

const GateScene := preload("res://scenes/gate.tscn")
const EnemyScene := preload("res://scenes/enemy.tscn")
const GATE_X := 2.0
## z: スタートからの距離、gates: 左右のゲートの [種類, 数]、enemies: 敵の [レーン番号, HP]
const DEFAULT_LAYOUT := [
	{"z": 12.0, "gates": [[Gate.Op.ADD, 10], [Gate.Op.ADD, -5]]},
	{"z": 25.0, "enemies": [[0, 5], [2, 5]]},
	{"z": 40.0, "gates": [[Gate.Op.MULTIPLY, 2], [Gate.Op.ADD, 5]]},
	{"z": 55.0, "enemies": [[0, 8], [1, 12], [2, 8]]},
	{"z": 70.0, "gates": [[Gate.Op.ADD, -10], [Gate.Op.MULTIPLY, 3]]},
	{"z": 85.0, "enemies": [[0, 20], [2, 15]]},
	{"z": 100.0, "gates": [[Gate.Op.ADD, 20], [Gate.Op.MULTIPLY, 2]]},
	{"z": 115.0, "enemies": [[0, 25], [1, 30], [2, 25]]},
	{"z": 130.0, "gates": [[Gate.Op.ADD, -15], [Gate.Op.ADD, 10]]},
	{"z": 142.0, "enemies": [[1, 40]]},
]
const MESSAGES := {
	Judge.Result.CLEARED: "CLEAR!",
	Judge.Result.GAME_OVER: "GAME OVER",
}

@export var forward_speed := 6.0
@export var course_length := 150.0
@export var layout: Array = DEFAULT_LAYOUT
@export var lane_count := 3
@export var lane_width := 3.0

var _course: Course
var _clock: SongClock
var _lanes: Lanes
var _result := Judge.Result.PLAYING

@onready var _player: Player = $Player
@onready var _camera: Camera3D = $Camera3D
@onready var _camera_offset := _camera.position
@onready var _message: Label = $UI/Message
@onready var _hint: Label = $UI/Hint


func _ready() -> void:
	_course = Course.new(forward_speed, course_length)
	_clock = TimerClock.new(course_length / forward_speed)
	_lanes = Lanes.new(lane_count, lane_width)
	$GoalLine.position.z = -course_length
	for row in layout:
		_spawn_row(row)


func _process(delta: float) -> void:
	if _result != Judge.Result.PLAYING:
		return
	_clock.advance(delta)
	_course.seek(_clock.time())
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
	_message.text = MESSAGES[_result]
	_message.visible = true
	_hint.visible = true


func _spawn_row(row: Dictionary) -> void:
	var z := -float(row.z)
	if row.has("gates"):
		var pair := Node3D.new()
		pair.position.z = z
		add_child(pair)
		for i in row.gates.size():
			var gate_area: GateArea = GateScene.instantiate()
			gate_area.op = row.gates[i][0]
			gate_area.amount = row.gates[i][1]
			gate_area.position.x = -GATE_X if i == 0 else GATE_X
			pair.add_child(gate_area)
	for spec in row.get("enemies", []):
		var enemy: Enemy = EnemyScene.instantiate()
		enemy.start_hp = spec[1]
		enemy.position = Vector3(_lanes.x_of(spec[0]), 0, z)
		add_child(enemy)
