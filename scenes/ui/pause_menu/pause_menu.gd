## プレイ中にEscで開く一時停止メニュー。停止中も動くようprocess_modeはALWAYS
extends CanvasLayer

signal title_requested

## タイトル画面（空ならシーンを切り替えない）
@export_file("*.tscn") var title_scene := "res://scenes/ui/title/title.tscn"


func _ready() -> void:
	%ResumeButton.pressed.connect(close)
	%TitleButton.pressed.connect(_on_title_pressed)


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


func _on_title_pressed() -> void:
	close()  # 一時停止したまま切り替えると、次のシーンも止まってしまう
	title_requested.emit()
	if title_scene:
		get_tree().change_scene_to_file(title_scene)
