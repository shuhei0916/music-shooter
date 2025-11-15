extends Area3D

@export var hp: int = 5

func _ready():
	update_label()
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		body._on_enemy_collided(self)

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("bullet"):
		take_damage(area.damage)
		area.queue_free()

func set_hp(new_hp):
	hp = new_hp
	update_label()

func update_label():
	$HPLabel.text = str(hp)

func take_damage(damage):
	hp -= damage
	update_label()
	if hp <= 0:
		queue_free()
