extends Control

@onready var result_panel = $ResultPanel
@onready var result_label = $ResultPanel/ResultLabel
@onready var _debug_panel = $DebugPanel
@onready var _growth_curve_graph: GrowthCurveGraph = $DebugPanel/GrowthCurveGraph


func show_result(is_win: bool):
	result_panel.visible = true
	result_label.text = "Run Completed!" if is_win else "Game Over"
	result_label.text += "\nPress Enter to retry."


func update_progress(current_time, total_time):
	var time_str = (
		"%s/%s" % [format_seconds_to_string(current_time), format_seconds_to_string(total_time)]
	)
	$SongProgressLabel.text = str(time_str)


func update_countdown(text: String) -> void:
	$SongProgressLabel.text = text


func set_growth_curve(points: PackedVector2Array) -> void:
	_growth_curve_graph.set_points(points)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_toggle"):
		_debug_panel.visible = not _debug_panel.visible


func format_seconds_to_string(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]
