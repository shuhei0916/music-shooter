## Kenney Animated Charactersのモデルを、スキンとアニメーションを指定して表示する
extends Node3D

const ASSET_DIR = "res://assets/kenney_animated-characters-protagonists/"
const MODEL = preload(ASSET_DIR + "Model/characterMedium.fbx")
## アニメーション名 -> (アニメーションを含むシーン, シーン内のアニメーション名)
const ANIMATIONS = {
	"run": [preload(ASSET_DIR + "Animations/run.fbx"), "Root|Run"],
	"idle": [preload(ASSET_DIR + "Animations/idle.fbx"), "Root|Idle"],
}
## 被弾演出（白く光る・のけぞる）が終わるまでの秒数
const HIT_DURATION := 0.15
## 被弾したときに奥（-Z）へのけぞる距離
const HIT_KNOCKBACK := 0.3

@export_enum("run", "idle") var animation := "run"
## 見た目のテクスチャ（ASSET_DIR/Skins/ 内のいずれか）
@export var skin: Texture2D

var _material: StandardMaterial3D
var _hit_tween: Tween
var _base_position: Vector3


func _ready() -> void:
	_base_position = position
	var model := MODEL.instantiate()
	add_child(model)
	_override_material(model)
	var animation_player := AnimationPlayer.new()
	model.add_child(animation_player)
	var library := AnimationLibrary.new()
	library.add_animation(animation, _load_animation(animation))
	animation_player.add_animation_library("", library)
	animation_player.play(animation)


## スキンの差し替えや被弾演出で、インポートした共有のマテリアルを書き換えないよう複製して使う
func _override_material(model: Node) -> void:
	var mesh: MeshInstance3D = model.find_children("*", "MeshInstance3D")[0]
	_material = mesh.get_active_material(0).duplicate()
	if skin:
		_material.albedo_texture = skin
	_material.emission = Color.WHITE
	mesh.set_surface_override_material(0, _material)


## 被弾演出を再生する。連続で当たったときは最初からやり直す
func play_hit() -> void:
	if _hit_tween:
		_hit_tween.kill()
	_material.emission_enabled = true
	_material.emission_energy_multiplier = 1.0
	position = _base_position + Vector3(0, 0, -HIT_KNOCKBACK)
	_hit_tween = create_tween().set_parallel()
	_hit_tween.tween_property(_material, "emission_energy_multiplier", 0.0, HIT_DURATION)
	_hit_tween.tween_property(self, "position", _base_position, HIT_DURATION)


func _load_animation(anim_name: String) -> Animation:
	var source: Node = ANIMATIONS[anim_name][0].instantiate()
	var source_player: AnimationPlayer = source.find_children("*", "AnimationPlayer")[0]
	# インポートした共有リソースを書き換えないよう複製してからループさせる
	var result: Animation = source_player.get_animation(ANIMATIONS[anim_name][1]).duplicate()
	result.loop_mode = Animation.LOOP_LINEAR
	source.free()
	return result
