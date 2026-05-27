extends CharacterBody3D

signal game_over_signal

const SPEED = 5.0

@export var horizontal_limit_min: float = -4.0
@export var horizontal_limit_max: float = 4.0

var hp = 1:
	set(value):
		hp = value
		_update_hp_label()

var _weapons: Array = []


func _ready() -> void:
	_weapons = get_children().filter(func(n): return n.is_in_group("weapon"))


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
			self.hp += value
		"multiply":
			self.hp *= value


func clamp_horizontal_position():
	position.x = clamp(position.x, horizontal_limit_min, horizontal_limit_max)


func take_damage(damage):
	self.hp -= damage
	if self.hp <= 0:
		game_over()


func game_over():
	print("GAME OVER")
	emit_signal("game_over_signal")


func _update_hp_label() -> void:
	var label := get_node_or_null("HPLabel")
	if label:
		label.text = str(hp)


func _on_enemy_collided(enemy: Node) -> void:
	var player_hp_before = hp

	take_damage(enemy.hp)
	enemy.take_damage(player_hp_before)


func shoot(channel: int = 0) -> void:
	if channel >= _weapons.size():
		return
	_weapons[channel].fire()
