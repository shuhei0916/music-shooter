class_name Bullet
extends Area3D

@export var speed := 30.0


func _process(delta: float) -> void:
	position.z -= speed * delta
