class_name Weapon
extends Node3D

@export var channel: int = 0
@export var color: Color = Color.WHITE
@export var level: int = 1


func is_on_grid(_tick: int, _timebase: int) -> bool:
	return true


func fire() -> void:
	pass


func trigger_flash() -> void:
	pass
