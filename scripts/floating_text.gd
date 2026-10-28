class_name FloatingText
extends Label3D
## 上に浮かびながら薄くなり、duration 秒で消える文字

@export var duration := 0.8
@export var rise := 1.5

var _elapsed := 0.0
var _start_y: float


func _ready() -> void:
	_start_y = position.y


func _process(delta: float) -> void:
	_elapsed += delta
	var t := minf(_elapsed / duration, 1.0)
	position.y = _start_y + rise * t
	modulate.a = 1.0 - t
	if t >= 1.0:
		queue_free()
