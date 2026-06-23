extends Area3D

@export var gate_type: String = "add"  # "add", "multiply"
@export var value: int = 1


func _ready():
	update_label()


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
				label.text = "❤️ +" + str(value)
			"multiply":
				label.text = "💕 x" + str(value)


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()
