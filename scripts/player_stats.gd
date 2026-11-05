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

var health: Health
var power := 1
var fire_level := 0
## 剣の段階。スネアやハイハットが1回鳴るとたまる剣の本数。ためられる上限もこれに比例して増える
var sword_count := 1
## 剣1本のダメージ。弾の威力（power）とは別
var sword_damage := 1
## 撃った剣が、ねらった敵が倒れたときに次の敵へ乗りかえられるか（あとでレアなゲートで解放する）
var sword_retarget := false


func _init(hp: int) -> void:
	health = Health.new(hp)


func raise_fire_level(amount: int) -> void:
	fire_level = mini(fire_level + amount, MAX_FIRE_LEVEL)


func beats_per_shot() -> float:
	return BASE_BEATS_PER_SHOT / pow(2, fire_level)


## 連射の段階が level のときに、1小節（4拍）で撃つ弾の数
static func shots_per_bar(level: int) -> int:
	return 1 << level


## ためられる剣の上限。ここまでたまったら次のキックで撃つ
func sword_capacity() -> int:
	return SWORDS_PER_VOLLEY * sword_count
