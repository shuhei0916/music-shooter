extends GutTest


func test_1000未満はそのまま表す():
	assert_eq(NumberFormat.short(999), "999")


func test_1000以上はkをつけて小数1桁まで表す():
	assert_eq(NumberFormat.short(1234), "1.2k")


func test_100万以上はm_10億以上はb_1兆以上はtをつける():
	assert_eq(NumberFormat.short(1_234_567), "1.2m")
	assert_eq(NumberFormat.short(1_234_567_890), "1.2b")
	assert_eq(NumberFormat.short(1_234_567_890_123), "1.2t")


func test_小数1桁目は切り捨てる():
	assert_eq(NumberFormat.short(999_999), "999.9k")
	assert_eq(NumberFormat.short(1_299), "1.2k")


func test_小数1桁目が0なら小数点以下を省く():
	assert_eq(NumberFormat.short(1_000), "1k")
	assert_eq(NumberFormat.short(25_000_000), "25m")
