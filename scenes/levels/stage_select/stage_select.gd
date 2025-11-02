extends Control

@export var song_manager_path: NodePath = NodePath("/root/SongManager")
@export var scene_manager_path: NodePath = NodePath("/root/SceneManager")
@export_file("*.tscn") var main_scene_path: String
@export_file("*.tscn") var main_menu_scene_path: String

@onready var vbox_container = $VBoxContainer

func _ready():
	populate_song_list()

func populate_song_list():
	var song_manager = get_node_or_null(song_manager_path)
	if song_manager == null:
		printerr("SongManager が見つかりません: ", song_manager_path)
		return

	var song_list = song_manager.get_song_list()
	
	# Clear any existing buttons except the "Back" button
	for child in vbox_container.get_children():
		if child.name != "BackButton":
			child.queue_free()

	for song_path in song_list:
		var button = Button.new()
		# Extract filename from path, remove .mid extension for display
		var song_name = song_path.get_file().get_basename()
		button.text = song_name
		
		# Connect pressed signal with the song path as a bound argument
		button.pressed.connect(Callable(self, "_on_song_button_pressed").bind(song_path))
		
		# Add the new button to the container, before the "Back" button
		vbox_container.add_child(button)
		vbox_container.move_child(button, vbox_container.get_child_count() - 2)

func _on_song_button_pressed(song_path: String):
	var song_manager = get_node_or_null(song_manager_path)
	var scene_manager = get_node_or_null(scene_manager_path)
	if song_manager == null or scene_manager == null:
		printerr("SongManager もしくは SceneManager が見つかりません")
		return
	if main_scene_path == "":
		printerr("main_scene_path が未設定です")
		return
	song_manager.select_song(song_path)
	scene_manager.change_scene(main_scene_path)

func _on_back_button_pressed():
	var scene_manager = get_node_or_null(scene_manager_path)
	if scene_manager == null:
		printerr("SceneManager が見つかりません: ", scene_manager_path)
		return
	if main_menu_scene_path == "":
		printerr("main_menu_scene_path が未設定です")
		return
	scene_manager.change_scene(main_menu_scene_path)
