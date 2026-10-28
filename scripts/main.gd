class_name Main
extends Node3D

@export var forward_speed := 6.0
@export var course_length := 150.0

var _course: Course

@onready var _player: Player = $Player
@onready var _camera: Camera3D = $Camera3D
@onready var _camera_offset := _camera.position


func _ready() -> void:
	_course = Course.new(forward_speed, course_length)


func _process(delta: float) -> void:
	_course.advance(delta)
	_player.position.z = -_course.distance
	_camera.position = _camera_offset + Vector3(0, 0, _player.position.z)
