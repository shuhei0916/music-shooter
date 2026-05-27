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
