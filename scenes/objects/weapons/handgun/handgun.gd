class_name Handgun
extends "res://scenes/objects/weapons/weapon.gd"

@export var bullet_scene: PackedScene

@onready var _flash: OmniLight3D = $Muzzle/FlashLight


func fire() -> void:
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.color = color
	get_tree().root.add_child(bullet)
	bullet.global_transform = $Muzzle.global_transform


func trigger_flash() -> void:
	_flash.light_energy = 3.0
	var tween = create_tween()
	tween.tween_property(_flash, "light_energy", 0.0, 0.1)
