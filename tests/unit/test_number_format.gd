extends GutTest

const NumberFormat = preload("res://scripts/number_format.gd")


func test_1000未満はそのまま表示する():
	assert_eq(NumberFormat.abbreviate(999), "999")


func test_10未満の桁は小数1桁で表示する():
	assert_eq(NumberFormat.abbreviate(1234), "1.2k")


func test_10以上の桁は整数で表示する():
	assert_eq(NumberFormat.abbreviate(35_000_000), "35M")


func test_10億以上はBで表示する():
	assert_eq(NumberFormat.abbreviate(1_400_000_000), "1.4B")


func test_1兆以上はTで表示する():
	assert_eq(NumberFormat.abbreviate(1_200_000_000_000), "1.2T")


func test_丸めて1000になるときは次の単位で表示する():
	assert_eq(NumberFormat.abbreviate(999_999), "1.0M")


func test_マイナスの値は符号をつけて表示する():
	assert_eq(NumberFormat.abbreviate(-1500), "-1.5k")
