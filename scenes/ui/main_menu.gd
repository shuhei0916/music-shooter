extends Control

@export var scene_manager_path: NodePath = NodePath("/root/SceneManager")
@export_file("*.tscn") var stage_select_scene_path: String

func _on_stage_select_button_pressed():
	# Use get_node to avoid editor errors with new autoloads
	var scene_manager = get_node_or_null(scene_manager_path)
	if scene_manager == null:
		printerr("SceneManager が見つかりません: ", scene_manager_path)
		return
	if stage_select_scene_path == "":
		printerr("stage_select_scene_path が未設定です")
		return
	scene_manager.change_scene(stage_select_scene_path)

func _on_settings_button_pressed():
	# This button doesn't do anything yet.
	print("Settings button pressed.")

func _on_exit_button_pressed():
	get_tree().quit()
