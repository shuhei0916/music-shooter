class_name StarField
extends RefCounted
## 背景の星の並びを作る。一様にばらまくと単調に見えるので、大半の粒を道の下や脇をうねる「光の川」に集め、
## 残りを空間全体の塵にする。奥行きは LENGTH でくり返すので、川のうねりは端と端でつながる形にする

## 奥行きのくり返しの長さ（m）
const LENGTH := 240.0
## 道の上をふさがないよう、道の幅（の半分）より少し広いこの範囲では、粒を CLEAR_BELOW より下にだけ置く
## BUILD で粒が集まっても（MusicVisual.GATHERED_SPREAD）道にかからない広さにする
const CLEAR_HALF_WIDTH := 7.0
const CLEAR_BELOW := -3.0
## 光の川。x・y: 中心の位置、sway: うねりの幅、waves: 奥行きのくり返しのあいだにうねる回数、
## phase: うねりの始まり、width: 川の太さ
const RIVERS := [
	{"x": -24.0, "y": -9.0, "sway": 9.0, "waves": 3, "phase": 0.0, "width": 3.5},
	{"x": 26.0, "y": -12.0, "sway": 11.0, "waves": 2, "phase": 2.1, "width": 4.5},
	{"x": 3.0, "y": -24.0, "sway": 16.0, "waves": 2, "phase": 4.2, "width": 6.0},
]
## 粒のうち光の川に集める割合
const RIVER_RATIO := 0.65
## 塵を置く範囲
const DUST_HALF_WIDTH := 75.0
const DUST_LOW := -50.0
const DUST_HIGH := 22.0
## 粒の大きさ（m）。ほとんどが小さく、ごく一部が大きく光る
const SIZE_MIN := 0.05
const SIZE_RANGE := 0.75
const SIZE_POWER := 7.0


## 粒を count 個作る。{position, size, seed: 粒ごとの乱数, tint: 2色のどちらに近いか}
static func generate(count: int, seed_value: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var stars := []
	for i in count:
		var z := rng.randf_range(0.0, LENGTH)
		var place := _in_river(rng, z) if rng.randf() < RIVER_RATIO else _in_dust(rng)
		(
			stars
			. append(
				{
					"position": _off_road(Vector3(place.x, place.y, z), rng),
					"size": SIZE_MIN + SIZE_RANGE * pow(rng.randf(), SIZE_POWER),
					"seed": rng.randf(),
					"tint": rng.randf(),
				}
			)
		)
	return stars


## 光の川 river の、奥行き z での中心（x, y）
static func river_center(river: int, z: float) -> Vector2:
	var spec: Dictionary = RIVERS[river]
	var angle: float = TAU * spec.waves * z / LENGTH + spec.phase
	return Vector2(spec.x + spec.sway * sin(angle), spec.y + spec.sway * 0.35 * cos(angle))


static func _in_river(rng: RandomNumberGenerator, z: float) -> Vector2:
	var river := rng.randi_range(0, RIVERS.size() - 1)
	var width: float = RIVERS[river].width
	return river_center(river, z) + Vector2(rng.randfn(0.0, width), rng.randfn(0.0, width * 0.6))


static func _in_dust(rng: RandomNumberGenerator) -> Vector2:
	return Vector2(
		rng.randf_range(-DUST_HALF_WIDTH, DUST_HALF_WIDTH), rng.randf_range(DUST_LOW, DUST_HIGH)
	)


## 道の上をふさぐ位置の粒を、道の下へ移す
static func _off_road(place: Vector3, rng: RandomNumberGenerator) -> Vector3:
	if absf(place.x) < CLEAR_HALF_WIDTH and place.y > CLEAR_BELOW:
		place.y = CLEAR_BELOW - rng.randf_range(0.0, 18.0)
	return place
