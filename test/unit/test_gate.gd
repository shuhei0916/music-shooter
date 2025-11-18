extends GutTest

var gate
var player

func before_each():
	gate = preload("res://scenes/objects/gate/gate.tscn").instantiate()
	player = preload("res://scenes/characters/player/player.tscn").instantiate()
	add_child_autofree(gate)
	add_child_autofree(player)

func test_Playerとゲートが衝突するとゲートが消滅する():
	gate._on_body_entered(player)
	assert_true(gate.is_queued_for_deletion())
