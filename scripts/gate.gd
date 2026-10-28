class_name Gate
extends RefCounted

enum Op { ADD, MULTIPLY }

var op: Op
var amount: int


func _init(p_op: Op, p_amount: int) -> void:
	op = p_op
	amount = p_amount


func apply(hp: int) -> int:
	match op:
		Op.MULTIPLY:
			return hp * amount
		_:
			return hp + amount


func label() -> String:
	match op:
		Op.MULTIPLY:
			return "×%d" % amount
		_:
			return "%+d" % amount


func is_harmful() -> bool:
	match op:
		Op.MULTIPLY:
			return amount < 1
		_:
			return amount < 0
