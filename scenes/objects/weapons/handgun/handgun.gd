class_name Handgun
extends "res://scenes/objects/weapons/weapon.gd"

@export var bullet_scene: PackedScene


func fire(container: Node) -> void:
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.color = color
	container.add_child(bullet)
	bullet.global_transform = $Muzzle.global_transform
