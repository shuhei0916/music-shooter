extends GutTest

class_name TestUtilsFormatNumber

func test_999はそのままの文字列を返す():
	var utils = load("res://utils.gd").new()
	var result = utils.format_number(999)
	utils.free()
	assert_eq("999", result)

func test_1000は1ドット0Kを返す():
	var utils = load("res://utils.gd").new()
	var result = utils.format_number(1000)
	utils.free()
	assert_eq("1.0K", result)
