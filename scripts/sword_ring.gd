class_name SwordRing
extends Node3D
## プレイヤーのまわりを回る、たまっている剣の見た目

const SwordScene := preload("res://scenes/sword.tscn")
## 剣を並べる輪の半径と、足もとからの高さ。輪が1秒に回る角度（ラジアン）
const RADIUS := 1.3
const HEIGHT := 1.0
const SPIN_SPEED := 2.0

## 並べる剣の形。撃ち出す剣と同じものを使う
var _mesh: Mesh


func _ready() -> void:
	var sword := SwordScene.instantiate()
	_mesh = sword.get_node("Body").mesh
	sword.free()


func _process(delta: float) -> void:
	rotation.y = wrapf(rotation.y + SPIN_SPEED * delta, 0.0, TAU)


## count 本の剣を、輪の上に等しい間をあけて、切っ先を上に向けて並べる
func show_count(count: int) -> void:
	while get_child_count() > count:
		var last := get_child(get_child_count() - 1)
		remove_child(last)
		last.queue_free()
	while get_child_count() < count:
		var blade := MeshInstance3D.new()
		blade.mesh = _mesh
		blade.rotation.x = -PI / 2.0
		add_child(blade)
	for i in count:
		get_child(i).position = SwordRing.slot(i, count)


## count 本のうち i 本目の剣の、輪の中での位置
static func slot(i: int, count: int) -> Vector3:
	var angle := TAU * i / count
	return Vector3(cos(angle) * RADIUS, HEIGHT, sin(angle) * RADIUS)
