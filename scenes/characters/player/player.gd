extends CharacterBody3D

@export var bullet_scene: PackedScene

signal hp_changed(new_hp)
signal game_over_signal

var character_count = 1:
	set(value):
		character_count = value
		emit_signal("hp_changed", character_count)

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func add_hp(amount):
	self.character_count += amount

func multiply_hp(factor):
	self.character_count *= factor

func apply_gate_effect(gate_type: String, value: int):
	match gate_type:
		"add":
			add_hp(value)
		"multiply":
			multiply_hp(value)
		_:
			printerr("Unknown gate_type: ", gate_type)

func take_damage(damage):
	if character_count > damage:
		self.character_count -= damage
	else:
		self.character_count = 0
		game_over()

func game_over():
	print("GAME OVER")
	emit_signal("game_over_signal")

enum WeaponType { HANDGUN, MELEE, LASER }

var enabled_weapons = {
	WeaponType.HANDGUN: true,
	WeaponType.MELEE: false,
	WeaponType.LASER: true
}

func set_weapon_enabled(weapon_type: WeaponType, is_enabled: bool):
	if enabled_weapons.has(weapon_type):
		enabled_weapons[weapon_type] = is_enabled
		print("Weapon %s is now %s" % [WeaponType.keys()[weapon_type], "enabled" if is_enabled else "disabled"])
	else:
		printerr("Tried to set status for an unknown weapon type.")

func attack(channel_num):
	var weapon_type
	if channel_num == 9:
		weapon_type = WeaponType.MELEE
	elif channel_num == 4:
		weapon_type = WeaponType.HANDGUN
	elif channel_num >= 10:
		weapon_type = WeaponType.LASER

	if not enabled_weapons.get(weapon_type, false):
		return

	match weapon_type:
		WeaponType.HANDGUN:
			_attack_handgun()
		WeaponType.MELEE:
			_attack_melee()
		WeaponType.LASER:
			_attack_laser()

func _attack_handgun():
	if not bullet_scene:
		printerr("bullet_scene が未設定です")
		return

	var bullet = bullet_scene.instantiate()
	var main_node = get_tree().get_root().get_node("Main")
	if main_node:
		main_node.add_child(bullet)
		bullet.global_transform = self.global_transform
		bullet.position.z -= 1.0
	else:
		printerr("Could not find Main node to add bullet.")

func _attack_melee():
	var melee_area = $MeleeAttackArea
	var melee_effect = $MeleeEffectMesh

	if melee_area:
		melee_area.monitoring = true
		if melee_effect:
			melee_effect.visible = true

		var timer = get_tree().create_timer(0.2)
		timer.timeout.connect(func():
			melee_area.monitoring = false
			if melee_effect:
				melee_effect.visible = false
		)
	else:
		printerr("MeleeAttackArea node not found. Please add it to the player scene.")

func _attack_laser():
	pass

func _on_melee_attack_area_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(10)
		print("Melee hit: ", body.name)
