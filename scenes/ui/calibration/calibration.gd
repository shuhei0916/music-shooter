## 映像と音のずれを合わせるタイミング調整画面
extends Node3D

const OFFSET_STEP_SEC = 0.005

var offset_sec := 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		offset_sec += OFFSET_STEP_SEC
	elif event.is_action_pressed("ui_left"):
		offset_sec -= OFFSET_STEP_SEC
