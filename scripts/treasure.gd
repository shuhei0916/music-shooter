class_name Treasure
extends Area3D
## 倒した敵が、倒れた場所に落とす宝箱。プレイヤーが触れると中身の分だけ HP が増える

const FloatingTextScene := preload("res://scenes/floating_text.tscn")
## 取ったときに飛び出す文字の、プレイヤーの足もとからの高さと色
const POPUP_HEIGHT := 3.2
const POPUP_COLOR := Color(0.4, 1, 0.5)
## 拍の線があるとき、取ったときの文字を何拍で消すか（ゲートと同じ）
const POPUP_BEATS := 2.0

## 取ったときに増える HP
@export var hp_bonus := 1
## 落とした敵が占めていたレーンの数。ボスの宝箱はボスと同じだけ大きくし、どのレーンからでも取れる
@export var lanes_wide := 1

## 取ったときの文字を出す長さを決める拍の線。無ければ文字の決めておいた長さで消す
var grid: BeatGrid
var _used := false

@onready var _label: Label3D = $Label


func _ready() -> void:
	if lanes_wide > 1:
		var wide := Enemy.SCALE_PER_LANE * lanes_wide
		scale = Vector3(wide, 1.0, wide)
		_label.scale = Vector3(1.0 / wide, 1.0, 1.0 / wide)
	_label.text = _bonus_text()
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area3D) -> void:
	if _used or not area is Player:
		return
	_used = true
	area.health.hp += hp_bonus
	var popup: FloatingText = FloatingTextScene.instantiate()
	popup.text = _bonus_text()
	popup.modulate = POPUP_COLOR
	popup.position.y = POPUP_HEIGHT
	if grid != null:
		popup.duration = grid.seconds_per_beat() * POPUP_BEATS
	area.add_child(popup)
	queue_free()


func _bonus_text() -> String:
	return "+" + NumberFormat.short(hp_bonus)
