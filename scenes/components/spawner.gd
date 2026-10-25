extends Node

const Inflation = preload("res://scripts/inflation.gd")

const CHEST_SPAWN_OFFSET_Z := -5.0
## 5ターン周期のうち、ゲート列（0ターン目）の間に逃げられない敵の列を出すターン
const ENEMY_ROW_TURN := 3
## 敵の列の3体のHPの倍率（弱・中・強のどれに突っ込むかを選ばせる）。レーンへの割り当てはシャッフルする
const ENEMY_ROW_HP_FACTORS: Array[float] = [0.5, 1.0, 2.0]

@export var gate_scene: PackedScene
@export var enemy_scene: PackedScene
@export var chest_scene: PackedScene
@export var enemy_spawn_probability: float = 0.1
## ゲート列のうちレベルアップ以外のゲートがマイナスになる確率（1列に必ずレベルアップゲートがあるので、全部がマイナスにはならない）
@export_range(0.0, 1.0) var minus_gate_probability: float = 0.3
## 曲の終わり（進み具合1）でゲートの値・敵のHP・弾のダメージに掛かる倍率
@export var inflation_end_scale: float = 1e8
@export_range(1, 100) var enemy_hp_min: int = 5
@export_range(1, 100) var enemy_hp_max: int = 20

var spawn_counter := 0
var markers: Array = []
var _growth_curve := PackedVector2Array()
var _weapon_colors: Dictionary = {}  # チャンネル -> 武器の色

@onready var anchor_root: Node3D = $AnchorRoot
@onready var spawn_timer: Timer = $SpawnTimer
@onready var main_scene: Node = get_parent()


func _ready() -> void:
	if anchor_root:
		markers = anchor_root.get_children()


func start() -> void:
	spawn_timer.start()


func stop() -> void:
	spawn_timer.stop()


func set_growth_curve(points: PackedVector2Array) -> void:
	_growth_curve = points


func set_weapon_colors(weapon_colors: Dictionary) -> void:
	_weapon_colors = weapon_colors


func _on_spawn_timer_timeout() -> void:
	spawn_counter += 1
	if spawn_counter % 5 == 0:
		_spawn_gate_row()
	# HP1のまま逃げられない列に当たらないよう、敵の列は最初のゲート列の後から出す
	elif spawn_counter % 5 == ENEMY_ROW_TURN and spawn_counter > 5:
		_spawn_enemy_row()
	else:
		_maybe_spawn_enemy()


func _spawn_gate_row() -> void:
	if markers.is_empty():
		return
	var level_up_index := randi() % markers.size()
	for i in markers.size():
		var gate = gate_scene.instantiate()
		gate.global_transform = markers[i].global_transform
		if i == level_up_index:
			_set_level_up_gate_properties(gate)
		else:
			_set_gate_properties(gate, _get_spawn_progress())
		main_scene.add_child(gate)


func _set_gate_properties(gate: Node, progress: float = -1.0) -> void:
	gate.gate_type = "add"
	gate.value = roundi(randi_range(5, 20) * _inflation_scale(progress))
	if randf() < minus_gate_probability:
		gate.value = -gate.value


func _set_level_up_gate_properties(gate: Node) -> void:
	gate.gate_type = "level_up"
	if not _weapon_colors.is_empty():
		var channel: int = _weapon_colors.keys().pick_random()
		gate.value = channel
		gate.weapon_color = _weapon_colors[channel]


func _maybe_spawn_enemy() -> void:
	if enemy_scene == null:
		return
	if randf() < enemy_spawn_probability:
		_spawn_enemy()


func _spawn_enemy_row() -> void:
	var factors := ENEMY_ROW_HP_FACTORS.duplicate()
	factors.shuffle()
	for i in markers.size():
		var enemy = _spawn_enemy_at(markers[i])
		enemy.hp = maxi(1, roundi(enemy.hp * factors[i % factors.size()]))


func _spawn_enemy() -> void:
	_spawn_enemy_at(_pick_random_marker())


func _spawn_enemy_at(marker: Marker3D) -> Node:
	var enemy = enemy_scene.instantiate()
	enemy.global_transform = marker.global_transform
	_set_enemy_properties(enemy, _get_spawn_progress())
	enemy.died.connect(_on_enemy_died.bind(enemy))
	main_scene.add_child(enemy)
	return enemy


func _on_enemy_died(enemy: Node) -> void:
	if chest_scene == null:
		return
	var chest = chest_scene.instantiate()
	chest.gate_type = "add"
	chest.value = randi_range(5, 20)
	main_scene.add_child(chest)
	chest.global_position = enemy.global_position + Vector3(0, 0, CHEST_SPAWN_OFFSET_Z)


## progressが負（成長曲線なし）なら倍率1
func _inflation_scale(progress: float) -> float:
	return Inflation.scale_at(maxf(progress, 0.0), inflation_end_scale)


func _pick_random_marker() -> Marker3D:
	if markers:
		return markers[randi() % markers.size()]
	return null


func _set_enemy_properties(enemy: Node, progress: float = -1.0) -> void:
	var value: int
	if _growth_curve.is_empty() or progress < 0.0:
		value = randi_range(enemy_hp_min, enemy_hp_max)
	else:
		value = int(lerp(float(enemy_hp_min), float(enemy_hp_max), progress))
	enemy.hp = value


func _get_spawn_progress() -> float:
	if _growth_curve.is_empty() or _growth_curve[-1].y == 0.0:
		return -1.0
	var current_time: float = (
		main_scene.midi_player.position * main_scene.midi_player.timebase_to_seconds
	)
	var max_count: float = _growth_curve[-1].y
	for i in range(_growth_curve.size() - 1, -1, -1):
		if _growth_curve[i].x <= current_time:
			return _growth_curve[i].y / max_count
	return 0.0
