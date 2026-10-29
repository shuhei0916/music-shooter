class_name Player
extends Area3D

const BulletScene := preload("res://scenes/bullet.tscn")

@export var start_hp := 10
@export var side_speed := 8.0
@export var road_half_width := 4.0

var stats: PlayerStats
var health: Health:
	get:
		return stats.health
var _steering: Steering
## 時刻 0 ちょうどの拍でも撃てるよう、最初は 0 より少し前にしておく
var _last_shot_check := -0.001

@onready var _hp_label: Label3D = $HpLabel
## 体を動かすときの支点（足もと）
@onready var _pivot: Node3D = $Pivot
@onready var _muzzle: Node3D = $Muzzle


func _ready() -> void:
	stats = PlayerStats.new(start_hp)
	_steering = Steering.new(side_speed, road_half_width)


func _process(delta: float) -> void:
	var axis := Input.get_axis("move_left", "move_right")
	position.x = _steering.next_x(position.x, axis, delta)
	_hp_label.text = NumberFormat.short(health.hp)


## 曲の時刻を受け取り、前回から拍の線をまたいでいたら撃つ
func shoot_on_beat(time: float, grid: BeatGrid) -> void:
	if grid.crossed(_last_shot_check, time, stats.beats_per_shot()):
		_fire()
	_last_shot_check = time


## 曲の位置 pos（SongMap.at の結果）に合わせて体を弾ませる
func dance(pos: Dictionary) -> void:
	_pivot.scale = Vector3.ONE * Groove.scale(pos.since_beat, pos.energy)


func _fire() -> void:
	var bullet: Bullet = BulletScene.instantiate()
	bullet.position = position + _muzzle.position
	bullet.damage = stats.power
	get_parent().add_child(bullet)
