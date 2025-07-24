extends Node

signal spawn_object(object_scene, properties)

@export var enemy_scene: PackedScene
@export var gate_scene: PackedScene # We will create gate.tscn later

var spawn_timer: Timer

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.name = "SpawnTimer" # Give the timer a name
	spawn_timer.wait_time = 2.0 # Spawn every 2 seconds
	spawn_timer.autostart = true
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	add_child(spawn_timer)

func _on_spawn_timer_timeout():
	# Randomly decide to spawn an enemy or a gate
	if randf() > 0.5:
		spawn_enemy()
	else:
		spawn_gate()

func spawn_enemy():
	var lane = randi_range(0, 2) # 0: left, 1: center, 2: right
	var x_pos = (lane - 1) * 3.0 # -3, 0, 3
	
	var properties = {
		"hp": randi_range(5, 30),
		"position": Vector3(x_pos, 1, -40)
	}
	emit_signal("spawn_object", enemy_scene, properties)

func spawn_gate():
	var lane = randi_range(0, 2)
	var x_pos = (lane - 1) * 3.0
	
	var gate_type = "add" if randf() > 0.5 else "multiply"
	var value = randi_range(5, 20) if gate_type == "add" else randi_range(2, 3)
	
	var properties = {
		"type": gate_type,
		"value": value,
		"position": Vector3(x_pos, 1, -40)
	}
	emit_signal("spawn_object", gate_scene, properties)
