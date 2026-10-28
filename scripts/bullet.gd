class_name Bullet
extends Area3D

@export var speed := 30.0
@export var max_range := 40.0
@export var damage := 1

var _traveled := 0.0


func _process(delta: float) -> void:
	var step := speed * delta
	position.z -= step
	_traveled += step
	if _traveled >= max_range:
		queue_free()
