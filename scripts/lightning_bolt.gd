class_name LightningBolt
extends MeshInstance3D
## 落雷の見た目。敵の足もとから空まで伸びる細い光の柱が、DURATION 秒で細く薄くなって消える
## 色は 1 を超える明るさにして、発光のにじみを出す

const DURATION := 0.25
const HEIGHT := 14.0
const WIDTH := 0.25
const COLOR := Color(3.0, 3.0, 1.6, 1.0)

var _elapsed := 0.0
var _material := StandardMaterial3D.new()


func _init() -> void:
	var box := BoxMesh.new()
	box.size = Vector3(WIDTH, HEIGHT, WIDTH)
	_material.albedo_color = COLOR
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.emission_enabled = true
	_material.emission = COLOR
	box.material = _material
	mesh = box


func _ready() -> void:
	# 柱の下の端が足もとに来るよう、柱の半分だけ上げる
	position.y += HEIGHT / 2.0
	_show()


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= DURATION:
		queue_free()
		return
	_show()


func _show() -> void:
	var t := _elapsed / DURATION
	scale = Vector3(1.0 - t * 0.7, 1.0, 1.0 - t * 0.7)
	_material.albedo_color.a = COLOR.a * (1.0 - t)
