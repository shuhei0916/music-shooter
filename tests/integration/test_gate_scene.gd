extends GutTest

var gate


func before_each():
	gate = preload("res://scenes/objects/gate/gate.tscn").instantiate()


func test_レベルアップゲートのラベルにレベルアップであることが表示される():
	gate.gate_type = "level_up"
	add_child_autofree(gate)
	assert_string_contains(gate.get_node("Pivot/Label3D").text, "Lv UP")
