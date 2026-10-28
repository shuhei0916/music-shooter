class_name PlayerStats
extends RefCounted
## プレイヤーの能力値。HPは耐久力、威力と連射の段階は攻撃力

var health: Health
var power := 1
var fire_level := 0


func _init(hp: int) -> void:
	health = Health.new(hp)
