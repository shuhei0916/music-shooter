extends Area3D

var speed = 30.0

func _process(delta):
	position.z -= speed * delta

func _on_area_entered(area):
	if area.is_in_group("enemy"):
		area.take_damage(1) # 仮のダメージ値
	queue_free()

func _on_visible_on_screen_notifier_3d_screen_exited():
	queue_free()
