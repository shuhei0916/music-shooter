class_name LoadoutHud
extends Control
## 左上に、持っている武器ごとに名前と段階、ダメージなどの強化の状況を並べる（例：「ドラム剣 Lv2」）

const FONT_SIZE := 22
const OUTLINE_SIZE := 6

var _rows := VBoxContainer.new()


func _ready() -> void:
	_rows.name = "Rows"
	_rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rows)


## プレイヤーの能力値 stats から、武器ごとの強化の状況を出す
func show_stats(stats: PlayerStats) -> void:
	var weapons := stats.weapons()
	while _rows.get_child_count() < weapons.size():
		_rows.add_child(_make_label())
	while _rows.get_child_count() > weapons.size():
		var extra := _rows.get_child(_rows.get_child_count() - 1)
		_rows.remove_child(extra)
		extra.queue_free()
	for i in weapons.size():
		_rows.get_child(i).text = text_of(weapons[i])


## 武器1つぶんの文字。1行目が名前と段階、2行目がダメージなどの項目
static func text_of(weapon: Dictionary) -> String:
	var level := "Lv MAX" if weapon.level >= weapon.max_level else "Lv%d" % weapon.level
	return "%s %s\n%s" % [weapon.name, level, "  ".join(weapon.details)]


func _make_label() -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", FONT_SIZE)
	label.add_theme_constant_override("outline_size", OUTLINE_SIZE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	return label
