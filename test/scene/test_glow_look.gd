extends GutTest
## 黒を基調に、ものが光って見える設定

const MainScene := preload("res://scenes/main.tscn")
const EnemyScene := preload("res://scenes/enemy.tscn")
const GateScene := preload("res://scenes/gate.tscn")


func _make_main() -> Main:
	var main: Main = MainScene.instantiate()
	main.song_path = ""
	main.forward_speed = 10.0
	main.course_length = 100.0
	main.layout = [{"z": 1000.0, "enemies": []}]
	return add_child_autofree(main)


func test_背景は暗い単色で発光がにじむ():
	var environment: Environment = _make_main().get_node("WorldEnvironment").environment
	assert_eq(environment.background_mode, Environment.BG_COLOR)
	assert_lt(environment.background_color.get_luminance(), 0.05)
	assert_true(environment.glow_enabled)


func test_動くものはすべて発光する():
	for path in [
		"res://scenes/enemy.tscn",
		"res://scenes/bullet.tscn",
		"res://scenes/sword.tscn",
		"res://scenes/treasure.tscn",
	]:
		var node: Node = autofree(load(path).instantiate())
		var material: StandardMaterial3D = node.get_node("Body").mesh.material
		assert_true(material.emission_enabled, path)
		assert_gt(material.emission_energy_multiplier, 1.0, path)


func test_プレイヤーも発光して道を照らす():
	var player: Node = autofree(load("res://scenes/player.tscn").instantiate())
	var material: StandardMaterial3D = player.get_node("Pivot/Body").mesh.material
	assert_true(material.emission_enabled)
	assert_true(player.get_node("Glow") is OmniLight3D)


func test_ゲートの枠は得損の色で発光する():
	var gate: GateArea = add_child_autofree(GateScene.instantiate())
	var material: StandardMaterial3D = gate.get_node("Frame/PostLeft").material_override
	assert_true(material.emission_enabled)
	assert_eq(material.emission, Color(gate.good_color, 1.0))
	assert_gt(material.emission_energy_multiplier, 1.0)


func test_背景が道の長さに合わせて線を引く():
	var main := _make_main()
	var edge: MeshInstance3D = main.get_node("Backdrop/RoadEdges/Edge0")
	assert_eq(edge.mesh.size.z, main.get_node("Road").mesh.size.y)
	assert_eq(edge.position.z, main.get_node("Road").position.z)


func test_背景はプレイヤーについてくる():
	var main := _make_main()
	main._process(0.5)
	var backdrop: Backdrop = main.get_node("Backdrop")
	var anchor: float = backdrop.stars_material().get_shader_parameter("anchor_z")
	assert_almost_eq(anchor, main.get_node("Player").position.z, 0.001)
	assert_lt(anchor, 0.0)


func test_当たった瞬間は敵の発光も強くなり元に戻る():
	var enemy: Enemy = EnemyScene.instantiate()
	enemy.start_hp = 10
	add_child_autofree(enemy)
	var material: StandardMaterial3D = enemy.get_node("Body").material_override
	var resting := material.emission_energy_multiplier
	enemy.take_hit(1)
	assert_gt(material.emission_energy_multiplier, resting)
	enemy._process(enemy.flash_duration)
	assert_eq(material.emission_energy_multiplier, resting)
