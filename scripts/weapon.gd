class_name Weapon
extends RefCounted
## パートの音に合わせて動く武器の共通の形。名前・段階・ダメージ・使うパートを持つ
## 段階で伸びる値（剣は1回に撃つ本数、衝撃波は広さ、落雷は一度に落ちる数）を level_value で返し、
## ゲートの文字（取る前と取ったあと）と自動操縦の得点（増える割合）はそこから出す
## 動き（撃つ・ダメージを与える）は Player が持つ

## 武器の名前の記号と、画面に出す名前。ゲートは記号で武器を指定する
const NAMES := {"sword": "剣", "shockwave": "衝撃波", "lightning": "落雷"}

## 名前の記号（"sword" など）
var id: String
var max_level: int
var level := 1
var damage := 1


func _init(p_id: String, p_max_level: int) -> void:
	id = p_id
	max_level = p_max_level


## 名前の記号 weapon_id の武器の、画面に出す名前
static func name_of(weapon_id: String) -> String:
	return NAMES[weapon_id]


func display_name() -> String:
	return name_of(id)


func raise_level(amount: int) -> void:
	level = mini(level + amount, max_level)


## 段階が lv のときの、段階で伸びる値
func level_value(lv: int) -> float:
	return lv


## 段階で伸びる値の文字
func format_value(value: float) -> String:
	return "%d" % roundi(value)


## 使うパートの文字（例：「キック」）
func parts_text() -> String:
	return ""


## ダメージのほかに出す強化の項目（例：「広さ 4m」）
func extra_details() -> Array:
	return []


## 画面に強化の状況を出すときの中身（PlayerStats.weapons の1つぶん）
func info() -> Dictionary:
	return {
		"name": display_name(),
		"level": level,
		"max_level": max_level,
		"parts": parts_text(),
		"details": ["ダメージ " + NumberFormat.short(damage)] + extra_details(),
	}


## 段階を amount 上げるゲートの文字。段階で伸びる値の、取る前と取ったあと。上限なら MAX
func level_label(amount: int) -> String:
	if level >= max_level:
		return display_name() + "MAX"
	var after := mini(level + amount, max_level)
	return (
		"%sUP\n%s->%s"
		% [display_name(), format_value(level_value(level)), format_value(level_value(after))]
	)


## 段階を amount 上げたときに、段階で伸びる値が増える割合。上限なら 0
func level_score(amount: int) -> float:
	var after := mini(level + amount, max_level)
	return level_value(after) / level_value(level) - 1.0
