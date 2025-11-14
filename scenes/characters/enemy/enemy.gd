extends Area3D

signal player_collided_with_enemy(enemy_hp)

@export var hp: int = 5

func _ready():
	update_label()
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		body._on_enemy_collided(self)
		queue_free() # Disappear after collision

func set_hp(new_hp):
	hp = new_hp
	update_label()

func update_label():
	var label = $Label3D
	if label:
		label.text = get_node("/root/Utils").format_number(hp)

func take_damage(damage):
	hp -= damage
	if hp <= 0:
		queue_free()
	else:
		update_label()
