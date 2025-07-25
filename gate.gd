extends Area3D

signal player_entered_gate(gate_type, value)

@export var gate_type: String = "add" # "add", "multiply"
@export var value: int = 1

var time = 0.0
const FLOAT_SPEED = 2.0
const FLOAT_AMOUNT = 0.2
const ROTATION_SPEED = 1.0

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	update_label()

func _on_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("player_entered_gate", gate_type, value)
		queue_free()

func set_gate_properties(type, val):
	gate_type = type
	value = val
	update_label()

func update_label():
	var label = get_node("Pivot/Label3D")
	if label:
		var prefix = "+" if gate_type == "add" else "x"
		label.text = prefix + str(value)

func _process(delta):
	time += delta
	
	var pivot = get_node("Pivot")
	if pivot:
		# Floating animation (up and down)
		var float_offset = sin(time * FLOAT_SPEED) * FLOAT_AMOUNT
		pivot.position.y = float_offset
		
		# Rotation animation
		pivot.rotate_y(ROTATION_SPEED * delta)
