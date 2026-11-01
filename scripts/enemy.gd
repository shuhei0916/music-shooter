class_name Enemy
extends Area3D

const FloatingTextScene := preload("res://scenes/floating_text.tscn")
## ダメージの数字を出す、敵の足もとからの高さ・色・文字の大きさ
const DAMAGE_HEIGHT := 2.6
const DAMAGE_COLOR := Color(1, 0.85, 0.3)
const DAMAGE_FONT_SIZE := 80
## 拍に合わせるとき、ダメージの数字を何拍で消すか。弾は多くても1拍に1発なので、次の数字と重ならない
const DAMAGE_BEATS := 1.0
## 2レーンを占める大きな敵の大きさ（ふつうの敵が 1）。2つのレーンの中心を覆う
const BIG_SCALE := 2.4

@export var start_hp := 3
## 占めるレーンの数。2 なら大きな敵として大きく出る
@export var lanes_wide := 1
@export var flash_duration := 0.12
@export var hit_scale := 1.15
## 当たったときの演出（光る・ふくらむ・ダメージの数字）を、何拍ごとの線に合わせて出すか
@export var hit_beats := 0.25
## 倒れる演出を、何拍ごとの線に合わせて始めるか。演出の秒数と、最後にどこまでふくらむか
@export var death_beats := 0.5
@export var death_duration := 0.25
@export var death_scale := 1.6

var health: Health
## 演出を拍に合わせるための、曲の時計と拍の線。どちらかが無ければ演出はすぐに出す
var clock: SongClock
var grid: BeatGrid
var _base_color: Color
var _flash_left := 0.0
## まだ演出を出していないダメージの合計と、それを出す時刻
var _pending_damage := 0
var _hit_at := INF
## 倒れる演出を始める時刻と、演出の残り秒数（演出の前は負）
var _die_at := INF
var _dying_left := -1.0

@onready var _hp_label: Label3D = $HpLabel
@onready var _body: MeshInstance3D = $Body


func _ready() -> void:
	health = Health.new(start_hp)
	if lanes_wide > 1:
		scale = Vector3.ONE * BIG_SCALE
	_update_hp_label()
	var material: StandardMaterial3D = _body.mesh.material.duplicate()
	_base_color = material.albedo_color
	_body.material_override = material
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	if _flash_left > 0.0:
		_flash_left = maxf(_flash_left - delta, 0.0)
		_show_hit_effect()
	_play_due_hit()
	_play_due_death()
	if _dying_left < 0.0:
		return
	_dying_left = maxf(_dying_left - delta, 0.0)
	_show_death_effect()
	if _dying_left == 0.0:
		queue_free()


func _on_area_entered(area: Area3D) -> void:
	if health.is_dead():
		return
	if area is Bullet:
		health.damage(area.damage)
		area.queue_free()
		if _pending_damage == 0:
			_hit_at = _beat_time(hit_beats)
		_pending_damage += area.damage
		_play_due_hit()
	elif area is Player:
		area.health.clash(health)
	_update_hp_label()
	if health.is_dead():
		_die()


## 倒れたら、すぐにHPの表示を消してほかのものとぶつからないようにし、倒れる演出は拍に合わせて始める
func _die() -> void:
	_hp_label.visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	_die_at = _beat_time(death_beats)
	_play_due_death()


## 曲の今の時刻。時計が無ければ 0
func _now() -> float:
	return clock.time() if clock != null else 0.0


## 今の時刻のあとで最初に来る、beats 拍ごとの線の時刻。拍に合わせないなら、すぐ（-INF）
func _beat_time(beats: float) -> float:
	if clock == null or grid == null:
		return -INF
	return grid.next_time(clock.time(), beats)


## 出す時刻になっていれば、たまったダメージの演出を出す
func _play_due_hit() -> void:
	if _pending_damage == 0 or _now() < _hit_at:
		return
	_flash_left = flash_duration
	_show_hit_effect()
	_show_damage(_pending_damage)
	_pending_damage = 0
	_hit_at = INF


## 始める時刻になっていれば、倒れる演出を始める
func _play_due_death() -> void:
	if _dying_left >= 0.0 or _now() < _die_at:
		return
	_dying_left = death_duration
	_body.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_show_death_effect()


## 倒れる演出。ふくらみながら薄くなって消える
func _show_death_effect() -> void:
	var t := 1.0 - _dying_left / death_duration
	_body.scale = Vector3.ONE * lerpf(1.0, death_scale, t)
	_body.material_override.albedo_color.a = 1.0 - t


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
	if grid != null:
		popup.duration = grid.seconds_per_beat() * DAMAGE_BEATS
	popup.position = position + Vector3(0, DAMAGE_HEIGHT * scale.y, 0)
	get_parent().add_child(popup)


func _update_hp_label() -> void:
	_hp_label.text = NumberFormat.short(health.hp)
