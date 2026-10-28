extends GutTest

const BulletScene := preload("res://scenes/bullet.tscn")


func test_弾は前へ速さの分だけ進む():
	var bullet: Bullet = BulletScene.instantiate()
	bullet.speed = 20.0
	add_child_autofree(bullet)
	simulate(bullet, 1, 0.1)
	assert_almost_eq(bullet.position.z, -2.0, 0.001)
