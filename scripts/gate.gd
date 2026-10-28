class_name Gate
extends RefCounted

enum Op { ADD }

var op: Op
var amount: int


func _init(p_op: Op, p_amount: int) -> void:
	op = p_op
	amount = p_amount


func apply(hp: int) -> int:
	return hp + amount
