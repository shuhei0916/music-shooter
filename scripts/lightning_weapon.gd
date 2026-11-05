class_name LightningWeapon
extends Weapon
## 落雷。パート（初めはスネア）が鳴った瞬間に、離れていても前にいる HP の多い敵に雷が落ちる（Lightning）
## 段階で伸びる値は、一度に雷が落ちる敵の数

const MAX_LEVEL := 5

## 鳴ると雷が落ちるパート
var part := "snare"


func _init() -> void:
	super("lightning", MAX_LEVEL)


## 一度に雷が落ちる敵の数
func strikes() -> int:
	return level


func format_value(value: float) -> String:
	return "%d体" % roundi(value)


func parts_text() -> String:
	return PartTrack.display_name(part)


func extra_details() -> Array:
	return ["一度に%d体" % strikes()]
