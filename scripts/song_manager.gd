extends Node

@export_dir var music_directory := "res://assets/audio"

const SMF = preload("res://addons/midi/SMF.gd")
const GrowthCurve = preload("res://scripts/growth_curve.gd")

var song_list: Array = []
var selected_song_path: String = ""
var growth_curve: PackedVector2Array = PackedVector2Array()
var smf_reader_factory: Callable = func():
	return SMF.new()

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
		growth_curve = PackedVector2Array()
		_compute_growth_curve()
	else:
		printerr("Selected song path not found in song list: %s" % path)

func get_selected_song() -> String:
	return selected_song_path

func get_growth_curve() -> PackedVector2Array:
	if growth_curve.is_empty() and selected_song_path != "":
		_compute_growth_curve()
	return growth_curve

func set_smf_reader_factory(factory: Callable) -> void:
	smf_reader_factory = factory

func _compute_growth_curve():
	if selected_song_path == "":
		growth_curve = PackedVector2Array()
		return

	var smf_reader = smf_reader_factory.call()
	if smf_reader == null:
		printerr("SMF reader factory returned null.")
		growth_curve = PackedVector2Array()
		return

	var result = smf_reader.read_file(selected_song_path)
	if result.error != OK or result.data == null:
		printerr("Failed to read midi file: %s" % selected_song_path)
		growth_curve = PackedVector2Array()
		return

	growth_curve = GrowthCurve.compute_from_smf(result.data)
