class_name Gate
extends RefCounted

enum Op { ADD, MULTIPLY, POWER, FIRE_RATE }

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
		_:
			stats.health.hp += amount


## ゲートに書く文字。プレイヤーの能力値を渡すと、威力のゲートは取る前と取ったあとのダメージを見せる
func label(stats: PlayerStats = null) -> String:
	match op:
		Op.MULTIPLY:
			return "×%d" % amount
		Op.POWER:
			if stats == null:
				return "ダメージUP\n" + _signed(amount)
			var after := stats.power + amount
			return "ダメージUP\n%s->%s" % [NumberFormat.short(stats.power), NumberFormat.short(after)]
		Op.FIRE_RATE:
			return _fire_rate_label(stats)
		_:
			return _signed(amount)


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


func is_harmful() -> bool:
	match op:
		Op.MULTIPLY:
			return amount < 1
		_:
			return amount < 0
