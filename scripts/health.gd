class_name Health
extends RefCounted

var hp: int


func _init(p_hp: int) -> void:
	hp = p_hp


func damage(amount: int) -> void:
	hp -= amount
