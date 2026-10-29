class_name ShotEffect
extends RefCounted
## 弾を撃ったときの演出。銃口が光って広がりながら消え、体が少しのけぞってすぐに戻る

## 銃口の光が消えるまでの秒数と、光の始めと終わりの大きさ
const FLASH_DURATION := 0.08
const FLASH_START_SIZE := 0.5
const FLASH_END_SIZE := 1.5
## 撃った瞬間に体が後ろへのけぞる角度（ラジアン）と、戻るまでの秒数
const RECOIL := 0.12
const RECOIL_DURATION := 0.12


## 撃ってから since_shot 秒たったときの、銃口の光の明るさ（1 から 0）
static func flash_brightness(since_shot: float) -> float:
	var rest := _rest(since_shot, FLASH_DURATION)
	return rest * rest


## 撃ってから since_shot 秒たったときの、銃口の光の大きさ
static func flash_size(since_shot: float) -> float:
	return lerpf(FLASH_END_SIZE, FLASH_START_SIZE, _rest(since_shot, FLASH_DURATION))


## 撃ってから since_shot 秒たったときの、体ののけぞりの角度（ラジアン）
static func recoil(since_shot: float) -> float:
	var rest := _rest(since_shot, RECOIL_DURATION)
	return RECOIL * rest * rest


## 終わりまでの残りの割合（1 から 0）
static func _rest(elapsed: float, duration: float) -> float:
	return clampf(1.0 - elapsed / duration, 0.0, 1.0)
