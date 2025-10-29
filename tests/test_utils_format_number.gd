extends GutTest

class_name TestUtilsFormatNumber

func test_999はそのままの文字列を返す():
	var utils = load("res://utils.gd").new()
	var result = utils.format_number(999.0)
	utils.free()
	assert_eq("999", result)
