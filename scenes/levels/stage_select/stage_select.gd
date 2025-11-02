extends Control

@onready var vbox_container = $VBoxContainer

func _ready():
	populate_song_list()

func populate_song_list():
	var song_list = get_node("/root/SongManager").get_song_list()
	
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
	get_node("/root/SongManager").select_song(song_path)
	get_node("/root/SceneManager").change_scene("res://main.tscn")

func _on_back_button_pressed():
	get_node("/root/SceneManager").change_scene("res://main_menu.tscn")
