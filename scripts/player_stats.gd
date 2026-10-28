class_name PlayerStats
extends RefCounted
## プレイヤーの能力値。HPは耐久力、威力と連射の段階は攻撃力

## 連射の段階の上限。0: 1拍に1発、1: 半拍に1発、2: 4分の1拍に1発
const MAX_FIRE_LEVEL := 2

var health: Health
var power := 1
var fire_level := 0


func _init(hp: int) -> void:
	health = Health.new(hp)


func raise_fire_level(amount: int) -> void:
	fire_level = mini(fire_level + amount, MAX_FIRE_LEVEL)


func beats_per_shot() -> float:
	return 1.0 / pow(2, fire_level)
