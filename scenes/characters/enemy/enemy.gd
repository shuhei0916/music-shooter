extends Area3D

signal died

const NumberFormat = preload("res://scripts/number_format.gd")

@export var hp: int = 5:
	set(value):
		hp = value
		update_label()


func _ready():
	update_label()


func _on_body_entered(body):
	if body.is_in_group("player"):
		body._on_enemy_collided(self)


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("bullet"):
		take_damage(area.damage)
		area.queue_free()


func update_label():
	var label := get_node_or_null("HPLabel")
	if label:
		label.text = NumberFormat.abbreviate(hp)


func take_damage(damage):
	hp -= damage
	if hp <= 0:
		died.emit()
		queue_free()
		return
	var model := get_node_or_null("CharacterModel")
	if model:
		model.play_hit()
