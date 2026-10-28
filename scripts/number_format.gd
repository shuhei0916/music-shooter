class_name NumberFormat
extends RefCounted
## 大きな数を 1.2k / 1.2m / 1.2b のように短く表す

const UNITS := [
	[1_000_000_000_000, "t"],
	[1_000_000_000, "b"],
	[1_000_000, "m"],
	[1_000, "k"],
]


## 小数1桁目は切り捨て、0なら省く。浮動小数点の誤差を避けるため整数だけで計算する
static func short(value: int) -> String:
	for unit in UNITS:
		if value >= unit[0]:
			var tenths: int = value / (unit[0] / 10)
			if tenths % 10 == 0:
				return "%d%s" % [tenths / 10, unit[1]]
			return "%d.%d%s" % [tenths / 10, tenths % 10, unit[1]]
	return str(value)
