extends Node3D

const WORLD_SPEED = 5.0

var player

func _ready():
	player = get_node("Player")
	player.hp_changed.connect(_on_player_hp_changed)
	
	# Add existing grounds to world_objects group
	for ground in get_tree().get_nodes_in_group("Ground"):
		ground.add_to_group("world_objects")

	# Create Gates
	create_gate("add", 10, Vector3(-2, 1, -10))
	create_gate("multiply", 2, Vector3(2, 1, -20))

	# Create Light
	var light = DirectionalLight3D.new()
	light.transform.basis = Basis.from_euler(Vector3(deg_to_rad(-30), deg_to_rad(-45), 0))
	light.transform.origin = Vector3(0, 4, 0)
	add_child(light)

	# Create Camera
	var camera = Camera3D.new()
	camera.transform.origin = Vector3(0, 5, 10)
	camera.look_at(Vector3.ZERO)
	add_child(camera)

func create_gate(type, value, position):
	var gate = Area3D.new()
	gate.add_to_group("world_objects")
	gate.set_script(load("res://gate.gd"))
	gate.gate_type = type
	gate.value = value
	gate.transform.origin = position
	
	var gate_shape = CollisionShape3D.new()
	gate_shape.shape = BoxShape3D.new()
	gate_shape.shape.size = Vector3(2, 2, 0.2)
	gate.add_child(gate_shape)
	
	# You can set a mesh for the gate here, e.g., a BoxMesh
	var gate_mesh = MeshInstance3D.new()
	gate_mesh.mesh = BoxMesh.new()
	gate_mesh.mesh.size = Vector3(2, 2, 0.2)
	gate.add_child(gate_mesh)
	
	# Create Value Label
	var value_label = Label3D.new()
	var prefix = "+" if type == "add" else "x"
	value_label.text = prefix + str(value)
	value_label.transform.origin = Vector3(0, 0, 0.2) # Position in front of the gate
	value_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	value_label.font_size = 96
	gate.add_child(value_label)
	
	add_child(gate)
	gate.player_entered_gate.connect(_on_player_entered_gate)

func _on_player_entered_gate(gate_type, value):
	if player:
		if gate_type == "add":
			player.add_characters(value)
		elif gate_type == "multiply":
			player.multiply_characters(value)

func _on_player_hp_changed(new_hp):
	var hp_label = player.get_node("HPLabel")
	if hp_label:
		hp_label.text = str(new_hp)

func _process(delta):
	for obj in get_tree().get_nodes_in_group("world_objects"):
		obj.global_translate(Vector3(0, 0, WORLD_SPEED * delta))
		
		# Reposition ground
		if obj.is_in_group("Ground"):
			if obj.global_transform.origin.z > 100:
				obj.global_transform.origin.z -= 300
