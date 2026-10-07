extends GutTest

const TITLE_SCENE = preload("res://scenes/ui/title/title.tscn")

var title
var _saved_return_scene: String


func before_each():
	_saved_return_scene = Session.calibration_return_scene
	title = TITLE_SCENE.instantiate()
	title.song_select_scene = ""  # テスト中にシーンを切り替えない
	title.calibration_scene = ""
	add_child_autofree(title)


func after_each():
	Session.calibration_return_scene = _saved_return_scene


func test_プレイで曲選択画面へ移る():
	watch_signals(title)
	title.get_node("%PlayButton").pressed.emit()
	assert_signal_emitted(title, "play_requested")


func test_タイミング調整で調整画面へ移る():
	watch_signals(title)
	title.get_node("%CalibrationButton").pressed.emit()
	assert_signal_emitted(title, "calibration_requested")


func test_調整画面を開くとき戻り先としてタイトルを記録する():
	title.get_node("%CalibrationButton").pressed.emit()
	assert_eq("res://scenes/ui/title/title.tscn", Session.calibration_return_scene)


func test_開いたときプレイにフォーカスがある():
	assert_true(title.get_node("%PlayButton").has_focus())
