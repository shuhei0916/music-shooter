class_name Player
extends Area3D

const BulletScene := preload("res://scenes/bullet.tscn")

@export var start_hp := 10
@export var side_speed := 8.0
@export var road_half_width := 4.0
@export var fire_interval := 0.2

var stats: PlayerStats
var health: Health:
	get:
		return stats.health
var _steering: Steering
var _fire_cooldown := 0.0

@onready var _hp_label: Label3D = $HpLabel


func _ready() -> void:
	stats = PlayerStats.new(start_hp)
	_steering = Steering.new(side_speed, road_half_width)


func _process(delta: float) -> void:
	var axis := Input.get_axis("move_left", "move_right")
	position.x = _steering.next_x(position.x, axis, delta)
	_hp_label.text = str(health.hp)
	_fire_cooldown -= delta
	if _fire_cooldown <= 0.0:
		_fire()
		_fire_cooldown += fire_interval


func _fire() -> void:
	var bullet: Bullet = BulletScene.instantiate()
	bullet.position = position + Vector3(0, 1, -0.6)
	get_parent().add_child(bullet)
