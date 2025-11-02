extends Control

@onready var result_panel = $ResultPanel
@onready var result_label = $ResultPanel/ResultLabel
@onready var new_run_button = $ResultPanel/NewRunButton
@onready var song_progress_label = $SongProgressLabel

func _ready():
	new_run_button.connect("pressed", Callable(self, "_on_new_run_pressed"))

func _process(delta):
	pass

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

func update_progress(current_time, total_time, current_tick, total_ticks):
	var time_str = "%s/%s" % [format_seconds_to_string(current_time), format_seconds_to_string(total_time)]
	var tick_str = "%d/%d ticks" % [current_tick, total_ticks]
	song_progress_label.text = "%s, %s" % [time_str, tick_str]

func format_seconds_to_string(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]
