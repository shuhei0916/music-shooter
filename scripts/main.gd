class_name Main
extends Node3D

const MESSAGES := {
	Judge.Result.CLEARED: "CLEAR!",
	Judge.Result.GAME_OVER: "GAME OVER",
}

@export var forward_speed := 6.0
@export var course_length := 150.0

var _course: Course
var _result := Judge.Result.PLAYING

@onready var _player: Player = $Player
@onready var _camera: Camera3D = $Camera3D
@onready var _camera_offset := _camera.position
@onready var _message: Label = $UI/Message
@onready var _hint: Label = $UI/Hint


func _ready() -> void:
	_course = Course.new(forward_speed, course_length)


func _process(delta: float) -> void:
	if _result != Judge.Result.PLAYING:
		return
	_course.advance(delta)
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
