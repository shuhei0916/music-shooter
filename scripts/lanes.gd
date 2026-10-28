class_name Lanes
extends RefCounted

var count: int
var width: float


func _init(p_count: int, p_width: float) -> void:
	count = p_count
	width = p_width


func x_of(lane: int) -> float:
	return (lane - (count - 1) / 2.0) * width
