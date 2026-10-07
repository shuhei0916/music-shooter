extends Area3D

signal passed

@export var gate_type: String = "add"  # "add", "multiply", "level_up"
@export var value: int = 1
## レベルアップゲートの表示色（対象武器の色）
@export var weapon_color: Color = Color.WHITE


func _ready():
	update_label()
	if gate_type == "level_up":
		_apply_weapon_color()


func _on_body_entered(body: Node) -> void:
	if not body:
		return
	if body.is_in_group("player"):
		body.apply_gate_effect(gate_type, value)
		passed.emit()
		queue_free()


func update_label():
	var label = get_node("Pivot/Label3D")
	if label:
		match gate_type:
			"add":
				label.text = "❤️ +" + str(value)
			"multiply":
				label.text = "💕 x" + str(value)
			"level_up":
				label.text = "🔫 Lv UP"


func _apply_weapon_color() -> void:
	var mesh: MeshInstance3D = $Pivot/MeshInstance3D
	var material: StandardMaterial3D = mesh.get_active_material(0).duplicate()
	material.albedo_color = Color(weapon_color, material.albedo_color.a)
	mesh.set_surface_override_material(0, material)


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()
