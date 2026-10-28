class_name GateArea
extends Area3D

const FloatingTextScene := preload("res://scenes/floating_text.tscn")
## 取ったときに飛び出す文字の、プレイヤーの足もとからの高さ
const POPUP_HEIGHT := 3.2

@export var op := Gate.Op.ADD
@export var amount := 1
@export var width := 4.0
@export var good_color := Color(0.3, 0.7, 1, 0.45)
@export var harmful_color := Color(1, 0.3, 0.3, 0.45)

var _gate: Gate
var _color: Color
var _used := false


func _ready() -> void:
	_gate = Gate.new(op, amount)
	$Label.text = _gate.label()
	_color = harmful_color if _gate.is_harmful() else good_color
	var material: StandardMaterial3D = $Panel.mesh.material.duplicate()
	material.albedo_color = _color
	$Panel.material_override = material
	var frame_material := StandardMaterial3D.new()
	frame_material.albedo_color = Color(_color, 1.0)
	for part: MeshInstance3D in $Frame.get_children():
		part.material_override = frame_material
	_apply_width()
	area_entered.connect(_on_area_entered)


## 当たり判定・パネル・枠を、幅に合わせる。リソースは他のゲートと共有しているので複製する
func _apply_width() -> void:
	var shape: BoxShape3D = $CollisionShape3D.shape.duplicate()
	shape.size.x = width
	$CollisionShape3D.shape = shape
	var panel: BoxMesh = $Panel.mesh.duplicate()
	panel.size.x = width - 0.4
	$Panel.mesh = panel
	$Frame/PostLeft.position.x = -(width / 2.0 - 0.15)
	$Frame/PostRight.position.x = width / 2.0 - 0.15


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
	_gate.apply(player.stats)
	var popup: FloatingText = FloatingTextScene.instantiate()
	popup.text = _gate.label()
	popup.modulate = Color(_color, 1.0)
	popup.position.y = POPUP_HEIGHT
	player.add_child(popup)
	queue_free()


static func _distance_x(a: Node3D, b: Node3D) -> float:
	return absf(a.global_position.x - b.global_position.x)
