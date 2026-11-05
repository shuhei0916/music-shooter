class_name PlayerStats
extends RefCounted
## プレイヤーの能力値。HPは耐久力、威力と連射の段階はビート弾の攻撃力
## 剣・衝撃波・落雷は、それぞれの武器（Weapon）が段階とダメージを持つ

## 連射の段階の上限。0: 1小節（4拍）に1発、1: 2拍に1発、2: 1拍に1発
## 撃ちすぎにならないよう、多くても1拍に1発までにする
const MAX_FIRE_LEVEL := 2
## 連射の段階が 0 のときに、何拍に1発撃つか
const BASE_BEATS_PER_SHOT := 4.0

var health: Health
var power := 1
var fire_level := 0
var sword: SwordWeapon = SwordWeapon.new()
var shockwave: ShockwaveWeapon = ShockwaveWeapon.new()
var lightning: LightningWeapon = LightningWeapon.new()


func _init(hp: int) -> void:
	health = Health.new(hp)


func raise_fire_level(amount: int) -> void:
	fire_level = mini(fire_level + amount, MAX_FIRE_LEVEL)


func beats_per_shot() -> float:
	return BASE_BEATS_PER_SHOT / pow(2, fire_level)


## 連射の段階が level のときに、1小節（4拍）で撃つ弾の数
static func shots_per_bar(level: int) -> int:
	return 1 << level


## 名前の記号（"sword"・"shockwave"・"lightning"）の武器
func weapon(id: String) -> Weapon:
	return {"sword": sword, "shockwave": shockwave, "lightning": lightning}[id]


## 持っている武器の一覧。画面に強化の状況を出すときに使う
## {"name": 名前, "level": 段階（1から）, "max_level": 段階の上限, "parts": 使うパートの文字,
##  "details": ダメージや解放した能力の文字}
func weapons() -> Array:
	var beat_gun := {
		"name": "ビート弾",
		"level": fire_level + 1,
		"max_level": MAX_FIRE_LEVEL + 1,
		"parts": "拍",
		"details": ["ダメージ " + NumberFormat.short(power)],
	}
	return [beat_gun, sword.info(), shockwave.info(), lightning.info()]
