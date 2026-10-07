extends GutTest

const CharacterModel = preload("res://scenes/characters/character_model/character_model.gd")

var model: CharacterModel


func before_each():
	model = CharacterModel.new()


func _animation_player() -> AnimationPlayer:
	return model.find_children("*", "AnimationPlayer", true, false)[0]


func test_指定したアニメーションを再生する():
	model.animation = "idle"
	add_child_autofree(model)
	assert_eq("idle", _animation_player().current_animation)


func test_アニメーションはループする():
	add_child_autofree(model)
	var animation_player := _animation_player()
	var current := animation_player.get_animation(animation_player.current_animation)
	assert_eq(Animation.LOOP_LINEAR, current.loop_mode)
