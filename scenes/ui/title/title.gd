## タイトル（メニュー）画面
extends Control

signal play_requested
signal calibration_requested

## 遷移先のシーン（空ならシーンを切り替えない）
@export_file("*.tscn") var song_select_scene := "res://scenes/ui/song_select/song_select.tscn"
@export_file("*.tscn") var calibration_scene := "res://scenes/ui/calibration/calibration.tscn"


func _ready() -> void:
	%PlayButton.pressed.connect(_go.bind(play_requested, "song_select_scene"))
	%CalibrationButton.pressed.connect(_on_calibration_pressed)
	%PlayButton.grab_focus()


func _on_calibration_pressed() -> void:
	Session.calibration_return_scene = scene_file_path
	_go(calibration_requested, "calibration_scene")


func _go(requested: Signal, scene_property: StringName) -> void:
	requested.emit()
	var scene: String = get(scene_property)
	if scene:
		get_tree().change_scene_to_file(scene)
