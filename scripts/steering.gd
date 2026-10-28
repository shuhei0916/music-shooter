class_name Steering
extends RefCounted

var speed: float
var half_width: float


func _init(p_speed: float, p_half_width: float) -> void:
	speed = p_speed
	half_width = p_half_width


func next_x(x: float, axis: float, delta: float) -> float:
	return x + axis * speed * delta
