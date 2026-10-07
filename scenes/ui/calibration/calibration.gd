## 映像と音のずれを合わせるタイミング調整画面
extends Node3D

const OFFSET_STEP_SEC = 0.005

## 調整を終えたときに戻るシーン（空ならシーンを切り替えない）
@export_file("*.tscn") var return_scene := "res://scenes/main/main.tscn"

var offset_sec := 0.0:
	set(value):
		offset_sec = value
		_update_offset_label()

@onready var _offset_label: Label = $UI/OffsetLabel


func _ready() -> void:
	offset_sec = Settings.visual_offset_sec


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		offset_sec += OFFSET_STEP_SEC
	elif event.is_action_pressed("ui_left"):
		offset_sec -= OFFSET_STEP_SEC
	elif event.is_action_pressed("ui_accept"):
		_save_and_return()


func _save_and_return() -> void:
	Settings.visual_offset_sec = offset_sec
	Settings.save_to_file()
	if return_scene:
		get_tree().change_scene_to_file(return_scene)


func _update_offset_label() -> void:
	if _offset_label:
		_offset_label.text = "映像オフセット: %+d ms" % roundi(offset_sec * 1000.0)
