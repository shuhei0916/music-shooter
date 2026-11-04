class_name PartHud
extends Control
## 右上の円の下に、曲のパートの項目ごとに、鳴っている大きさの棒と、鳴った瞬間に光るランプを並べる
## 解析（tools/parts.py）がきちんと取れているかを、聞きながら目で確かめるためのもの

## ランプが光ってから消えるまでの秒数と、消えているときの濃さ
const FLASH_SECONDS := 0.15
const LAMP_OFF_ALPHA := 0.15
const ROW_HEIGHT := 22.0
const NAME_WIDTH := 64.0
const BAR_WIDTH := 100.0
const LAMP_SIZE := 14.0
## 項目ごとの表示名と色。ここに無い項目は名前を大文字にし、白で出す
const DISPLAY := {
	"vocals": ["VOCAL", Color(1.0, 0.55, 0.8)],
	"kick": ["KICK", Color(1.0, 0.45, 0.3)],
	"snare": ["SNARE", Color(1.0, 0.85, 0.3)],
	"hihat": ["HIHAT", Color(0.6, 1.0, 0.5)],
	"bass": ["BASS", Color(0.4, 0.6, 1.0)],
	"other": ["OTHER", Color(0.75, 0.6, 1.0)],
}

## 見せる解析。入れ替えると行を並べ直す
var track := PartTrack.new():
	set(value):
		track = value
		if is_node_ready():
			_build_rows()
var _rows := VBoxContainer.new()


func _ready() -> void:
	_rows.name = "Rows"
	add_child(_rows)
	_build_rows()


func _build_rows() -> void:
	for row in _rows.get_children():
		_rows.remove_child(row)
		row.queue_free()
	for part in track.names():
		_rows.add_child(_make_row(part))


## 曲の time 秒の様子を表示する
func show_at(time: float) -> void:
	for row in _rows.get_children():
		var part: String = row.name
		row.get_node("Bar").value = track.level(part, time)
		var lamp: ColorRect = row.get_node("Lamp")
		var flash := clampf(track.since_onset(part, time) / FLASH_SECONDS, 0.0, 1.0)
		lamp.color.a = lerpf(1.0, LAMP_OFF_ALPHA, flash)


func _make_row(part: String) -> HBoxContainer:
	var display: Array = DISPLAY.get(part, [part.to_upper(), Color.WHITE])
	var row := HBoxContainer.new()
	row.name = part
	row.custom_minimum_size.y = ROW_HEIGHT
	var label := Label.new()
	label.name = "Name"
	label.text = display[0]
	label.custom_minimum_size.x = NAME_WIDTH
	label.add_theme_font_size_override("font_size", 14)
	row.add_child(label)
	var bar := ProgressBar.new()
	bar.name = "Bar"
	bar.min_value = 0.0
	bar.max_value = 1.0
	bar.step = 0.0
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(BAR_WIDTH, LAMP_SIZE)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var fill := StyleBoxFlat.new()
	fill.bg_color = display[1]
	bar.add_theme_stylebox_override("fill", fill)
	row.add_child(bar)
	var lamp := ColorRect.new()
	lamp.name = "Lamp"
	lamp.color = Color(display[1], LAMP_OFF_ALPHA)
	lamp.custom_minimum_size = Vector2(LAMP_SIZE, LAMP_SIZE)
	lamp.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(lamp)
	return row
