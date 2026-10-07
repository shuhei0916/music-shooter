## 曲選択画面
extends Control

## タイトルに戻るよう要求されたとき
signal back_requested

const SongLibrary = preload("res://scripts/song_library.gd")

@export_dir var songs_dir := "res://assets/audio"
## 曲を選んだ後に移るシーン（空ならシーンを切り替えない）
@export_file("*.tscn") var next_scene := "res://scenes/main/main.tscn"
## 戻る先のシーン（空ならシーンを切り替えない）
@export_file("*.tscn") var back_scene := "res://scenes/ui/title/title.tscn"

@onready var _song_list: VBoxContainer = %SongList


func _ready() -> void:
	for song_path in SongLibrary.list_songs(songs_dir):
		var button := Button.new()
		button.text = SongLibrary.display_name(song_path)
		button.pressed.connect(_on_song_chosen.bind(song_path))
		_song_list.add_child(button)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		back_requested.emit()
		if back_scene:
			get_tree().change_scene_to_file(back_scene)


func _on_song_chosen(song_path: String) -> void:
	Session.song_path = song_path
	if next_scene:
		get_tree().change_scene_to_file(next_scene)
