class_name SongClock
extends RefCounted
## コースの進み具合を決める時計。曲の再生位置や経過時間を「時刻」として返す


func start() -> void:
	pass


func advance(_delta: float) -> void:
	pass


func time() -> float:
	return 0.0


func duration() -> float:
	return 0.0
