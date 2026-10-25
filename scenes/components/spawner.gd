extends Node

const Inflation = preload("res://scripts/inflation.gd")

const CHEST_SPAWN_OFFSET_Z := -5.0
## 5ターン周期のうち、ゲート列（0ターン目）の間に逃げられない敵の列を出すターン
const ENEMY_ROW_TURN := 3
## 敵の列の3体のHPの倍率（弱・中・強のどれに突っ込むかを選ばせる）。レーンへの割り当てはシャッフルする
const ENEMY_ROW_HP_FACTORS: Array[float] = [0.5, 1.0, 2.0]


## ゲートのノードを作らずに扱うゲートの中身（シミュレーターでも使う）
class GateSpec:
	var gate_type := "add"
	var value := 0
	var weapon_color := Color.WHITE


@export var gate_scene: PackedScene
@export var enemy_scene: PackedScene
@export var chest_scene: PackedScene
@export var enemy_spawn_probability: float = 0.1
## 加算ゲートの値の基本の範囲（インフレ倍率を掛ける前）。難易度はtests/unit/test_balance.gdで確かめる
@export var gate_value_min: int = 20
@export var gate_value_max: int = 60
## ゲート列のうちレベルアップ以外のゲートがマイナスになる確率（1列に必ずレベルアップゲートがあるので、全部がマイナスにはならない）
@export_range(0.0, 1.0) var minus_gate_probability: float = 0.3
## ゲート列のうちレベルアップ以外のゲートが乗算ゲート（×2か×3）になる確率。積み重ねで序盤の選択が最後まで効く
@export_range(0.0, 1.0) var multiply_gate_probability: float = 0.15
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
	match turn_kind(spawn_counter):
		"gate_row":
			_spawn_gate_row()
		"enemy_row":
			_spawn_enemy_row()
		_:
			_maybe_spawn_enemy()


## turn（1始まり）に何を出すか: "gate_row"、"enemy_row"、"single"（確率で敵1体）
func turn_kind(turn: int) -> String:
	if turn % 5 == 0:
		return "gate_row"
	# HP1のまま逃げられない列に当たらないよう、敵の列は最初のゲート列の後から出す
	if turn % 5 == ENEMY_ROW_TURN and turn > 5:
		return "enemy_row"
	return "single"


func _spawn_gate_row() -> void:
	var specs := gate_row_specs(spawn_counter, _get_spawn_progress(), markers.size())
	for i in markers.size():
		var gate = gate_scene.instantiate()
		gate.global_transform = markers[i].global_transform
		gate.gate_type = specs[i].gate_type
		gate.value = specs[i].value
		gate.weapon_color = specs[i].weapon_color
		main_scene.add_child(gate)


## turnに出すゲート列の各レーンのゲートの中身。1つがレベルアップゲート、残りは加算か乗算。
## 最初のゲート列には、HP1のまま次の敵の列で運悪く死なないよう、プラスの加算ゲートを1つ含める
func gate_row_specs(turn: int, progress: float, lane_count: int) -> Array[GateSpec]:
	var specs: Array[GateSpec] = []
	var level_up_index := randi() % lane_count
	var plus_index := (level_up_index + 1) % lane_count if _is_first_gate_row(turn) else -1
	for i in lane_count:
		var spec := GateSpec.new()
		if i == level_up_index:
			_set_level_up_gate_properties(spec)
		elif i == plus_index:
			_set_plus_gate_properties(spec, progress)
		else:
			_set_gate_properties(spec, progress)
		specs.append(spec)
	return specs


func _is_first_gate_row(turn: int) -> bool:
	return range(1, turn).all(func(t): return turn_kind(t) != "gate_row")


func _set_gate_properties(gate: Object, progress: float = -1.0) -> void:
	if randf() < multiply_gate_probability:
		gate.gate_type = "multiply"
		gate.value = randi_range(2, 3)
		return
	_set_plus_gate_properties(gate, progress)
	if randf() < minus_gate_probability:
		gate.value = -gate.value


func _set_plus_gate_properties(gate: Object, progress: float) -> void:
	gate.gate_type = "add"
	gate.value = roundi(randi_range(gate_value_min, gate_value_max) * _inflation_scale(progress))


func _set_level_up_gate_properties(gate: Object) -> void:
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
	var hps := enemy_row_hps(_get_spawn_progress())
	for i in markers.size():
		var enemy = _spawn_enemy_at(markers[i])
		enemy.hp = hps[i % hps.size()]


## 敵の列の各レーンのHP。同じ基本のHPに、レーンごとにシャッフルした倍率を掛ける
func enemy_row_hps(progress: float) -> Array[int]:
	var base := randi_range(enemy_hp_min, enemy_hp_max) * _inflation_scale(progress)
	var factors := ENEMY_ROW_HP_FACTORS.duplicate()
	factors.shuffle()
	var hps: Array[int] = []
	for factor in factors:
		hps.append(maxi(1, roundi(base * factor)))
	return hps


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
	_set_chest_properties(chest, _get_spawn_progress())
	main_scene.add_child(chest)
	chest.global_position = enemy.global_position + Vector3(0, 0, CHEST_SPAWN_OFFSET_Z)


## 今の再生位置でのインフレ倍率
func current_inflation_scale() -> float:
	return _inflation_scale(_get_spawn_progress())


## progressが負（成長曲線なし）なら倍率1
func _inflation_scale(progress: float) -> float:
	return Inflation.scale_at(maxf(progress, 0.0), inflation_end_scale)


func _set_chest_properties(chest: Node, progress: float = -1.0) -> void:
	chest.gate_type = "add"
	chest.value = roundi(randi_range(5, 20) * _inflation_scale(progress))


func _pick_random_marker() -> Marker3D:
	if markers:
		return markers[randi() % markers.size()]
	return null


func _set_enemy_properties(enemy: Node, progress: float = -1.0) -> void:
	enemy.hp = roundi(randi_range(enemy_hp_min, enemy_hp_max) * _inflation_scale(progress))


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
