class_name Enemy
extends Area3D

@export var start_hp := 3

var health: Health


func _ready() -> void:
	health = Health.new(start_hp)
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area3D) -> void:
	if area is Bullet:
		health.damage(1)
		area.queue_free()
