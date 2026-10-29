class_name Player
extends Area3D

const BulletScene := preload("res://scenes/bullet.tscn")

@export var start_hp := 10
@export var side_speed := 8.0
@export var road_half_width := 4.0
## 撃った瞬間の、銃口の光が道を照らす明るさ
@export var muzzle_light_energy := 3.0

var stats: PlayerStats
var health: Health:
	get:
		return stats.health
var _steering: Steering
## 時刻 0 ちょうどの拍でも撃てるよう、最初は 0 より少し前にしておく
var _last_shot_check := -0.001
## 最後に撃ってからの秒数。まだ撃っていなければ INF
var _since_shot := INF

@onready var _hp_label: Label3D = $HpLabel
## 体を動かすときの支点（足もと）
@onready var _pivot: Node3D = $Pivot
@onready var _muzzle: Node3D = $Muzzle
@onready var _flash: MeshInstance3D = $Muzzle/Flash
@onready var _muzzle_light: OmniLight3D = $Muzzle/Light


func _ready() -> void:
	stats = PlayerStats.new(start_hp)
	_steering = Steering.new(side_speed, road_half_width)


func _process(delta: float) -> void:
	var axis := Input.get_axis("move_left", "move_right")
	position.x = _steering.next_x(position.x, axis, delta)
	_hp_label.text = NumberFormat.short(health.hp)
	_since_shot += delta
	_show_shot_effect()


## 曲の時刻を受け取り、前回から拍の線をまたいでいたら撃つ
func shoot_on_beat(time: float, grid: BeatGrid) -> void:
	if grid.crossed(_last_shot_check, time, stats.beats_per_shot()):
		_fire()
	_last_shot_check = time


## 曲の位置 pos（SongMap.at の結果）に合わせて体を弾ませる。beat_length は1拍の秒数
func dance(pos: Dictionary, beat_length: float) -> void:
	var squash := Groove.squash(pos.since_beat, pos.beat_in_bar == 0, pos.energy)
	# 縮んだ分だけ横にふくらませ、つぶれたように見せる
	_pivot.scale = Vector3(1.0 + squash / 2, 1.0 - squash, 1.0 + squash / 2)
	_pivot.rotation.z = Groove.sway(pos.beat_in_bar, pos.since_beat, beat_length, pos.energy)


func _fire() -> void:
	var bullet: Bullet = BulletScene.instantiate()
	bullet.position = position + _muzzle.position
	bullet.damage = stats.power
	get_parent().add_child(bullet)
	_since_shot = 0.0


func _show_shot_effect() -> void:
	var brightness := ShotEffect.flash_brightness(_since_shot)
	_flash.visible = brightness > 0.0
	_flash.transparency = 1.0 - brightness
	_flash.scale = Vector3.ONE * ShotEffect.flash_size(_since_shot)
	_muzzle_light.light_energy = muzzle_light_energy * brightness
	_pivot.rotation.x = ShotEffect.recoil(_since_shot)
