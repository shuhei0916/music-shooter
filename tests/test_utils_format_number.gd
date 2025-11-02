extends GutTest

class_name TestUtilsFormatNumber

func test_999はそのままの文字列を返す():
	var utils = load("res://scripts/utils.gd").new()
	var result = utils.format_number(999)
	utils.free()
	assert_eq("999", result)

func test_1000は1ドット0Kを返す():
	var utils = load("res://scripts/utils.gd").new()
	var result = utils.format_number(1000)
	utils.free()
	assert_eq("1.0K", result)

func test_1500は1ドット5Kを返す():
	var utils = load("res://scripts/utils.gd").new()
	var result = utils.format_number(1500)
	utils.free()
	assert_eq("1.5K", result)

func test_1000000は1ドット0Mを返す():
	var utils = load("res://scripts/utils.gd").new()
	var result = utils.format_number(1000000)
	utils.free()
	assert_eq("1.0M", result)
