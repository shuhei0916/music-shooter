class_name Health
extends RefCounted

var hp: int:
	set(value):
		hp = maxi(value, 0)


func _init(p_hp: int) -> void:
	hp = p_hp


func damage(amount: int) -> void:
	hp -= amount


func is_dead() -> bool:
	return hp == 0


func clash(other: Health) -> void:
	var amount := mini(hp, other.hp)
	damage(amount)
	other.damage(amount)
