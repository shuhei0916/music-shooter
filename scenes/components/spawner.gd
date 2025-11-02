extends Node

signal spawn_object(object_scene, properties)

@export var enemy_scene: PackedScene
@export var gate_scene: PackedScene

const SPAWN_INTERVAL = 2.0
const SPAWN_DISTANCE = -40.0
const LANE_WIDTH = 3.0
const LANE_COUNT = 3

var randf_provider: Callable
var randi_range_provider: Callable

var spawn_timer: Timer

func _init():
	randf_provider = Callable(self, "_default_randf")
	randi_range_provider = Callable(self, "_default_randi_range")

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
		_spawn_full_row()
	else:
		if _randf() > 0.5:
			spawn_enemy()
		else:
			spawn_gate_row()

func spawn_enemy(lane = -1):
	if lane == -1:
		lane = _randi_range(0, LANE_COUNT - 1)
	var x_pos = (lane - 1) * LANE_WIDTH
	
	var properties = {
		"hp": _randi_range(5, 30),
		"position": Vector3(x_pos, 1, SPAWN_DISTANCE)
	}
	emit_signal("spawn_object", enemy_scene, properties)

func spawn_gate(lane = -1):
	if lane == -1:
		lane = _randi_range(0, LANE_COUNT - 1)
	var x_pos = (lane - 1) * LANE_WIDTH
	
	var gate_type = "add" if _randf() > 0.5 else "multiply"
	var value = _randi_range(5, 20) if gate_type == "add" else _randi_range(2, 3)
	
	var properties = {
		"type": gate_type,
		"value": value,
		"position": Vector3(x_pos, 1, SPAWN_DISTANCE)
	}
	emit_signal("spawn_object", gate_scene, properties)

func spawn_gate_row():
	for i in range(LANE_COUNT):
		spawn_gate(i)

func spawn_enemy_row():
	for i in range(LANE_COUNT):
		spawn_enemy(i)

func _spawn_full_row():
	if _randf() > 0.5:
		spawn_enemy_row()
	else:
		spawn_gate_row()

func _default_randf():
	return randf()

func _default_randi_range(min_val, max_val):
	return randi_range(min_val, max_val)

func _randf():
	return randf_provider.call()

func _randi_range(min_val, max_val):
	return randi_range_provider.call(min_val, max_val)
