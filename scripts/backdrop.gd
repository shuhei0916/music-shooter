class_name Backdrop
extends Node3D
## 音に反応する背景。光の粒（StarField・stars.gdshader）と、道の光る線を動かす

const STAR_COUNT := 16000
## 粒の並びは曲によらず同じでよいので、シードを決めておく
const STAR_SEED := 20261106
## 盛り上がりが最大のとき、粒が前に進む速さの何倍で流れるか
const FLOW_HOT := 2.5
## 値が目標へ近づく速さ（1秒あたり）。色はゆっくり、弾ける広がりは速く
const COLOR_RATE := 2.5
const ENERGY_RATE := 3.0
const SPREAD_RATE := 10.0
## 道の線の太さと、光の強さ。両端の線はキックで KICK_GLOW だけ強くなる
const EDGE_WIDTH := 0.08
const EDGE_GLOW := 1.6
const KICK_GLOW := 5.0
const LANE_WIDTH := 0.04
const LANE_GLOW := 0.5
const LINE_HEIGHT := 0.03

## どの Backdrop でも同じなので、1つ作ったら使い回す（ゲームをやり直すたびに作らない）
static var _shared_stars: MultiMesh

## 派手な表示か。false のときは粒を消し、道の線もキックに反応させない
var _fancy := true
var _scroll := 0.0
## 目標へなめらかに近づけている値。最初に見せるときは目標そのものにする
var _started := false
var _energy := 0.0
var _spread := 1.0
var _color_a := Color.BLACK
var _color_b := Color.BLACK
var _material: ShaderMaterial
var _edge_material := StandardMaterial3D.new()
var _lane_material := StandardMaterial3D.new()

@onready var _stars: MultiMeshInstance3D = $Stars


func _ready() -> void:
	_material = _stars.material_override.duplicate()
	_stars.material_override = _material
	_stars.multimesh = _star_mesh()
	_material.set_shader_parameter("field_length", StarField.LENGTH)
	for material in [_edge_material, _lane_material]:
		material.albedo_color = Color.BLACK
		material.emission_enabled = true
	_lane_material.emission_energy_multiplier = LANE_GLOW
	_edge_material.emission_energy_multiplier = EDGE_GLOW


## 派手な表示とシンプル表示を切り替える
func set_fancy(fancy: bool) -> void:
	_fancy = fancy
	_stars.visible = fancy


## 粒のシェーダーの材質（音の値を渡す先）
func stars_material() -> ShaderMaterial:
	return _material


## 道の両端の線の材質
func edge_material() -> StandardMaterial3D:
	return _edge_material


## 道の両端とレーンの境目に、中心が z_center で長さ length の光る線を引く
func fit_road(lane_count: int, lane_width: float, z_center: float, length: float) -> void:
	var half := lane_count * lane_width / 2.0
	var edges: Node3D = $RoadEdges
	_add_line(edges, "Edge0", -half, EDGE_WIDTH, z_center, length, _edge_material)
	_add_line(edges, "Edge1", half, EDGE_WIDTH, z_center, length, _edge_material)
	for i in lane_count - 1:
		var x := -half + lane_width * (i + 1)
		_add_line(edges, "Lane%d" % i, x, LANE_WIDTH, z_center, length, _lane_material)


## look（MusicVisual.at の結果）を見た目に映す。anchor_z はプレイヤーの位置、speed は前に進む速さ
func show_at(look: Dictionary, anchor_z: float, speed: float, delta: float) -> void:
	_approach(look, delta)
	_scroll += speed * lerpf(1.0, FLOW_HOT, _energy) * delta
	var values := {
		"anchor_z": anchor_z,
		"scroll": _scroll,
		"kick_age": look.kick_age,
		"snare": look.snare,
		"hihat": look.hihat,
		"bass": look.bass,
		"burst": look.burst,
		"energy": _energy,
		"spread": _spread,
		"color_a": _color_a,
		"color_b": _color_b,
	}
	for param in values:
		_material.set_shader_parameter(param, values[param])
	_edge_material.emission = _color_a
	_lane_material.emission = _color_a
	var kick_glow: float = KICK_GLOW * look.kick if _fancy else 0.0
	_edge_material.emission_energy_multiplier = EDGE_GLOW + kick_glow


## 急に変わると目につく値を、目標へ少しずつ近づける
func _approach(look: Dictionary, delta: float) -> void:
	var color_step := 1.0 if not _started else 1.0 - exp(-COLOR_RATE * delta)
	var energy_step := 1.0 if not _started else 1.0 - exp(-ENERGY_RATE * delta)
	var spread_step := 1.0 if not _started else 1.0 - exp(-SPREAD_RATE * delta)
	_started = true
	_color_a = _color_a.lerp(look.color_a, color_step)
	_color_b = _color_b.lerp(look.color_b, color_step)
	_energy = lerpf(_energy, look.energy, energy_step)
	_spread = lerpf(_spread, look.spread, spread_step)


func _add_line(
	parent: Node3D,
	line_name: String,
	x: float,
	width: float,
	z_center: float,
	length: float,
	material: Material
) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, 0.02, length)
	mesh.material = material
	var line := MeshInstance3D.new()
	line.name = line_name
	line.mesh = mesh
	line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	line.position = Vector3(x, LINE_HEIGHT, z_center)
	parent.add_child(line)


static func _star_mesh() -> MultiMesh:
	if _shared_stars != null:
		return _shared_stars
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	var mesh := MultiMesh.new()
	mesh.transform_format = MultiMesh.TRANSFORM_3D
	mesh.use_custom_data = true
	mesh.mesh = quad
	var stars := StarField.generate(STAR_COUNT, STAR_SEED)
	mesh.instance_count = stars.size()
	for i in stars.size():
		mesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, stars[i].position))
		mesh.set_instance_custom_data(i, Color(stars[i].seed, stars[i].size, stars[i].tint))
	_shared_stars = mesh
	return mesh
