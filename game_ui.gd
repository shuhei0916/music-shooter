extends Control

@onready var time_label = $TimeLabel
@onready var result_panel = $ResultPanel
@onready var result_label = $ResultPanel/ResultLabel
@onready var new_run_button = $ResultPanel/NewRunButton

var time_left = 60

func _ready():
	new_run_button.connect("pressed", Callable(self, "_on_new_run_pressed"))

func _process(delta):
	if time_left > 0:
		time_left -= delta
		time_label.text = "Time: " + str(int(time_left))
		if time_left <= 0:
			show_result(true) # Run Completed

func show_result(is_win):
	result_panel.visible = true
	if is_win:
		result_label.text = "Run Completed!"
	else:
		result_label.text = "Game Over"
	
	# Stop the spawner and player
	var root = get_tree().get_root().get_node("Main")
	if root:
		var spawner = root.get_node("Spawner")
		if spawner:
			spawner.stop_spawning()
		
		var player = root.get_node("Player")
		if player:
			player.set_physics_process(false)

func _on_new_run_pressed():
	get_node("/root/SceneManager").change_scene("res://main_menu.tscn")
