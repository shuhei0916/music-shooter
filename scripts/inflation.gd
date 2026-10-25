## 曲の進み具合に応じて、ゲートの値・敵のHP・弾のダメージに掛けるインフレ倍率
extends RefCounted


## progress: 曲の進み具合（0→1）、end_scale: 進み具合1での倍率
static func scale_at(progress: float, end_scale: float) -> float:
	return pow(end_scale, progress)
