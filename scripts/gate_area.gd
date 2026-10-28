class_name GateArea
extends Area3D

@export var op := Gate.Op.ADD
@export var amount := 1
@export var good_color := Color(0.3, 0.7, 1, 0.45)
@export var harmful_color := Color(1, 0.3, 0.3, 0.45)

var _gate: Gate
var _used := false


func _ready() -> void:
	_gate = Gate.new(op, amount)
	$Label.text = _gate.label()
	var material: StandardMaterial3D = $Panel.mesh.material.duplicate()
	material.albedo_color = harmful_color if _gate.is_harmful() else good_color
	$Panel.material_override = material
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area3D) -> void:
	if _used or not area is Player:
		return
	_used = true
	area.health.hp = _gate.apply(area.health.hp)
