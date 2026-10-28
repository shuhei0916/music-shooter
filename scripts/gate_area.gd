class_name GateArea
extends Area3D

@export var op := Gate.Op.ADD
@export var amount := 1

var _gate: Gate
var _used := false


func _ready() -> void:
	_gate = Gate.new(op, amount)
	$Label.text = _gate.label()
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area3D) -> void:
	if _used or not area is Player:
		return
	_used = true
	area.health.hp = _gate.apply(area.health.hp)
