## タイトル（メニュー）画面
extends Control

signal play_requested
signal calibration_requested

## 遷移先のシーン（空ならシーンを切り替えない）
@export_file("*.tscn") var song_select_scene := "res://scenes/ui/song_select/song_select.tscn"
@export_file("*.tscn") var calibration_scene := "res://scenes/ui/calibration/calibration.tscn"


func _ready() -> void:
	%PlayButton.pressed.connect(_on_play_pressed)
	%CalibrationButton.pressed.connect(_on_calibration_pressed)


func _on_play_pressed() -> void:
	play_requested.emit()
	if song_select_scene:
		get_tree().change_scene_to_file(song_select_scene)


func _on_calibration_pressed() -> void:
	calibration_requested.emit()
	if calibration_scene:
		get_tree().change_scene_to_file(calibration_scene)
