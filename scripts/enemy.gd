class_name Enemy
extends Area3D

@export var start_hp := 3

var health: Health

@onready var _hp_label: Label3D = $HpLabel


func _ready() -> void:
	health = Health.new(start_hp)
	_hp_label.text = str(health.hp)
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area3D) -> void:
	if area is Bullet:
		health.damage(1)
		area.queue_free()
	elif area is Player:
		area.health.clash(health)
	_hp_label.text = str(health.hp)
	if health.is_dead():
		queue_free()
