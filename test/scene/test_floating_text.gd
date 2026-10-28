extends GutTest

const FloatingTextScene := preload("res://scenes/floating_text.tscn")


func _make_text() -> FloatingText:
	var text: FloatingText = FloatingTextScene.instantiate()
	text.duration = 1.0
	text.rise = 2.0
	return add_child_autofree(text)


func test_時間がたつと上に浮かぶ():
	var text := _make_text()
	simulate(text, 1, 0.5)
	assert_almost_eq(text.position.y, 1.0, 0.001)


func test_時間がたつと薄くなる():
	var text := _make_text()
	simulate(text, 1, 0.5)
	assert_lt(text.modulate.a, 1.0)
	assert_gt(text.modulate.a, 0.0)


func test_表示する時間が過ぎると消える():
	var text := _make_text()
	simulate(text, 1, 1.0)
	assert_true(text.is_queued_for_deletion())
