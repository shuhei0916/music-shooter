class_name Weapon
extends Node3D

@export var channel: int = 0
@export var color: Color = Color.WHITE
@export var level: int = 1


func is_on_grid(tick: int, timebase: int) -> bool:
	return tick % (timebase * 4) == 0


func fire() -> void:
	pass


func trigger_flash() -> void:
	pass
