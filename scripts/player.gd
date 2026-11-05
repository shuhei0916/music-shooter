class_name Player
extends Area3D

const BulletScene := preload("res://scenes/bullet.tscn")
const SwordScene := preload("res://scenes/sword.tscn")

@export var start_hp := 10
@export var side_speed := 8.0
@export var road_half_width := 4.0

var stats: PlayerStats
## 自動操縦。キーの操作の代わりに、auto_axis の向き（-1 で左、1 で右）に動く
var autopilot := false
var auto_axis := 0.0
## まわりにためている剣。ためるパート（初めはハイハット）でたまり、撃つパート（初めはスネア）で撃ち出す
var swords := SwordQuiver.new()
var health: Health:
	get:
		return stats.health
var _steering: Steering
## 時刻 0 ちょうどの拍でも撃てるよう、最初は 0 より少し前にしておく
var _last_shot_check := -0.001
var _last_sword_check := -0.001
var _last_shockwave_check := -0.001

@onready var _hp_label: Label3D = $HpLabel
## 体を動かすときの支点（足もと）
@onready var _pivot: Node3D = $Pivot
@onready var _muzzle: Node3D = $Muzzle
@onready var _sword_ring: SwordRing = $SwordRing


func _ready() -> void:
	stats = PlayerStats.new(start_hp)
	_steering = Steering.new(side_speed, road_half_width)


func _process(delta: float) -> void:
	var axis := auto_axis if autopilot else Input.get_axis("move_left", "move_right")
	position.x = _steering.next_x(position.x, axis, delta)
	_hp_label.text = NumberFormat.short(health.hp)


## 曲の時刻を受け取り、前回から拍の線をまたいでいたら撃つ
func shoot_on_beat(time: float, grid: BeatGrid) -> void:
	if grid.crossed(_last_shot_check, time, stats.beats_per_shot()):
		_fire()
	_last_shot_check = time


## 曲の時刻とパートの解析を受け取り、前回からのあいだに鳴った音で剣をため、撃つときは撃ち出す
func play_swords(time: float, track: PartTrack) -> void:
	var released := swords.update(track, _last_sword_check, time, stats)
	_last_sword_check = time
	for i in released:
		_launch_sword(position + _sword_ring.transform * SwordRing.slot(i, released))
	_sword_ring.show_count(swords.count)


## 曲の時刻とパートの解析を受け取り、前回からのあいだに衝撃波のパート（初めはキック）が鳴った回数だけ、
## 前に向けた扇形の中の敵にダメージを与え、足元から衝撃波の弧を出す
func play_shockwave(time: float, track: PartTrack) -> void:
	var beats := track.onsets_in(stats.shockwave_part, _last_shockwave_check, time).size()
	_last_shockwave_check = time
	var radius := stats.shockwave_radius()
	for i in beats:
		Shockwave.blast(
			position, get_tree().get_nodes_in_group("enemies"), radius, stats.shockwave_damage
		)
		# 弧はプレイヤーの子にして、広がるあいだも足元に付いてこさせる
		var ring := ShockwaveRing.new()
		ring.radius = radius
		add_child(ring)


## 曲の位置 pos（SongMap.at の結果）に合わせて体を弾ませる
func dance(pos: Dictionary) -> void:
	_pivot.scale = Vector3.ONE * Groove.scale(pos.since_beat, pos.energy)


func _fire() -> void:
	var bullet: Bullet = BulletScene.instantiate()
	bullet.position = position + _muzzle.position
	bullet.damage = stats.power
	get_parent().add_child(bullet)


func _launch_sword(from: Vector3) -> void:
	var sword: Sword = SwordScene.instantiate()
	sword.position = from
	sword.damage = stats.sword_damage
	sword.retarget = stats.sword_retarget
	get_parent().add_child(sword)
