extends Node

signal spawn_object(object_scene, properties)

@export var enemy_scene: PackedScene
@export var gate_scene: PackedScene

const SPAWN_INTERVAL = 2.0
const SPAWN_DISTANCE = -40.0
const LANE_WIDTH = 3.0

var spawn_timer: Timer

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.name = "SpawnTimer"
	spawn_timer.wait_time = SPAWN_INTERVAL
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	add_child(spawn_timer)
	# Don't start automatically

func start_spawning():
	spawn_timer.start()

func stop_spawning():
	spawn_timer.stop()

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
		lane = randi_range(0, 2)
	var x_pos = (lane - 1) * LANE_WIDTH
	
	var properties = {
		"hp": randi_range(5, 30),
		"position": Vector3(x_pos, 1, SPAWN_DISTANCE)
	}
	emit_signal("spawn_object", enemy_scene, properties)

func spawn_gate(lane = -1):
	if lane == -1:
		lane = randi_range(0, 2)
	var x_pos = (lane - 1) * LANE_WIDTH
	
	var gate_type = "add" if randf() > 0.5 else "multiply"
	var value = randi_range(5, 20) if gate_type == "add" else randi_range(2, 3)
	
	var properties = {
		"type": gate_type,
		"value": value,
		"position": Vector3(x_pos, 1, SPAWN_DISTANCE)
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
