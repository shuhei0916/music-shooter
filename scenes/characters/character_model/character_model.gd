## Kenney Animated Charactersのモデルを、スキンとアニメーションを指定して表示する
extends Node3D

const ASSET_DIR = "res://assets/kenney_animated-characters-protagonists/"
const MODEL = preload(ASSET_DIR + "Model/characterMedium.fbx")
## アニメーション名 -> (アニメーションを含むシーン, シーン内のアニメーション名)
const ANIMATIONS = {
	"run": [preload(ASSET_DIR + "Animations/run.fbx"), "Root|Run"],
	"idle": [preload(ASSET_DIR + "Animations/idle.fbx"), "Root|Idle"],
}

@export_enum("run", "idle") var animation := "run"


func _ready() -> void:
	var model := MODEL.instantiate()
	add_child(model)
	var animation_player := AnimationPlayer.new()
	model.add_child(animation_player)
	var library := AnimationLibrary.new()
	library.add_animation(animation, _load_animation(animation))
	animation_player.add_animation_library("", library)
	animation_player.play(animation)


func _load_animation(anim_name: String) -> Animation:
	var source: Node = ANIMATIONS[anim_name][0].instantiate()
	var source_player: AnimationPlayer = source.find_children("*", "AnimationPlayer")[0]
	var result: Animation = source_player.get_animation(ANIMATIONS[anim_name][1])
	source.free()
	return result
