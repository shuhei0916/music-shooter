extends GutTest

const Gate = preload("res://scenes/objects/gate/gate.gd")
const Player = preload("res://scenes/characters/player/player.gd")

var player
var gate


func before_each():
	gate = Gate.new()
	player = Player.new()
	# ここでplayerはスクリプトのインスタンス＝シーンではないのでグループには属していない
	player.add_to_group("player")  # なので、手動でグループに追加


func after_each():
	gate.free()
	player.free()


func test_プレイヤーと衝突するとゲートが消滅する():
	gate._on_body_entered(player)
	assert_true(gate.is_queued_for_deletion())
