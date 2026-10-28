class_name Gate
extends RefCounted

enum Op { ADD, MULTIPLY, POWER, FIRE_RATE }

var op: Op
var amount: int


func _init(p_op: Op, p_amount: int) -> void:
	op = p_op
	amount = p_amount


func apply(stats: PlayerStats) -> void:
	match op:
		Op.MULTIPLY:
			stats.health.hp *= amount
		Op.POWER:
			stats.power += amount
		Op.FIRE_RATE:
			stats.raise_fire_level(amount)
		_:
			stats.health.hp += amount


func label() -> String:
	match op:
		Op.MULTIPLY:
			return "×%d" % amount
		Op.POWER:
			return "威力%+d" % amount
		Op.FIRE_RATE:
			return "連射UP"
		_:
			return "%+d" % amount


func is_harmful() -> bool:
	match op:
		Op.MULTIPLY:
			return amount < 1
		_:
			return amount < 0
