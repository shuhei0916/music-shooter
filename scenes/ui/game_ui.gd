extends Control

@onready var result_panel = $ResultPanel
@onready var result_label = $ResultPanel/ResultLabel
@onready var debug_overlay = $DebugOverlay


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


func toggle_debug() -> void:
	debug_overlay.visible = not debug_overlay.visible


func notify_midi_event(ch_num: int, track_name: String, note: int, velocity: int) -> void:
	debug_overlay.notify_midi_event(ch_num, track_name, note, velocity)


func format_seconds_to_string(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]
