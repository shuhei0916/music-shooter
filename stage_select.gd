extends Control

func _on_stage_1_button_pressed():
	# This button will always load the main game scene for now.
	get_node("/root/SceneManager").change_scene("res://main.tscn")

func _on_back_button_pressed():
	get_node("/root/SceneManager").change_scene("res://main_menu.tscn")
