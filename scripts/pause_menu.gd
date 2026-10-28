class_name PauseMenu
extends CanvasLayer
## Escキーでゲームを一時停止するメニュー。ゲームの終了は、呼び出し側が quit_requested を受けて行う

signal quit_requested

@onready var _resume_button: Button = $Box/ResumeButton


func _ready() -> void:
	visible = false
	_resume_button.pressed.connect(_close)
	$Box/QuitButton.pressed.connect(quit_requested.emit)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	if visible:
		_close()
	else:
		_open()


func _open() -> void:
	get_tree().paused = true
	visible = true
	_resume_button.grab_focus()


func _close() -> void:
	get_tree().paused = false
	visible = false
