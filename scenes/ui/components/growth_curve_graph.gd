extends Control

class_name GrowthCurveGraph

const MARGIN := 10.0

var points: PackedVector2Array = PackedVector2Array()

func set_points(new_points: PackedVector2Array) -> void:
	points = new_points
	queue_redraw()

func compute_polyline(rect_size: Vector2) -> PackedVector2Array:
	var result := PackedVector2Array()
	if points.is_empty():
		return result
	var max_x := points[points.size() - 1].x
	var max_y := points[points.size() - 1].y
	if max_x <= 0.0 or max_y <= 0.0:
		return result
	var width := rect_size.x - MARGIN * 2.0
	var height := rect_size.y - MARGIN * 2.0
	if width <= 0.0 or height <= 0.0:
		return result
	for point in points:
		var px := MARGIN + (point.x / max_x) * width
		var py := rect_size.y - MARGIN - (point.y / max_y) * height
		result.append(Vector2(px, py))
	return result

func _draw() -> void:
	var size := get_size()
	var polyline := compute_polyline(size)
	if polyline.size() >= 2:
		draw_polyline(polyline, Color(0.2, 0.9, 0.4), 2.0)
	var origin := Vector2(MARGIN, size.y - MARGIN)
	var x_end := Vector2(size.x - MARGIN, size.y - MARGIN)
	var y_end := Vector2(MARGIN, MARGIN)
	draw_line(origin, x_end, Color(0.7, 0.7, 0.7))
	draw_line(origin, y_end, Color(0.7, 0.7, 0.7))
