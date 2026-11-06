extends GutTest
## 見た目の設定の保存と読み込み

const PATH := "user://test_look.cfg"


func after_each() -> void:
	DirAccess.remove_absolute(PATH)


func test_保存したことがなければ派手な表示にする():
	assert_true(LookSettings.load_fancy(PATH))


func test_保存した設定を読み込める():
	LookSettings.save_fancy(PATH, false)
	assert_false(LookSettings.load_fancy(PATH))
	LookSettings.save_fancy(PATH, true)
	assert_true(LookSettings.load_fancy(PATH))


func test_設定のファイルが壊れていたら派手な表示にする():
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string("これは設定ではない [[[")
	file.close()
	assert_true(LookSettings.load_fancy(PATH))
