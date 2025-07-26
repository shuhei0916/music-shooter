extends Control

func _on_stage_select_button_pressed():
	# Use get_node to avoid editor errors with new autoloads
	get_node("/root/SceneManager").change_scene("res://stage_select.tscn")

func _on_settings_button_pressed():
	# This button doesn't do anything yet.
	print("Settings button pressed.")

func _on_exit_button_pressed():
	get_tree().quit()
