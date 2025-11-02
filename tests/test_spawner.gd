extends GutTest

class_name TestSpawner

var spawner
var emitted := []

func before_each():
	spawner = load("res://scenes/components/spawner.gd").new()
	spawner.enemy_scene = load("res://scenes/characters/enemy/enemy.tscn")
	spawner.gate_scene = load("res://scenes/objects/gate/gate.tscn")
	spawner.spawn_object.connect(_on_spawn_object)
	emitted.clear()

func after_each():
	spawner.queue_free()
	await get_tree().process_frame
	emitted.clear()

func _on_spawn_object(scene, properties):
	emitted.append({"scene": scene, "properties": properties})

func _set_rand_sources(rand_values := [], randi_values := []):
	var rand_queue = rand_values.duplicate()
	var randi_queue = randi_values.duplicate()

	spawner.randf_provider = func():
		if rand_queue.is_empty():
			return 0.0
		return rand_queue.pop_front()

	spawner.randi_range_provider = func(min_val, max_val):
		if randi_queue.is_empty():
			return min_val
		return randi_queue.pop_front()

func test_spawn_enemy_emits_expected_properties():
	_set_rand_sources([], [2, 12]) # lane index 2 (right), hp 12
	spawner.spawn_enemy()
	assert_eq(1, emitted.size())
	var record = emitted[0]
	assert_eq(spawner.enemy_scene, record["scene"])
	var props = record["properties"]
	assert_eq(Vector3((2 - 1) * 3, 1, -40), props["position"])
	assert_eq(12, props["hp"])

func test_spawn_gate_row_emits_three_gates():
	_set_rand_sources([0.7, 0.7, 0.7], [10, 11, 12]) # all add gates with deterministic values
	spawner.spawn_gate_row()
	assert_eq(3, emitted.size())
	for i in range(3):
		var record = emitted[i]
		assert_eq(spawner.gate_scene, record["scene"])
		var props = record["properties"]
		assert_eq(Vector3((i - 1) * 3, 1, -40), props["position"])
		assert_eq("add", props["type"])
		assert_eq(10 + i, props["value"])

func test_full_row_enemy_triggered_on_interval():
	_set_rand_sources([0.8], [9, 10, 11]) # one randf for deciding enemy row, randi for hp
	spawner.spawn_counter = 3 # so after increment it becomes 4
	spawner._on_spawn_timer_timeout()
	assert_eq(3, emitted.size())
	for i in range(3):
		var props = emitted[i]["properties"]
		assert_eq(Vector3((i - 1) * 3, 1, -40), props["position"])
	assert_eq([9, 10, 11], emitted.map(func(record): return record["properties"]["hp"]))

func test_non_interval_gate_spawns_full_row():
	_set_rand_sources([0.3, 0.6, 0.6, 0.6], [15, 16, 17]) 
	# First randf selects gate row because 0.3 <= 0.5, remaining for gate types (3 calls)
	spawner.spawn_counter = 1
	spawner._on_spawn_timer_timeout()
	assert_eq(3, emitted.size())
	var types = emitted.map(func(record): return record["properties"]["type"])
	assert_eq(["add", "add", "add"], types)

func test_non_interval_enemy_spawns_single_enemy():
	_set_rand_sources([0.9], [1, 25]) # lane, hp
	spawner.spawn_counter = 1
	spawner._on_spawn_timer_timeout()
	assert_eq(1, emitted.size())
	assert_eq(spawner.enemy_scene, emitted[0]["scene"])
