class_name BeatHud
extends Control
## 画面の右上の円。拍に合わせて脈打ち、いまのセクションの名前と、セクションの何小節目かを表示する

## 盛り上がりが 0 のときと 1 のときの円の色
const CALM_COLOR := Color(0.3, 0.65, 1.0)
const HOT_COLOR := Color(1.0, 0.3, 0.45)
const RADIUS := 70.0
const RING_WIDTH := 4.0
## 下に並べる、何拍目かを示す点
const DOT_RADIUS := 5.0
const DOT_GAP := 16.0
const DOT_Y := 48.0

## 円の大きさ（1 が元の大きさ）
var pulse := 1.0
var beat_in_bar := 0
var beats_per_bar := 4
var color := CALM_COLOR

@onready var _label: Label = $Label
@onready var _bar: Label = $Bar
@onready var _section: Label = $Section


## SongMap.at() で求めた位置を表示する
func show_at(pos: Dictionary) -> void:
	pulse = BeatPulse.scale(pos.since_beat, pos.beat_in_bar == 0)
	beat_in_bar = pos.beat_in_bar
	color = CALM_COLOR.lerp(HOT_COLOR, clampf(pos.energy, 0.0, 1.0))
	_label.text = pos.label
	_section.text = ""
	if pos.section_count > 0:
		_section.text = "SEC %d / %d" % [pos.section_index + 1, pos.section_count]
	var bar: int = pos.bar_in_section + 1
	_bar.text = str(bar)
	if pos.bars_in_section > 0:
		_bar.text = "%d / %d" % [bar, pos.bars_in_section]
	queue_redraw()


func _draw() -> void:
	var center := size / 2.0
	var radius := RADIUS * pulse
	draw_circle(center, radius, Color(color, 0.25))
	draw_arc(center, radius, 0.0, TAU, 64, color, RING_WIDTH, true)
	for i in beats_per_bar:
		var x := (i - (beats_per_bar - 1) / 2.0) * DOT_GAP
		var dot := color if i == beat_in_bar else Color(color, 0.3)
		draw_circle(center + Vector2(x, DOT_Y), DOT_RADIUS, dot)
