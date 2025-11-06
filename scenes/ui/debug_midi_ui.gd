extends CanvasLayer

# チャンネルごとのラベルを保持
var channel_labels := []
@onready var track_info_container: VBoxContainer = $TrackInfoContainer
@onready var growth_curve_graph: Control = $GrowthCurveGraph
var growth_curve_points: PackedVector2Array = PackedVector2Array()

func _ready():
	if track_info_container == null:
		printerr("DebugMidiUi scene needs TrackInfoContainer.")
		return
	if growth_curve_graph == null:
		printerr("DebugMidiUi scene needs GrowthCurveGraph.")
		return

	hide_ui()

	for i in range(16):
		var hbox := HBoxContainer.new()
		var ch_label := Label.new()
		ch_label.text = "Ch %2d:" % (i + 1)
		ch_label.set_custom_minimum_size(Vector2(70, 0))

		var name_label := Label.new()
		name_label.text = "Instrument Name"
		name_label.set_custom_minimum_size(Vector2(200, 0))

		var count_label := Label.new()
		count_label.text = "Notes: 0"

		hbox.add_child(ch_label)
		hbox.add_child(name_label)
		hbox.add_child(count_label)
		track_info_container.add_child(hbox)

		channel_labels.append({
			"name": name_label,
			"count": count_label
		})

	update_growth_curve(growth_curve_points)

func update_track_data(channel_number: int, instrument_name: String, note_count: int) -> void:
	if channel_number >= 0 and channel_number < channel_labels.size():
		var labels = channel_labels[channel_number]
		labels["name"].text = instrument_name
		labels["count"].text = "Notes: " + str(note_count)

func update_growth_curve(points: PackedVector2Array) -> void:
	growth_curve_points = points
	if growth_curve_graph:
		growth_curve_graph.set_points(points)

func show_ui() -> void:
	visible = true

func hide_ui() -> void:
	visible = false

func toggle_ui() -> void:
	visible = not visible

func is_ui_visible() -> bool:
	return visible
