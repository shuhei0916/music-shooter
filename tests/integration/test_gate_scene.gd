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


func test_マイナスのゲートのラベルにはマイナスの値が表示される():
	gate.gate_type = "add"
	gate.value = -10
	add_child_autofree(gate)
	assert_eq("❤️ -10", gate.get_node("Pivot/Label3D").text)


func test_マイナスのゲートは赤いメッシュで表示する():
	gate.gate_type = "add"
	gate.value = -10
	add_child_autofree(gate)
	var albedo: Color = gate.get_node("Pivot/MeshInstance3D").get_active_material(0).albedo_color
	albedo.a = 1.0
	assert_eq(albedo, Color.RED)


func test_加算ゲートのラベルは単位つきで表示する():
	gate.gate_type = "add"
	gate.value = 1500
	add_child_autofree(gate)
	assert_eq("❤️ +1.5k", gate.get_node("Pivot/Label3D").text)
