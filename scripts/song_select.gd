class_name SongSelect
extends Control
## 曲を選ぶ画面。music/ の遊べる曲（SongLibrary）をボタンで並べ、押した曲でゲームを始める

signal song_chosen(path: String)

## 遊べる曲を探すフォルダ
@export var music_dir := "res://music"

## [{path, title, bpm}, ...]。null なら music_dir から探す
var songs: Variant = null
## 曲を選んだら、その曲でゲームを始める。false なら song_chosen で知らせるだけ
var start_on_choose := true

@onready var _list: VBoxContainer = %List


func _ready() -> void:
	if songs == null:
		songs = SongLibrary.songs(music_dir)
	%Empty.visible = songs.is_empty()
	for song: Dictionary in songs:
		var button := Button.new()
		button.text = label(song)
		button.add_theme_font_size_override("font_size", 32)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(song_chosen.emit.bind(song.path))
		_list.add_child(button)
	if start_on_choose:
		song_chosen.connect(func(path: String): Main.start(get_tree(), path))
	if not songs.is_empty():
		_list.get_child(0).grab_focus.call_deferred()


## ボタンに書く文字。曲の名前と BPM（分からなければ名前だけ）
static func label(song: Dictionary) -> String:
	if song.bpm <= 0.0:
		return song.title
	return "%s   BPM %d" % [song.title, roundi(song.bpm)]
