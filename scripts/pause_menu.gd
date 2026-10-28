class_name PauseMenu
extends CanvasLayer


func _ready() -> void:
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_open()


func _open() -> void:
	get_tree().paused = true
	visible = true
