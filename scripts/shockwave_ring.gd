class_name ShockwaveRing
extends MeshInstance3D
## 衝撃波の見た目。プレイヤーから前に向けた扇形の弧が、半径 radius まで広がりながら薄くなり、DURATION 秒で消える
## 形は Shockwave と同じ扇形（前から左右に Shockwave.HALF_ANGLE ずつ）

const DURATION := 0.3
const COLOR := Color(1.0, 0.6, 0.2, 0.8)
## 弧の太さ（半径 1 のときの、内側の半径）と、床からの高さ。弧を何個の四角でつなぐか
const INNER := 0.8
const HEIGHT := 0.1
const SEGMENTS := 24

## 広がりきったときの半径
var radius := 4.0
var _elapsed := 0.0
var _material := StandardMaterial3D.new()


func _init() -> void:
	_material.albedo_color = COLOR
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh = _arc_mesh()
	mesh.surface_set_material(0, _material)


func _ready() -> void:
	position.y = HEIGHT
	_show()


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= DURATION:
		queue_free()
		return
	_show()


func _show() -> void:
	var t := _elapsed / DURATION
	var size := maxf(radius * t, 0.01)
	scale = Vector3(size, 1.0, size)
	_material.albedo_color.a = COLOR.a * (1.0 - t)


## 半径 1 の、前（-z）に向けた扇形の弧（内側の半径 INNER）。床に平らに置く
func _arc_mesh() -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in SEGMENTS:
		var a0 := lerpf(-Shockwave.HALF_ANGLE, Shockwave.HALF_ANGLE, float(i) / SEGMENTS)
		var a1 := lerpf(-Shockwave.HALF_ANGLE, Shockwave.HALF_ANGLE, float(i + 1) / SEGMENTS)
		var in0 := _point(a0, INNER)
		var out0 := _point(a0, 1.0)
		var in1 := _point(a1, INNER)
		var out1 := _point(a1, 1.0)
		for vertex in [in0, out0, out1, in0, out1, in1]:
			tool.add_vertex(vertex)
	return tool.commit()


## 前（-z）から angle だけ右に回した向きの、中心から distance の床の上の点
static func _point(angle: float, distance: float) -> Vector3:
	return Vector3(sin(angle), 0.0, -cos(angle)) * distance
