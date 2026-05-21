class_name Bullet
extends Area3D

@export var damage: int = 1

var speed = 30.0


func _process(delta):
	position.z -= speed * delta


func _on_visible_on_screen_notifier_3d_screen_exited():
	queue_free()
