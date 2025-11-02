extends Node

@export_dir var music_directory := "res://assets/audio"

var song_list: Array = []
var selected_song_path: String = ""

func _ready():
	_scan_songs()

func _scan_songs():
	song_list.clear()
	var dir = DirAccess.open(music_directory)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and (file_name.ends_with(".mid") or file_name.ends_with(".midi")):
				song_list.append(music_directory.path_join(file_name))
			file_name = dir.get_next()
	else:
		printerr("Could not open '%s' directory." % music_directory)
	
	song_list.sort() # Sort alphabetically

func get_song_list() -> Array:
	return song_list

func select_song(path: String):
	if path in song_list:
		selected_song_path = path
	else:
		printerr("Selected song path not found in song list: %s" % path)

func get_selected_song() -> String:
	return selected_song_path
