extends CharacterBody3D

signal game_over_signal

const NumberFormat = preload("res://scripts/number_format.gd")
const SPEED = 5.0

@export var horizontal_limit_min: float = -4.0
@export var horizontal_limit_max: float = 4.0

var hp = 1:
	set(value):
		hp = value
		_update_hp_label()

var _weapon_map: Dictionary = {}
var _last_fired_ticks: Dictionary = {}  # チャンネル -> 最後に発射したノートのtick


func _ready() -> void:
	_rebuild_weapon_map()


## 武器（子ノードの並び順）のチャンネルを付け替える。-1を指定した武器はチャンネルを変えない
func set_weapon_channels(channels: Array) -> void:
	var weapons := _weapons()
	for i in mini(channels.size(), weapons.size()):
		if channels[i] != -1:
			weapons[i].channel = channels[i]
	_rebuild_weapon_map()


func _weapons() -> Array:
	return get_children().filter(func(child): return child.is_in_group("weapon"))


func _rebuild_weapon_map() -> void:
	_weapon_map.clear()
	for weapon in _weapons():
		_weapon_map[weapon.channel] = weapon


func _physics_process(_delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	clamp_horizontal_position()


func apply_gate_effect(gate_type: String, value: int):
	match gate_type:
		"add":
			if value < 0:  # マイナスのゲート
				take_damage(-value)
			else:
				self.hp += value
		"multiply":
			self.hp *= value
		"level_up":  # valueは対象の武器のチャンネル
			var weapon = _weapon_map.get(value)
			if weapon:
				weapon.level += 1


func clamp_horizontal_position():
	position.x = clamp(position.x, horizontal_limit_min, horizontal_limit_max)


func take_damage(damage):
	self.hp -= damage
	if self.hp <= 0:
		game_over()


func game_over():
	print("GAME OVER")
	game_over_signal.emit()


func _update_hp_label() -> void:
	var label := get_node_or_null("HPLabel")
	if label:
		label.text = NumberFormat.abbreviate(hp)


func _on_enemy_collided(enemy: Node) -> void:
	var player_hp_before = hp

	take_damage(enemy.hp)
	enemy.take_damage(player_hp_before)


func get_weapon_channels() -> Array:
	return _weapon_map.keys()


func get_weapon_colors() -> Dictionary:
	var colors := {}
	for channel in _weapon_map:
		colors[channel] = _weapon_map[channel].color
	return colors


## 弾1発のダメージ（基本1）にインフレ倍率を掛ける
func set_damage_scale(scale: float) -> void:
	for weapon in _weapon_map.values():
		weapon.damage = maxi(1, roundi(scale))


func on_note(channel: int, tick: int, timebase: int) -> void:
	var weapon = _weapon_map.get(channel)
	if weapon == null or not weapon.is_on_grid(tick, timebase):
		return
	if _last_fired_ticks.get(channel) == tick:  # 同じtickの和音（キック＋ハイハット等）は1発にまとめる
		return
	_last_fired_ticks[channel] = tick
	weapon.fire()
