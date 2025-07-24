extends Node

signal spawn_object(object_scene, properties)

@export var enemy_scene: PackedScene
@export var gate_scene: PackedScene

var spawn_timer: Timer

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.name = "SpawnTimer" # Give the timer a name
	spawn_timer.wait_time = 2.0 # Spawn every 2 seconds
	spawn_timer.autostart = true
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	add_child(spawn_timer)

var spawn_counter = 0

func _on_spawn_timer_timeout():
	spawn_counter += 1
	
	# Every 4th spawn, do a full row spawn
	if spawn_counter % 4 == 0:
		spawn_full_row()
	else:
		# Randomly decide to spawn an enemy or a gate
		if randf() > 0.5:
			spawn_enemy()
		else:
			spawn_gate()

func spawn_enemy(lane = -1):
	if lane == -1:
		lane = randi_range(0, 2) # 0: left, 1: center, 2: right
	var x_pos = (lane - 1) * 3.0 # -3, 0, 3
	
	var properties = {
		"hp": randi_range(5, 30),
		"position": Vector3(x_pos, 1, -40)
	}
	emit_signal("spawn_object", enemy_scene, properties)

func spawn_gate(lane = -1):
	if lane == -1:
		lane = randi_range(0, 2)
	var x_pos = (lane - 1) * 3.0
	
	var gate_type = "add" if randf() > 0.5 else "multiply"
	var value = randi_range(5, 20) if gate_type == "add" else randi_range(2, 3)
	
	var properties = {
		"type": gate_type,
		"value": value,
		"position": Vector3(x_pos, 1, -40)
	}
	emit_signal("spawn_object", gate_scene, properties)

func spawn_full_row():
	# Decide if the row will be enemies or gates
	var is_enemy_row = randf() > 0.5
	
	for i in range(3): # For each of the 3 lanes
		if is_enemy_row:
			spawn_enemy(i)
		else:
			spawn_gate(i)
