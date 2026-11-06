extends GutTest
## 音に反応する背景

const BackdropScene := preload("res://scenes/backdrop.tscn")


func _make() -> Backdrop:
	return add_child_autofree(BackdropScene.instantiate())


func _look(overrides := {}) -> Dictionary:
	var look := {
		"kick_age": 100.0,
		"kick": 0.0,
		"snare": 0.0,
		"hihat": 0.0,
		"bass": 0.0,
		"energy": 0.5,
		"spread": 1.0,
		"burst": 0.0,
		"color_a": Color(0, 0, 1),
		"color_b": Color(0, 1, 0),
	}
	look.merge(overrides, true)
	return look


func _param(backdrop: Backdrop, param: String) -> Variant:
	return backdrop.stars_material().get_shader_parameter(param)


func test_シェーダーが読めて音の値を受け取れる():
	var uniforms: Array = _make().stars_material().shader.get_shader_uniform_list()
	var names: Array = uniforms.map(func(u): return u.name)
	for param in ["anchor_z", "scroll", "kick_age", "snare", "hihat", "bass", "energy", "spread"]:
		assert_has(names, param)


func test_星の数だけ粒を置く():
	var backdrop := _make()
	assert_eq(backdrop.get_node("Stars").multimesh.instance_count, Backdrop.STAR_COUNT)


func test_音の値をシェーダーに渡す():
	var backdrop := _make()
	var look := _look({"kick_age": 0.25, "snare": 0.5, "hihat": 0.75, "bass": 0.1})
	backdrop.show_at(look, -30.0, 6.0, 0.016)
	assert_eq(_param(backdrop, "anchor_z"), -30.0)
	assert_eq(_param(backdrop, "kick_age"), 0.25)
	assert_eq(_param(backdrop, "snare"), 0.5)
	assert_eq(_param(backdrop, "hihat"), 0.75)
	assert_almost_eq(float(_param(backdrop, "bass")), 0.1, 0.001)


func test_盛り上がるほど粒が速く流れる():
	var calm := _make()
	var hot := _make()
	calm.show_at(_look({"energy": 0.0}), 0.0, 6.0, 1.0)
	hot.show_at(_look({"energy": 1.0}), 0.0, 6.0, 1.0)
	assert_almost_eq(float(_param(calm, "scroll")), 6.0, 0.001)
	assert_gt(float(_param(hot, "scroll")), float(_param(calm, "scroll")))


func test_色は急に変えず目標へ近づける():
	var backdrop := _make()
	backdrop.show_at(_look({"color_a": Color(0, 0, 0)}), 0.0, 6.0, 100.0)
	backdrop.show_at(_look({"color_a": Color(1, 0, 0)}), 0.0, 6.0, 0.05)
	assert_between(_param(backdrop, "color_a").r, 0.001, 0.999)


func test_広がりと盛り上がりもなめらかに変える():
	var backdrop := _make()
	backdrop.show_at(_look({"spread": 1.0, "energy": 0.0}), 0.0, 6.0, 100.0)
	backdrop.show_at(_look({"spread": 2.0, "energy": 1.0}), 0.0, 6.0, 0.01)
	assert_between(float(_param(backdrop, "spread")), 1.001, 1.999)
	assert_between(float(_param(backdrop, "energy")), 0.001, 0.999)


func test_道の両端に光る線を道の長さで引く():
	var backdrop := _make()
	backdrop.fit_road(3, 3.0, -100.0, 400.0)
	var left: MeshInstance3D = backdrop.get_node("RoadEdges/Edge0")
	var right: MeshInstance3D = backdrop.get_node("RoadEdges/Edge1")
	assert_eq(left.position.x, -4.5)
	assert_eq(right.position.x, 4.5)
	assert_eq(left.position.z, -100.0)
	assert_eq(left.mesh.size.z, 400.0)


func test_道のレーンの境目にも線を引く():
	var backdrop := _make()
	backdrop.fit_road(3, 3.0, -100.0, 400.0)
	assert_eq(backdrop.get_node("RoadEdges/Lane0").position.x, -1.5)
	assert_eq(backdrop.get_node("RoadEdges/Lane1").position.x, 1.5)


func test_道の線はキックで強く光る():
	var backdrop := _make()
	backdrop.fit_road(3, 3.0, -100.0, 400.0)
	backdrop.show_at(_look({"kick": 0.0}), 0.0, 6.0, 0.016)
	var quiet := backdrop.edge_material().emission_energy_multiplier
	backdrop.show_at(_look({"kick": 1.0}), 0.0, 6.0, 0.016)
	assert_gt(backdrop.edge_material().emission_energy_multiplier, quiet)


func test_シンプル表示ではキックで道の線が光らない():
	var backdrop := _make()
	backdrop.set_fancy(false)
	backdrop.show_at(_look(), 0.0, 6.0, 0.016)
	var quiet := backdrop.edge_material().emission_energy_multiplier
	backdrop.show_at(_look({"kick": 1.0}), 0.0, 6.0, 0.016)
	assert_eq(backdrop.edge_material().emission_energy_multiplier, quiet)
	assert_false(backdrop.get_node("Stars").visible)


func test_シンプル表示から戻すと粒もキックの反応も戻る():
	var backdrop := _make()
	backdrop.set_fancy(false)
	backdrop.set_fancy(true)
	backdrop.show_at(_look(), 0.0, 6.0, 0.016)
	var quiet := backdrop.edge_material().emission_energy_multiplier
	backdrop.show_at(_look({"kick": 1.0}), 0.0, 6.0, 0.016)
	assert_gt(backdrop.edge_material().emission_energy_multiplier, quiet)
	assert_true(backdrop.get_node("Stars").visible)
