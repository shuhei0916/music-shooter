extends Area3D

signal player_entered_gate(gate_type, value, gate_node)

@export var gate_type: String = "add" # "add", "multiply"
@export var value: int = 1

func _ready():
	update_label()

func _on_body_entered(body):
	print("hit")
	if body.is_in_group("player"):
		emit_signal("player_entered_gate", gate_type, value, self)

func set_gate_properties(type, val):
	gate_type = type
	value = val
	update_label()

func update_label():
	var label = get_node("Pivot/Label3D")
	if label:
		var text = ""
		match gate_type:
			"add":
				text = "❤️ +" + str(value)
			"multiply":
				text = "💕 x" + str(value)
			_:
				# Fallback for unknown types
				var prefix = "+" if gate_type == "add" else "x"
				text = prefix + str(value)
		label.text = text

func _process(delta):
	pass

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()
