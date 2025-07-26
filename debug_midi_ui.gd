extends Control

# An array to hold the label nodes for each channel
var channel_labels = []

func _ready():
	# Assuming the scene has a VBoxContainer named "TrackInfoContainer"
	var container = $Panel/MarginContainer/TrackInfoContainer
	if not container:
		printerr("DebugMidiUi scene needs a VBoxContainer named 'TrackInfoContainer'")
		return

	# Create 16 rows for the 16 MIDI channels
	for i in range(16):
		var hbox = HBoxContainer.new()
		
		var ch_label = Label.new()
		ch_label.text = "Ch %2d:" % (i + 1)
		ch_label.set_custom_minimum_size(Vector2(70, 0))
		
		var name_label = Label.new()
		name_label.text = "Instrument Name"
		name_label.set_custom_minimum_size(Vector2(200, 0))
		
		var count_label = Label.new()
		count_label.text = "Notes: 0"
		
		hbox.add_child(ch_label)
		hbox.add_child(name_label)
		hbox.add_child(count_label)
		
		container.add_child(hbox)
		
		# Store references to the labels we need to update
		channel_labels.append({
			"name": name_label,
			"count": count_label
		})

# Call this function from main.gd to update the UI
func update_track_data(channel_number, instrument_name, note_count):
	if channel_number >= 0 and channel_number < 16:
		var labels = channel_labels[channel_number]
		labels["name"].text = instrument_name
		labels["count"].text = "Notes: " + str(note_count)
