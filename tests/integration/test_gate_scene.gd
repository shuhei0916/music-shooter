extends GutTest

var gate


func before_each():
	gate = preload("res://scenes/objects/gate/gate.tscn").instantiate()


func test_レベルアップゲートのラベルにレベルアップであることが表示される():
	gate.gate_type = "level_up"
	add_child_autofree(gate)
	assert_string_contains(gate.get_node("Pivot/Label3D").text, "Lv UP")


func test_レベルアップゲートは武器の色でメッシュを表示する():
	gate.gate_type = "level_up"
	gate.weapon_color = Color.ORANGE
	add_child_autofree(gate)
	var albedo: Color = gate.get_node("Pivot/MeshInstance3D").get_active_material(0).albedo_color
	albedo.a = 1.0
	assert_eq(albedo, Color.ORANGE)
