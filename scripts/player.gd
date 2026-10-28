class_name Player
extends Area3D

@export var start_hp := 10

var health: Health


func _ready() -> void:
	health = Health.new(start_hp)
