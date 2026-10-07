extends GutTest

const TITLE_SCENE = preload("res://scenes/ui/title/title.tscn")

var title


func before_each():
	title = TITLE_SCENE.instantiate()
	title.song_select_scene = ""  # テスト中にシーンを切り替えない
	title.calibration_scene = ""
	add_child_autofree(title)


func test_プレイで曲選択画面へ移る():
	watch_signals(title)
	title.get_node("%PlayButton").pressed.emit()
	assert_signal_emitted(title, "play_requested")


func test_タイミング調整で調整画面へ移る():
	watch_signals(title)
	title.get_node("%CalibrationButton").pressed.emit()
	assert_signal_emitted(title, "calibration_requested")
