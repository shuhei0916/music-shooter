class_name SwordWeapon
extends Weapon
## 剣。ためるパートが鳴るたびに段階の本数だけたまり、上限（段階 × SWORDS_PER_VOLLEY 本）までたまったら、
## 撃つパートが鳴ったときにまとめて撃つ（SwordQuiver）。段階で伸びる値は1回に撃つ本数

## 段階の上限
const MAX_LEVEL := 8
## 段階が 1 のときに、1回にまとめて撃つ剣の本数（ためられる上限）
const SWORDS_PER_VOLLEY := 4
## ためるパートと撃つパートの組み合わせ（[ためるパート, 撃つパート]）
## どの組み合わせが遊んで気持ちいいかを比べるため、遊びながら順に切りかえられる。最初のものから始める
## キックは衝撃波が使うので、初めはキックを使わない組み合わせにする
const PART_PRESETS := [
	[["hihat"], "snare"],
	[["snare", "hihat"], "kick"],
	[["bass"], "kick"],
	[["other"], "snare"],
]

## 撃った剣が、ねらった敵が倒れたときに次の敵へ乗りかえられるか（1枚だけのカードで解放する）
var retarget := false
## ためるパート（鳴るたびにたまる）と、撃つパート（上限までたまっていれば鳴ったときに撃つ）
var charge_parts: Array = PART_PRESETS[0][0]
var release_part: String = PART_PRESETS[0][1]
var _preset := 0


func _init() -> void:
	super("sword", MAX_LEVEL)


## ためられる剣の上限。ここまでたまったら次に撃つパートが鳴ったときに撃つ
func capacity() -> int:
	return SWORDS_PER_VOLLEY * level


func level_value(lv: int) -> float:
	return SWORDS_PER_VOLLEY * lv


## パートの組み合わせを、PART_PRESETS の次のものにする（最後の次は最初）
func cycle_parts() -> void:
	_preset = (_preset + 1) % PART_PRESETS.size()
	charge_parts = PART_PRESETS[_preset][0]
	release_part = PART_PRESETS[_preset][1]


## 例：「スネア・ハイハット → キック」
func parts_text() -> String:
	var charge := "・".join(charge_parts.map(PartTrack.display_name))
	return "%s → %s" % [charge, PartTrack.display_name(release_part)]


func extra_details() -> Array:
	return ["乗りかえ"] if retarget else []
