class_name Gate
extends RefCounted

enum Op { ADD, MULTIPLY, POWER, FIRE_RATE, SWORD, SWORD_DAMAGE, SWORD_RETARGET }

var op: Op
var amount: int


func _init(p_op: Op, p_amount: int) -> void:
	op = p_op
	amount = p_amount


func apply(stats: PlayerStats) -> void:
	match op:
		Op.MULTIPLY:
			stats.health.hp *= amount
		Op.POWER:
			stats.power += amount
		Op.FIRE_RATE:
			stats.raise_fire_level(amount)
		Op.SWORD:
			stats.raise_sword_level(amount)
		Op.SWORD_DAMAGE:
			stats.sword_damage += amount
		Op.SWORD_RETARGET:
			stats.sword_retarget = true
		_:
			stats.health.hp += amount


## ゲートに書く文字。プレイヤーの能力値を渡すと、強化のゲートは取る前と取ったあとの値を見せる
func label(stats: PlayerStats = null) -> String:
	var text := _signed(amount)
	match op:
		Op.MULTIPLY:
			text = "×%d" % amount
		Op.POWER:
			text = _damage_label("ダメージUP", stats.power if stats != null else null)
		Op.FIRE_RATE:
			text = _fire_rate_label(stats)
		Op.SWORD:
			text = _sword_label(stats)
		Op.SWORD_DAMAGE:
			text = _damage_label("剣ダメージUP", stats.sword_damage if stats != null else null)
		Op.SWORD_RETARGET:
			text = "剣の乗りかえ"
	return text


## ダメージを上げるゲートの文字。今のダメージ current が分かれば取る前と取ったあと、分からなければ上がる数
func _damage_label(title: String, current: Variant) -> String:
	if current == null:
		return title + "\n" + _signed(amount)
	return "%s\n%s->%s" % [title, NumberFormat.short(current), NumberFormat.short(current + amount)]


## 符号つきで、大きな数は短く表す（+12k、-3.5m）
static func _signed(value: int) -> String:
	return ("+" if value >= 0 else "-") + NumberFormat.short(absi(value))


## 連射のゲートの文字。1小節に撃つ数の取る前と取ったあと。上限なら取っても変わらないので MAX
func _fire_rate_label(stats: PlayerStats) -> String:
	if stats == null:
		return "連射UP"
	if stats.fire_level >= PlayerStats.MAX_FIRE_LEVEL:
		return "連射MAX"
	var after := mini(stats.fire_level + amount, PlayerStats.MAX_FIRE_LEVEL)
	return (
		"連射UP\n%d->%d"
		% [PlayerStats.shots_per_bar(stats.fire_level), PlayerStats.shots_per_bar(after)]
	)


## 剣のゲートの文字。1回にまとめて撃つ剣の本数の、取る前と取ったあと
func _sword_label(stats: PlayerStats) -> String:
	if stats == null:
		return "剣UP"
	var before := stats.sword_capacity()
	var after := PlayerStats.SWORDS_PER_VOLLEY * (stats.sword_count + amount)
	return "剣UP\n%d->%d" % [before, after]


func is_harmful() -> bool:
	match op:
		Op.MULTIPLY:
			return amount < 1
		_:
			return amount < 0
