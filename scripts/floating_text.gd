class_name FloatingText
extends Label3D
## ポンと大きく出て、初めに素早く上がり、最後の短いあいだで薄くなって duration 秒で消える文字

## 出た瞬間の大きさ（元の大きさが 1）と、元の大きさに戻るまでの時間（表示する時間に対する割合）
const POP_SCALE := 1.4
const POP_PART := 0.15
## 表示する時間のうち、最後のこの割合で薄くなって消える。それまではっきり見せる
const FADE_PART := 0.35

@export var duration := 0.8
@export var rise := 1.5

var _elapsed := 0.0
var _start_y: float


func _ready() -> void:
	_start_y = position.y


func _process(delta: float) -> void:
	_elapsed += delta
	var t := minf(_elapsed / duration, 1.0)
	scale = Vector3.ONE * lerpf(POP_SCALE, 1.0, minf(t / POP_PART, 1.0))
	# 初めは速く、終わりはほぼ止まる
	position.y = _start_y + rise * (1.0 - pow(1.0 - t, 3))
	modulate.a = minf((1.0 - t) / FADE_PART, 1.0)
	if t >= 1.0:
		queue_free()
