## 映像と音のずれを合わせるタイミング調整画面
extends Node3D

## 調整を終えて画面を閉じたとき（保存の有無によらず）
signal closed

const NoteScheduler = preload("res://scripts/note_scheduler.gd")
const Metronome = preload("res://scripts/metronome.gd")
const SoundfontCache = preload("res://scripts/soundfont_cache.gd")
const OFFSET_STEP_SEC = 0.005
const CLICK_BPM = 120.0
const CLICK_BEATS = 600  # 5分ぶん
## play()後に設定し、使う音色だけを読み込む（mainと同じ理由）
const SOUNDFONT_PATH = "res://assets/audio/GeneralUser-GS.sf2"

## 調整を終えたときに戻るシーン（空ならシーンを切り替えない）
@export_file("*.tscn") var return_scene := "res://scenes/main/main.tscn"

var offset_sec := 0.0:
	set(value):
		offset_sec = value
		_update_offset_label()

var _note_scheduler: NoteScheduler

@onready var _offset_label: Label = $UI/OffsetLabel
@onready var _midi_player: MidiPlayer = $MidiPlayer
@onready var _player = $Player


func _ready() -> void:
	offset_sec = Settings.visual_offset_sec
	_player.set_physics_process(false)  # ←→はオフセット調整に使うので移動させない
	for weapon in _player.get_children().filter(func(n): return n.is_in_group("weapon")):
		weapon.level = weapon.MAX_LEVEL  # クリックのたびに撃つ
	_midi_player.smf_data = Metronome.build(CLICK_BPM, CLICK_BEATS)
	_midi_player.play()
	SoundfontCache.load_into(_midi_player, SOUNDFONT_PATH)
	_note_scheduler = NoteScheduler.new(_midi_player.track_status.events)


func _process(_delta: float) -> void:
	for chunk in _note_scheduler.pop_due_ahead(_midi_player, offset_sec):
		_player.on_note(chunk.channel_number, chunk.time, _midi_player.smf_data.timebase)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		offset_sec += OFFSET_STEP_SEC
	elif event.is_action_pressed("ui_left"):
		offset_sec -= OFFSET_STEP_SEC
	elif event.is_action_pressed("ui_accept"):
		Settings.visual_offset_sec = offset_sec
		Settings.save_to_file()
		_close()
	elif event.is_action_pressed("ui_cancel"):
		_close()


func _close() -> void:
	closed.emit()
	if return_scene:
		get_tree().change_scene_to_file(return_scene)


func _update_offset_label() -> void:
	if _offset_label:
		_offset_label.text = "映像オフセット: %+d ms" % roundi(offset_sec * 1000.0)
