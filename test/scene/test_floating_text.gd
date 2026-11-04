extends GutTest

const FloatingTextScene := preload("res://scenes/floating_text.tscn")


func _make_text() -> FloatingText:
	var text: FloatingText = FloatingTextScene.instantiate()
	text.duration = 1.0
	text.rise = 2.0
	return add_child_autofree(text)


func test_出た瞬間は大きく出る():
	var text := _make_text()
	simulate(text, 1, 0.0)
	assert_gt(text.scale.x, 1.0)


func test_すぐに元の大きさに戻る():
	var text := _make_text()
	simulate(text, 1, FloatingText.POP_PART)
	assert_almost_eq(text.scale.x, 1.0, 0.0001)


func test_初めに素早く上がり半分の時間で半分より高く上がる():
	var text := _make_text()
	simulate(text, 1, 0.5)
	assert_gt(text.position.y, 1.0)
	assert_lt(text.position.y, 2.0)


func test_表示する時間が過ぎると上がりきっている():
	var text := _make_text()
	simulate(text, 1, 1.0)
	assert_almost_eq(text.position.y, 2.0, 0.001)


func test_消え始めるまでははっきり見える():
	var text := _make_text()
	simulate(text, 1, 1.0 - FloatingText.FADE_PART)
	assert_almost_eq(text.modulate.a, 1.0, 0.0001)


func test_最後の短いあいだで薄くなる():
	var text := _make_text()
	simulate(text, 1, 1.0 - FloatingText.FADE_PART / 2.0)
	assert_lt(text.modulate.a, 1.0)
	assert_gt(text.modulate.a, 0.0)


func test_表示する時間が過ぎると消える():
	var text := _make_text()
	simulate(text, 1, 1.0)
	assert_true(text.is_queued_for_deletion())


func test_色を変えても薄くするのは透明度だけ():
	var text := _make_text()
	text.modulate = Color(1, 0.5, 0)
	simulate(text, 1, 1.0 - FloatingText.FADE_PART / 2.0)
	assert_eq([text.modulate.r, text.modulate.g, text.modulate.b], [1.0, 0.5, 0.0])
