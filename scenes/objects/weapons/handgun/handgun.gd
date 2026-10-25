class_name Handgun
extends Weapon

@export var bullet_scene: PackedScene


func fire() -> void:
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.color = color
	bullet.damage = damage
	get_tree().root.add_child(bullet)
	bullet.global_transform = $Muzzle.global_transform
