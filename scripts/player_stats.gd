class_name PlayerStats
extends RefCounted
## プレイヤーの能力値。HPは耐久力、威力と連射の段階は攻撃力

## 連射の段階の上限。0: 1小節（4拍）に1発、1: 2拍に1発、2: 1拍に1発
## 撃ちすぎにならないよう、多くても1拍に1発までにする
const MAX_FIRE_LEVEL := 2
## 連射の段階が 0 のときに、何拍に1発撃つか
const BASE_BEATS_PER_SHOT := 4.0
## 剣の段階が 1 のときに、1回にまとめて撃つ剣の本数（ためられる上限）
const SWORDS_PER_VOLLEY := 4
## 剣の段階の上限
const MAX_SWORD_LEVEL := 8
## 剣をためるパートと撃つパートの組み合わせ（[ためるパート, 撃つパート]）
## どの組み合わせが遊んで気持ちいいかを比べるため、遊びながら順に切りかえられる。最初のものから始める
## キックは衝撃波が使うので、初めはキックを使わない組み合わせにする
const SWORD_PART_PRESETS := [
	[["hihat"], "snare"],
	[["snare", "hihat"], "kick"],
	[["bass"], "kick"],
	[["other"], "snare"],
]
## 衝撃波の段階の上限と、段階が 1 のときの届く広さ（半径 m）、段階が1つ上がるごとに広がる長さ
const MAX_SHOCKWAVE_LEVEL := 5
const BASE_SHOCKWAVE_RADIUS := 4.0
const SHOCKWAVE_RADIUS_STEP := 1.0

var health: Health
var power := 1
var fire_level := 0
## 剣の段階。スネアやハイハットが1回鳴るとたまる剣の本数。ためられる上限もこれに比例して増える
var sword_count := 1
## 剣1本のダメージ。弾の威力（power）とは別
var sword_damage := 1
## 撃った剣が、ねらった敵が倒れたときに次の敵へ乗りかえられるか（あとでレアなゲートで解放する）
var sword_retarget := false
## 剣をためるパート（鳴るたびにたまる）と、撃つパート（上限までたまっていれば鳴ったときに撃つ）
var sword_charge_parts: Array = SWORD_PART_PRESETS[0][0]
var sword_release_part: String = SWORD_PART_PRESETS[0][1]
## 衝撃波の段階（届く広さ）と、1回のダメージ、鳴ると衝撃波を出すパート
var shockwave_level := 1
var shockwave_damage := 1
var shockwave_part := "kick"
var _sword_preset := 0


func _init(hp: int) -> void:
	health = Health.new(hp)


func raise_fire_level(amount: int) -> void:
	fire_level = mini(fire_level + amount, MAX_FIRE_LEVEL)


func raise_sword_level(amount: int) -> void:
	sword_count = mini(sword_count + amount, MAX_SWORD_LEVEL)


func raise_shockwave_level(amount: int) -> void:
	shockwave_level = mini(shockwave_level + amount, MAX_SHOCKWAVE_LEVEL)


## 衝撃波の届く広さ（半径 m）。段階が level のとき（省略すると今の段階）
func shockwave_radius(level := shockwave_level) -> float:
	return BASE_SHOCKWAVE_RADIUS + SHOCKWAVE_RADIUS_STEP * (level - 1)


## 長さ（m）の文字。整数ならそのまま、そうでなければ小数1桁（4m、4.5m）
static func meters(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return "%dm" % roundi(value)
	return "%.1fm" % value


## 剣のパートの組み合わせを、SWORD_PART_PRESETS の次のものにする（最後の次は最初）
func cycle_sword_parts() -> void:
	_sword_preset = (_sword_preset + 1) % SWORD_PART_PRESETS.size()
	sword_charge_parts = SWORD_PART_PRESETS[_sword_preset][0]
	sword_release_part = SWORD_PART_PRESETS[_sword_preset][1]


func beats_per_shot() -> float:
	return BASE_BEATS_PER_SHOT / pow(2, fire_level)


## 連射の段階が level のときに、1小節（4拍）で撃つ弾の数
static func shots_per_bar(level: int) -> int:
	return 1 << level


## ためられる剣の上限。ここまでたまったら次のキックで撃つ
func sword_capacity() -> int:
	return SWORDS_PER_VOLLEY * sword_count


## 持っている武器の一覧。画面に強化の状況を出すときに使う
## {"name": 名前, "level": 段階（1から）, "max_level": 段階の上限, "parts": 使うパートの文字,
##  "details": ダメージや解放した能力の文字}
func weapons() -> Array:
	var sword_details := ["ダメージ " + NumberFormat.short(sword_damage)]
	if sword_retarget:
		sword_details.append("乗りかえ")
	return [
		{
			"name": "ビート弾",
			"level": fire_level + 1,
			"max_level": MAX_FIRE_LEVEL + 1,
			"parts": "拍",
			"details": ["ダメージ " + NumberFormat.short(power)],
		},
		{
			"name": "剣",
			"level": sword_count,
			"max_level": MAX_SWORD_LEVEL,
			"parts": _sword_parts_text(),
			"details": sword_details,
		},
		{
			"name": "衝撃波",
			"level": shockwave_level,
			"max_level": MAX_SHOCKWAVE_LEVEL,
			"parts": PartTrack.display_name(shockwave_part),
			"details":
			[
				"ダメージ " + NumberFormat.short(shockwave_damage),
				"広さ " + PlayerStats.meters(shockwave_radius()),
			],
		},
	]


## 剣の使うパートの文字（例：「スネア・ハイハット → キック」）
func _sword_parts_text() -> String:
	var charge := "・".join(sword_charge_parts.map(PartTrack.display_name))
	return "%s → %s" % [charge, PartTrack.display_name(sword_release_part)]
