class_name Enemy
extends Area3D

const FloatingTextScene := preload("res://scenes/floating_text.tscn")
## ダメージの数字を出す、敵の足もとからの高さ・色・文字の大きさ
const DAMAGE_HEIGHT := 2.6
const DAMAGE_COLOR := Color(1, 0.85, 0.3)
const DAMAGE_FONT_SIZE := 80

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
		_show_damage(area.damage)
	elif area is Player:
		area.health.clash(health)
	_update_hp_label()
	if health.is_dead():
		queue_free()


func _show_hit_effect() -> void:
	var t := _flash_left / flash_duration
	_body.material_override.albedo_color = _base_color.lerp(Color.WHITE, t)
	_body.scale = Vector3.ONE * lerpf(1.0, hit_scale, t)


## 受けたダメージの数字を、敵の頭の上に浮かべる。敵が消えても残るよう、敵と同じ親に置く
func _show_damage(amount: int) -> void:
	var popup: FloatingText = FloatingTextScene.instantiate()
	popup.text = NumberFormat.short(amount)
	popup.modulate = DAMAGE_COLOR
	popup.font_size = DAMAGE_FONT_SIZE
	popup.position = position + Vector3(0, DAMAGE_HEIGHT, 0)
	get_parent().add_child(popup)


func _update_hp_label() -> void:
	_hp_label.text = NumberFormat.short(health.hp)
