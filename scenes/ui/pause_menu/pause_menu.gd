## プレイ中にEscで開く一時停止メニュー。停止中も動くようprocess_modeはALWAYS
extends CanvasLayer


func _ready() -> void:
	%ResumeButton.pressed.connect(close)


func open() -> void:
	visible = true
	get_tree().paused = true


func close() -> void:
	visible = false
	get_tree().paused = false
