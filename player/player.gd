extends CharacterBody3D

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
const MOVE_SPEED = 10.0

func handle_lane_movement(delta):
	if Input.is_action_just_pressed("ui_right") and current_lane < 2:
		current_lane += 1
	if Input.is_action_just_pressed("ui_left") and current_lane > 0:
		current_lane -= 1
	
	target_x = (current_lane - 1) * LANE_WIDTH
	
	# Smoothly move to the target lane
	global_transform.origin.x = lerp(global_transform.origin.x, target_x, MOVE_SPEED * delta)
	velocity.x = 0 # We handle movement directly via transform
	velocity.z = 0

func add_characters(amount):
	self.character_count += amount
	print("Characters: ", character_count)

func multiply_characters(factor):
	self.character_count *= factor
	print("Characters: ", character_count)

func take_damage(damage):
	if character_count > damage:
		self.character_count -= damage
	else:
		game_over()

func game_over():
	print("GAME OVER")
	emit_signal("game_over_signal")
	# The game over screen will now handle restarting
