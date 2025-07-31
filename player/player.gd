extends CharacterBody3D

const BULLET_SCENE = preload("res://bullet.tscn")

signal hp_changed(new_hp)
signal game_over_signal

var character_count = 1:
	set(value):
		character_count = value
		emit_signal("hp_changed", character_count)

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Lane-based movement
	handle_lane_movement(delta)
	
	move_and_slide()

var current_lane = 1 # 0: left, 1: center, 2: right
var target_x = 0.0
const LANE_WIDTH = 3.0
const LANE_MOVE_SPEED = 10.0

func handle_lane_movement(delta):
	if Input.is_action_just_pressed("ui_right") and current_lane < 2:
		current_lane += 1
	if Input.is_action_just_pressed("ui_left") and current_lane > 0:
		current_lane -= 1
	
	target_x = (current_lane - 1) * LANE_WIDTH
	
	# Smoothly move to the target lane
	global_transform.origin.x = lerp(global_transform.origin.x, target_x, LANE_MOVE_SPEED * delta)
	velocity.x = 0 # We handle movement directly via transform
	velocity.z = 0

func add_characters(amount):
	self.character_count += amount
	# print("Characters: ", character_count)

func multiply_characters(factor):
	self.character_count *= factor
	# print("Characters: ", character_count)

func take_damage(damage):
	if character_count > damage:
		self.character_count -= damage
	else:
		game_over()

func game_over():
	print("GAME OVER")
	emit_signal("game_over_signal")
	# The game over screen will now handle restarting

enum WeaponType { HANDGUN, MELEE, LASER }

var enabled_weapons = {
	WeaponType.HANDGUN: true,
	WeaponType.MELEE: false, # Disable melee as requested
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
	
	# Check if the determined weapon is enabled before attacking
	if not enabled_weapons.get(weapon_type, false):
		# print("Weapon type %s is disabled." % WeaponType.keys()[weapon_type])
		return # Do nothing if the weapon is disabled

	# 武器タイプに応じて、それぞれの攻撃処理を呼び出す
	match weapon_type:
		WeaponType.HANDGUN:
			_attack_handgun()
		WeaponType.MELEE:
			_attack_melee()
		WeaponType.LASER:
			_attack_laser()

func _attack_handgun():
	var bullet = BULLET_SCENE.instantiate()
	# Add the bullet to the main scene, not the player
	var main_node = get_tree().get_root().get_node("Main")
	if main_node:
		main_node.add_child(bullet)
		bullet.global_transform = self.global_transform
		bullet.position.z -= 1.0 # Spawn slightly in front of the player
	else:
		printerr("Could not find Main node to add bullet.")

func _attack_melee():
	var melee_area = $MeleeAttackArea
	var melee_effect = $MeleeEffectMesh # We will add this node in the editor

	if melee_area:
		melee_area.monitoring = true
		if melee_effect:
			melee_effect.visible = true

		# Disable the area and effect after a short time
		var timer = get_tree().create_timer(0.2)
		timer.timeout.connect(func(): 
			melee_area.monitoring = false
			if melee_effect:
				melee_effect.visible = false
		)
		# print("Attack: MELEE")
	else:
		printerr("MeleeAttackArea node not found. Please add it to the player scene.")


func _attack_laser():
	# TODO: Implement laser attack
	# print("Attack: LASER")
	pass

func _on_melee_attack_area_body_entered(body):
	if body.is_in_group("enemies"):
		# Assuming enemies have a take_damage method
		body.take_damage(10) # Example damage value
		print("Melee hit: ", body.name)
