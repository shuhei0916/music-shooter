class_name NumberFormat
extends RefCounted
## 大きな数を 1.2k / 1.2m / 1.2b のように短く表す


static func short(value: int) -> String:
	if value < 1000:
		return str(value)
	return "%.1fk" % (value / 1000.0)
