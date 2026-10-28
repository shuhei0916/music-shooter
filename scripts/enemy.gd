class_name Enemy
extends Area3D

@export var start_hp := 3
@export var flash_duration := 0.12
@export var hit_scale := 1.15

var health: Health
var _base_color: Color
var _flash_left := 0.0

@onready var _hp_label: Label3D = $HpLabel
@onready var _body: MeshInstance3D = $Body


func _ready() -> void:
	health = Health.new(start_hp)
	_update_hp_label()
	var material: StandardMaterial3D = _body.mesh.material.duplicate()
	_base_color = material.albedo_color
	_body.material_override = material
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	if _flash_left <= 0.0:
		return
	_flash_left = maxf(_flash_left - delta, 0.0)
	_show_hit_effect()


func _on_area_entered(area: Area3D) -> void:
	if area is Bullet:
		health.damage(area.damage)
		area.queue_free()
		_flash_left = flash_duration
		_show_hit_effect()
	elif area is Player:
		area.health.clash(health)
	_update_hp_label()
	if health.is_dead():
		queue_free()


func _show_hit_effect() -> void:
	var t := _flash_left / flash_duration
	_body.material_override.albedo_color = _base_color.lerp(Color.WHITE, t)
	_body.scale = Vector3.ONE * lerpf(1.0, hit_scale, t)


func _update_hp_label() -> void:
	_hp_label.text = NumberFormat.short(health.hp)
