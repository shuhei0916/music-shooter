extends CharacterBody3D

@export var bullet_scene: PackedScene
@export var horizontal_limit_min: float = -4.0
@export var horizontal_limit_max: float = 4.0

signal hp_changed(new_hp)
signal game_over_signal

var hp = 1:
	set(value):
		hp = value
		emit_signal("hp_changed", hp)

const SPEED = 5.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	clamp_horizontal_position()

func add_hp(amount):
	self.hp += amount

func multiply_hp(factor):
	self.hp *= factor

func apply_gate_effect(gate_type: String, value: int):
	match gate_type:
		"add":
			add_hp(value)
		"multiply":
			multiply_hp(value)
		_:
			printerr("Unknown gate_type: ", gate_type)

func clamp_horizontal_position():
	if horizontal_limit_min > horizontal_limit_max:
		var temp = horizontal_limit_min
		horizontal_limit_min = horizontal_limit_max
		horizontal_limit_max = temp
	var pos = position
	pos.x = clamp(pos.x, horizontal_limit_min, horizontal_limit_max)
	position = pos

func take_damage(damage):
	if hp > damage:
		self.hp -= damage
	else:
		self.hp = 0
		game_over()

func game_over():
	print("GAME OVER")
	emit_signal("game_over_signal")
