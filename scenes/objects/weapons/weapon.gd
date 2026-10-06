class_name Weapon
extends Node3D

## レベルごとの1小節（4/4拍子）の分割数
const LEVEL_DIVISIONS: Array[int] = [1, 4, 8]
## グリッドに関係なく全ノートで発射するレベル
const MAX_LEVEL := 4

@export var channel: int = 0
@export var color: Color = Color.WHITE
@export var level: int = 1


func is_on_grid(tick: int, timebase: int) -> bool:
	if level >= MAX_LEVEL:
		return true
	var step: int = timebase * 4 / LEVEL_DIVISIONS[level - 1]
	return tick % step == 0


func fire() -> void:
	pass


func trigger_flash() -> void:
	pass
