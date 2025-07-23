extends CharacterBody3D

signal hp_changed(new_hp)

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

	# Handle horizontal movement
	var input_dir = Input.get_axis("ui_left", "ui_right")
	velocity.x = input_dir * SPEED
	velocity.z = 0 # No forward/backward movement

	move_and_slide()

func add_characters(amount):
	self.character_count += amount
	print("Characters: ", character_count)

func multiply_characters(factor):
	self.character_count *= factor
	print("Characters: ", character_count)
