extends Area3D

const NumberFormat = preload("res://scripts/number_format.gd")
const MINUS_GATE_COLOR := Color.RED

@export var gate_type: String = "add"  # "add", "multiply", "level_up"
@export var value: int = 1
## レベルアップゲートの表示色（対象武器の色）
@export var weapon_color: Color = Color.WHITE


func _ready():
	update_label()
	if gate_type == "level_up":
		_apply_mesh_color(weapon_color)
	elif gate_type == "add" and value < 0:
		_apply_mesh_color(MINUS_GATE_COLOR)


func _on_body_entered(body: Node) -> void:
	if not body:
		return
	if body.is_in_group("player"):
		body.apply_gate_effect(gate_type, value)
		queue_free()


func update_label():
	var label = get_node("Pivot/Label3D")
	if label:
		match gate_type:
			"add":
				label.text = "❤️ " + ("+" if value >= 0 else "") + NumberFormat.abbreviate(value)
			"multiply":
				label.text = "💕 x" + str(value)
			"level_up":
				label.text = "🔫 Lv UP"


func _apply_mesh_color(color: Color) -> void:
	var mesh: MeshInstance3D = $Pivot/MeshInstance3D
	var material: StandardMaterial3D = mesh.get_active_material(0).duplicate()
	material.albedo_color = Color(color, material.albedo_color.a)
	mesh.set_surface_override_material(0, material)


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()
