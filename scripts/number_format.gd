## インフレした大きな数値を「1.2k」「35M」「1.4B」のように単位をつけて短く表示する
extends RefCounted

const UNITS: Array[String] = ["", "k", "M", "B", "T"]


static func abbreviate(n: int) -> String:
	var sign := "-" if n < 0 else ""
	var value := absf(n)
	var unit := 0
	while value >= 1000.0 and unit < UNITS.size() - 1:
		value /= 1000.0
		unit += 1
	if unit == 0:
		return str(n)
	if roundf(value) >= 1000.0 and unit < UNITS.size() - 1:  # 999.9k → 1000k ではなく 1.0M
		value /= 1000.0
		unit += 1
	var digits := "%.1f" % value if value < 9.95 else str(roundi(value))
	return sign + digits + UNITS[unit]
