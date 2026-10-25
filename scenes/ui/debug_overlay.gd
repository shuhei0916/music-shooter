class_name DebugOverlay
extends Control

var _channel_labels: Dictionary = {}
var _note_counts: Dictionary = {}  # チャンネル -> これまでに受け取ったノート数

@onready var _vbox: VBoxContainer = $VBoxContainer


func notify_midi_event(ch_num: int, track_name: String, note: int, velocity: int) -> void:
	if ch_num not in _channel_labels:
		_add_channel_row(ch_num)
	_note_counts[ch_num] = _note_counts.get(ch_num, 0) + 1
	var label: Label = _channel_labels[ch_num]
	var bar := _make_vel_bar(velocity)
	var values := [ch_num, track_name, note, velocity, bar, _note_counts[ch_num]]
	label.text = "ch%02d  %-20s  note=%-3d  vel=%-3d  %s  notes=%d" % values
	_flash_label(label)


func _add_channel_row(ch_num: int) -> void:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", 14)
	_vbox.add_child(label)
	_channel_labels[ch_num] = label


func _make_vel_bar(velocity: int) -> String:
	var filled := int(velocity / 12.7)
	return "█".repeat(filled) + "░".repeat(10 - filled)


func _flash_label(label: Label) -> void:
	label.modulate = Color.WHITE
	var tween := create_tween()
	tween.tween_property(label, "modulate", Color(0.7, 1.0, 0.7), 0.2)
