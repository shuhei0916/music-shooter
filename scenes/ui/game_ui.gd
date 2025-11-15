extends Control

@export var scene_manager_path: NodePath = NodePath("/root/SceneManager")
@export_file("*.tscn") var main_menu_scene_path: String

@onready var result_panel = $ResultPanel
@onready var result_label = $ResultPanel/ResultLabel
@onready var new_run_button = $ResultPanel/NewRunButton

func _ready():
	new_run_button.connect("pressed", Callable(self, "_on_new_run_pressed"))

func _process(delta):
	pass

func show_result(is_win: bool):
	result_panel.visible = true
	result_label.text = "Run Completed!" if is_win else "Game Over"
	
	# Stop the spawner and player
	#var root = get_tree().get_root().get_node_or_null("Main")
	#if root == null:
		#return
	#var spawner = root.get_node_or_null("Spawner")
	#if spawner:
		#spawner.stop_spawning()
	#var player = root.get_node_or_null("Player")
	#if player:
		#player.set_physics_process(false)

func _on_new_run_pressed():
	if main_menu_scene_path == "":
		printerr("main_menu_scene_path が未設定です")
		return
	var scene_manager = get_node_or_null(scene_manager_path)
	if scene_manager == null:
		printerr("SceneManager が見つかりません: ", scene_manager_path)
		return
	scene_manager.change_scene(main_menu_scene_path)

func update_progress(current_time, total_time):
	var time_str = "%s/%s" % [
		format_seconds_to_string(current_time), 
		format_seconds_to_string(total_time)
	]
	$SongProgressLabel.text = str(time_str)

func format_seconds_to_string(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]
