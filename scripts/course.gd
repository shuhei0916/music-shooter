class_name Course
extends RefCounted

var speed: float
var length: float
var distance := 0.0


func _init(p_speed: float, p_length: float) -> void:
	speed = p_speed
	length = p_length


func advance(delta: float) -> void:
	distance = minf(distance + speed * delta, length)


func is_finished() -> bool:
	return distance >= length
