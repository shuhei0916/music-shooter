class_name GrowthGraph
extends Control
## デバッグモードで見せる成長曲線のグラフ。横は時刻（曲の始まりから終わりまで）、縦は強さ（対数）
## 規模の曲線（ふつうの敵の HP）、ボスの HP、プレイヤーの HP の記録、いまの時刻の縦線を描く

## 縦のいちばん大きい値を、曲線とボスのいちばん大きい値の何倍にするか（プレイヤーが上回っても見えるように）
const HEADROOM := 10.0
## プレイヤーの強さを記録する時刻の間隔（秒）。最後の点はいまの値で、ひとつ前の点からこの間隔があくまで置き換え続ける
const RECORD_STEP := 0.25
## プレイヤーの値が縦の上限を超えそうなら、上限をその値の何倍まで広げるか
const PLAYER_HEADROOM := 2.0
const BACKGROUND_COLOR := Color(0, 0, 0, 0.55)
const GRID_COLOR := Color(1, 1, 1, 0.15)
const CURVE_COLOR := Color(1, 1, 1, 0.9)
const BOSS_COLOR := Color(1, 0.3, 0.3)
const PLAYER_COLOR := Color(0.4, 1, 0.5)
const TIME_COLOR := Color(1, 0.85, 0.2)
const FONT_SIZE := 12
## 右上に出す、線の色の見方
const LEGEND := [["敵のHP", CURVE_COLOR], ["ボス", BOSS_COLOR], ["プレイヤーのHP", PLAYER_COLOR]]

var max_value := 10.0
var time := 0.0
## プレイヤーの強さの記録。Vector2(時刻, HP)
var player_points: Array[Vector2] = []
var _duration := 1.0
var _curve_points: Array = []
var _boss_points: Array = []


## curve_points・boss_points: Vector2(時刻, 値) の並び。duration: 曲の長さ（秒）
func setup(curve_points: Array, boss_points: Array, duration: float) -> void:
	_curve_points = curve_points
	_boss_points = boss_points
	_duration = maxf(duration, 0.001)
	var top := 1.0
	for point in curve_points + boss_points:
		top = maxf(top, point.y)
	max_value = top * HEADROOM
	queue_redraw()


## いまの時刻と、プレイヤーの強さ（HP）
func show_at(p_time: float, player_value: float) -> void:
	time = p_time
	var point := Vector2(p_time, player_value)
	var count := player_points.size()
	if count >= 2 and player_points[-1].x - player_points[-2].x < RECORD_STEP:
		player_points[-1] = point
	else:
		player_points.append(point)
	max_value = maxf(max_value, player_value * PLAYER_HEADROOM)
	if is_visible_in_tree():
		queue_redraw()


## 時刻 t と値 value の、グラフの上の位置。値は 1〜max_value を下から上へ対数で並べ、枠に収める
func point_of(t: float, value: float) -> Vector2:
	var ratio := clampf(log(maxf(value, 1.0)) / log(max_value), 0.0, 1.0)
	return Vector2(t / _duration * size.x, size.y * (1.0 - ratio))


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND_COLOR)
	_draw_grid()
	_draw_line_of(_curve_points, CURVE_COLOR)
	for point in _boss_points:
		draw_circle(point_of(point.x, point.y), 4.0, BOSS_COLOR)
	_draw_line_of(player_points, PLAYER_COLOR)
	var x := point_of(time, 1.0).x
	draw_line(Vector2(x, 0), Vector2(x, size.y), TIME_COLOR, 2.0)
	_draw_legend()


func _draw_legend() -> void:
	var font := get_theme_default_font()
	var y := FONT_SIZE + 4.0
	for item in LEGEND:
		draw_string(
			font, Vector2(0, y), item[0], HORIZONTAL_ALIGNMENT_RIGHT, size.x - 6, FONT_SIZE, item[1]
		)
		y += FONT_SIZE + 2.0


## 1k・1m・1b … の横線と、その数
func _draw_grid() -> void:
	var font := get_theme_default_font()
	var value := 1_000
	while value < max_value:
		var y := point_of(0.0, value).y
		draw_line(Vector2(0, y), Vector2(size.x, y), GRID_COLOR)
		draw_string(
			font,
			Vector2(4, y - 2),
			NumberFormat.short(value),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			FONT_SIZE
		)
		value *= 1_000


func _draw_line_of(points: Array, color: Color) -> void:
	if points.size() < 2:
		return
	var line := PackedVector2Array()
	for point in points:
		line.append(point_of(point.x, point.y))
	draw_polyline(line, color, 2.0)
