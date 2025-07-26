extends Node

# Call this function from anywhere to change the current scene
func change_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)
