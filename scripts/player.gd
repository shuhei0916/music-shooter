class_name Player
extends Area3D

@export var start_hp := 10
@export var side_speed := 8.0
@export var road_half_width := 4.0

var health: Health
var _steering: Steering


func _ready() -> void:
	health = Health.new(start_hp)
	_steering = Steering.new(side_speed, road_half_width)


func _process(delta: float) -> void:
	var axis := Input.get_axis("move_left", "move_right")
	position.x = _steering.next_x(position.x, axis, delta)
