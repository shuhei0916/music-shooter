class_name Bullet
extends Area3D

static var _material_cache: Dictionary = {}

@export var damage: int = 1
@export var color: Color = Color.WHITE

var speed = 30.0


func _ready() -> void:
	var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh:
		if not _material_cache.has(color):
			var mat := StandardMaterial3D.new()
			mat.albedo_color = color
			_material_cache[color] = mat
		mesh.set_surface_override_material(0, _material_cache[color])


func _process(delta):
	position.z -= speed * delta


func _on_visible_on_screen_notifier_3d_screen_exited():
	queue_free()
