## プレイ中にEscで開く一時停止メニュー。停止中も動くようprocess_modeはALWAYS
extends CanvasLayer


func _ready() -> void:
	%ResumeButton.pressed.connect(close)


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		# 再開したmainが同じEscを受け取って、また一時停止しないように
		get_viewport().set_input_as_handled()


func open() -> void:
	visible = true
	get_tree().paused = true


func close() -> void:
	visible = false
	get_tree().paused = false
