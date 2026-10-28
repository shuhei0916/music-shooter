extends GutTest


func test_1000未満はそのまま表す():
	assert_eq(NumberFormat.short(999), "999")


func test_1000以上はkをつけて小数1桁まで表す():
	assert_eq(NumberFormat.short(1234), "1.2k")
