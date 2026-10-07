## 曲選択画面
extends Control

const SongLibrary = preload("res://scripts/song_library.gd")

@export_dir var songs_dir := "res://assets/audio"
## 曲を選んだ後に移るシーン（空ならシーンを切り替えない）
@export_file("*.tscn") var next_scene := "res://scenes/main/main.tscn"

@onready var _song_list: VBoxContainer = %SongList


func _ready() -> void:
	for song_path in SongLibrary.list_songs(songs_dir):
		var button := Button.new()
		button.text = SongLibrary.display_name(song_path)
		_song_list.add_child(button)
