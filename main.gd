extends Node3D

const WORLD_SPEED = 5.0

var player

@onready var midi_player = $MidiPlayer

func _ready():
	# Setup MidiPlayer
	midi_player.soundfont = "res://music/GeneralUser-GS.sf2"
	midi_player.file = "res://music/ABBA_-_Dancing_Queen.mid"
	midi_player.midi_event.connect(_on_midi_event)
	midi_player.play()

	player = get_node("Player")
	player.hp_changed.connect(_on_player_hp_changed)
	player.game_over_signal.connect(_on_game_over)
	

	# Connect to Spawner
	var spawner = get_node("Spawner")
	spawner.spawn_object.connect(_on_spawn_object)
	spawner.start_spawning()

func _on_spawn_object(object_scene, properties):
	var instance = object_scene.instantiate()
	
	if instance.is_in_group("world_objects"):
		add_child(instance)
		instance.transform.origin = properties.position
		
		if instance.has_method("set_hp"): # For enemies
			instance.set_hp(properties.hp)
			instance.player_collided_with_enemy.connect(_on_player_collided_with_enemy)
		elif instance.has_method("set_gate_properties"): # For gates
			instance.set_gate_properties(properties.type, properties.value)
			instance.player_entered_gate.connect(_on_player_entered_gate)

func _on_player_entered_gate(gate_type, value):
	if player:
		if gate_type == "add":
			player.add_characters(value)
		elif gate_type == "multiply":
			player.multiply_characters(value)

func _on_player_collided_with_enemy(enemy_hp):
	if player:
		player.take_damage(enemy_hp)

func _on_game_over():
	var ui = get_node("GameUI")
	if ui:
		ui.show_result(false) # It's a loss

func _on_player_hp_changed(new_hp):
	var hp_label = player.get_node("HPLabel")
	if hp_label:
		hp_label.text = get_node("/root/Utils").format_number(new_hp)

func _process(delta):
	for obj in get_tree().get_nodes_in_group("world_objects"):
		obj.global_translate(Vector3(0, 0, WORLD_SPEED * delta))

func _on_midi_event(channel, event):
	# We are interested in Note On events
	if event.type == SMF.MIDIEventType.note_on and event.velocity > 0:
		var channel_status = channel as MidiPlayer.GodotMIDIPlayerChannelStatus
		print("MIDI Event: Channel %d (%s), Note: %d, Velocity: %d" % [channel_status.number, channel_status.track_name, event.note, event.velocity])
