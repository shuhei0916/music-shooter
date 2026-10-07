extends GutTest

const SPAWNER_SCENE := preload("res://scenes/components/spawner.tscn")
var spawner


func before_each():
	spawner = SPAWNER_SCENE.instantiate()
	add_child_autofree(spawner)
	await get_tree().process_frame


func test_敵スポーン確率が100パーセントならゲート非発生ターンで敵が1体スポーンする():
	spawner.enemy_spawn_probability = 1.0
	spawner.spawn_counter = 0

	var enemies_before = get_tree().get_nodes_in_group("enemy").size()
	spawner._on_spawn_timer_timeout()
	var enemies_after = get_tree().get_nodes_in_group("enemy").size()

	assert_eq(enemies_before + 1, enemies_after)


func test_敵を倒すと宝箱がシーンに追加される():
	spawner.chest_scene = preload("res://scenes/objects/chest/chest.tscn")
	spawner.enemy_spawn_probability = 1.0
	spawner.spawn_counter = 0

	var enemies_before_spawn = get_tree().get_nodes_in_group("enemy").duplicate()
	spawner._on_spawn_timer_timeout()
	var new_enemies = get_tree().get_nodes_in_group("enemy").filter(
		func(e): return not enemies_before_spawn.has(e)
	)
	var enemy = new_enemies[0]

	var chests_before = get_tree().get_nodes_in_group("chest").size()
	enemy.take_damage(enemy.hp)
	var chests_after = get_tree().get_nodes_in_group("chest").size()
	assert_eq(chests_before + 1, chests_after)


func _spawn_gate_row() -> Array:
	spawner.spawn_counter = 4  # 次のタイムアウトがゲート列のターンになる
	spawner._on_spawn_timer_timeout()
	var gates = get_children().filter(func(n): return "gate_type" in n)
	for gate in gates:
		autofree(gate)
	return gates


func test_ゲート列のうち1つはレベルアップゲートになる():
	var gates = _spawn_gate_row()
	assert_eq(1, gates.filter(func(g): return g.gate_type == "level_up").size())


func test_レベルアップゲートの対象チャンネルは武器のあるチャンネルから選ばれる():
	spawner.set_weapon_colors({9: Color.ORANGE})
	var gates = _spawn_gate_row()
	var level_up_gate = gates.filter(func(g): return g.gate_type == "level_up")[0]
	assert_eq(9, level_up_gate.value)


func test_レベルアップゲートには対象武器の色が設定される():
	spawner.set_weapon_colors({9: Color.ORANGE})
	var gates = _spawn_gate_row()
	var level_up_gate = gates.filter(func(g): return g.gate_type == "level_up")[0]
	assert_eq(Color.ORANGE, level_up_gate.weapon_color)


func _player_body() -> Node:
	var player: Node = autofree(preload("res://scenes/characters/player/player.gd").new())
	player.add_to_group("player")
	return player


func test_ゲート列のうち1つを通ると同じ列の他のゲートは消える():
	var gates = _spawn_gate_row()
	gates[0]._on_body_entered(_player_body())
	assert_true(gates[1].is_queued_for_deletion())


func test_同じ列のゲートを通った後に別のゲートに触れても効果は得られない():
	var add_gates = _spawn_gate_row().filter(func(g): return g.gate_type == "add")
	var player := _player_body()
	add_gates[0]._on_body_entered(player)  # 同じフレームで2つのゲートに触れた場合
	var hp_after_first: int = player.hp
	add_gates[1]._on_body_entered(player)
	assert_eq(hp_after_first, player.hp)
