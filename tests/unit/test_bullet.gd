extends GutTest

const BulletScript = preload("res://scenes/objects/bullet/bullet.gd")

var bullet


func before_each():
	bullet = preload("res://scenes/objects/bullet/bullet.tscn").instantiate()
	add_child_autofree(bullet)


func test_colorプロパティがマテリアルに反映される():
	bullet.color = Color.RED
	bullet._ready()
	var mesh = bullet.get_node("MeshInstance3D")
	assert_eq(mesh.get_active_material(0).albedo_color, Color.RED)


func test_弾は影を落とさない():
	# 床に映る影が、もう1発の弾に見間違えられるため
	var mesh: MeshInstance3D = bullet.get_node("MeshInstance3D")
	assert_eq(GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, mesh.cast_shadow)
