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
	var color := harmful_color if _gate.is_harmful() else good_color
	var material: StandardMaterial3D = $Panel.mesh.material.duplicate()
	material.albedo_color = color
	$Panel.material_override = material
	var frame_material := StandardMaterial3D.new()
	frame_material.albedo_color = Color(color, 1.0)
	for part: MeshInstance3D in $Frame.get_children():
		part.material_override = frame_material
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area3D) -> void:
	if _used or not area is Player:
		return
	# 同じ距離なら先に並んでいる（左の）ゲートを選ぶ
	var nearest: GateArea = null
	for sibling in get_parent().get_children():
		if sibling is GateArea:
			sibling.close()
			if nearest == null or _distance_x(sibling, area) < _distance_x(nearest, area):
				nearest = sibling
	nearest.give_to(area)


func close() -> void:
	_used = true


func give_to(player: Player) -> void:
	player.health.hp = _gate.apply(player.health.hp)
	queue_free()


static func _distance_x(a: Node3D, b: Node3D) -> float:
	return absf(a.global_position.x - b.global_position.x)
